import 'package:android_intent_plus/android_intent.dart';
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
import 'toggle_flashlight_usecase.dart';
import '../../platform/android_app_launcher.dart';

class ProcessCommandUseCase {
  final IntentDetectionService intentDetectionService;
  final LaunchAppUseCase launchAppUseCase;
  final MakeCallUseCase makeCallUseCase;
  final OpenUrlUseCase openUrlUseCase;
  final ToggleFlashlightUseCase toggleFlashlightUseCase;
  final ContextRepository contextRepository;
  final AppRepository appRepository;
  final ContactRepository contactRepository;

  List<AppInfo>? _cachedApps;
  List<ContactInfo>? _cachedContacts;

  ProcessCommandUseCase({
    required this.intentDetectionService,
    required this.launchAppUseCase,
    required this.makeCallUseCase,
    required this.openUrlUseCase,
    required this.toggleFlashlightUseCase,
    required this.contextRepository,
    required this.appRepository,
    required this.contactRepository,
  });

  Future<CommandResponse> call(String rawCommand) async {
    await _warmupCaches();
    final intent = await intentDetectionService.detect(
      rawCommand,
      installedApps: _cachedApps ?? [],
    );
    final response = await _executeIntent(intent);

    if (intent.replyText != null && intent.replyText!.isNotEmpty) {
      if (response.success && response.contactChoices == null) {
        return CommandResponse.success(intent.replyText!,
            launchedApp: response.launchedApp);
      }
    }
    return response;
  }

