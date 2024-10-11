import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogControl {
  AnsiPen info = AnsiPen()..blue(bold: true);
  AnsiPen success = AnsiPen()..green(bold: true);
  AnsiPen warning = AnsiPen()..yellow(bold: true);
  AnsiPen error = AnsiPen()..red(bold: true);

  void logInfo(String message) {
    debugPrint(info(message));
  }

  void logSuccess(String message) {
    debugPrint(success(message));
  }

  void logWarning(String message) {
    debugPrint(warning(message));
  }

  void logError(String message) {
    debugPrint(error(message));
  }
}

class SnackBarUtil {
  static void showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.lightGreen,
        // margin: const EdgeInsets.all(16.0),
        duration: const Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }
}