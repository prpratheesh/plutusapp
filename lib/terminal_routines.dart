import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class POSManager {
  static const MethodChannel _platform = MethodChannel('pinelabs_sdk');
  static List<dynamic> scannedDevices = [];

  static Future<void> initialisePLsystems() async {
    try {
      // Initialize POS lib
      final response = await _platform.invokeMethod('posLibInitialize');
      print('POS Lib initialization response: $response');
      // Scan for BT devices after initializing POS lib
      // scanBTDevices();
      // print('--------------SCANNING ONLINE DEVICES---------------');
      // // Scan online POS devices
      // scanOnlinePOSDevices();
      // print('--------------SCANNING ONLINE DEVICES---------------');
    } on PlatformException catch (e) {
      print('Failed to initialize POS lib: ${e.message}');
    }
  }

  static Future<List<DeviceDetails>?> scanOnlinePOSDevices() async {
    try {
      var data = await POSManager._platform.invokeMethod('scanOnlinePOSDevice');
      if (data != null && data['list'] != null && data['list'] is List<dynamic> && data['list'].isNotEmpty) {
        var deviceList = (data['list'] as List<dynamic>)
            .map((deviceData) => DeviceDetails.fromMap(deviceData.cast<String, dynamic>())) // Cast keys to String
            .toList();
        return deviceList;
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      print('Inside catch block: ${e.message}');
      return null;
    }
  }

  static Future<dynamic?> getConfig() async {
    try {
      var configData = await POSManager._platform.invokeMethod('getConfiguration');
      return configData;
    } on PlatformException catch (e) {
      print('Inside catch block: ${e.message}');
      return null;
    }
  }

  // static Future<dynamic?> setConfig(Map<String, Object> configData) async {
  //   try {
  //     var setConfigData = await _platform.invokeMethod('setConfiguration', {
  //       'configData': configData
  //     });
  //     print('---------------------PRINTING CONFIG DATA----------------------------');
  //     print('Response from Terminal: ${setConfigData.toString()}');
  //     print('---------------------PRINTING CONFIG DATA----------------------------');
  //     return setConfigData;
  //   } on PlatformException catch (e) {
  //     print('Inside catch block: ${e.message}');
  //     return null;
  //   }
  // }

  static Future<String?> setConfig(ConfigData configData) async {
    try {
      final result = await _platform.invokeMethod('setConfiguration', configData.toMap());
      print('Response from Terminal: ${result.toString()}');
      return result;
    } on PlatformException catch (e) {
      print('Error setting configuration: ${e.message}');
      return null;
    }
  }

  static Future<void> connectToDevice(String ip, String port) async {
    try {
      final result = await _platform.invokeMethod('connectToDevice', {
        'ip': ip,
        'port': port,
      });
      print('Connection result: $result');
      // Handle connection result as needed
    } on PlatformException catch (e) {
      print('Failed to connect to device: ${e.message}');
      // Handle connection failure
    }
  } //WINDOWS

  static Future<String> testTCP(String ip, String port) async {
    try {
      final dynamic isConnected = await _platform.invokeMethod<String>('testTCP', {
        'ip': ip,
        'port': port,
      });

      // Example: Interpret the String result from Kotlin
      if (isConnected == 'true') {
        return 'true';
      } else {
        return 'false';
      }
    } on PlatformException catch (e) {
      print("Failed to Connect: ${e.message}");
      return 'Error';
    }
  }

  static Future<int?> checkTcpComStatus(int timeInterval) async {
    try {
      final dynamic result = await _platform.invokeMethod<int>('checkTcpComStatus', {'timeInterval': timeInterval});
      int? eventId = result as int?;
      return eventId;
    } on PlatformException catch (e) {
      print('Failed to check TCP communication status: ${e.message}');
      throw e; // Throw or handle the exception as needed
    }
  }

  static Future<String?> doTransaction(String paymentRequest, int transactionType) async {
    try {
      final String? result = await _platform.invokeMethod('doTransaction', {
        'paymentRequest': paymentRequest,
        'transactionType': transactionType,
      });
      return result;
    } on PlatformException catch (e) {
      // Handle the error here, for example:
      print("Failed to do transaction: '${e.message}'");
      return null;
    }
  }

  static Future<List<DeviceDetails>?> scanBTDevices() async {
    try {
      var data = await POSManager._platform.invokeMethod('scanBTDevice');
      if (data != null && data['list'] != null && data['list'] is List<dynamic> && data['list'].isNotEmpty) {
        var deviceList = (data['list'] as List<dynamic>)
            .map((deviceData) => DeviceDetails.fromMap(deviceData.cast<String, dynamic>())) // Cast keys to String
            .toList();
        return deviceList;
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      print('Inside catch block: ${e.message}');
      return null;
    }
  }

  static Future<bool?> testBT(String btSsid) async {
    try {
      final bool? isConnected = await _platform.invokeMethod<bool>('testBT', {'btSsid': btSsid});
      return isConnected;
    } on PlatformException catch (e) {
      print('Failed to test Bluetooth: ${e.message}');
      return false;
    }
  }

  static Future<int?> checkBtComStatus(int timeInterval) async {
    try {
      final dynamic result = await _platform.invokeMethod<int>('checkBtComStatus', {'timeInterval': timeInterval});
      int? eventId = result as int?;
      return eventId;
    } on PlatformException catch (e) {
      print('Failed to check BT communication status: ${e.message}');
      throw e; // Throw or handle the exception as needed
    }
  }

}

// Define the DeviceDetails class here as well
class DeviceDetails {
  final bool isBtDevice;
  final String deviceSlNo;
  final String deviceId;
  final String deviceIp;
  final String devicePort;
  final String btDeviceSsid;
  final String btDeviceName;

  DeviceDetails({
    required this.isBtDevice,
    required this.deviceSlNo,
    required this.deviceId,
    required this.deviceIp,
    required this.devicePort,
    required this.btDeviceSsid,
    required this.btDeviceName,
  });

  // Factory method to create DeviceDetails object from map
  factory DeviceDetails.fromMap(Map<String, dynamic> map) {
    return DeviceDetails(
      isBtDevice: map['isBtDevice'] ?? false,
      deviceSlNo: map['deviceSlNo'] ?? 'NA',
      deviceId: map['deviceId'] ?? 'NA',
      deviceIp: map['deviceIp'] ?? 'NA',
      devicePort: map['devicePort'] ?? 'NA',
      btDeviceSsid: map['btDeviceSsid'] ?? 'NA',
      btDeviceName: map['btDeviceName'] ?? 'NA',
    );
  }
}

class DeviceData {
  final String devId;
  final int msgType;
  final String posIP;
  final String posPort;
  final String slNo;

  DeviceData({
    required this.devId,
    required this.msgType,
    required this.posIP,
    required this.posPort,
    required this.slNo,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      devId: json['devId'],
      msgType: json['msgType'],
      posIP: json['posIP'],
      posPort: json['posPort'],
      slNo: json['slNo'],
    );
  }
}

class ConfigData {
  String tcpIP;
  String tcpPort;
  String commPortNumber;
  String baudRate;
  bool isConnectivityFallBackAllowed;
  String btSSID;
  String btName;
  int commP1;
  int commP2;
  int commP3;
  String connectionMode;
  String logPath;
  bool isLogsEnabled;
  int logLevel;
  int dayToRetainLogs;
  int retryCount;
  int connectionTimeOut;
  bool isDemoMode;
  String cashierID;
  String cashierName;
  String deviceSlNo;
  String deviceId;

  ConfigData({
    required this.tcpIP,
    required this.tcpPort,
    required this.commPortNumber,
    required this.baudRate,
    required this.isConnectivityFallBackAllowed,
    required this.btSSID,
    required this.btName,
    required this.commP1,
    required this.commP2,
    required this.commP3,
    required this.connectionMode,
    required this.logPath,
    required this.isLogsEnabled,
    required this.logLevel,
    required this.dayToRetainLogs,
    required this.retryCount,
    required this.connectionTimeOut,
    required this.isDemoMode,
    required this.cashierID,
    required this.cashierName,
    required this.deviceSlNo,
    required this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'tcpIP': tcpIP,
      'tcpPort': tcpPort,
      'commPortNumber': commPortNumber,
      'baudRate': baudRate,
      'isConnectivityFallBackAllowed': isConnectivityFallBackAllowed,
      'btSSID': btSSID,
      'btName': btName,
      'commP1': commP1,
      'commP2': commP2,
      'commP3': commP3,
      'connectionMode': connectionMode,
      'logPath': logPath,
      'isLogsEnabled': isLogsEnabled,
      'logLevel': logLevel,
      'dayToRetainLogs': dayToRetainLogs,
      'retryCount': retryCount,
      'connectionTimeOut': connectionTimeOut,
      'isDemoMode': isDemoMode,
      'cashierID': cashierID,
      'cashierName': cashierName,
      'deviceSlNo': deviceSlNo,
      'deviceId': deviceId,
    };
  }

  factory ConfigData.fromMap(Map<String, dynamic> map) {
    return ConfigData(
      tcpIP: map['tcpIP'] as String,
      tcpPort: map['tcpPort'] as String,
      commPortNumber: map['commPortNumber'] as String,
      baudRate: map['baudRate'] as String,
      isConnectivityFallBackAllowed: map['isConnectivityFallBackAllowed'] as bool,
      btSSID: map['btSSID'] as String,
      btName: map['btName'] as String,
      commP1: map['commP1'] as int,
      commP2: map['commP2'] as int,
      commP3: map['commP3'] as int,
      connectionMode: map['connectionMode'] as String,
      logPath: map['logPath'] as String,
      isLogsEnabled: map['isLogsEnabled'] as bool,
      logLevel: map['logLevel'] as int,
      dayToRetainLogs: map['dayToRetainLogs'] as int,
      retryCount: map['retryCount'] as int,
      connectionTimeOut: map['connectionTimeOut'] as int,
      isDemoMode: map['isDemoMode'] as bool,
      cashierID: map['cashierID'] as String,
      cashierName: map['cashierName'] as String,
      deviceSlNo: map['deviceSlNo'] as String,
      deviceId: map['deviceId'] as String,
    );
  }
}


