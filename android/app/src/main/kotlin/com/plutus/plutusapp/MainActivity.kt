package com.plutus.plutusapp

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "PLUTUS-API"
    private val PLUTUS_SMART_ACTION = "com.pinelabs.masterapp.SERVER"
    private val PLUTUS_SMART_PACKAGE = "com.pinelabs.masterapp"
    private var isServiceBound = false
    private var mService: IBinder? = null
    private var pendingResult: MethodChannel.Result? = null // Holds the result for returning data to Flutter

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            Log.d("MainActivity", "Service connected: $name")
            Toast.makeText(this@MainActivity, "Service connected", Toast.LENGTH_SHORT).show()
            mService = service
            isServiceBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.d("MainActivity", "Service disconnected: $name")
            Toast.makeText(this@MainActivity, "Service disconnected", Toast.LENGTH_SHORT).show()
            mService = null
            isServiceBound = false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "bindToService" -> bindToService(result)
                "startTransaction" -> {
                    val transactionData = call.argument<String>("transactionData")
                    if (transactionData != null && isServiceBound) {
                        startTransaction(transactionData, result)
                    } else {
                        result.error("SERVICE_NOT_BOUND", "Service not bound or missing transaction data", null)
                    }
                }
                "startPrintJob" -> {
                    val printData = call.argument<String>("printData") // Change to Map
                    if (printData != null && isServiceBound) {
                        startPrintJob(printData, result)
                    } else {
                        result.error("SERVICE_NOT_BOUND", "Service not bound or missing print data", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun bindToService(result: MethodChannel.Result) {
        try {
            val intent = Intent().apply {
                action = PLUTUS_SMART_ACTION
                setPackage(PLUTUS_SMART_PACKAGE)
            }
            val success = bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
            if (success) {
                Log.d("MainActivity", "Binding to service initiated")
                result.success("BINDING SUCCESS.")
            } else {
                Log.e("MainActivity", "Failed to bind to service")
                result.error("BINDING_FAILED", "Failed to initiate service binding", null)
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error binding to service", e)
            result.error("BINDING_ERROR", e.localizedMessage, null)
        }
    }

    private fun startTransaction(transactionData: String, result: MethodChannel.Result) {
        try {
            Log.d("MainActivity", "Service bound, starting transaction: $transactionData")
            pendingResult = result // Store the result to send back later

            // Prepare the intent for the external service interaction
            val intent = Intent("com.pinelabs.masterapp.HYBRID_REQUEST")
            intent.setPackage(PLUTUS_SMART_PACKAGE)
            intent.putExtra("REQUEST_DATA", transactionData)
            intent.putExtra("packageName", "com.plutus.plutusapp") // Replace with your app's package name
            // Start the activity for a result
            startActivityForResult(intent, 1001)
        } catch (e: Exception) {
            Log.e("MainActivity", "Error starting transaction", e)
            result.error("TRANSACTION_ERROR", e.localizedMessage, null)
        }
    }

    private fun startPrintJob(printData: String, result: MethodChannel.Result) {
        try {
            Log.d("MainActivity", "Service bound, starting transaction: $printData")
            pendingResult = result // Store the result to send back later
            // Prepare the intent for the external service interaction
            val intent = Intent("com.pinelabs.masterapp.HYBRID_REQUEST")
            intent.setPackage(PLUTUS_SMART_PACKAGE)
            intent.putExtra("REQUEST_DATA", printData)
            intent.putExtra("packageName", "com.plutus.plutusapp") // Replace with your app's package name
            // Start the activity for a result
            startActivityForResult(intent, 1002)
        } catch (e: Exception) {
            Log.e("MainActivity", "Error starting print job", e)
            result.error("PRINT_JOB_ERROR", e.localizedMessage, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1001) {
            if (pendingResult == null) {
                Log.e("MainActivity", "No pending result to return transaction data")
                return
            }

            try {
                if (resultCode == RESULT_OK && data != null) {
                    val responseData = data.getStringExtra("RESPONSE_DATA") // Adjust key to match your API
                    Log.d("MainActivity", "Transaction result: $responseData")

                    // Send the result back to Flutter
                    pendingResult?.success(responseData)
                } else {
                    Log.e("MainActivity", "Transaction failed or canceled")
                    pendingResult?.error(
                        "TRANSACTION_FAILED",
                        "Transaction failed or canceled by user",
                        null
                    )
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Error handling transaction result", e)
                pendingResult?.error("TRANSACTION_ERROR", e.localizedMessage, null)
            } finally {
                pendingResult = null // Clear the pending result to avoid memory leaks
            }
        }
        if (requestCode == 1002) {  // Match the print job request code
            if (pendingResult == null) {
                Log.e("MainActivity", "No pending result to return print job response")
                return
            }

            try {
                if (resultCode == RESULT_OK && data != null) {
                    val responseData = data.getStringExtra("RESPONSE_DATA") // Adjust key to match your API
                    Log.d("MainActivity", "Transaction result: $responseData")

                    // Send the result back to Flutter
                    pendingResult?.success(responseData)
                } else {
                    Log.e("MainActivity", "Printing failed or canceled")
                    pendingResult?.error(
                        "PRINTING_FAILED",
                        "PRINTING failed or canceled by user",
                        null
                    )
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "Error handling printing result", e)
                pendingResult?.error("PRINTING_ERROR", e.localizedMessage, null)
            } finally {
                pendingResult = null // Clear the pending result to avoid memory leaks
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isServiceBound) {
            unbindService(serviceConnection)
            isServiceBound = false
        }
    }
}
