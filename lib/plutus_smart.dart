import 'package:flutter/services.dart';

class PlutusSmart {
  static const MethodChannel _channel = MethodChannel('PLUTUS-API');

  static Future<String> bindToService() async {
    try {
      final result = await _channel.invokeMethod('bindToService');
      return result;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> startTransaction(String transactionData) async {
    try {
      final result = await _channel.invokeMethod('startTransaction', {
        'transactionData': transactionData,
      });

      return result;
      print('Transaction Result: $result');
      // Process the transaction result
    } catch (e) {
      print('Error: $e');
      return 'ERROR';
      // Handle errors
    }
  }

  static Future<String> startPrintJob(String printData) async {
    try {
      final result = await _channel.invokeMethod('startPrintJob', {
        'printData': printData,
      });

      print('Print Job Result: $result');
      return result;
    } catch (e) {
      print('Error: $e');
      return 'ERROR';
    }
  }
}
