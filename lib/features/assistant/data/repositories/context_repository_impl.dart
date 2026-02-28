import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/context_repository.dart';

class ContextRepositoryImpl implements ContextRepository {
  final SharedPreferences prefs;

  ContextRepositoryImpl(this.prefs);

  static const _lastAppKey = 'last_opened_app';
  static const _lastAppPackageKey = 'last_opened_app_package';
  static const _lastSearchKey = 'last_search_query';
  static const _chatMessagesKey = 'chat_messages';

  @override
  Future<void> saveLastOpenedApp(AppInfo appInfo) async {
    await prefs.setString(_lastAppKey, appInfo.name);
    await prefs.setString(_lastAppPackageKey, appInfo.packageName);
  }

  @override
  Future<AppInfo?> getLastOpenedApp() async {
    final name = prefs.getString(_lastAppKey);
    final packageName = prefs.getString(_lastAppPackageKey);
    if (name != null && packageName != null) {
      return AppInfo(name: name, packageName: packageName);
    }
    return null;
  }

  @override
  Future<void> saveLastSearchQuery(String query) async {
    await prefs.setString(_lastSearchKey, query);
  }

  @override
  Future<String?> getLastSearchQuery() async {
    return prefs.getString(_lastSearchKey);
  }

  @override
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final listStr = messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_chatMessagesKey, listStr);
  }

  @override
  Future<List<ChatMessage>> getMessages() async {
    try {
      final listStr = prefs.getStringList(_chatMessagesKey);
      if (listStr == null) return [];
      return listStr
          .map((str) => ChatMessage.fromJson(jsonDecode(str)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static const _onboardingKey = 'onboarding_completed';
  static const _languageKey = 'preferred_language';

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(_onboardingKey, completed);
  }

  @override
  bool isOnboardingCompleted() {
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> setPreferredLanguage(String languageCode) async {
    await prefs.setString(_languageKey, languageCode);
  }

  @override
  String getPreferredLanguage() {
    return prefs.getString(_languageKey) ?? 'en';
  }
}
