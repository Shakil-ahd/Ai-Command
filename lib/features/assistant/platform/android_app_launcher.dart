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

  /// Launches an app by its package name.
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
}
