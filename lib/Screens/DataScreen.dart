import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  late Future<List<Map<String, dynamic>>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = _fetchFiles();
  }

  Future<List<Map<String, dynamic>>> _fetchFiles() async {
    List<Map<String, dynamic>> files = [];
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email ?? '';
      Reference storageRef = FirebaseStorage.instance.ref().child(email);
      ListResult result = await storageRef.listAll();

      for (var item in result.items) {
        String downloadURL = await item.getDownloadURL();
        String name = item.name;
        bool isVideo = name.endsWith('.mp4');
        files.add({'url': downloadURL, 'isVideo': isVideo});
      }
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(
          "Your Private Data",
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> files = snapshot.data!;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1, // Maintain a 1:1 aspect ratio (square)
                ),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return GridTile(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenGallery(
                              files: files,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1, // Maintain a 1:1 aspect ratio (square)
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8), // Set the corner radius here
                              child: files[index]['isVideo']
                                  ? VideoPlayerScreen(url: files[index]['url'])
                                  : Image.network(files[index]['url'], fit: BoxFit.cover),
                            ),
                          ),
                          Center(
                            child: files[index]['isVideo']
                                ? Icon(
                              Icons.play_circle_rounded,
                              color: Colors.black,
                              size: 28,
                            )
                                : SizedBox.shrink(), // Hide icon for images
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );


            } else {
              return const Center(child: Text('No data available'));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Error fetching data'));
          }
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoControllerManager.instance.getController(widget.url);
    _initializeVideo();
  }

  @override
  void dispose() {
    VideoControllerManager.instance.disposeController(widget.url);
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (!_videoController.value.isInitialized) {
      await _videoController.initialize();
      _videoController.setLooping(true);
      setState(() {});
      _videoController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build(context) to enable AutomaticKeepAliveClientMixin
    return Scaffold(
      body: _videoController.value.isInitialized
          ? Center(
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  bool get wantKeepAlive => true; // Override wantKeepAlive to return true
}


class FullScreenImageScreen extends StatelessWidget {
  final String url;

  const FullScreenImageScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}

class FullScreenVideoPlayerScreen extends StatefulWidget {
  final String url;

  const FullScreenVideoPlayerScreen({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerScreenState createState() => _FullScreenVideoPlayerScreenState();
}

class _FullScreenVideoPlayerScreenState extends State<FullScreenVideoPlayerScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the video is playing when initialized
        _videoController.play();
        setState(() {}); // Update UI to reflect video initialization
      });

    // Listen to video controller changes
    _videoController.addListener(_videoListener);
  }

  @override
  void dispose() {
    // Dispose of the video controller when no longer needed
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  // Listener to handle video playback state changes
  void _videoListener() {
    if (!_videoController.value.isPlaying && _videoController.value.isInitialized) {
      // Handle playback if needed (e.g., replay, pause)
      _videoController.play();
    }
    setState(() {}); // Update UI when playback state changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videoController.value.isInitialized
          ? Center(
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenGallery extends StatelessWidget {
  final List<Map<String, dynamic>> files;
  final int initialIndex;

  FullScreenGallery({
    Key? key,
    required this.files,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: files.length,
        itemBuilder: (context, index) {
          return files[index]['isVideo']
              ? FullScreenVideoPlayerScreen(key: UniqueKey(), url: files[index]['url'])
              : FullScreenImageScreen(key: UniqueKey(), url: files[index]['url']);
        },
      ),
    );
  }
}
class VideoControllerManager {
  static final VideoControllerManager _instance = VideoControllerManager._internal();
  final Map<String, VideoPlayerController> _controllers = {};

  VideoControllerManager._internal();

  static VideoControllerManager get instance => _instance;

  VideoPlayerController getController(String url) {
    if (_controllers.containsKey(url)) {
      return _controllers[url]!;
    } else {
      VideoPlayerController controller = VideoPlayerController.network(url);
      _controllers[url] = controller;
      return controller;
    }
  }

  void disposeController(String url) {
    if (_controllers.containsKey(url)) {
      _controllers[url]!.dispose();
      _controllers.remove(url);
    }
  }
}
