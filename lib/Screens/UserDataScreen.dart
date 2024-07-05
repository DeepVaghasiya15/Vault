import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({Key? key}) : super(key: key);

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
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.black)),
          content: const Text('Are you sure you want to delete this file?', style: TextStyle(color: Colors.black54)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black45)),
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
        builder: (context) => FullScreenMedia(
          mediaPaths: urls,
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
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "Stored Data",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
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
          print('URL of ${file['name']}: ${file['url']}');
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
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Center(child: Text('Error loading image'));
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

class FullScreenMedia extends StatefulWidget {
  final List<String> mediaPaths;
  final int initialIndex;

  const FullScreenMedia({
    Key? key,
    required this.mediaPaths,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenMediaState createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<FullScreenMedia> {
  late PageController _pageController;
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeMedia(widget.mediaPaths[widget.initialIndex]);
  }

  Future<void> _initializeMedia(String url) async {
    if (url.endsWith('.mp4')) {
      await _initializeVideoPlayer(url);
    } else {
      _disposeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer(String url) async {
    _disposeVideoPlayer();

    _videoPlayerController = VideoPlayerController.network(url);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: true,
    );

    setState(() {});
  }

  void _disposeVideoPlayer() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeVideoPlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaPaths.length,
            onPageChanged: (index) {
              _initializeMedia(widget.mediaPaths[index]);
            },
            itemBuilder: (context, index) {
              final mediaPath = widget.mediaPaths[index];
              return Center(
                child: mediaPath.endsWith('.mp4')
                    ? GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoFullScreen(
                          url: mediaPath,
                        ),
                      ),
                    );
                  },
                  child: (_chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized)
                      ? Chewie(controller: _chewieController!)
                      : const CircularProgressIndicator(),
                )
                    : Image.network(
                  mediaPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading image: $error');
                    return const Center(child: Text('Error loading image'));
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                _disposeVideoPlayer();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoFullScreen extends StatefulWidget {
  final String url;

  const VideoFullScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoFullScreenState createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    print('Initializing video player for ${widget.url}');
    _videoPlayerController = VideoPlayerController.network(widget.url);
    await _videoPlayerController.initialize();

    print('Video player initialized: ${_videoPlayerController.value.isInitialized}');
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _chewieController != null &&
            _chewieController.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController)
            : const CircularProgressIndicator(),
      ),
    );
  }
}