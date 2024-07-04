import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  List<Map<String, dynamic>> _userFiles = [];
  bool _loading = true;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _fetchUserFiles();
  }

  Future<void> _fetchUserFiles() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? '';
        ListResult result = await FirebaseStorage.instance.ref().child(email).listAll();

        List<Map<String, dynamic>> files = await Future.wait(result.items.map((ref) async {
          String downloadURL = await ref.getDownloadURL();
          return {'url': downloadURL, 'name': ref.name};
        }).toList());

        setState(() {
          _userFiles = files;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching user files: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteFile(String fileName) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email ?? '';
        await FirebaseStorage.instance.ref().child(email).child(fileName).delete();

        setState(() {
          _userFiles.removeWhere((file) => file['name'] == fileName);
        });
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<void> _confirmDelete(BuildContext context, String fileName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to delete this file?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteFile(fileName);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeVideoPlayer(String url) async {
    try {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.dispose();
      }
      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.play();
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    List<String> urls = _userFiles.map((file) => file['url'] as String).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imagePaths: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "Stored Data",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: _userFiles.length,
        itemBuilder: (context, index) {
          final file = _userFiles[index];
          return GestureDetector(
            onTap: () => _openFullScreen(context, index),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: file['name'].endsWith('.mp4')
                        ? FutureBuilder<void>(
                      future: _initializeVideoPlayer(file['url']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return VideoPlayer(_videoPlayerController!);
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    )
                        : Image.network(
                      file['url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        print('Stack trace: $stackTrace');
                        return Center(child: Text('Error loading image: $error'));
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, file['name']),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenImage({
    Key? key,
    required this.imagePaths,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late int currentIndex;
  late double initialPositionX;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    if (widget.imagePaths[currentIndex].endsWith('.mp4')) {
      _initializeVideoPlayer(widget.imagePaths[currentIndex]);
    }
  }

  Future<void> _initializeVideoPlayer(String url) async {
    try {
      if (_videoPlayerController != null) {
        await _videoPlayerController!.dispose();
      }
      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.play();
      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void goToNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.imagePaths.length;
      if (widget.imagePaths[currentIndex].endsWith('.mp4')) {
        _initializeVideoPlayer(widget.imagePaths[currentIndex]);
      } else {
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      }
    });
  }

  void goToPrevious() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.imagePaths.length) % widget.imagePaths.length;
      if (widget.imagePaths[currentIndex].endsWith('.mp4')) {
        _initializeVideoPlayer(widget.imagePaths[currentIndex]);
      } else {
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      }
    });
  }

  void handleHorizontalDragUpdate(DragUpdateDetails details) {
    double currentPositionX = details.globalPosition.dx;
    double distance = currentPositionX - initialPositionX;
    double threshold = 50.0; // Adjust this threshold as needed

    if (distance.abs() >= threshold) {
      if (distance > 0) {
        // Swiping towards the right
        if (currentIndex > 0) {
          setState(() {
            currentIndex--;
            initialPositionX = currentPositionX; // Update initial position for next swipe
            if (widget.imagePaths[currentIndex].endsWith('.mp4')) {
              _initializeVideoPlayer(widget.imagePaths[currentIndex]);
            } else {
              _videoPlayerController?.dispose();
              _videoPlayerController = null;
            }
          });
        }
      } else {
        // Swiping towards the left
        if (currentIndex < widget.imagePaths.length - 1) {
          setState(() {
            currentIndex++;
            initialPositionX = currentPositionX; // Update initial position for next swipe
            if (widget.imagePaths[currentIndex].endsWith('.mp4')) {
              _initializeVideoPlayer(widget.imagePaths[currentIndex]);
            } else {
              _videoPlayerController?.dispose();
              _videoPlayerController = null;
            }
          });
        }
      }
    }
  }

  void handleHorizontalDragStart(DragStartDetails details) {
    initialPositionX = details.globalPosition.dx;
  }

  void handleHorizontalDragEnd(DragEndDetails details) {
    // Handle any final logic after the drag ends if needed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: handleHorizontalDragUpdate,
      onHorizontalDragStart: handleHorizontalDragStart,
      onHorizontalDragEnd: handleHorizontalDragEnd,
      child: Scaffold(
        body: Stack(
          children: [
            Center(
              child: widget.imagePaths[currentIndex].endsWith('.mp4')
                  ? _videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              )
                  : const Center(child: CircularProgressIndicator())
                  : Image.network(
                widget.imagePaths[currentIndex],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return const Center(child: Text('Error loading image'));
                },
              ),
            ),
            Positioned(
              top: 50,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: goToPrevious,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 20,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                onPressed: goToNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
