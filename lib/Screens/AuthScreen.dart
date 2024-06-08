import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vault/Screens/HomePage.dart';
import 'package:vault/Screens/PreHomeScreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

//Fingerprint or FaceID Support state
enum SupportState {
  unknown,
  supported,
  unSupported,
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometric;

  @override
  void initState() {
    auth.isDeviceSupported().then(
            (bool isSupported) => setState(() => supportState = isSupported ? SupportState.supported : SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

  //For checking biometrics
  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
      print("Biometric Supported: $canCheckBiometric");
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometric = false;
    }
  }

  //Getting available Biometrics
  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
      print("Supported Biometrics $biometricTypes");
    } on PlatformException catch (e) {
      print(e);
    }
    setState(() {
      availableBiometric = biometricTypes;
    });
  }

  //Authneticating with your biometrics
  Future<void> authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
          localizedReason: 'Authenticate with Fingerprint or Face ID',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ));
      if (!mounted) {
        return;
      }
      if (authenticated) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PreHomeScreen()));
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Authentication ",
            style: TextStyle(
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary,
            )),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(supportState == SupportState.supported ? 'Biometric authentication is supported on this device' : supportState == SupportState.unSupported ? 'Biometric authentication is not supported on this device' : 'Checking biometric support...'),
            // Text(
            //   supportState == SupportState.supported
            //       ? 'Biometric authentication is supported on this device'
            //       : supportState == SupportState.unSupported
            //         ? 'Biometric authentication is not supported on this device'
            //         : 'Checking biometric support...',
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     color: supportState == SupportState.supported
            //         ? Colors.green
            //         : supportState == SupportState.unSupported
            //             ? Colors.red
            //             : Colors.grey,
            //   )
            // ),
            // SizedBox(height: 20,),
            // Text('Supported biometrics : $availableBiometric'),
            // SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //FaceID Image
                Image.asset('assets/images/FaceID2.png',
                  width: 200,
                    height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 80),
                //Button for authenticate
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: ElevatedButton(
                    onPressed: authenticateWithBiometrics,
                    child: const Text.rich(
                      TextSpan(
                        text: "Authenticate with ",
                        style: TextStyle(fontFamily: 'Lato', fontSize: 15),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Fingerprint",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                          ),
                          TextSpan(
                            text: " or ",
                            style: TextStyle(fontFamily: 'Lato', fontSize: 15),
                          ),
                          TextSpan(
                            text: "Face ID",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
