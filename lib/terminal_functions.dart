import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart'; // For cross-platform considerations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:plutusapp/plutus_smart.dart';
import 'logger.dart';

class TerminalFunctions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TerminalFunctions> with TickerProviderStateMixin{
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  TextEditingController _responseController = TextEditingController();
  final TextEditingController _billRefNoController = TextEditingController();
  final ScrollController _defaultScrollController = ScrollController();
  final TextEditingController _logController = TextEditingController();
  final TextEditingController _jsonController = TextEditingController();
  String _selectedTransaction = 'SALE';
  String _selectedInterface = 'WINDOWS';
  bool _isChecked = false;
  String statusMsg = '';
  String statusMsg2 = '';
  late AnimationController animationController;
  List<String> statusMessages = [];
  ScrollController _scrollController = ScrollController();
  int _seconds = 0;
  Timer? _timer;
  final FocusNode _payloadFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _billRefNoFocusNode = FocusNode();
  bool printerEnabled = false;
  bool scannerEnabled = false;
  String typeOfIntegration = 'NA';
  // String imgPath = '';
  String imgPath = 'PL.jpg';
  String hexDataImg = '';
  var testData;
  bool _isExpanded = false;
  String BILLING_REF = '';
  String SALE_AMT = '0';
  String TR_TYPE = '';
  String status = "Idle";
  Map<String, dynamic> payload ={
    "Detail": {
      "BillingRefNo": "TX98765432",
      "PaymentAmount": 100,
      "TransactionType": 4001,
    },
    "Header": {
      "ApplicationId": "100", // Your Application ID
      "MethodId": "1001",
      "UserId": "user1234", // User ID
      "VersionNo": "1.0",
    }
  };
  Map<String, dynamic> printData = {
    "Header": {
      "ApplicationId": "2d1425547b914f6992b52e74069390a0", // Replace with your actual App ID
      "UserId": "user1234",
      "MethodId": "1002",
      "VersionNo": "1.0",
    },
    "Detail": {
      "PrintRefNo": "123456789",
      "SavePrintData": false,
      "Data": [
        {
          "PrintDataType": "0",
          "PrinterWidth": 24,
          "IsCenterAligned": true,
          "DataToPrint": "String Data",
          "ImagePath": "0",
          "ImageData": "0"
        },
        {
          "PrintDataType": "1",
          "PrinterWidth": 24,
          "IsCenterAligned": true,
          "DataToPrint": "",
          "ImagePath": "Image Path",
          "ImageData": "0"
        },
        {
          "PrintDataType": "2",
          "PrinterWidth": 24,
          "IsCenterAligned": true,
          "DataToPrint": "",
          "ImagePath": "",
          "ImageData": "Image Data String"
        },
        {
          "PrintDataType": "3",
          "PrinterWidth": 24,
          "IsCenterAligned": true,
          "DataToPrint": "Bar Code Data in String",
          "ImagePath": "",
          "ImageData": ""
        },
        {
          "PrintDataType": "4",
          "PrinterWidth": 24,
          "IsCenterAligned": true,
          "DataToPrint": "QR Code Data in String",
          "ImagePath": "",
          "ImageData": ""
        }
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
    startTimer();
    getAppPackageName();
    initializeApp();
    super.initState();
  }

  @override
  void dispose() {
    _payloadFocusNode.dispose();
    _amountFocusNode.dispose();
    _billRefNoFocusNode.dispose();
    _payloadController.dispose();
    _amountController.dispose();
    _billRefNoController.dispose();
    animationController.dispose();
    _scrollController.dispose();
    _jsonController.clear();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initializeApp() async{
    addStatusMessage('BINDING INITIATED.');
    var result = await PlutusSmart.bindToService();
    addStatusMessage(result.toString());
  }

  void getAppPackageName() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Logger.log('Package name: ${packageInfo.packageName}', level: LogLevel.info);
    Logger.log('App name: ${packageInfo.appName}', level: LogLevel.info);
    Logger.log('Version: ${packageInfo.version}', level: LogLevel.info);
    Logger.log('Build Number: ${packageInfo.buildNumber}', level: LogLevel.info);
    Logger.log('Build Signature: ${packageInfo.buildSignature}', level: LogLevel.info);
    Logger.log('Installer Store: ${packageInfo.installerStore}', level: LogLevel.info);
  }

  Widget _title() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height / 18,
      child: Text(
        'TRANSACTIONS',
        style: GoogleFonts.montserrat(
          decoration: TextDecoration.underline,
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.normal,
          decorationColor: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> startTransaction() async {
    addStatusMessage('INITIATING TRANSACTION.');
    Logger.log('INITIATING TRANSACTION.',level: LogLevel.debug);
    try {
      // Prepare the transaction payload
      payload = {
        "Detail": {
          "BillingRefNo": "TX98765432",
          "PaymentAmount": 5000,
          "TransactionType": 4001,
        },
        "Header": {
          "ApplicationId": "2d1425547b914f6992b52e74069390a0", // Your Application ID
          "MethodId": "1001",
          "UserId": "user1234", // User ID
          "VersionNo": "1.0",
        }
      };
      final String transactionPayload = jsonEncode(payload);
      final result = await PlutusSmart.startTransaction(transactionPayload);
      Logger.log('TRANSACTION STATUS :$result',level: LogLevel.debug);
      Logger.log(result,level: LogLevel.debug);
      addStatusMessage(result);
    } catch (e) {
      addStatusMessage('EXCEPTION TRANSACTION STATUS : $e');
      Logger.log('EXCEPTION TRANSACTION STATUS : $e',level: LogLevel.error);
    }
  }

  Future<void> startUpiTransaction() async {
    addStatusMessage('INITIATING UPI TRANSACTION.');
    Logger.log('INITIATING UPI TRANSACTION.',level: LogLevel.debug);
    try {
      // Prepare the transaction payload
      payload = {
        "Detail": {
          "BillingRefNo": "TX98765432",
          "PaymentAmount": 5000,
          "TransactionType": 5120,
        },
        "Header": {
          "ApplicationId": "2d1425547b914f6992b52e74069390a0", // Your Application ID
          "MethodId": "1001",
          "UserId": "user1234", // User ID
          "VersionNo": "1.0",
        }
      };
      final String transactionPayload = jsonEncode(payload);
      final result = await PlutusSmart.startTransaction(transactionPayload);
      Logger.log('UPI TRANSACTION STATUS :$result',level: LogLevel.debug);
      Logger.log(result,level: LogLevel.debug);
      addStatusMessage(result);
    } catch (e) {
      addStatusMessage('UPI EXCEPTION TRANSACTION STATUS : $e');
      Logger.log('UPI EXCEPTION TRANSACTION STATUS : $e',level: LogLevel.error);
    }
  }

  Future<void> startPrint() async {
    Logger.log('INITIATING TRANSACTION.',level: LogLevel.debug);
    try {
      final String printPayload = jsonEncode(printData);
      // Call the native method to start the transaction
      final result = await PlutusSmart.startPrintJob(printPayload);
      // Handle the response
      Logger.log('PRINT STATUS : $result',level: LogLevel.debug);
    } catch (e) {
      Logger.log('PRINT STATUS : $e',level: LogLevel.error);
    }
  }

  Widget _transactionSelector(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TYPE: ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded:
                            true, // Ensure the dropdown button expands to fill its container
                        value: _selectedTransaction,
                        items: <String>[
                          'SALE',
                          'REFUND',
                          'VOID',
                          'SETTLE',
                          'UPI',
                          'SALE+TIP',
                          'PRINT',
                          'SCAN'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            setState(() {
                              _jsonController.text = const JsonEncoder.withIndent('').convert(printData);
                            });
                            _amountController.clear();
                            _billRefNoController.clear();
                            _selectedTransaction = newValue!;
                            if (newValue != 'PRINT') {
                              printerEnabled = false;
                            } else {
                              printerEnabled = true;
                            }
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return <String>[
                            'SALE',
                            'REFUND',
                            'VOID',
                            'SETTLE',
                            'UPI',
                            'SALE+TIP',
                            'PRINT',
                            'SCAN'
                          ].map((String value) {
                            return Center(
                              child: Text(
                                _selectedTransaction,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AMT: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    enabled: !_isChecked,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z0-9]*$')),
                    ],
                    controller: _amountController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ENTER AMT',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context)
                            .requestFocus(_billRefNoFocusNode);
                      });
                    },
                    validator: (value) {
                      if (!_isChecked && value != null && value.isNotEmpty) {
                        final RegExp regex = RegExp(r'^\d{1,14}(\.\d{1,15})?$');
                        if (!regex.hasMatch(value)) {
                          return 'Only alphanumeric characters (max 15)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'REF NO :   ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    enabled: !_isChecked,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z0-9]*$')),
                    ],
                    controller: _billRefNoController,
                    focusNode: _billRefNoFocusNode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'BILLING REF NUMBER',
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        BILLING_REF = value;
                      });
                    },
                    validator: (value) {
                      if (!_isChecked && value != null && value.isNotEmpty) {
                        final RegExp regex = RegExp(r'^[a-zA-Z0-9]{1,15}$');
                        if (!regex.hasMatch(value)) {
                          return 'Only alphanumeric characters (max 15)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: _selectedTransaction == 'SCAN' ? null : () async{
                if (!_isChecked) {
                  switch (_selectedTransaction) {
                    case 'SALE':
                      // Logger.log('Transaction response: $response',level: LogLevel.warning);
                      startTransaction();
                      break;
                    case 'REFUND':

                      break;
                    case 'VOID':

                      break;
                    case 'SETTLEMENT':

                      break;
                    case 'UPI':
                      startUpiTransaction();
                      break;
                    case 'SALE+TIP':
                      break;
                    case 'PRINT':
                      await PlutusSmart.bindToService();
                      startPrint();
                      break;
                    default:
                      TR_TYPE = '';
                  }
                } else {
                  Logger.log('FUNCTION NOT IMPLEMENTED',level: LogLevel.warning);
                  addStatusMessage('FUNCTION NOT IMPLEMENTED');
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xffdf8e33).withAlpha(10),
                      offset: const Offset(2, 4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  color: _selectedTransaction == 'SCAN' ? Colors.grey : Colors.black ,
                  border: Border.all(
                    color: Colors.white, // White color border
                    width: 1, // Border width
                  ),
                ),
                child: const Text(
                  'PROCESS',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _responseSelector(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: statusMessages.length,
          controller: _scrollController,
          itemBuilder: (context, index) {
            final message = statusMessages[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.justify,
              ),
            );
          },
        ),
    );
  }

  Widget _printDemo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white),
      ),
      child: SingleChildScrollView(
      child: GestureDetector(
          onDoubleTap: () async{
    },
      child: TextFormField(
        controller: _jsonController,
        keyboardType: TextInputType.multiline,
        maxLines: null, // Allows for unlimited lines of text
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 14,
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(5),
        ),
        onChanged: (value) {
          setState(() {
            try {
              var parsedData = jsonDecode(_jsonController.text);
              printData = convertToMapOfMaps(parsedData);
            } catch (e) {
              Logger.log('Error parsing JSON: $e', level: LogLevel.error);
            }
          });
        },
      ),
    ),
    ),
    );
  }

  void addStatusMessage(String message) {
    String currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    setState(() {
      statusMessages.add('$currentTime :  $message');
    });
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  Map<String, Map<String, Object>> convertToMapOfMaps(Map<String, dynamic> data) {
    Map<String, Map<String, Object>> result = {};
    data.forEach((key, value) {
      if (value is Map<String, Object>) {
        result[key] = value;
      } else if (value is Map<String, dynamic>) {
        // Convert inner map to Map<String, Object>
        result[key] = Map<String, Object>.from(value);
      } else {
        // Handle other cases as needed
        // For simplicity, assume you only deal with maps here
      }
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            gradient: LinearGradient(
              colors: [Color(0xff00bf8f), Color(0xff001510)],
              stops: [0, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30),
              _title(),
              _transactionSelector(context),
              const SizedBox(height: 5),
              printerEnabled
                    ? Expanded(child:_printDemo(context)):
                      Expanded(child:_responseSelector(context)),
            ],
          ),
        ),
      ),
    );
  }
}
