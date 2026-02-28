import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/repositories/context_repository.dart';

/// Implements [ContextRepository] using SharedPreferences for persistence.
class ContextRepositoryImpl implements ContextRepository {
  static const _lastAppKey = 'last_opened_app';
  static const _lastQueryKey = 'last_search_query';

  final SharedPreferences _prefs;

  ContextRepositoryImpl(this._prefs);

  @override
  Future<AppInfo?> getLastOpenedApp() async {
    final json = _prefs.getString(_lastAppKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return AppInfo(
        name: map['name'] as String,
        packageName: map['packageName'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLastOpenedApp(AppInfo app) async {
    final json = jsonEncode({
      'name': app.name,
      'packageName': app.packageName,
    });
    await _prefs.setString(_lastAppKey, json);
  }

  @override
  Future<String?> getLastSearchQuery() async {
    return _prefs.getString(_lastQueryKey);
  }

  @override
  Future<void> saveLastSearchQuery(String query) async {
    await _prefs.setString(_lastQueryKey, query);
  }
}
