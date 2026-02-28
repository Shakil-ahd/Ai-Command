import '../entities/app_info.dart';
import '../entities/chat_message.dart';

abstract class ContextRepository {
  Future<void> saveLastOpenedApp(AppInfo appInfo);
  Future<AppInfo?> getLastOpenedApp();

  Future<void> saveLastSearchQuery(String query);
  Future<String?> getLastSearchQuery();

  Future<void> saveMessages(List<ChatMessage> messages);
  Future<List<ChatMessage>> getMessages();

  Future<void> setOnboardingCompleted(bool completed);
  bool isOnboardingCompleted();

  Future<void> setPreferredLanguage(String languageCode);
  String getPreferredLanguage();
}
