import 'package:flutter/services.dart';
import '../domain/entities/app_info.dart';

/// Communicates with the native Android side via a MethodChannel
/// to query installed apps and launch them by package name.
///
/// The corresponding Kotlin handler is in MainActivity.kt.
class AndroidAppLauncher {
  static const _channel = MethodChannel('com.assistant/app_launcher');

  /// Returns a list of all installed (non-system) apps.
  Future<List<AppInfo>> getInstalledApps(
      {bool includeSystemApps = false}) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getInstalledApps',
        {'includeSystemApps': includeSystemApps},
      );

      return result
          .cast<Map<dynamic, dynamic>>()
          .map((app) => AppInfo(
                name: app['name'] as String? ?? '',
                packageName: app['packageName'] as String? ?? '',
                isSystemApp: app['isSystemApp'] as bool? ?? false,
              ))
          .where((app) => app.name.isNotEmpty && app.packageName.isNotEmpty)
          .toList();
    } on PlatformException catch (e) {
      // Log and return empty list — app continues gracefully
      print('[AndroidAppLauncher] getInstalledApps error: ${e.message}');
      return [];
    }
  }

  Future<bool> launchApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod(
        'launchApp',
        {'packageName': packageName},
      );
      return result;
    } on PlatformException catch (e) {
      print('[AndroidAppLauncher] launchApp error: ${e.message}');
      return false;
    }
  }

  Future<bool> toggleBluetooth(bool enable) async {
    try {
      return await _channel.invokeMethod('toggleBluetooth', {'enable': enable});
    } catch (e) {
      print('[AndroidAppLauncher] toggleBluetooth e: $e');
      return false;
    }
  }

  Future<bool> toggleWifi(bool enable) async {
    try {
      return await _channel.invokeMethod('toggleWifi', {'enable': enable});
    } catch (e) {
      print('[AndroidAppLauncher] toggleWifi e: $e');
      return false;
    }
  }

  Future<bool> directCall(String phoneNumber) async {
    try {
      return await _channel
          .invokeMethod('directCall', {'phoneNumber': phoneNumber});
    } catch (e) {
      print('[AndroidAppLauncher] directCall error: $e');
      return false;
    }
  }
}
