import '../entities/app_info.dart';

abstract class AppRepository {
  Future<List<AppInfo>> getInstalledApps({bool includeSystemApps = false});
  Future<bool> launchApp(String packageName);
}
