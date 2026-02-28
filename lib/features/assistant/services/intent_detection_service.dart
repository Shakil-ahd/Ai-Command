import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/entities/app_info.dart';
import '../domain/entities/command_intent.dart';
import 'gemini_service.dart';

class IntentDetectionService {
  final GeminiService geminiService;

  static final _openPatterns = RegExp(
    r'\b(open|launch|start|run|show|go to|navigate to|use|activate)\b',
    caseSensitive: false,
  );

  static final _callPatterns = RegExp(
    r'\b(call|dial|phone|ring|contact)\b',
    caseSensitive: false,
  );

  static final _youtubeSearchPatterns = RegExp(
    r'\b(search|find|look up|look for|play|watch)\b.*(on|in|via|using|at)?\s*youtube\b',
    caseSensitive: false,
  );

  static final _urlPattern = RegExp(
    r'(https?://|www\.)[^\s]+|[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?(/[^\s]*)?',
    caseSensitive: false,
  );

  static final _reopenPatterns = RegExp(
    r'\b(open it again|reopen|open again|launch again|open that again)\b',
    caseSensitive: false,
  );

  static final _multiCommandSplitter = RegExp(
    r'\s+(and then|then|and|also|after that|next|plus)\s+',
    caseSensitive: false,
  );

  static final _flashlightOnPatterns = RegExp(
    r'\b(turn on flashlight|flashlight on|torch on|turn on torch|light on|on light|flash on|on flash|turn on light)\b',
    caseSensitive: false,
  );

  static final _flashlightOffPatterns = RegExp(
    r'\b(turn off flashlight|flashlight off|torch off|turn off torch|light off|off light|flash off|off flash|turn off light)\b',
    caseSensitive: false,
  );

  static final _wifiOnPatterns = RegExp(
      r'\b(turn on wi-fi|turn on wifi|wifi on|wi-fi on|enable wifi|enable wi-fi|on wifi|on wi-fi|start wifi|start wi-fi|wifi start|wi-fi start)\b',
      caseSensitive: false);
  static final _wifiOffPatterns = RegExp(
      r'\b(turn off wi-fi|turn off wifi|wifi off|wi-fi off|disable wifi|disable wi-fi|off wifi|off wi-fi|stop wifi|stop wi-fi|wifi stop|wi-fi stop)\b',
      caseSensitive: false);

  static final _bluetoothOnPatterns = RegExp(
      r'\b(turn on bluetooth|bluetooth on|enable bluetooth|on bluetooth|start bluetooth|bluetooth start|bt on|on bt)\b',
      caseSensitive: false);
  static final _bluetoothOffPatterns = RegExp(
      r'\b(turn off bluetooth|bluetooth off|disable bluetooth|off bluetooth|stop bluetooth|bluetooth stop|bt off|off bt)\b',
      caseSensitive: false);

  static final _cameraPatterns = RegExp(
      r'\b(open camera|camera open|take picture|take photo|start camera|camera|launch camera|on camera|camera on)\b',
      caseSensitive: false);

  static final _locationPatterns = RegExp(
      r'\b(turn on location|location on|gps on|turn on gps|on location|on gps|turn off location|location off|gps off|turn off gps|off location|off gps|location settings|location|start gps|stop gps)\b',
      caseSensitive: false);

  static final _airplaneModePatterns = RegExp(
      r'\b(turn on airplane mode|airplane mode on|flight mode on|turn on flight mode|on airplane mode|on flight mode|on airplane|airplane on|on flight|flight on|turn off airplane mode|airplane mode off|flight mode off|turn off flight mode|off airplane mode|off flight mode|off airplane|airplane off|off flight|flight off|airplane mode|flight mode)\b',
      caseSensitive: false);

  static final _brightnessPatterns = RegExp(
      r'\b(increase brightness|decrease brightness|brightness up|brightness down|set brightness|brightness settings|change brightness|brightness|on brightness|brightness on|off brightness|brightness off)\b',
      caseSensitive: false);

