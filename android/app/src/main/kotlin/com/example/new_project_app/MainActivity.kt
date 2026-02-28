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
                            val bluetoothAdapter: android.bluetooth.BluetoothAdapter? = android.bluetooth.BluetoothAdapter.getDefaultAdapter()
                            if (enable) {
                                bluetoothAdapter?.enable()
                            } else {
                                bluetoothAdapter?.disable()
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    "toggleWifi" -> {
                        val enable = call.argument<Boolean>("enable") ?: true
                        try {
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                                val panelIntent = Intent(android.provider.Settings.Panel.ACTION_WIFI)
                                panelIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(panelIntent)
                                result.success(true)
                            } else {
                                val wifiManager = applicationContext.getSystemService(android.content.Context.WIFI_SERVICE) as android.net.wifi.WifiManager
                                wifiManager.isWifiEnabled = enable
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
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
