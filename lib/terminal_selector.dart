import 'dart:convert';
import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pl_integration_tester/terminal_functions.dart';
import 'dart:async';
import 'package:pl_integration_tester/terminal_routines.dart';
import 'package:pl_integration_tester/transaction_screen.dart';

import 'log_control.dart';

class TerminalSelect extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TerminalSelect> with SingleTickerProviderStateMixin {
  late List<dynamic> _posDevices = [];
  late List<int> _selectedIndices = [];
  int? _selectedIndex;
  late AnimationController _controller;
  ValueNotifier<bool> isSpinning = ValueNotifier<bool>(false);
  set posDevices(List<dynamic>? value) {
    setState(() {
      _posDevices = value!;
    });
  }

  List<dynamic>? get posDevices => _posDevices;
  String _selectedInterface = "TCP";
  String status = 'Please Wait';
  LogControl logger = LogControl();
  DeviceDetails? device;
  ConfigData? configData;
  bool isBT = false;
  bool isTCP = false;
  bool isApp = false;
  bool isTerminalConnected = false;

  @override
  void initState() {
    super.initState();
    ansiColorDisabled = false;
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    isSpinning.addListener(() {
      if (isSpinning.value) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _title() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      // height: MediaQuery.of(context).size.height / 18,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'I',
            style: GoogleFonts.montserrat(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: 35,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            children: const [
              TextSpan(
                text: 'ntegration ',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 25,
                    fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: 'T',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.normal),
              ),
              TextSpan(
                text: 'ester',
                style: TextStyle(color: Colors.black87, fontSize: 25),
              ),
            ]),
      ),
    );
  }

  Widget _scanButton() {
    bool devicesFound = false; // Flag to track if devices are found
    return InkWell(
      onTap: () async {
        setState(() {
          posDevices = []; // Clear the list initially
          isSpinning.value = true;
          isTerminalConnected = false;
        });
        Future.delayed(const Duration(seconds: 45), () {
          if (!devicesFound) {
            setState(() {
              posDevices = []; // Clear the list
              isSpinning.value = false;
            });
            SnackBarUtil.showCustomSnackBar(
                context, 'No devices found within 45 seconds');
          }
        });
        var data;
        if (_selectedInterface == 'TCP') {
          setState(() {
            isTCP = true;
            isBT = false;
            isApp = false;
          });
          data = await POSManager.scanOnlinePOSDevices();
          logger.logInfo('Scanning Started for TCP');
        } else if (_selectedInterface == 'BLE') {
          setState(() {
            isTCP = false;
            isBT = true;
            isApp = false;
          });
          data = await POSManager.scanBTDevices();
          logger.logInfo('Scanning Started for BLE');
        }
        if (data != null) {
          logger.logInfo('Scanning Finished with Device Discovery Success.');
          setState(() {
            posDevices = data!;
            devicesFound =
                true; // Set flag to true indicating devices are found
            isSpinning.value = false;
          });
        }
      },
      onDoubleTap: () async {},
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
          color: Colors.black,
          border: Border.all(
            color: Colors.white, // White color border
            width: 1, // Border width
          ),
        ),
        child: const Text(
          'Scan Terminal',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _terminalShow() {
    return ValueListenableBuilder<bool>(
      valueListenable: isSpinning,
      builder: (context, spinning, child) {
        return InkWell(
          onTap: () {
            // Handle container tap if needed
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white),
            ),
            child: posDevices != null && posDevices!.isEmpty
                ? Center(
                    child: spinning
                        ? _spinner() // Show the spinner when scanning
                        : const Text(
                            'No Devices Found. Initiate Terminal Scan.',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                  )
                : SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio:
                            1.3, // Adjust the aspect ratio as needed
                      ),
                      itemCount: posDevices!.length,
                      itemBuilder: (context, index) {
                        device = posDevices![index];
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _selectedIndex = index;
                            });
                            configData = ConfigData(
                              tcpIP: device!.deviceIp.toString(),
                              tcpPort: device!.devicePort.toString(),
                              commPortNumber: '1',
                              baudRate: '9600',
                              isConnectivityFallBackAllowed: true,
                              btSSID: device!.btDeviceSsid.toString(),
                              btName: device!.btDeviceName.toString(),
                              commP1: 1,
                              commP2: 2,
                              commP3: 3,
                              connectionMode: 'TCPIP',
                              logPath: 'logs/PosLib/log',
                              isLogsEnabled: true,
                              logLevel: 0,
                              dayToRetainLogs: 2,
                              retryCount: 3,
                              connectionTimeOut: 120,
                              isDemoMode: false,
                              cashierID: 'PR',
                              cashierName: 'PR',
                              deviceSlNo: device!.deviceSlNo.toString(),
                              deviceId: device!.deviceId.toString(),
                            );
                            if (_selectedInterface == 'BLE') {
                              configData!.commP1 = 2;
                              configData!.commP2 = 1;
                              configData!.commP3 = 3;
                              configData!.connectionMode = 'BT';
                            } else if (_selectedInterface == 'TCP') {
                              configData!.commP1 = 1;
                              configData!.commP2 = 2;
                              configData!.commP3 = 3;
                              configData!.connectionMode = 'TCPIP';
                            } else {
                              configData!.commP1 = 3;
                              configData!.commP2 = 1;
                              configData!.commP3 = 2;
                              configData!.connectionMode = 'App2App';
                            }
                            SnackBarUtil.showCustomSnackBar(
                                context, 'SETTING CONFIG DATA');
                            logger.logInfo('Entering Set Configuration');
                            var setConfig =
                                await POSManager.setConfig(configData!);
                            SnackBarUtil.showCustomSnackBar(
                                context, '${setConfig?.toUpperCase()}');
                            logger.logInfo('Set Config Completed: $setConfig');
                            logger.logInfo('Entering Get Configuration');
                            var getConfig = await POSManager.getConfig();
                            logger.logInfo('Get Config Completed: $getConfig');
                            if (isTCP) {
                              logger.logInfo('Entering Test TCP');
                              SnackBarUtil.showCustomSnackBar(context,
                                  'TESTING TCPIP -> ${device!.deviceIp}');
                              var terminalStatusIp = await POSManager.testTCP(
                                  device!.deviceIp, device!.devicePort);
                              logger.logInfo(
                                  'Test TCP Completed: $terminalStatusIp');
                              if (terminalStatusIp == 'true') {
                                setState(() {
                                  SnackBarUtil.showCustomSnackBar(
                                      context, 'TCPIP CONNECTION SUCCESS');
                                  isTerminalConnected = true;
                                });
                              } else {
                                setState(() {
                                  SnackBarUtil.showCustomSnackBar(
                                      context, 'TCPIP CONNECTION FAILURE');
                                  isTerminalConnected = false;
                                });
                              }
                            } else if (isBT) {
                              logger.logInfo('Entering Test BT');
                              SnackBarUtil.showCustomSnackBar(context,
                                  'TESTING BLE -> ${device!.btDeviceSsid}');
                              bool? terminalStatusBt =
                                  await POSManager.testBT(device!.btDeviceSsid);
                              logger.logInfo(
                                  'Test BT Completed: $terminalStatusBt');
                              if (terminalStatusBt == true) {
                                setState(() {
                                  SnackBarUtil.showCustomSnackBar(
                                      context, 'BLE CONNECTION SUCCESS');
                                  isTerminalConnected = true;
                                });
                              } else {
                                setState(() {
                                  SnackBarUtil.showCustomSnackBar(
                                      context, 'BLE CONNECTION FAILURE');
                                  isTerminalConnected = false;
                                });
                              }
                            }
                          },
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: _selectedIndex == index
                                ? Colors.green
                                : Colors.white,
                            child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: isTCP
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ID: ${device!.deviceId}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'SL: ${device!.deviceSlNo}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'IP: ${device!.deviceIp}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'PORT: ${device!.devicePort}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          // Add more details here if needed
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ID: ${device!.deviceId}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'SL: ${device!.deviceSlNo}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'NAME: ${device!.btDeviceName}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 5.0),
                                          Text(
                                            'SSID: ${device!.btDeviceSsid}',
                                            style: const TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          // Add more details here if needed
                                        ],
                                      )),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _spinner() {
    return Center(
      child: ValueListenableBuilder<bool>(
        valueListenable: isSpinning,
        builder: (context, spinning, child) {
          return AnimatedBuilder(
            animation: _controller,
            child: Container(
              width: 50.0,
              height: 50.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    25.0), // Half of the width/height to make it circular
                child: Image.asset(
                    'assets/spinner.png'), // Replace with your own asset
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              return Transform.rotate(
                angle: _controller.value * 2.0 * 3.141592653589793,
                child: child,
              );
            },
          );
        },
      ),
    );
  }

  Widget _interfaceSelect() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text("METHOD",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              _buildRadioButton("BLE"),
              _buildRadioButton("TCP"),
              _buildRadioButton("APP"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                "TEST",
                _testButtonPressed,
                Colors.black,
                isTerminalConnected,
              ),
              _buildButton(
                "TRANSACTIONS",
                _saveButtonPressed,
                Colors.black,
                isTerminalConnected,
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedInterface,
          activeColor: Colors.white, // Change radio button color here
          onChanged: (String? newValue) {
            setState(() {
              isSpinning.value = false;
              _posDevices = [];
              _selectedInterface = newValue!;
              SnackBarUtil.showCustomSnackBar(
                  context, '$_selectedInterface selected');
              if (newValue == 'APP') {
                isTerminalConnected = true;
              } else {
                isTerminalConnected = false;
              }
            });
          },
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold), // Change text color here
        ),
      ],
    );
  }

  Widget _buildButton(
      String label, VoidCallback onPressed, Color color, bool isEnabled) {
    return SizedBox(
      width: 150, // Set a fixed width or adjust as needed
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Change button background color here
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8), // Adjust button border radius
            side: const BorderSide(
              color: Colors.white, // White color border
              width: 1, // Border width
            ),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: 16), // Adjust vertical padding
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  void _testButtonPressed() async {
    if (isTCP) {
      logger.logInfo('Entering Check TCPCOM STATUS');
      SnackBarUtil.showCustomSnackBar(context, 'Entering Check TCPCOM STATUS');
      int? eventId = await POSManager.checkTcpComStatus(1);
      switch (eventId) {
        case 3000:
          SnackBarUtil.showCustomSnackBar(
              context, 'TCP Connected and Payment app is Down');
          break;
        case 1000:
          SnackBarUtil.showCustomSnackBar(
              context, 'TCP Connected and Payment app is Up');
          break;
        case 1001:
        case 1002:
        case 1003:
          SnackBarUtil.showCustomSnackBar(context, 'TCP Disconnected');
          break;
        default:
          SnackBarUtil.showCustomSnackBar(context, 'Unknown Event');
      }
      logger.logInfo('Event ID received: $eventId');
    } else if (isBT) {
      logger.logInfo('Entering Check BTCOM STATUS');
      SnackBarUtil.showCustomSnackBar(context, 'Entering Check BTCOM STATUS');
      int? eventId = await POSManager.checkBtComStatus(1);
      switch (eventId) {
        case 3000:
          SnackBarUtil.showCustomSnackBar(
              context, 'BT Connected and Payment app is Down');
          break;
        case 2000:
          SnackBarUtil.showCustomSnackBar(
              context, 'BT Connected and Payment app is Up');
          break;
        case 2001:
        case 2002:
          SnackBarUtil.showCustomSnackBar(context, 'BT Disconnected');
          break;
        default:
          SnackBarUtil.showCustomSnackBar(context, 'Unknown Event');
      }
      logger.logInfo('Event ID received: $eventId');
    }
  }

  void _saveButtonPressed() async {
    if (_selectedInterface != 'APP') {
      if (device != null && configData != null) {
        logger.logSuccess('Configuration Saved. Routing to TXN Page.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TerminalFunctions(device: device!, configData: configData!),
          ),
        );
      } else {
        logger.logError('Select device and Proceed.');
        SnackBarUtil.showCustomSnackBar(
            context, 'Select any device and Proceed.');
      }
    } else {
      configData = ConfigData(
        tcpIP: 'NA',
        tcpPort: 'NA',
        commPortNumber: '1',
        baudRate: '9600',
        isConnectivityFallBackAllowed: true,
        btSSID: 'NA',
        btName: 'NA',
        commP1: 3,
        commP2: 1,
        commP3: 2,
        connectionMode: 'App2App',
        logPath: 'logs/PosLib/log',
        isLogsEnabled: true,
        logLevel: 0,
        dayToRetainLogs: 2,
        retryCount: 3,
        connectionTimeOut: 120,
        isDemoMode: false,
        cashierID: 'PR',
        cashierName: 'PR',
        deviceSlNo: 'NA',
        deviceId: 'NA',
      );
      SnackBarUtil.showCustomSnackBar(context, 'SETTING CONFIG DATA');
      logger.logInfo('Entering Set Configuration');
      var setConfig = await POSManager.setConfig(configData!);
      SnackBarUtil.showCustomSnackBar(
          context, '${setConfig?.toUpperCase()}');
      logger.logInfo('Set Config Completed: $setConfig');
      logger.logInfo('Entering Get Configuration');
      var getConfig = await POSManager.getConfig();
      logger.logInfo('Get Config Completed: $getConfig ');
      logger.logSuccess('Configuration Saved. Routing to TXN Page. ');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TerminalFunctions(device: null, configData: null),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _title(),
                const SizedBox(
                  height: 10,
                ),
                _interfaceSelect(),
                const SizedBox(
                  height: 5,
                ),
                _terminalShow(),
                const SizedBox(
                  height: 20,
                ),
                _scanButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
