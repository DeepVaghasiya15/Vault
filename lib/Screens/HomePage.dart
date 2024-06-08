import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(appState.appName,
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 28,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            onPressed: () => Navigator.pushNamed(context, '/SettingScreen'),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: IconButton(
          icon: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 60,
          ), onPressed: () => Navigator.pushNamed(context, '/CameraScreen'),
        ),
      ),
    );
  }
}
