import '../entities/app_info.dart';

/// Stores and retrieves context memory (last opened app, last query, etc.).
abstract class ContextRepository {
  /// Returns the last successfully launched app.
  Future<AppInfo?> getLastOpenedApp();

  /// Persists the last launched app.
  Future<void> saveLastOpenedApp(AppInfo app);

  /// Returns the last search query.
  Future<String?> getLastSearchQuery();

  /// Persists the last search query.
  Future<void> saveLastSearchQuery(String query);
}