  static final _mobileDataPatterns = RegExp(
      r'\b(turn on mobile data|mobile data on|cellular data on|data on|on mobile data|on data|turn off mobile data|mobile data off|cellular data off|data off|off mobile data|off data|mobile data settings|data settings|mobile data|cellular on|on cellular)\b',
      caseSensitive: false);

  static final _hotspotPatterns = RegExp(
      r'\b(turn on hotspot|hotspot on|tethering on|on hotspot|hotspot start|start hotspot|turn off hotspot|hotspot off|tethering off|off hotspot|hotspot stop|stop hotspot|hotspot settings|hotspot)\b',
      caseSensitive: false);

  static final _soundPatterns = RegExp(
      r'\b(sound settings|volume settings|mute|unmute|silent mode|vibration mode|sound|on silent|silent on|off silent|silent off|on vibrate|vibrate on|off vibrate|vibrate off)\b',
      caseSensitive: false);

  static final _clearChatPatterns = RegExp(
      r'\b(clear chat|delete chat|delete messages|clear all chat|clear history)\b',
      caseSensitive: false);

  IntentDetectionService(this.geminiService);

  static const Map<String, String> _aliases = {
    'yt': 'YouTube',
    'youtube': 'YouTube',
    'fb': 'Facebook',
    'facebook': 'Facebook',
    'insta': 'Instagram',
    'ig': 'Instagram',
    'wa': 'WhatsApp',
    'whatsapp': 'WhatsApp',
    'maps': 'Google Maps',
    'gmap': 'Google Maps',
    'gmail': 'Gmail',
    'google': 'Google',
    'chrome': 'Google Chrome',
    'playstore': 'Google Play Store',
    'settings': 'Settings',
    'calculator': 'Calculator',
    'calendar': 'Calendar',
    'camera': 'Camera',
    'clock': 'Clock',
  };

  Future<CommandIntent> detect(String rawText,
      {List<AppInfo> installedApps = const []}) async {
    final rawTrimmed = rawText.trim();
    if (rawTrimmed.isEmpty)
      return CommandIntent(type: IntentType.unknown, rawText: rawTrimmed);

    final text = _resolveAlias(rawTrimmed);

    final musicIntent = _detectMusicPlatformIntent(text);
    if (musicIntent != null) return musicIntent;

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      final geminiIntent = await geminiService.detectIntentWithGemini(text);
      if (geminiIntent != null && geminiIntent.type != IntentType.unknown) {
        return geminiIntent;
      }
    }

    final localIntent = _fallbackDetect(text);
    if (localIntent.type != IntentType.unknown) return localIntent;

    if (installedApps.isNotEmpty) {
      final cleaned = _stripFiller(text);
      final appIntent = _matchAppByName(cleaned, installedApps, text);
      if (appIntent != null) return appIntent;
    }

