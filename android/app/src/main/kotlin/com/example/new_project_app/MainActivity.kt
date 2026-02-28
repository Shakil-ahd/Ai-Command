package com.example.new_project_app

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity — bridges Flutter ↔ Android for installed-app operations.
 *
 * Channel: "com.assistant/app_launcher"
 * Methods:
 *   - getInstalledApps(includeSystemApps: Boolean) → List<Map>
 *   - launchApp(packageName: String) → Boolean
 */
class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.assistant/app_launcher"
    private val STATE_CHANNEL = "com.assistant/call_state"
    private var callStateChannel: MethodChannel? = null
    private var wasOffHook = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        val includeSystem = call.argument<Boolean>("includeSystemApps") ?: false
                        try {
                            val apps = getInstalledApps(includeSystem)
                            result.success(apps)
                        } catch (e: Exception) {
                            result.error("APPS_ERROR", "Failed to get apps: ${e.message}", null)
                        }
                    }

                    "launchApp" -> {
                        val packageName = call.argument<String>("packageName")
                        if (packageName == null) {
                            result.error("NULL_PKG", "packageName is null", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val launched = launchApp(packageName)
                            result.success(launched)
                        } catch (e: Exception) {
                            result.error("LAUNCH_ERROR", "Failed to launch: ${e.message}", null)
                        }
                    }

                    "toggleBluetooth" -> {
                        val enable = call.argument<Boolean>("enable") ?: true
                        try {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                                // Android 13+ requires system panel — open Bluetooth settings panel
                                val panelIntent = Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS)
                                panelIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(panelIntent)
                                result.success(true)
                            } else {
                                val bluetoothAdapter = android.bluetooth.BluetoothAdapter.getDefaultAdapter()
                                if (enable) {
                                    @Suppress("DEPRECATION")
                                    bluetoothAdapter?.enable()
                                } else {
                                    @Suppress("DEPRECATION")
                                    bluetoothAdapter?.disable()
                                }
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "toggleWifi" -> {
                        val enable = call.argument<Boolean>("enable") ?: true
                        try {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                                // Android 10+ requires user interaction via Settings Panel
                                val panelIntent = Intent(android.provider.Settings.Panel.ACTION_WIFI)
                                panelIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(panelIntent)
                                result.success(true)
                            } else {
                                @Suppress("DEPRECATION")
                                val wifiManager = applicationContext.getSystemService(android.content.Context.WIFI_SERVICE) as android.net.wifi.WifiManager
                                @Suppress("DEPRECATION")
                                wifiManager.isWifiEnabled = enable
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "directCall" -> {
                        val number = call.argument<String>("phoneNumber")
                        if (number != null) {
                            try {
                                val intent = Intent(Intent.ACTION_CALL)
                                intent.data = Uri.parse("tel:${number.replace("[^\\d+]".toRegex(), "")}")
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                if (checkSelfPermission(android.Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
                                    registerCallStateListener()
                                    startActivity(intent)
                                    result.success(true)
                                } else {
                                    result.error("PERMISSION_DENIED", "CALL_PHONE permission not granted", null)
                                }
                            } catch (e: Exception) {
                                result.error("CALL_ERROR", e.message, null)
                            }
                        } else {
                            result.error("NULL_NUMBER", "Phone number is null", null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }

        callStateChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STATE_CHANNEL)

        // Try to register initially if we already have permission.
        registerCallStateListener()
    }

    private var hasRegisteredCallListener = false

    // Maintain strong references to prevent garbage collection of the listeners
    private var callReceiver: android.content.BroadcastReceiver? = null

    private var lastIncomingNumber: String? = null

    private fun registerCallStateListener() {
        if (hasRegisteredCallListener) return
        try {
            if (checkSelfPermission(android.Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED &&
                checkSelfPermission(android.Manifest.permission.READ_CALL_LOG) == PackageManager.PERMISSION_GRANTED) {
                
                val filter = android.content.IntentFilter(android.telephony.TelephonyManager.ACTION_PHONE_STATE_CHANGED)
                callReceiver = object : android.content.BroadcastReceiver() {
                    override fun onReceive(context: android.content.Context, intent: Intent) {
                        val stateStr = intent.getStringExtra(android.telephony.TelephonyManager.EXTRA_STATE)
                        if (stateStr == android.telephony.TelephonyManager.EXTRA_STATE_RINGING) {
                            wasOffHook = true
                            val number = intent.getStringExtra(android.telephony.TelephonyManager.EXTRA_INCOMING_NUMBER)
                            
                            // Only act if we actually have a number and it's not a duplicate
                            if (!number.isNullOrEmpty() && number != lastIncomingNumber) {
                                lastIncomingNumber = number
                                val name = getContactName(number)
                                runOnUiThread {
                                    callStateChannel?.invokeMethod("onIncomingCall", name)
                                }
                            } else if (number.isNullOrEmpty() && lastIncomingNumber == null) {
                                // Sometimes the first broadcast has a null number, wait a bit
                                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                                    if (lastIncomingNumber == null) {
                                        lastIncomingNumber = "hidden"
                                        callStateChannel?.invokeMethod("onIncomingCall", "Unknown")
                                    }
                                }, 1000)
                            }
                        } else if (stateStr == android.telephony.TelephonyManager.EXTRA_STATE_OFFHOOK) {
                            wasOffHook = true
                        } else if (stateStr == android.telephony.TelephonyManager.EXTRA_STATE_IDLE) {
                            lastIncomingNumber = null
                            if (wasOffHook) {
                                wasOffHook = false
                                runOnUiThread {
                                    callStateChannel?.invokeMethod("onCallEnded", null)
                                }
                            }
                        }
                    }
                }
                registerReceiver(callReceiver, filter)
                hasRegisteredCallListener = true
            } else {
                requestPermissions(
                    arrayOf(
                        android.Manifest.permission.READ_PHONE_STATE,
                        android.Manifest.permission.READ_CALL_LOG,
                        android.Manifest.permission.READ_CONTACTS
                    ), 101
                )
            }
        } catch (e: Exception) {
            // Ignore SecurityException if permission is not granted
        }
    }

    private fun getContactName(phoneNumber: String?): String {
        if (phoneNumber.isNullOrEmpty()) return "Unknown"
        var contactName = "Unknown"
        try {
            if (checkSelfPermission(android.Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED) {
                val uri = Uri.withAppendedPath(android.provider.ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber))
                val projection = arrayOf(android.provider.ContactsContract.PhoneLookup.DISPLAY_NAME)
                val cursor = contentResolver.query(uri, projection, null, null, null)
                if (cursor != null) {
                    if (cursor.moveToFirst()) {
                        contactName = cursor.getString(0)
                    }
                    cursor.close()
                }
            }
        } catch (e: Exception) {
            // Ignored
        }
        return contactName
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 101 && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            registerCallStateListener()
        }
    }

    /**
     * Returns all installed applications as a list of Maps containing:
     * - name: String
     * - packageName: String
     * - isSystemApp: Boolean
     */
    private fun getInstalledApps(includeSystemApps: Boolean): List<Map<String, Any>> {
        val pm = packageManager
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            PackageManager.GET_META_DATA.toLong()
        } else {
            PackageManager.GET_META_DATA.toLong()
        }

        val installedPackages = pm.getInstalledApplications(PackageManager.GET_META_DATA)

        return installedPackages
            .filter { appInfo ->
                // Filter out our own app
                if (appInfo.packageName == packageName) return@filter false

                val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val isUpdatedSystemApp = (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0

                // Include system apps if requested; always include updated system apps
                includeSystemApps || !isSystemApp || isUpdatedSystemApp
            }
            .filter { appInfo ->
                // Only include apps that have a launcher intent (actual launchable apps)
                pm.getLaunchIntentForPackage(appInfo.packageName) != null
            }
            .mapNotNull { appInfo ->
                try {
                    val name = pm.getApplicationLabel(appInfo).toString()
                    val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0

                    mapOf(
                        "name" to name,
                        "packageName" to appInfo.packageName,
                        "isSystemApp" to isSystemApp
                    )
                } catch (e: Exception) {
                    null // Skip apps that throw errors
                }
            }
            .sortedBy { it["name"] as String }
    }

    /**
     * Launches an app by package name.
     * Returns true if successfully launched, false otherwise.
     */
    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                true
            } else {
                // Fallback: try to open via Play Store
                val storeIntent = Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("market://details?id=$packageName")
                )
                storeIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(storeIntent)
                false
            }
        } catch (e: Exception) {
            false
        }
    }
}
