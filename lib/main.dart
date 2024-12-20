import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plutusapp/terminal_functions.dart';

// Main entry point of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(App());
}

// Request necessary permissions
Future<void> requestPermissions() async {
  final statuses = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse,
    Permission.locationAlways,
    Permission.storage,
    Permission.camera,
  ].request();

  if (statuses[Permission.bluetooth]!.isGranted &&
      statuses[Permission.bluetoothScan]!.isGranted &&
      statuses[Permission.bluetoothConnect]!.isGranted &&
      statuses[Permission.locationWhenInUse]!.isGranted &&
      statuses[Permission.locationAlways]!.isGranted &&
      statuses[Permission.storage]!.isGranted &&
      statuses[Permission.camera]!.isGranted ) {
    print('All necessary permissions are granted.');
  } else {
    print('Some permissions are not granted.');
    if (statuses[Permission.storage]!.isPermanentlyDenied) {
      await openAppSettings(); // Open app settings to manually grant permission
    }
  }
}

// Main app widget
class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

// App state management
class AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      title: "APP TO APP TESTER",
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
          bodyLarge: GoogleFonts.oswald(textStyle: textTheme.bodyLarge),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TerminalFunctions(),
    );
  }
}