    return CommandIntent(type: IntentType.unknown, rawText: text);
  }

  String _stripFiller(String text) {
    return text
        .toLowerCase()
        .replaceAll(
            RegExp(
                r'\b(open|start|launch|play|watch|listen to|use|show|go to|navigate to|on|in|into|please|can you|could you|will you|i want to|take me to)\b',
                caseSensitive: false),
            '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  CommandIntent? _matchAppByName(
      String cleaned, List<AppInfo> apps, String rawText) {
    if (cleaned.isEmpty) return null;
    String? bestPkgName;
    String? bestAppName;
    double bestScore = 0.42;

    for (final app in apps) {
      final normName = app.name.toLowerCase().trim();
      if (normName.isEmpty) continue;

      if (normName == cleaned ||
          normName.contains(cleaned) ||
          cleaned.contains(normName)) {
        bestScore = 1.0;
        bestPkgName = app.packageName;
        bestAppName = app.name;
        break;
      }

      final score = _diceSimilarity(cleaned, normName);
      if (score > bestScore) {
        bestScore = score;
        bestPkgName = app.packageName;
        bestAppName = app.name;
      }
    }

    if (bestPkgName != null && bestAppName != null) {
      return CommandIntent(
        type: IntentType.openApp,
        rawText: rawText,
        targetAppName: bestAppName,
      );
    }
    return null;
  }

  double _diceSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.length < 2 || b.length < 2) return 0.0;
    final setA = <String>{};
    for (int i = 0; i < a.length - 1; i++) setA.add(a.substring(i, i + 2));
    final setB = <String>{};
    for (int i = 0; i < b.length - 1; i++) setB.add(b.substring(i, i + 2));
    final intersection = setA.intersection(setB).length;
    return (2.0 * intersection) / (setA.length + setB.length);
  }

  CommandIntent _fallbackDetect(String text) {
    if (_reopenPatterns.hasMatch(text)) {
      return CommandIntent(type: IntentType.reopen, rawText: text);
    }

    if (_flashlightOnPatterns.hasMatch(text)) {
      return CommandIntent(type: IntentType.turnOnFlashlight, rawText: text);
    }

    if (_flashlightOffPatterns.hasMatch(text)) {
      return CommandIntent(type: IntentType.turnOffFlashlight, rawText: text);
    }

    if (_wifiOnPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.turnOnWifi, rawText: text);
    if (_wifiOffPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.turnOffWifi, rawText: text);
    if (_bluetoothOnPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.turnOnBluetooth, rawText: text);
    if (_bluetoothOffPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.turnOffBluetooth, rawText: text);
    if (_cameraPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.openCamera, rawText: text);

    if (_locationPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings,
          rawText: text,
          targetSetting: 'location');
    }

    if (_airplaneModePatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings,
          rawText: text,
          targetSetting: 'airplane_mode');
    }

    if (_brightnessPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings,
          rawText: text,
          targetSetting: 'display');
    }

    if (_mobileDataPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings,
          rawText: text,
          targetSetting: 'mobile_data');
    }

    if (_hotspotPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings,
          rawText: text,
          targetSetting: 'hotspot');
    }

    if (_soundPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openSettings, rawText: text, targetSetting: 'sound');
    }

    if (_clearChatPatterns.hasMatch(text))
      return CommandIntent(type: IntentType.clearChat, rawText: text);

    if (text.toLowerCase().contains('who is sakoai') ||
        text.toLowerCase().contains('your name')) {
      return CommandIntent(
        type: IntentType.generalChat,
        rawText: text,
        replyText:
            'I am SakoAI, your personal smartphone assistant. I can help you open apps, call contacts, search YouTube, and control your device features like Bluetooth or Flashlight.',
      );
    }
    if (text.toLowerCase().contains('how to use') ||
        text.toLowerCase().contains('help') ||
        text.toLowerCase().contains('what can you do') ||
        text.toLowerCase().contains('what do you do')) {
      return CommandIntent(
        type: IntentType.generalChat,
        rawText: text,
        replyText: 'I can help you with many things! Try saying:\n\n'
            '• "Open WhatsApp" or "Launch Facebook"\n'
            '• "Call [Contact Name]"\n'
            '• "Play sad songs" or "on YouTube [Query]"\n'
            '• "Light on", "WiFi off", "Bluetooth on"\n'
            '• "Open Camera" or "Location settings"\n'
            '• "Brightness up" or "Airplane mode"\n\n'
            'Just type or tap the mic to start!'
            'Finally BOOMS....',
      );
    }

    final musicResult = _detectMusicPlatformIntent(text);
    if (musicResult != null) return musicResult;

    final parts = text.split(_multiCommandSplitter);
    if (parts.length > 1) {
      final subIntents = parts
          .map((p) => _fallbackDetect(p.trim()))
          .where((i) => i.type != IntentType.unknown)
          .toList();

      if (subIntents.length > 1) {
        return CommandIntent(
          type: IntentType.multiCommand,
          rawText: text,
          subCommands: subIntents,
        );
      }
    }

    final urlMatch = _urlPattern.firstMatch(text);
    if (urlMatch != null &&
        !_openPatterns
            .hasMatch(text.split(RegExp(r'\s+url\s+|\s+link\s+')).first)) {
      final isLikelyUrl = _looksLikeUrl(text);
      if (isLikelyUrl) {
        return CommandIntent(
          type: IntentType.openUrl,
          rawText: text,
          url: urlMatch.group(0),
        );
      }
    }

    if (_youtubeSearchPatterns.hasMatch(text)) {
      final query = _extractYouTubeQuery(text);
      if (query != null && query.isNotEmpty) {
        return CommandIntent(
          type: IntentType.youtubeSearch,
          rawText: text,
          searchQuery: query,
        );
      }
    }

    if (_callPatterns.hasMatch(text)) {
      final contactName = _extractEntityAfterVerb(text, _callPatterns);
      if (contactName != null && contactName.isNotEmpty) {
        return CommandIntent(
          type: IntentType.makeCall,
          rawText: text,
          targetContact: contactName,
        );
      }
    }

    if (_openPatterns.hasMatch(text)) {
      final appName = _extractEntityAfterVerb(text, _openPatterns);
      if (appName != null && appName.isNotEmpty) {
        if (_looksLikeUrl(appName)) {
          return CommandIntent(
            type: IntentType.openUrl,
            rawText: text,
            url: appName,
          );
        }
        return CommandIntent(
          type: IntentType.openApp,
          rawText: text,
          targetAppName: appName,
        );
      }
    }

    if (urlMatch != null) {
      return CommandIntent(
        type: IntentType.openUrl,
        rawText: text,
        url: urlMatch.group(0),
      );
    }

    return CommandIntent(type: IntentType.unknown, rawText: text);
  }

  CommandIntent? _detectMusicPlatformIntent(String text) {
    final lower = text.toLowerCase().trim();

    final musicKeywords = [
      'music',
      'song',
      'songs',
      'video',
      'videos',
      'playlist',
      'sad',
      'happy',
      'romantic',
      'funny',
      'lofi',
      'relaxing',
      'energetic',
      'workout',
      'chill',
      'party',
      'devotional',
      'jazz',
      'classical',
      'hip hop',
      'pop',
      'rock',
      'rap',
      'bollywood',
      'english',
      'bangla',
      'hindi',
      'special',
      'funny video',
      'video song',
      'relax',
      'instrumental',
      'natok',
      'cartoon'
    ];

    final platformPattern = RegExp(
      r'^(?:play|watch|listen to)?\s*(.+?)\s+on\s+(youtube|yt|spotify|music\s*app|music)\s*$',
      caseSensitive: false,
    );

    final pm = platformPattern.firstMatch(lower);
    if (pm != null) {
      final query = pm.group(1)?.trim() ?? '';
      final platform = pm.group(2)?.toLowerCase() ?? '';

      if (platform == 'youtube' || platform == 'yt') {
        return CommandIntent(
          type: IntentType.youtubeSearch,
          rawText: text,
          searchQuery: query,
        );
      } else if (platform == 'spotify') {
        final spotifyUri = 'spotify:search:${Uri.encodeComponent(query)}';
        return CommandIntent(
          type: IntentType.openUrl,
          rawText: text,
          url: spotifyUri,
          replyText: 'Searching Spotify for "$query"...',
        );
      } else if (platform.contains('music')) {
        return CommandIntent(
          type: IntentType.openApp,
          rawText: text,
          targetAppName: 'Music',
          replyText: 'Opening your music app for "$query"...',
        );
      }
    }

    final playOnlyPattern = RegExp(
      r'^(?:play|watch|listen to)\s+(.+?)$',
      caseSensitive: false,
    );
    final pom = playOnlyPattern.firstMatch(lower);
    if (pom != null) {
      final query = pom.group(1)?.trim() ?? '';
      if (query.isNotEmpty) {
        final hasMusicWord = musicKeywords.any((k) => lower.contains(k));
        if (hasMusicWord) {
          return CommandIntent(
            type: IntentType.youtubeSearch,
            rawText: text,
            searchQuery: query,
          );
        }
      }
    }

    final explicitMusicWords = [
      'music',
      'song',
      'songs',
      'video',
      'videos',
      'lofi',
      'playlist',
      'special',
      'instrumental'
    ];
    final lowerTrimmed = lower.trim();
    if (explicitMusicWords.any((w) => lowerTrimmed.contains(w))) {
      if (lowerTrimmed.length > 3) {
        String cleanQuery = lowerTrimmed
            .replaceAll(RegExp(r'\b(google|search|google search)\b'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        return CommandIntent(
          type: IntentType.youtubeSearch,
          rawText: text,
          searchQuery: cleanQuery,
        );
      }
    }

    final platformMentionRegex = RegExp(
        r'^(.*?)\s+on\s+(youtube|yt|facebook|fb|instagram|insta|spotify|tiktok)\s*$',
        caseSensitive: false);
    final platformMatch = platformMentionRegex.firstMatch(lower);
    if (platformMatch != null) {
      final query = platformMatch.group(1)?.trim() ?? '';
      final platform = platformMatch.group(2)?.toLowerCase() ?? '';

      if (platform == 'youtube' || platform == 'yt') {
        return CommandIntent(
            type: IntentType.youtubeSearch, rawText: text, searchQuery: query);
      } else if (platform == 'facebook' || platform == 'fb') {
        return CommandIntent(
            type: IntentType.openUrl,
            rawText: text,
            url:
                'https://www.facebook.com/search/top/?q=${Uri.encodeComponent(query)}',
            replyText: 'Searching Facebook for "$query"...');
      } else if (platform == 'instagram' || platform == 'insta') {
        return CommandIntent(
            type: IntentType.openUrl,
            rawText: text,
            url:
                'https://www.instagram.com/explore/tags/${Uri.encodeComponent(query.replaceAll(" ", ""))}/',
            replyText: 'Searching Instagram for "$query"...');
      }
    }

    return null;
  }

  String _resolveAlias(String text) {
    final lower = text.trim().toLowerCase();
    if (_aliases.containsKey(lower)) {
      return _aliases[lower]!;
    }
    String result = text;
    for (final alias in _aliases.keys) {
      result = result.replaceAllMapped(
        RegExp(r'\b' + RegExp.escape(alias) + r'\b', caseSensitive: false),
        (m) => _aliases[alias]!,
      );
    }
    return result;
  }

  String? _extractEntityAfterVerb(String text, RegExp verbPattern) {
    final match = verbPattern.firstMatch(text);
    if (match == null) return null;

    final afterVerb = text.substring(match.end).trim();
    final cleaned = afterVerb
        .replaceAll(
            RegExp(r'^(the|a|an|my|that|this)\s+', caseSensitive: false), '')
        .trim();

    final stop = RegExp(r'\s+(and|or|then|,|\.)\s+', caseSensitive: false);
    final stopMatch = stop.firstMatch(cleaned);
    return stopMatch == null ? cleaned : cleaned.substring(0, stopMatch.start);
  }

  String? _extractYouTubeQuery(String text) {
    final musicMoods = [
      'special',
      'song',
      'songs',
      'music',
      'video',
      'videos',
      'romantic',
      'sad',
      'pop',
      'rock',
      'natok',
      'cartoon'
    ];

    final pattern1 = RegExp(
      r'\b(?:search|find|look up|look for|play|watch)\s+(.+?)\s+(?:on|in|via|using|at)?\s*youtube\b',
      caseSensitive: false,
    );
    final m1 = pattern1.firstMatch(text);
    if (m1 != null) return m1.group(1)?.trim();

    final playMusicPattern = RegExp(
      r'\bplay\s+(.+?)(?:\s+music|\s+songs?|\s+videos?)?\s*$',
      caseSensitive: false,
    );
    final mPlay = playMusicPattern.firstMatch(text);
    if (mPlay != null) {
      final q = mPlay.group(1)?.trim() ?? '';
      if (q.isNotEmpty) {
        final isMood = musicMoods.any((m) => q.toLowerCase().contains(m));
        return isMood ? '$q music' : q;
      }
    }

    final pattern2 = RegExp(
      r'\byoutube\b.{0,20}(?:search|find)?\s*(?:for|about)?\s+(.+)',
      caseSensitive: false,
    );
    final m2 = pattern2.firstMatch(text);
    if (m2 != null) return m2.group(1)?.trim();

    return null;
  }

  bool _looksLikeUrl(String text) {
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.') ||
        RegExp(r'^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}').hasMatch(text.trim());
  }
}