  Future<CommandResponse> _executeIntent(CommandIntent intent) async {
    switch (intent.type) {
      case IntentType.openApp:
        final targetAppName = intent.targetAppName?.trim() ?? '';
        if (targetAppName.isEmpty)
          return CommandResponse.error(
              'Sorry, I couldn\'t determine which app to open.');
        return _handleOpenApp(targetAppName, intent.rawText);

      case IntentType.makeCall:
        final targetContact = intent.targetContact?.trim() ?? '';
        if (targetContact.isEmpty)
          return CommandResponse.error(
              'Sorry, I couldn\'t determine the contact name.');
        return _handleCall(targetContact, intent.rawText);

      case IntentType.openUrl:
        final url = intent.url?.trim() ?? '';
        if (url.isEmpty)
          return CommandResponse.error('Sorry, the URL provided is empty.');
        return _handleUrl(url);

      case IntentType.youtubeSearch:
        final searchQuery = intent.searchQuery?.trim() ?? '';
        if (searchQuery.isEmpty)
          return CommandResponse.error('Sorry, no search query was detected.');
        return _handleYouTubeSearch(searchQuery);

      case IntentType.reopen:
        return _handleReopen();

      case IntentType.multiCommand:
        return _handleMultiCommand(intent.subCommands);

      case IntentType.turnOnFlashlight:
        return _handleFlashlight(true);

      case IntentType.turnOffFlashlight:
        return _handleFlashlight(false);

      case IntentType.turnOnWifi:
        return _handleToggleSetting('wifi', true);

      case IntentType.turnOffWifi:
        return _handleToggleSetting('wifi', false);

      case IntentType.turnOnBluetooth:
        return _handleToggleSetting('bluetooth', true);

      case IntentType.turnOffBluetooth:
        return _handleToggleSetting('bluetooth', false);

      case IntentType.clearChat:
        return CommandResponse.success('Chat cleared.', clearChat: true);

      case IntentType.openSettings:
        final settingType = intent.targetSetting?.trim() ?? 'general';
        return _handleOpenSettings(settingType);

      case IntentType.openCamera:
        return _handleOpenCamera();

      case IntentType.generalChat:
        return CommandResponse.success(
            intent.replyText ?? 'Hello! I am SakoAI.');

      case IntentType.unknown:
        return CommandResponse.error('Sorry, I didn\'t understand that.');
    }
  }

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
      return CommandResponse.success('📞 Calling ${result.contact.name}…');
    } else if (result is CallMultipleMatches) {
      return CommandResponse.multipleContacts(
        'Found multiple contacts matching "$contactName". Who do you want to call?',
        result.contacts,
      );
    } else if (result is CallNotFound) {
      return CommandResponse.error(
          '❌ No contact named "${result.query}" found.');
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
    String finalQuery = query;

    finalQuery = finalQuery
        .replaceAll(RegExp(r'\s+on\s+(youtube|yt)', caseSensitive: false), '')
        .trim();

    final searchUrl =
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(finalQuery)}';

    final isMoodSearch = RegExp(
            r'\b(sad|romantic|funny|natok|cartoon|special)\b',
            caseSensitive: false)
        .hasMatch(finalQuery);

    final result = await openUrlUseCase(searchUrl);
    await contextRepository.saveLastSearchQuery(finalQuery);

    if (result is Success<String>) {
      return CommandResponse.success(isMoodSearch
          ? '▶️ Finding a $finalQuery for you on YouTube...'
          : '▶️ Searching YouTube for "$finalQuery"');
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

  Future<CommandResponse> _handleFlashlight(bool turnOn) async {
    final result = await toggleFlashlightUseCase(turnOn: turnOn);
    if (result is Success<bool>) {
      return CommandResponse.success(
          turnOn ? '🔦 Flashlight turned ON' : '🔦 Flashlight turned OFF');
    } else if (result is Failure<bool>) {
      return CommandResponse.error(result.message);
    }
    return CommandResponse.error('Could not toggle flashlight.');
  }

  Future<CommandResponse> _handleMultiCommand(
      List<CommandIntent> subCommands) async {
    final responses = <String>[];
    for (final sub in subCommands) {
      final r = await _executeIntent(sub);
      responses.add(r.message);
      if (subCommands.indexOf(sub) < subCommands.length - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    return CommandResponse.success(responses.join('\n'));
  }

  Future<CommandResponse> _handleOpenSettings(String settingType) async {
    String action;
    switch (settingType.toLowerCase()) {
      case 'wifi':
        action = 'android.settings.WIFI_SETTINGS';
        break;
      case 'bluetooth':
        action = 'android.settings.BLUETOOTH_SETTINGS';
        break;
      case 'display':
      case 'brightness':
        action = 'android.settings.DISPLAY_SETTINGS';
        break;
      case 'airplane_mode':
      case 'flight_mode':
        action = 'android.settings.AIRPLANE_MODE_SETTINGS';
        break;
      case 'location':
      case 'gps':
        action = 'android.settings.LOCATION_SOURCE_SETTINGS';
        break;
      case 'mobile_data':
      case 'data':
        action = 'android.settings.DATA_ROAMING_SETTINGS';
        break;
      case 'hotspot':
      case 'tethering':
        action = 'android.settings.WIRELESS_SETTINGS';
        break;
      case 'sound':
      case 'volume':
        action = 'android.settings.SOUND_SETTINGS';
        break;
      default:
        action = 'android.settings.SETTINGS';
    }

    try {
      final intent = AndroidIntent(action: action);
      await intent.launch();
      return CommandResponse.success('Opening settings...');
    } catch (e) {
      return CommandResponse.error('Could not open settings.');
    }
  }

  Future<CommandResponse> _handleToggleSetting(
      String setting, bool enable) async {
    final launcher = AndroidAppLauncher();
    bool success = false;

    if (setting == 'wifi') {
      success = await launcher.toggleWifi(enable);
      if (success)
        return CommandResponse.success(enable
            ? '📶 Opening Wi-Fi settings to turn on...'
            : '📶 Opening Wi-Fi settings to turn off...');
    } else if (setting == 'bluetooth') {
      success = await launcher.toggleBluetooth(enable);
      if (success)
        return CommandResponse.success(enable
            ? '🔵 Turning on Bluetooth...'
            : '🔵 Turning off Bluetooth...');
    }

    return _handleOpenSettings(setting);
  }

  Future<CommandResponse> _handleOpenCamera() async {
    try {
      final intent = const AndroidIntent(
        action: 'android.media.action.STILL_IMAGE_CAMERA',
      );
      await intent.launch();
      return CommandResponse.success('Opening camera...');
    } catch (e) {
      return CommandResponse.error('Could not open camera.');
    }
  }

  Future<void> _warmupCaches() async {
    _cachedApps ??= await appRepository.getInstalledApps();
    _cachedContacts ??= await contactRepository.getContacts();
  }

  Future<void> refreshCaches() async {
    _cachedApps = await appRepository.getInstalledApps();
    _cachedContacts = await contactRepository.getContacts();
  }
}

class CommandResponse {
  final bool success;
  final bool clearChat;
  final String message;
  final AppInfo? launchedApp;
  final List<ContactInfo>? contactChoices;

  const CommandResponse._({
    required this.success,
    required this.message,
    this.clearChat = false,
    this.launchedApp,
    this.contactChoices,
  });

  factory CommandResponse.success(String msg,
          {AppInfo? launchedApp, bool clearChat = false}) =>
      CommandResponse._(
          success: true,
          message: msg,
          clearChat: clearChat,
          launchedApp: launchedApp);

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
