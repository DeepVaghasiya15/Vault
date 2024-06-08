import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../State/AppState.dart';
import '../State/ChangeAppName.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  void _changeAppName() {
    if (_formKey.currentState!.validate()) {
      Provider.of<AppState>(context, listen: false).changeAppName(_appNameController.text);
    }
  }
  void _changeAppNames() {
    if (_formKey.currentState!.validate()) {
      String newName = _appNameController.text;
      AppNameChannel.changeAppName(newName);
      setState(() {
        print('App name changed to: $newName');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          appState.appName, // Use app name from state
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _appNameController,
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                decoration: const InputDecoration(
                  labelText: 'New App Name',
                  labelStyle: TextStyle(color: Colors.grey),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {_changeAppName();
                  _changeAppNames();},
                child: const Text('Change App Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
