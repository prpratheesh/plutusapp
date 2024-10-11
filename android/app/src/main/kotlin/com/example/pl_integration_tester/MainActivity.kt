package com.example.pl_integration_tester
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import com.pos.poslib.callback.ScanDeviceListener
import com.pos.poslib.model.DeviceDetails
import com.pos.poslib.poslibmanager.PosLibManager
import java.util.concurrent.Executors
import com.pos.poslib.model.ConfigData
import com.pos.poslib.callback.ComEventListener
import com.pos.poslib.callback.TransactionListener
import com.pos.poslib.comm.BluetoothManager
import android.bluetooth.BluetoothAdapter

private const val TAG = "MainActivity"
private const val CHANNEL = "pinelabs_sdk"

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

               // Set up MethodChannel
        val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (binaryMessenger != null) {
            MethodChannel(binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "posLibInitialize" -> {
                            val response = initializePineLabsSDK()
                            result.success(response)
                        }

                        "scanOnlinePOSDevice" -> {
                            scanOnlinePOSDevices(result)
                        }

                        "connectToDevice" -> {
                            val ip = call.argument<String>("ip") ?: ""
                            val port = call.argument<String>("port") ?: ""
                            connectToDevice(ip, port, result)
                        }

                        "getConfiguration" -> {
                            getConfiguration(result)
                        }

                        "setConfiguration" -> {
                            val configDataMap = call.arguments as Map<String, Any>
                            val configData = configDataMap.toConfigData()
                            setConfiguration(configData, result)
                        }

                        "testTCP" -> {
                            val ip = call.argument<String>("ip")
                            val port = call.argument<String>("port")
                            if (ip != null && port != null) {
                                testTCP(ip, port, result) // Pass 'result' to testTCP method
                            } else {
                                result.error(
                                    "INVALID_ARGUMENTS",
                                    "IP and Port must not be null",
                                    null
                                )
                            }
                        }
                        "checkTcpComStatus" -> {
                            val timeInterval = call.argument<Int>("timeInterval") ?: 0
                            checkTcpComStatus(timeInterval, result)
                        }
                        "doTransaction" -> {
                            val paymentRequest = call.argument<String>("paymentRequest")
                            val transactionType = call.argument<Int>("transactionType")
                            if (paymentRequest != null && transactionType != null) {
                                doTransaction(paymentRequest, transactionType, result)
                            } else {
                                result.error(
                                    "INVALID_ARGUMENTS",
                                    "Payment Request and Transaction Type must not be null",
                                    null
                                )
                            }
                        }
                        "scanBTDevice" -> {
                            scanBTDevice(result)
                        }
                        "testBT" -> {
                            val btSsid = call.argument<String>("btSsid")
                            if (btSsid != null) {
                                testBT(btSsid, result)
                            } else {
                                result.error("INVALID_ARGUMENTS", "Bluetooth SSID must not be null", null)
                            }
                        }
                        "checkBtComStatus" -> {
                            val timeInterval = call.argument<Int>("timeInterval") ?: 0
                            checkBtComStatus(timeInterval, result)
                        }
                        else -> {
                            result.notImplemented()
                        }
                    }
                } catch (e: Exception) {
                    result.error("ERROR", "An error occurred: ${e.message}", null)
                }
            }
        } else {
            Log.e(TAG, "BinaryMessenger is null")
        }
    }

    private fun initializePineLabsSDK(): String {
        val success = PosLibManager.getInstance().posLibInitialize(applicationContext)
        return if (success) {
            "POS Lib initialized successfully"
        } else {
            throw Exception("Failed to initialize POS Lib")
        }
    }

    private fun scanOnlinePOSDevices(result: MethodChannel.Result) {
        PosLibManager.getInstance().scanOnlinePOSDevice(object : ScanDeviceListener {
            override fun onSuccess(list: List<DeviceDetails>) {
                val deviceList = list.map { device ->
                    mapOf(
                        "deviceSlNo" to device.deviceSlNo,
                        "deviceId" to device.deviceId,
                        "isBtDevice" to device.isBtDevice,
                        "deviceIp" to device.deviceIp,
                        "devicePort" to device.devicePort
                    )
                }
                Log.d(TAG, "Scanned device list: $deviceList")
                Log.d(TAG, "Result status: ${result.toString()}")
                result.success(mapOf("list" to deviceList))
            }

            override fun onFailure(errorMsg: String, errorCode: Int) {
                Log.e(TAG, "Failed to scan online POS devices: $errorMsg, error code: $errorCode")
                result.error(
                    "FAILURE",
                    "Failed to scan online POS devices: $errorMsg, error code: $errorCode",
                    null
                )
            }
        }, applicationContext)
    }

    private fun connectToDevice(ip: String, port: String, result: MethodChannel.Result) {
        val executorService = Executors.newSingleThreadExecutor()
        executorService.execute {
            val isConnected = PosLibManager.getInstance().testTCP(ip, port)
            runOnUiThread {
                if (isConnected) {
                    result.success("Device Connected")
                } else {
                    result.error("FAILURE", "Failed to Connect", null)
                }
            }
        }
        executorService.shutdown()
        Log.d(TAG, "Exiting connect()")
    }

    private fun testTCP(ip: String, port: String, result: MethodChannel.Result) {
        val executorService = Executors.newSingleThreadExecutor()

        executorService.execute {
            try {
                // Perform the testTCP operation
                val isConnected = PosLibManager.getInstance().testTCP(ip, port)

                // Handle the result on the UI thread
                runOnUiThread {
                    if (isConnected) {
                        result.success("true")
                    } else {
                        result.success("false")
                    }
                }
            } catch (e: Exception) {
                // Handle any exceptions
                runOnUiThread {
                    result.error("TEST_TCP_ERROR", "Failed to execute testTCP: ${e.message}", null)
                }
            } finally {
                // Shutdown the executor service
                executorService.shutdown()
            }
        }
    }

    private fun getConfiguration(result: MethodChannel.Result) {
        val configData = ConfigData()
        val posLibManager = PosLibManager.getInstance()
        val status = posLibManager.getConfiguration(configData)
        if (status == 0) {
            result.success(configData.toMap())
        } else {
            result.error("UNAVAILABLE", "POS Lib not initialized", null)
        }
    }

    private fun setConfiguration(configData: ConfigData, result: MethodChannel.Result) {
        val posLibManager = PosLibManager.getInstance()
        val status = posLibManager.setConfiguration(configData, this)
        if (status == 0) {
            result.success("Configuration set successfully")
        } else {
            result.error("FAILURE", "Failed to set configuration", null)
        }
    }

    private fun scanBTDevice(result: MethodChannel.Result) {
        val scanDeviceListener = object : ScanDeviceListener {
            override fun onSuccess(list: List<DeviceDetails>) {
                val deviceList = list.map { device ->
                    mapOf(
                        "deviceSlNo" to device.deviceSlNo,
                        "deviceId" to device.deviceId,
                        "isBtDevice" to device.isBtDevice,
                        "deviceIp" to device.deviceIp,
                        "devicePort" to device.devicePort,
                        "btDeviceSsid" to device.btDeviceSsid,
                        "btDeviceName" to device.btDeviceName
                    )
                }
                Log.d(TAG, "Scanned Bluetooth device list: $deviceList")
                result.success(mapOf("list" to deviceList))
            }


            override fun onFailure(errorMsg: String, errorCode: Int) {
                Log.e(TAG, "Failed to scan Bluetooth devices: $errorMsg, error code: $errorCode")
                result.error(
                    "FAILURE",
                    "Failed to scan Bluetooth devices: $errorMsg, error code: $errorCode",
                    null
                )
            }
        }
        PosLibManager.getInstance().scanBTDevice(scanDeviceListener, this)
    }

    private fun testBT(btSsid: String, result: MethodChannel.Result) {
        val executorService = Executors.newSingleThreadExecutor()
        executorService.execute {
            try {
                // Perform the testBT operation
                val isConnected = PosLibManager.getInstance().testBT(btSsid)
                runOnUiThread {
                    result.success(isConnected)
                }
            } catch (e: Exception) {
                // Handle any exceptions
                runOnUiThread {
                    result.error("TEST_BT_ERROR", "Failed to execute testBT: ${e.message}", null)
                }
            } finally {
                // Shutdown the executor service
                executorService.shutdown()
            }
        }
    }

    private fun checkBtComStatus(timeInterval: Int, result: MethodChannel.Result) {
        val btComEventListener = object : ComEventListener {
            var hasReplied = false
            override fun onEvent(eventId: Int) {
                if (hasReplied) return
                Log.d(TAG, "Entering checkBtComStatus()")
                Log.i(TAG, "Entering checkBtComStatus on onEvent : $eventId")
                // Send only the eventId back to Dart
                result.success(eventId)
                hasReplied = true
            }
        }
        // Invoke method on native side with callback
        PosLibManager.getInstance().checkBtComStatus(btComEventListener, this, timeInterval)
    }

    // Extension function to convert Map<String, Any> to ConfigData
    private fun Map<String, Any>.toConfigData(): ConfigData {
        return ConfigData().apply {
            tcpIP = this@toConfigData["tcpIP"] as String
            tcpPort = this@toConfigData["tcpPort"] as String
            commPortNumber = this@toConfigData["commPortNumber"] as String
            baudRate = this@toConfigData["baudRate"] as String
            isConnectivityFallBackAllowed = this@toConfigData["isConnectivityFallBackAllowed"] as Boolean
            btSSID = this@toConfigData["btSSID"] as String
            btName = this@toConfigData["btName"] as String
            commP1 = (this@toConfigData["commP1"] as Number).toInt()
            commP2 = (this@toConfigData["commP2"] as Number).toInt()
            commP3 = (this@toConfigData["commP3"] as Number).toInt()
            connectionMode = this@toConfigData["connectionMode"] as String
            logPath = this@toConfigData["logPath"] as String
            isLogsEnabled = this@toConfigData["isLogsEnabled"] as Boolean
            logLevel = (this@toConfigData["logLevel"] as Number).toInt()
            dayToRetainLogs = (this@toConfigData["dayToRetainLogs"] as Number).toInt()
            retryCount = (this@toConfigData["retryCount"] as Number).toInt()
            connectionTimeOut = (this@toConfigData["connectionTimeOut"] as Number).toInt()
            isDemoMode = this@toConfigData["isDemoMode"] as Boolean
            cashierID = this@toConfigData["cashierID"] as String
            cashierName = this@toConfigData["cashierName"] as String
            deviceSlNo = this@toConfigData["deviceSlNo"] as String
            deviceId = this@toConfigData["deviceId"] as String
        }
    }

    // Extension function to convert ConfigData to Map<String, Any>
    private fun ConfigData.toMap(): Map<String, Any> {
        return mapOf(
            "tcpIP" to tcpIP,
            "tcpPort" to tcpPort,
            "commPortNumber" to commPortNumber,
            "baudRate" to baudRate,
            "isConnectivityFallBackAllowed" to isConnectivityFallBackAllowed,
            "btSSID" to btSSID,
            "btName" to btName,
            "commP1" to commP1,
            "commP2" to commP2,
            "commP3" to commP3,
            "connectionMode" to connectionMode,
            "logPath" to logPath,
            "isLogsEnabled" to isLogsEnabled,
            "logLevel" to logLevel,
            "dayToRetainLogs" to dayToRetainLogs,
            "retryCount" to retryCount,
            "connectionTimeOut" to connectionTimeOut,
            "isDemoMode" to isDemoMode,
            "cashierID" to cashierID,
            "cashierName" to cashierName,
            "deviceSlNo" to deviceSlNo,
            "deviceId" to deviceId
        )
    }

    private fun checkTcpComStatus(timeInterval: Int, result: MethodChannel.Result) {
        val tcpComEventListener = object : ComEventListener {
            var hasReplied = false
            override fun onEvent(eventId: Int) {
                if (hasReplied) return
                Log.d(TAG, "Entering tcpComEventListener()")
                Log.i(TAG, "Entering tcpComEventListener on onEvent : $eventId")
                // Send only the eventId back to Dart
                result.success(eventId)
                hasReplied = true
            }
        }
        // Invoke method on native side with callback
        PosLibManager.getInstance().checkTcpComStatus(tcpComEventListener, this, timeInterval)
    }

    private fun doTransaction(paymentRequest: String, transactionType: Int, result: MethodChannel.Result) {
        Handler(Looper.getMainLooper()).postDelayed({
            val executor = Executors.newSingleThreadExecutor()
            executor.execute {
                PosLibManager.getInstance().doTransaction(this, paymentRequest, transactionType, object : TransactionListener {
                    override fun onSuccess(paymentResponse: String) {
                        runOnUiThread {
                            result.success(paymentResponse)
                        }
                    }

                    override fun onFailure(errorMsg: String, errorCode: Int) {
                        runOnUiThread {
                            result.error("TRANSACTION_FAILURE", errorMsg, errorCode)
                        }
                    }
                })
                executor.shutdown()
            }
        }, 100)
    }
}

