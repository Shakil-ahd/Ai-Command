import '../entities/app_info.dart';
import '../repositories/app_repository.dart';
import '../../services/fuzzy_matcher_service.dart';
import '../../../../core/utils/result.dart';

/// Launches an app by name using fuzzy matching against installed apps.
class LaunchAppUseCase {
  final AppRepository _appRepository;
  final FuzzyMatcherService _fuzzyMatcher;

  LaunchAppUseCase(this._appRepository, this._fuzzyMatcher);

  /// [appName] is the human-supplied name (may be misspelled).
  /// [installedApps] is the cached list; if null, we fetch fresh.
  Future<Result<AppInfo>> call({
    required String appName,
    List<AppInfo>? installedApps,
  }) async {
    try {
      final apps = installedApps ?? await _appRepository.getInstalledApps();

      if (apps.isEmpty) {
        return const Failure('No apps found on device');
      }

      // Find best match using fuzzy matching
      final match = _fuzzyMatcher.findBestAppMatch(appName, apps);

      if (match == null) {
        return Failure('"$appName" is not installed on your device.');
      }

      final launched = await _appRepository.launchApp(match.packageName);
      if (!launched) {
        return Failure('Could not open ${match.name}. Please try again.');
      }

      return Success(match);
    } catch (e) {
      return Failure('Error launching app: $e', error: e);
    }
  }
}
