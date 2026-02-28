import '../../domain/entities/app_info.dart';
import '../../domain/repositories/app_repository.dart';
import '../../platform/android_app_launcher.dart';

/// Implements [AppRepository] using the native Android MethodChannel.
class AppRepositoryImpl implements AppRepository {
  final AndroidAppLauncher _launcher;

  AppRepositoryImpl(this._launcher);

  @override
  Future<List<AppInfo>> getInstalledApps({bool includeSystemApps = false}) {
    return _launcher.getInstalledApps(includeSystemApps: includeSystemApps);
  }

  @override
  Future<bool> launchApp(String packageName) {
    return _launcher.launchApp(packageName);
  }
}
