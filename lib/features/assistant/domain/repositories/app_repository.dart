import '../entities/app_info.dart';

/// Contract for installed-app data source.
abstract class AppRepository {
  /// Returns all installed (non-system) apps on the device.
  Future<List<AppInfo>> getInstalledApps({bool includeSystemApps = false});

  /// Launches an app by its package name.
  /// Returns true on success.
  Future<bool> launchApp(String packageName);
}
