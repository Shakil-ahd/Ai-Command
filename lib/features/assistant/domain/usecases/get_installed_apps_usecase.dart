import '../entities/app_info.dart';
import '../repositories/app_repository.dart';
import '../../../../core/utils/result.dart';

/// Fetches all installed apps from the device.
class GetInstalledAppsUseCase {
  final AppRepository _repository;

  GetInstalledAppsUseCase(this._repository);

  Future<Result<List<AppInfo>>> call({bool includeSystemApps = false}) async {
    try {
      final apps = await _repository.getInstalledApps(
        includeSystemApps: includeSystemApps,
      );
      return Success(apps);
    } catch (e) {
      return Failure('Failed to get installed apps', error: e);
    }
  }
}
