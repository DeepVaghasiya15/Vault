import 'dart:io';
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
          title: Text('Confirm Delete', style: TextStyle(color: Colors.white),),
          content: Text('Are you sure you want to delete this file?', style: TextStyle(color: Colors.white70),),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white60),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red),),
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
    _videoPlayerController = VideoPlayerController.network(url);
    await _videoPlayerController!.initialize();
    _videoPlayerController!.setLooping(true);
    _videoPlayerController!.play();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Stored Data",
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _userFiles.length,
        itemBuilder: (context, index) {
          final file = _userFiles[index];
          return Stack(
            children: [
              Positioned.fill(
                child: file['name'].endsWith('.mp4')
                    ? FutureBuilder<void>(
                  future: _initializeVideoPlayer(file['url']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return VideoPlayer(_videoPlayerController!);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                )
                    : Image.network(
                  file['url'],
                  fit: BoxFit.cover,
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
          );
        },
      ),
    );
  }
}
