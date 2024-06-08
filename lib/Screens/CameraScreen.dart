import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0;
  bool isRecording = false;
  Timer? _timer;
  int _elapsedTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  //Initialize Camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![selectedCameraIndex], // Select the camera based on the index
        ResolutionPreset.ultraHigh,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // Rebuild the widget after the camera is initialized
    }
  }

  //Toggling camera front & rear
  Future<void> _toggleCamera() async {
    if (cameras == null || cameras!.isEmpty) {
      return;
    }
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras!.length;
    await _initializeCamera();
  }

  //Recording Video
  Future<void> _recordVideo() async {
    if (isRecording) {
      XFile videoFile = await _controller.stopVideoRecording();
      _stopTimer();
      setState(() {
        isRecording = false;
      });
      print('Video saved to ${videoFile.path}');
    } else {
      final directory = await getTemporaryDirectory();
      final path = join(
        directory.path,
        '${DateTime.now()}.mp4',
      );
      await _controller.startVideoRecording();
      _startTimer();
      setState(() {
        isRecording = true;
      });
      print('Recording video to $path');
    }
  }

  //Starting of Timer when clicked on video recording
  void _startTimer() {
    _elapsedTime = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  //Stoping of Timer when clicked on stop recording
  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopTimer();
    super.dispose();
  }

  // OnTapFocus in camera for focusing on objects
  void _onTapFocus(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller.setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Camera',
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _onTapFocus(details, constraints),
                      child: CameraPreview(_controller),
                    );
                  },
                ),
                if (isRecording)
                  Positioned(
                    top: 5,
                    left: 100,
                    right: 100,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8), // Adjust the radius as needed
                      ),
                      child: Text(
                        _formatElapsedTime(_elapsedTime),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Error initializing camera'));
          }
        },
      ),
      //All 3 buttons of camera
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Button for recording video
          FloatingActionButton(
            heroTag: 'recordVideo',
            onPressed: _recordVideo,
            backgroundColor: isRecording ? Colors.red : null,
            child: Icon(isRecording ? Icons.stop : Icons.videocam),
          ),
          const SizedBox(width: 20),
          //Button for taking photo
          FloatingActionButton(
            heroTag: 'takePhoto',
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final directory = await getTemporaryDirectory();
                final path = join(
                  directory.path,
                  '${DateTime.now()}.png',
                );
                // Take the picture and get the file
                XFile picture = await _controller.takePicture();
                // Move the file to the desired path
                await picture.saveTo(path);
                print('Picture saved to $path');
              } catch (e) {
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 20),
          //For toggling camera front and back
          FloatingActionButton(
            heroTag: 'toggleCamera',
            onPressed: _toggleCamera,
            child: const Icon(Icons.switch_camera),
          ),
        ],
      ),
    );
  }
  //Calculating time
  String _formatElapsedTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}