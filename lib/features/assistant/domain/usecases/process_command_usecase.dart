import '../entities/app_info.dart';
import '../entities/contact_info.dart';
import '../entities/command_intent.dart';
import '../repositories/app_repository.dart';
import '../repositories/contact_repository.dart';
import '../repositories/context_repository.dart';
import '../../services/intent_detection_service.dart';
import '../../../../core/utils/result.dart';
import 'launch_app_usecase.dart';
import 'make_call_usecase.dart';
import 'open_url_usecase.dart';

/// The central use-case that orchestrates command processing.
///
/// Flow:
///   1. Parse raw text → CommandIntent (via IntentDetectionService)
///   2. Route intent → appropriate action use-case
///   3. Update context memory
///   4. Return human-readable response
class ProcessCommandUseCase {
  final IntentDetectionService intentDetectionService;
  final LaunchAppUseCase launchAppUseCase;
  final MakeCallUseCase makeCallUseCase;
  final OpenUrlUseCase openUrlUseCase;
  final ContextRepository contextRepository;
  final AppRepository appRepository;
  final ContactRepository contactRepository;

  // Cache — refreshed on first command and on explicit refresh
  List<AppInfo>? _cachedApps;
  List<ContactInfo>? _cachedContacts;

  ProcessCommandUseCase({
    required this.intentDetectionService,
    required this.launchAppUseCase,
    required this.makeCallUseCase,
    required this.openUrlUseCase,
    required this.contextRepository,
    required this.appRepository,
    required this.contactRepository,
  });

  Future<CommandResponse> call(String rawCommand) async {
    // Ensure caches are loaded
    await _warmupCaches();

    final intent = intentDetectionService.detect(rawCommand);

    return _executeIntent(intent);
  }

  Future<CommandResponse> _executeIntent(CommandIntent intent) async {
    switch (intent.type) {
      case IntentType.openApp:
        return _handleOpenApp(intent.targetAppName!, intent.rawText);

      case IntentType.makeCall:
        return _handleCall(intent.targetContact!, intent.rawText);

      case IntentType.openUrl:
        return _handleUrl(intent.url!);

      case IntentType.youtubeSearch:
        return _handleYouTubeSearch(intent.searchQuery!);

      case IntentType.reopen:
        return _handleReopen();

      case IntentType.multiCommand:
        return _handleMultiCommand(intent.subCommands);

      case IntentType.unknown:
        return CommandResponse.error(
          '🤔 I didn\'t understand that. Try:\n'
          '• "open whatsapp"\n'
          '• "call mom"\n'
          '• "search flutter on youtube"\n'
          '• "open youtube.com"',
        );
    }
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  Future<CommandResponse> _handleOpenApp(String appName, String rawText) async {
    final result = await launchAppUseCase(
      appName: appName,
      installedApps: _cachedApps,
    );

    if (result is Success<AppInfo>) {
      await contextRepository.saveLastOpenedApp(result.data);
      return CommandResponse.success(
        '✅ Opened ${result.data.name}',
        launchedApp: result.data,
      );
    } else if (result is Failure<AppInfo>) {
      return CommandResponse.error(result.message);
    }
    return CommandResponse.error('Unknown error launching app.');
  }

  Future<CommandResponse> _handleCall(
      String contactName, String rawText) async {
    final result = await makeCallUseCase(
      contactName: contactName,
      cachedContacts: _cachedContacts,
    );

    if (result is CallSuccess) {
      return CommandResponse.success(
        '📞 Calling ${result.contact.name}…',
      );
    } else if (result is CallMultipleMatches) {
      return CommandResponse.multipleContacts(
        'Found multiple contacts matching "$contactName". Who do you want to call?',
        result.contacts,
      );
    } else if (result is CallNotFound) {
      return CommandResponse.error(
        '❌ No contact named "${result.query}" found.',
      );
    } else if (result is CallError) {
      return CommandResponse.error(result.message);
    }
    return CommandResponse.error('Unknown call error.');
  }

  Future<CommandResponse> _handleUrl(String url) async {
    final result = await openUrlUseCase(url);
    if (result is Success<String>) {
      return CommandResponse.success('🌐 ${result.data}');
    } else if (result is Failure<String>) {
      return CommandResponse.error(result.message);
    }
    return CommandResponse.error('Could not open URL.');
  }

  Future<CommandResponse> _handleYouTubeSearch(String query) async {
    final searchUrl =
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}';
    final result = await openUrlUseCase(searchUrl);
    await contextRepository.saveLastSearchQuery(query);

    if (result is Success<String>) {
      return CommandResponse.success('▶️ Searching YouTube for "$query"');
    } else if (result is Failure<String>) {
      return CommandResponse.error(result.message);
    }
    return CommandResponse.error('Could not open YouTube search.');
  }

  Future<CommandResponse> _handleReopen() async {
    final lastApp = await contextRepository.getLastOpenedApp();
    if (lastApp == null) {
      return CommandResponse.error(
          '❓ No app was opened recently. What would you like to open?');
    }
    return _handleOpenApp(lastApp.name, 'reopen ${lastApp.name}');
  }

  Future<CommandResponse> _handleMultiCommand(
      List<CommandIntent> subCommands) async {
    final responses = <String>[];
    for (final sub in subCommands) {
      final r = await _executeIntent(sub);
      responses.add(r.message);
      // Small delay between sequential launches
      if (subCommands.indexOf(sub) < subCommands.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    return CommandResponse.success(responses.join('\n'));
  }

  // ── Cache management ─────────────────────────────────────────────────────

  Future<void> _warmupCaches() async {
    _cachedApps ??= await appRepository.getInstalledApps();
    _cachedContacts ??= await contactRepository.getContacts();
  }

  /// Force-refresh caches (call after permission grant or on explicit request).
  Future<void> refreshCaches() async {
    _cachedApps = await appRepository.getInstalledApps();
    _cachedContacts = await contactRepository.getContacts();
  }
}

// ── Response DTO ──────────────────────────────────────────────────────────────

class CommandResponse {
  final bool success;
  final String message;
  final AppInfo? launchedApp;
  final List<ContactInfo>? contactChoices;

  const CommandResponse._({
    required this.success,
    required this.message,
    this.launchedApp,
    this.contactChoices,
  });

  factory CommandResponse.success(String msg, {AppInfo? launchedApp}) =>
      CommandResponse._(success: true, message: msg, launchedApp: launchedApp);

  factory CommandResponse.error(String msg) =>
      CommandResponse._(success: false, message: msg);

  factory CommandResponse.multipleContacts(
    String msg,
    List<ContactInfo> contacts,
  ) =>
      CommandResponse._(
        success: false,
        message: msg,
        contactChoices: contacts,
      );
}
