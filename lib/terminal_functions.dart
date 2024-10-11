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
import 'package:pl_integration_tester/terminal_routines.dart';
import 'package:file_picker/file_picker.dart';
import 'log_control.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show rootBundle;

class TerminalFunctions extends StatefulWidget {
  final dynamic device;
  final ConfigData? configData;

  TerminalFunctions({required this.device, required this.configData});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TerminalFunctions> with TickerProviderStateMixin{
  DeviceDetails? get device => widget.device;
  ConfigData? get configData => widget.configData;
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
  ////////////////////data elements////////////////////
  String IDENTIFICATIN_NO = '1000';
  String FUNCTION_CODE = '0997';
  String DATA_LENGTH = '0016';
  String DATA = '';
  String EOT = 'FF';
  String TR_TYPE = '';
  String SALE_AMT = '0';
  // String BILLING_REF = 'TESTREFNOHAVE23FIELDS23';
  String BILLING_REF = '';
  bool _isBillRefEnter = false;
  int TXN_TYPE = 6;
  int SCAN_TXN_TYPE = 1007;
////////////////////data elements////////////////////
  LogControl logger = LogControl();
  bool printerEnabled = false;
  bool scannerEnabled = false;
  String typeOfIntegration = 'NA';
  // String imgPath = '';
  String imgPath = 'PL.jpg';
  String hexDataImg = '';
  var testData;
  bool _isExpanded = false;
  static const int PRINTER_SUCCESS = 0;
  static const int PRINTER_FAILED = 1;
  static const int PRINTER_BUSY = 1001;
  static const int PRINTER_OUT_OF_PAPER = 1002;
  static const int PRINTER_LOW_PAPER = 1003;
  static const int PRINTER_LOW_BATTERY = 1004;
  static const int PRINTER_HARDWARE_ERROR = 1005;
  static const int PRINTER_OVERHEAT = 1006;
  static const int PRINTER_BUFFER_OVERFLOW = 1007;
  static const int PRINTER_PAPER_ALIGN_POSITION = 1008;
  static const int PRINTER_PAPER_JAM = 1009;
  static const int PRINTER_CUT_POSITION_ERROR = 1010;
  static const int PRINTER_DATA_FORMAT_ERROR = 1011;
  static const int PRINTER_LIBRARY_ERROR = 1012;
  static const int PRINTER_COVER_OPEN_ERROR = 1013;
  static const int PRINTER_REQ_DATA_INCORRECT = 1014;
  static const int RERQUEST_DATA_NOT_FOUND = 1015;
  static const int APPLICATION_IS_BUSY = 1016;
  static const int PRINTING_DATA_NOT_FOUND = 1017;
  static const int UNKNOWN_ERROR = 1099;
  static const int PRINTER_NOT_AVAILABLE = 1101;

  static const int SCAN_CODE = 1007;
  static const int SCAN_CODE_CAMERA=1009;
  static const int MULTI_SCAN_CODE_CAMERA=1010;
  static const int STOP_SCAN = 1012;

  @override
  void initState() {
    if(configData!=null) {
      getConfig();
    }
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationController.repeat();
    startTimer();
    initTestData();
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

  void initTestData(){
    print("<<<<<<<< $imgPath >>>>>>>>");
    testData = {
      "Header": {
        "ApplicationId": "8a555650d06c407e97bc73fc7d69a673",
        "UserId": "***123**123***",
        "MethodId": "1002",
        "VersionNo": "1.0"
      },
      "Detail": {
        "PrintRefNo": "123456789",
        "SavePrintData": true,
        "Data": [
          {
            "PrintDataType": "0",
            "PrinterWidth": 24,
            "IsCenterAligned": true,
            "DataToPrint": "------------------------"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 24,
            "IsCenterAligned": true,
            "DataToPrint": "TEST DATA @24PRINT WIDTH"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 28,
            "IsCenterAligned": true,
            "DataToPrint": "TEST DATA @28 PRINT WIDTH"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 32,
            "IsCenterAligned": true,
            "DataToPrint": "TEST DATA @32 PRINT WIDTH"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 40,
            "IsCenterAligned": true,
            "DataToPrint": "TEST DATA @40 PRINT WIDTH"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 48,
            "IsCenterAligned": true,
            "DataToPrint": "TEST DATA @48 PRINT WIDTH"
          },
          // {
          //   "PrintDataType": "1",
          //   "IsCenterAligned": true,
          //   "strImagePath": imgPath
          // },//img
          {
            "PrintDataType": "2",
            "IsCenterAligned": true,
            "strImageData": hexDataImg,
          },//img hex path
          {
            "PrintDataType": "0",
            "PrinterWidth": 24,
            "IsCenterAligned": true,
            "DataToPrint": "               "
          },
          {
            "PrintDataType": "3",
            "IsCenterAligned": true,
            "DataToPrint": "TEST BARCODE"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 24,
            "IsCenterAligned": true,
            "DataToPrint": "               "
          },
          {
            "PrintDataType": "4",
            "IsCenterAligned": true,
            "DataToPrint": "TEST QR DATA"
          },
          {
            "PrintDataType": "0",
            "PrinterWidth": 24,
            "IsCenterAligned": true,
            "DataToPrint": "------------------------\n"
          },
        ]
      }
    };
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
          fontSize: 25.0,
          fontWeight: FontWeight.normal,
          decorationColor: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _deviceDetails() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding:
          const EdgeInsets.only(bottom: 2, top: 2), // Add padding to the bottom
      child: Text(
        'TERMINAL: SL:${device?.deviceSlNo}/IP:${device?.deviceIp}/$typeOfIntegration',
        style: GoogleFonts.montserrat(
          decoration: TextDecoration.none,
          color: Colors.black,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          decorationColor: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
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
                              _jsonController.text = JsonEncoder.withIndent('').convert(testData);
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
                            'SALE+TIP',
                            'PRINT',
                            'SCAN'
                          ].map((String value) {
                            return Center(
                              child: Text(
                                _selectedTransaction!,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Text(
                        'EN ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                            if (_isChecked) {
                              _amountController.clear();
                              _billRefNoController.clear();
                              FocusScope.of(context).unfocus();
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                FocusScope.of(context)
                                    .requestFocus(_payloadFocusNode);
                              });
                            } else {
                              _payloadController.clear();
                              FocusScope.of(context).unfocus();
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                FocusScope.of(context)
                                    .requestFocus(_amountFocusNode);
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    enabled: _isChecked,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-zA-Z0-9]*$')),
                    ],
                    controller: _payloadController,
                    focusNode: _payloadFocusNode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'MANUAL PAYLOAD CREATION',
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
            const SizedBox(height: 10),
            InkWell(
              onTap: _selectedTransaction == 'SCAN' ? null : () async{
                if (!_isChecked) {
                  switch (_selectedTransaction) {
                    case 'SALE':
                      if (checkTxnAmt()) {
                        TR_TYPE = '4001';
                        addStatusMessage('INITIATING SALE TRANSACTION');
                        String DATA_ASCII =
                            '$TR_TYPE,$BILLING_REF,$SALE_AMT,,,,,,,';
                        DATA = convertToHex(DATA_ASCII);
                        String payloadLength = (decimalToHexWithLeadingZeros(
                            DATA_ASCII.length, 4));
                        DATA_LENGTH = payloadLength.toString().toUpperCase();
                        final dataElement = (IDENTIFICATIN_NO +
                                FUNCTION_CODE +
                                DATA_LENGTH +
                                DATA +
                                EOT)
                            .toUpperCase();
                        addStatusMessage(hexToAscii(dataElement!));
                        var datapayment = await POSManager.doTransaction(
                            dataElement, TXN_TYPE);
                        addStatusMessage(hexToAscii(datapayment!));
                        logger.logSuccess(datapayment.toString());
                      } else {
                        logger.error('Enter Transaction Amount');
                        SnackBarUtil.showCustomSnackBar(
                            context, 'Enter Transaction Amount');
                      }
                      break;
                    case 'REFUND':
                      if (checkTxnAmt()) {
                        TR_TYPE = '4002';
                        addStatusMessage('INITIATING REFUND TRANSACTION');
                        String DATA_ASCII =
                            '$TR_TYPE,$BILLING_REF,$SALE_AMT,,,,,,,';
                        DATA = convertToHex(DATA_ASCII);
                        String payloadLength = (decimalToHexWithLeadingZeros(
                            DATA_ASCII.length, 4));
                        DATA_LENGTH = payloadLength.toString().toUpperCase();
                        final dataElement = (IDENTIFICATIN_NO +
                                FUNCTION_CODE +
                                DATA_LENGTH +
                                DATA +
                                EOT)
                            .toUpperCase();
                        var datapayment = await POSManager.doTransaction(
                            dataElement, TXN_TYPE);
                        addStatusMessage(hexToAscii(dataElement!));
                        logger.logSuccess(datapayment.toString());
                      } else {
                        logger.error('Enter Transaction Amount');
                        SnackBarUtil.showCustomSnackBar(
                            context, 'Enter Transaction Amount');
                      }
                      break;
                    case 'VOID':
                      if (checkTxnAmt()) {
                        TR_TYPE = '4006';
                        addStatusMessage('INITIATING VOID TRANSACTION');
                        String DATA_ASCII =
                            '$TR_TYPE,$BILLING_REF,$SALE_AMT,,,,,,,';
                        DATA = convertToHex(DATA_ASCII);
                        String payloadLength = (decimalToHexWithLeadingZeros(
                            DATA_ASCII.length, 4));
                        DATA_LENGTH = payloadLength.toString().toUpperCase();
                        final dataElement = (IDENTIFICATIN_NO +
                                FUNCTION_CODE +
                                DATA_LENGTH +
                                DATA +
                                EOT)
                            .toUpperCase();
                        var datapayment = await POSManager.doTransaction(
                            dataElement, TXN_TYPE);
                        addStatusMessage(hexToAscii(dataElement!));
                        logger.logSuccess(datapayment.toString());
                      } else {
                        logger.error('Enter Transaction Amount');
                        SnackBarUtil.showCustomSnackBar(
                            context, 'Enter Transaction Amount');
                      }
                      break;
                    case 'SETTLEMENT':
                      TR_TYPE = '6001';
                      addStatusMessage('INITIATING SETTLEMENT TRANSACTION');
                      const dataElement =
                          '10000997001A363030312C2C2C2C2C2C2C2C2C2CFF';
                      addStatusMessage(hexToAscii(dataElement!));
                      var datapayment =
                          await POSManager.doTransaction(dataElement, TXN_TYPE);
                      addStatusMessage(hexToAscii(datapayment!));
                      logger.logSuccess(datapayment.toString());
                      break;
                    case 'SALE+TIP':
                      if (checkTxnAmt()) {
                        TR_TYPE = '4011';
                        addStatusMessage('INITIATING SALE+TIP TRANSACTION');
                        String DATA_ASCII =
                            '$TR_TYPE,$BILLING_REF,$SALE_AMT,,,,,,,';
                        DATA = convertToHex(DATA_ASCII);
                        String payloadLength = (decimalToHexWithLeadingZeros(
                            DATA_ASCII.length, 4));
                        DATA_LENGTH = payloadLength.toString().toUpperCase();
                        final dataElement = (IDENTIFICATIN_NO +
                                FUNCTION_CODE +
                                DATA_LENGTH +
                                DATA +
                                EOT)
                            .toUpperCase();
                        var datapayment = await POSManager.doTransaction(
                            dataElement, TXN_TYPE);
                        addStatusMessage(hexToAscii(dataElement!));
                        logger.logSuccess(datapayment.toString());
                      } else {
                        logger.error('Enter Transaction Amount');
                        SnackBarUtil.showCustomSnackBar(
                            context, 'Enter Transaction Amount');
                      }
                      break;
                    case 'PRINT':
                      logger.info('INITIATING SAMPLE PRINT');
                      addStatusMessage('INITIATING SAMPLE PRINT');
                      SnackBarUtil.showCustomSnackBar(context, 'INITIATING SAMPLE PRINT');
                      String testDataString = jsonEncode(testData);
                      var datapayment =
                          await POSManager.doTransaction(testDataString, 1002);
                      // logger.logSuccess(datapayment.toString());
                      if(datapayment!=null){
                        Map<String, dynamic> jsonData = jsonDecode(datapayment);
                        int responseCode = jsonData['Response']['ResponseCode'];
                        handlePrinterStatus(responseCode);
                        addStatusMessage('PRINT SUCCESS');
                      }else{
                        SnackBarUtil.showCustomSnackBar(context, 'PRINT FAILURE');
                        addStatusMessage('PRINT FAILURE');
                      }
                      // addStatusMessage(hexToAscii(datapayment!));
                      break;
                    default:
                      TR_TYPE = '';
                  }
                } else {
                  logger.logSuccess('FUNCTION NOT IMPLEMENTED');
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
        padding: const EdgeInsets.all(10),
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
            final ByteData byteData = await rootBundle.load('assets/PL.jpg');
            hexDataImg = await localImageToHexString('assets/PL.jpg');
            initTestData();
            setState(() {
              _jsonController.text = const JsonEncoder.withIndent('').convert(testData);
            });
            print(_jsonController.text);
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
              testData = convertToMapOfMaps(parsedData);
            } catch (e) {
              print('Error parsing JSON: $e');
            }
          });
        },
      ),
    ),
    ),
    );
  }

  Future<void> sendDataToPort8082(String data) async {
    addStatusMessage('CONNECTING TO PORT 8082');
    String host = 'localhost';
    int port = 8082;
    try {
      var socket = await Socket.connect(host, port);
      print('CONNECTED TO ${host.toUpperCase()}:$port');
      addStatusMessage('CONNECTED TO ${host.toUpperCase()}:$port');
      var pyldaAscii = hexToAscii(data);
      String pyldaHex = data.toString().trim();
      addStatusMessage('PAYLOAD ASCII: $pyldaAscii');
      // addStatusMessage('PAYLOAD HEX: $pyldaHex'.trim());
      List<int> bytes = [];
      for (int i = 0; i < data.length; i += 2) {
        String hex = data.substring(i, i + 2);
        bytes.add(int.parse(hex, radix: 16));
      }
      socket.add(bytes);
      socket.listen(
        (List<int> event) {
          String response = String.fromCharCodes(event);
          print(response);
          var responseT = extractDataInsideQuotes(response);
          if (responseT != '0') {
            addStatusMessage(
                '----------------TERMINAL RESPONSE----------------');
            addStatusMessage(responseT);
            addStatusMessage(
                '----------------TERMINAL RESPONSE----------------');
          } else {
            var responseE = extractAlphanumeric(response);
            addStatusMessage(
                '----------------TERMINAL RESPONSE----------------');
            addStatusMessage(responseE.toUpperCase());
            addStatusMessage(
                '----------------TERMINAL RESPONSE----------------');
          }
          // Check if the response contains the end character ÿ
          if (response.contains('\u00FF')) {
            // Close the socket connection
            socket.destroy();
            print('CONNECTION CLOSED.');
            addStatusMessage('CONNECTION CLOSED.');
          }
        },
        onError: (dynamic error) {
          print('LISTENING ERROR: ${error.toString().toUpperCase()}');
          addStatusMessage(
              'LISTENING ERROR: ${error.toString().toUpperCase()}');
          socket.destroy();
        },
        cancelOnError: true,
      );
      print('DATA SENT.');
      addStatusMessage('DATA SENT.');
    } catch (e) {
      print('ERROR: ${e.toString().toUpperCase()}');
      addStatusMessage('ERROR: ${e.toString().toUpperCase()}');
    }
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

  String extractDataInsideQuotes(String response) {
    int firstQuoteIndex = response.indexOf('"');
    int lastQuoteIndex = response.lastIndexOf('"');

    if (firstQuoteIndex == -1 ||
        lastQuoteIndex == -1 ||
        firstQuoteIndex == lastQuoteIndex) {
      // Invalid response format or no content inside quotes
      return '0';
    }

    return response.substring(firstQuoteIndex, lastQuoteIndex + 1);
  }

  String convertToHex(String input) {
    List<int> codeUnits = input.codeUnits;
    String hexString = '';
    for (int codeUnit in codeUnits) {
      hexString += codeUnit.toRadixString(16).padLeft(2, '0');
    }
    return hexString;
  }

  String hexToDecimalWithLeadingZeros(String hexString, int desiredLength) {
    int decimalResult = int.parse(hexString, radix: 16);
    String formattedResult = decimalResult.toString();
    while (formattedResult.length < desiredLength) {
      formattedResult = '00$formattedResult';
    }
    return formattedResult;
  }

  String decimalToHexWithLeadingZeros(int decimalNumber, int desiredLength) {
    String hexResult = decimalNumber.toRadixString(16);
    while (hexResult.length < desiredLength) {
      hexResult = '00$hexResult';
    }
    return hexResult;
  }

  String extractAlphanumeric(String response) {
    // Define a regular expression pattern to match alphanumeric characters
    RegExp regex = RegExp(r'[a-zA-Z0-9\s]+');
    // Find all matches of alphanumeric characters in the response
    Iterable<Match> matches = regex.allMatches(response);
    // Join the matches to form the final alphanumeric string
    String alphanumericData = matches.map((match) => match.group(0)!).join('');
    return alphanumericData;
  }

  String hexToAscii(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      int byte = int.parse(hex, radix: 16);
      bytes.add(byte);
    }

    // Explicitly replace control characters with their representations
    String asciiString = String.fromCharCodes(bytes);
    asciiString = asciiString.replaceAll("\x00", "[NUL]");
    asciiString = asciiString.replaceAll("\x01", "[SOH]");
    asciiString = asciiString.replaceAll("\x02", "[STX]");
    asciiString = asciiString.replaceAll("\x03", "[ETX]");
    asciiString = asciiString.replaceAll("\x04", "[EOT]");
    asciiString = asciiString.replaceAll("\x05", "[ENQ]");
    asciiString = asciiString.replaceAll("\x06", "[ACK]");
    asciiString = asciiString.replaceAll("\x07", "[BEL]");
    asciiString = asciiString.replaceAll("\x08", "[BS]");
    asciiString = asciiString.replaceAll("\x09", "[TAB]");
    asciiString = asciiString.replaceAll("\x0A", "[LF]");
    asciiString = asciiString.replaceAll("\x0B", "[VT]");
    asciiString = asciiString.replaceAll("\x0C", "[FF]");
    asciiString = asciiString.replaceAll("\x0D", "[CR]");
    asciiString = asciiString.replaceAll("\x0E", "[SO]");
    asciiString = asciiString.replaceAll("\x0F", "[SI]");
    asciiString = asciiString.replaceAll("\x10", "[DLE]");
    asciiString = asciiString.replaceAll("\x11", "[DC1]");
    asciiString = asciiString.replaceAll("\x12", "[DC2]");
    asciiString = asciiString.replaceAll("\x13", "[DC3]");
    asciiString = asciiString.replaceAll("\x14", "[DC4]");
    asciiString = asciiString.replaceAll("\x15", "[NAK]");
    asciiString = asciiString.replaceAll("\x16", "[SYN]");
    asciiString = asciiString.replaceAll("\x17", "[ETB]");
    asciiString = asciiString.replaceAll("\x18", "[CAN]");
    asciiString = asciiString.replaceAll("\x19", "[EM]");
    asciiString = asciiString.replaceAll("\x1A", "[SUB]");
    asciiString = asciiString.replaceAll("\x1B", "[ESC]");
    asciiString = asciiString.replaceAll("\x1C", "[FS]");
    asciiString = asciiString.replaceAll("\x1D", "[GS]");
    asciiString = asciiString.replaceAll("\x1E", "[RS]");
    asciiString = asciiString.replaceAll("\x1F", "[US]");
    asciiString = asciiString.replaceAll("\x7F", "[DEL]");
    // Add more replacements for other control characters as needed
    return asciiString;
  }

  void getConfig() async {
    if (configData!.commP1 == 1) {
      setState(() {
        typeOfIntegration = 'TCP';
      });
    } else if (configData!.commP1 == 2) {
      setState(() {
        typeOfIntegration = 'BLE';
      });
    } else if (configData!.commP1 == 3) {
      setState(() {
        typeOfIntegration = 'APP2APP';
      });
    }
  }

  bool checkTxnAmt() {
    if ((_amountController.text != '' && _amountController.text != null) &&
        double.tryParse(_amountController.text) != 0.0) {
      setState(() {
        SALE_AMT = _amountController.text;
      });
      return true;
    } else {
      return false;
    }
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

  Future<void> pickImage() async {
    FilePickerResult? result;
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
      }catch(e){
        print(e.toString());
      }
      if (result != null) {
        PlatformFile file = result.files.first;
        print('Original File Name: ${file.name}');
        print('File Path: ${file.path}');
        print('File Extension: ${file.extension}');

        // Handle null file path
        if (file.path != null) {
          hexDataImg = await imageToHexString(file.path!);
          setState(() {
            imgPath = file.path!;
          });
          // Assuming initTestData() initializes or updates testData
          initTestData();
          setState(() {
            _jsonController.text = const JsonEncoder.withIndent('').convert(testData);
          });
          print(_jsonController.text);
        } else {
          print('File path is null');
        }
      } else {
        // User canceled the picker
        print('User canceled the picker');
      }
    } else {
      // Permission denied
      print('Storage permission denied');
      if (await Permission.storage.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  void handlePrinterStatus(status) {
    String message;
    switch (status) {
      case PRINTER_SUCCESS:
        message = 'PRINT SUCCESS';
        break;
      case PRINTER_FAILED:
        message = 'PRINT FAILED';
        break;
      case PRINTER_BUSY:
        message = 'PRINTER BUSY';
        break;
      case PRINTER_OUT_OF_PAPER:
        message = 'PRINTER OUT OF PAPER';
        break;
      case PRINTER_LOW_PAPER:
        message = 'PRINTER LOW PAPER';
        break;
      case PRINTER_LOW_BATTERY:
        message = 'PRINTER LOW BATTERY';
        break;
      case PRINTER_HARDWARE_ERROR:
        message = 'PRINTER HARDWARE ERROR';
        break;
      case PRINTER_OVERHEAT:
        message = 'PRINTER OVERHEAT';
        break;
      case PRINTER_BUFFER_OVERFLOW:
        message = 'PRINTER BUFFER OVERFLOW';
        break;
      case PRINTER_PAPER_ALIGN_POSITION:
        message = 'PRINTER PAPER ALIGN POSITION';
        break;
      case PRINTER_PAPER_JAM:
        message = 'PRINTER PAPER JAM';
        break;
      case PRINTER_CUT_POSITION_ERROR:
        message = 'PRINTER CUT POSITION ERROR';
        break;
      case PRINTER_DATA_FORMAT_ERROR:
        message = 'PRINTER DATA FORMAT ERROR';
        break;
      case PRINTER_LIBRARY_ERROR:
        message = 'PRINTER LIBRARY ERROR';
        break;
      case PRINTER_COVER_OPEN_ERROR:
        message = 'PRINTER COVER OPEN ERROR';
        break;
      case PRINTER_REQ_DATA_INCORRECT:
        message = 'PRINTER REQ DATA INCORRECT';
        break;
      case RERQUEST_DATA_NOT_FOUND:
        message = 'REQUEST DATA NOT FOUND';
        break;
      case APPLICATION_IS_BUSY:
        message = 'APPLICATION IS BUSY';
        break;
      case PRINTING_DATA_NOT_FOUND:
        message = 'PRINTING DATA NOT FOUND';
        break;
      case UNKNOWN_ERROR:
        message = 'UNKNOWN ERROR';
        break;
      case PRINTER_NOT_AVAILABLE:
        message = 'PRINTER NOT AVAILABLE';
        break;
      default:
        message = 'UNKNOWN STATUS';
    }
    SnackBarUtil.showCustomSnackBar(context, message);
    addStatusMessage(message);
  }

  String bytes2HexString(Uint8List data) {
    final buffer = StringBuffer();
    for (int byte in data) {
      final hex = byte & 0xFF;
      if (hex < 16) {
        buffer.write('0'); // Add leading zero for single-digit hex
      }
      buffer.write(hex.toRadixString(16).toUpperCase()); // Convert to hex and make uppercase
    }
    return buffer.toString();
  }

// Function to read image file and convert to hex string
  Future<String> imageToHexString(String imagePath) async {
    // Load the image file as bytes
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    // Convert bytes to hex string
    return bytes2HexString(Uint8List.fromList(bytes));
  }

  Future<String> localImageToHexString(String assetPath) async {
    try {
      final ByteData byteData = await rootBundle.load(assetPath);
      final Uint8List buffer = byteData.buffer.asUint8List();
      // Convert byte buffer to hex string (implement this function as needed)
      return bytesToHex(buffer);
    } catch (e) {
      print('Error loading asset: $e');
      return '';
    }
  }

// Convert bytes to hex string
  String bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (var byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
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
              _deviceDetails(),
              _transactionSelector(context),
              const SizedBox(height: 5),
              printerEnabled
                    ? Expanded(child:_printDemo(context)):
                      Expanded(child:_responseSelector(context)),
            ],
          ),
        ),
      ),
        floatingActionButton:
        _selectedTransaction == 'SCAN' ? Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isExpanded ? 60 : 0,
                    child: FloatingActionButton(
                      heroTag: "btn1",
                      elevation: 9.0,
                      tooltip: "CANCEL",
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        setState(() {
                          SCAN_TXN_TYPE = STOP_SCAN;
                        });
                        var payload = {
                          "Header": {
                            "ApplicationId": '1001',
                            "MethodId": SCAN_TXN_TYPE,
                            "UserId": "userId",
                            "VersionNo": "1.0"
                          }
                        };
                        String testDataString = jsonEncode(payload);
                        var datascan = await POSManager.doTransaction(testDataString, SCAN_TXN_TYPE);
                        Map<String, dynamic> jsonData = jsonDecode(datascan!);
                        String scannedData = jsonData['Response']['ResponseMsg'];
                        addStatusMessage(scannedData.toUpperCase());
                      },
                      child: const Icon(Icons.cancel),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isExpanded ? 60 : 0,
                    child: FloatingActionButton(
                      heroTag: "btn2",
                      elevation: 9.0,
                      tooltip: "MULTI BARCODE",
                      backgroundColor: Colors.cyanAccent,
                      onPressed: () async {
                        setState(() {
                          SCAN_TXN_TYPE = MULTI_SCAN_CODE_CAMERA;
                        });
                        var payload = {
                          "Header": {
                            "ApplicationId": '1001',
                            "MethodId": SCAN_TXN_TYPE,
                            "UserId": "userId",
                            "VersionNo": "1.0"
                          }
                        };
                        String testDataString = jsonEncode(payload);
                        var datascan = await POSManager.doTransaction(testDataString, SCAN_TXN_TYPE);
                        print(datascan);
                        Map<String, dynamic> jsonData = jsonDecode(datascan!);
                        List<dynamic> scannedDataList = jsonData['Response']['ScannedDataList'];
                        for (var item in scannedDataList) {
                          print('itemValue: ${item['itemValue']}, itemCount: ${item['itemCount']}');
                          addStatusMessage('DATA : ${item['itemValue']} - COUNT : ${item['itemCount']}');
                        }
                      },
                      child: const Icon(Icons.browse_gallery),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isExpanded ? 60 : 0,
                    child: FloatingActionButton(
                      heroTag: "btn3",
                      elevation: 9.0,
                      tooltip: "CAMERA",
                      backgroundColor: Colors.lightGreenAccent,
                      onPressed: () async {
                        setState(() {
                          SCAN_TXN_TYPE = SCAN_CODE_CAMERA;
                        });
                        var payload = {
                          "Header": {
                            "ApplicationId": '1001',
                            "MethodId": SCAN_TXN_TYPE,
                            "UserId": "userId",
                            "VersionNo": "1.0"
                          }
                        };
                        String testDataString = jsonEncode(payload);
                        var datascan = await POSManager.doTransaction(testDataString, SCAN_TXN_TYPE);
                        Map<String, dynamic> jsonData = jsonDecode(datascan!);
                        String scannedData = jsonData['Response']['ScannedData'];
                        addStatusMessage('DATA : $scannedData');
                      },
                      child: const Icon(Icons.camera),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isExpanded ? 60 : 0,
                    child: FloatingActionButton(
                      heroTag: "btn4",
                      elevation: 9.0,
                      tooltip: "BARCODE",
                      backgroundColor: Colors.indigoAccent,
                      onPressed: () async {
                        setState(() {
                          SCAN_TXN_TYPE = SCAN_CODE;
                        });
                        var payload = {
                          "Header": {
                            "ApplicationId": '1001',
                            "MethodId": SCAN_TXN_TYPE,
                            "UserId": "userId",
                            "VersionNo": "1.0"
                          }
                        };
                        String testDataString = jsonEncode(payload);
                        var datascan = await POSManager.doTransaction(testDataString, SCAN_TXN_TYPE);
                        Map<String, dynamic> jsonData = jsonDecode(datascan!);
                        String scannedData = jsonData['Response']['ScannedData'];
                        addStatusMessage('DATA : $scannedData');
                      },
                      child: const Icon(Icons.barcode_reader),
                    ),
                  ),
                  SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: "toggle",
                    elevation: 9.0,
                    tooltip: _isExpanded ? "Collapse" : "Expand",
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Icon(_isExpanded ? Icons.close : Icons.menu),
                  ),
                ],
              ),
            ),
          ],
        ) : Container()
    );
  }
}
