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

  static final _banglishOpenPatterns = RegExp(
      r'\b(kholo|khola|kholun|open koro|open kor|on koro|on kor|calu koro|chalu koro|start koro|start kor)\b',
      caseSensitive: false);

  static final _banglishCallPatterns = RegExp(
      r'\b(call koro|call kor|call de|call dao|phone koro|phone kor|ke call koro|ke call kor|ke phone koro)\b',
      caseSensitive: false);

  static final _banglishFlashlightOnPatterns = RegExp(
      r'\b(torch on koro|torch on kor|light on koro|light on kor|flashlight on koro|flashlight on kor|torch jala|torch jalo|light jala|light jalo|aloh jala|aloh jalo|alo jala|alo jalo|torch chalao|torch calu koro|torch chalu koro)\b',
      caseSensitive: false);

  static final _banglishFlashlightOffPatterns = RegExp(
      r'\b(torch off koro|torch off kor|light off koro|light off kor|flashlight off koro|flashlight off kor|torch niva|torch nibhao|light niva|light nibhao|torch bondho koro|torch bondho kor|light bondho koro|light bondho kor)\b',
      caseSensitive: false);

  static final _banglishWifiOnPatterns = RegExp(
      r'\b(wifi on koro|wifi on kor|wifi calu koro|wifi chalu koro|wifi chalao|wifi daw)\b',
      caseSensitive: false);

  static final _banglishWifiOffPatterns = RegExp(
      r'\b(wifi off koro|wifi off kor|wifi bondho koro|wifi bondho kor|wifi band koro)\b',
      caseSensitive: false);

  static final _banglishBluetoothOnPatterns = RegExp(
      r'\b(bluetooth on koro|bluetooth on kor|bluetooth calu koro|bluetooth chalu koro|bluetooth chalao)\b',
      caseSensitive: false);

  static final _banglishBluetoothOffPatterns = RegExp(
      r'\b(bluetooth off koro|bluetooth off kor|bluetooth bondho koro|bluetooth bondho kor|bluetooth band koro)\b',
      caseSensitive: false);

  static final _banglishCameraPatterns = RegExp(
      r'\b(camera kholo|camera khola|camera open koro|camera on koro|photo tolo|photo tola|photo uthao|picture tolo|picture tola)\b',
      caseSensitive: false);

  static final _banglishClearChatPatterns = RegExp(
      r'\b(chat clear koro|chat delete koro|chat moche felo|chat moche dao|chat sesh koro|chat shesh koro|chat porishshar koro|chat porishkar koro)\b',
      caseSensitive: false);

  static final _banglishYoutubePatterns = RegExp(
      r'\b(youtube e|youtube te|youtube theke|youtube search koro|youtube kholo|youtube open koro)\b',
      caseSensitive: false);

  static final _banglishReopenPatterns = RegExp(
      r'\b(abar kholo|abar open koro|ager ta kholo|again kholo|ager ta open koro)\b',
      caseSensitive: false);

  static final _banglaFlashlightOnPatterns = RegExp(
      r'(টর্চ অন|টর্চ জ্বালাও|আলো জ্বালাও|ফ্লাশলাইট অন|লাইট অন|টর্চ চালু|আলো চালু)',
      caseSensitive: false);

  static final _banglaFlashlightOffPatterns = RegExp(
      r'(টর্চ অফ|টর্চ নেভাও|আলো নেভাও|ফ্লাশলাইট অফ|লাইট অফ|টর্চ বন্ধ|আলো বন্ধ)',
      caseSensitive: false);

  static final _banglaWifiOnPatterns = RegExp(
      r'(ওয়াইফাই অন|ওয়াইফাই চালু|ওয়াই-ফাই অন|ওয়াই-ফাই চালু|wifi অন|wifi চালু)',
      caseSensitive: false);

  static final _banglaWifiOffPatterns = RegExp(
      r'(ওয়াইফাই অফ|ওয়াইফাই বন্ধ|ওয়াই-ফাই অফ|ওয়াই-ফাই বন্ধ|wifi অফ|wifi বন্ধ)',
      caseSensitive: false);

  static final _banglaBluetoothOnPatterns = RegExp(
      r'(ব্লুটুথ অন|ব্লুটুথ চালু|bluetooth অন|bluetooth চালু)',
      caseSensitive: false);

  static final _banglaBluetoothOffPatterns = RegExp(
      r'(ব্লুটুথ অফ|ব্লুটুথ বন্ধ|bluetooth অফ|bluetooth বন্ধ)',
      caseSensitive: false);

  static final _banglaCameraPatterns = RegExp(
      r'(ক্যামেরা খোলো|ক্যামেরা ওপেন|ছবি তোলো|ফটো তোলো)',
      caseSensitive: false);

  static final _banglaOpenPatterns = RegExp(
      r'(খোলো|খুলুন|ওপেন কর|ওপেন করো|চালু কর|চালু করো|স্টার্ট কর)',
      caseSensitive: false);

  static final _banglaCallPatterns = RegExp(
      r'(কল কর|কল করো|ফোন কর|ফোন করো|কল দাও|কে কল কর|কে ফোন কর)',
      caseSensitive: false);

  static final _banglaClearChatPatterns = RegExp(
      r'(চ্যাট ক্লিয়ার|চ্যাট ডিলিট|চ্যাট মুছে ফেল|চ্যাট পরিষ্কার)',
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

    final banglishIntent = _detectBanglishIntent(text);
    if (banglishIntent != null) return banglishIntent;

    final banglaIntent = _detectBanglaIntent(text);
    if (banglaIntent != null) return banglaIntent;

    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet && !geminiService.isQuotaExhausted) {
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

    if (!hasInternet) {
      return CommandIntent(
        type: IntentType.generalChat,
        rawText: text,
        replyText:
            '📵 ইন্টারনেট সংযোগ নেই। তবে আমি অফলাইনেও অ্যাপ খোলা, কল করা, ফ্ল্যাশলাইট, ওয়াইফাই, ব্লুটুথ ইত্যাদি নিয়ন্ত্রণ করতে পারি!\n\nNo internet connection. But I can still open apps, make calls, and control flashlight, WiFi, Bluetooth offline!',
      );
    }

    if (geminiService.isQuotaExhausted) {
      return CommandIntent(
        type: IntentType.generalChat,
        rawText: text,
        replyText:
            '⚠️ API লিমিট শেষ হয়ে গেছে। তবে আমি এখনও অ্যাপ খোলা, কল করা, YouTube সার্চ, ফ্ল্যাশলাইট, ওয়াইফাই, ব্লুটুথ, ক্যামেরা, সেটিংস ইত্যাদি সব কাজ করতে পারি!\n\n'
            'শুধু AI চ্যাট (প্রশ্ন-উত্তর) এর জন্য API key দরকার।\n\n'
            'API limit exceeded. But I can still open apps, make calls, search YouTube, control flashlight, WiFi, Bluetooth, camera, settings and more!\n\n'
            'Only AI chat (Q&A) needs the API key.',
      );
    }

    return CommandIntent(type: IntentType.unknown, rawText: text);
  }

  CommandIntent? _detectBanglishIntent(String text) {
    final lower = text.toLowerCase().trim();

    if (_banglishFlashlightOnPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOnFlashlight,
          rawText: text,
          replyText: 'টর্চ জ্বালাচ্ছি...');
    }
    if (_banglishFlashlightOffPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOffFlashlight,
          rawText: text,
          replyText: 'টর্চ বন্ধ করছি...');
    }

    if (_banglishWifiOnPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOnWifi,
          rawText: text,
          replyText: 'WiFi চালু করছি...');
    }
    if (_banglishWifiOffPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOffWifi,
          rawText: text,
          replyText: 'WiFi বন্ধ করছি...');
    }

    if (_banglishBluetoothOnPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOnBluetooth,
          rawText: text,
          replyText: 'Bluetooth চালু করছি...');
    }
    if (_banglishBluetoothOffPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.turnOffBluetooth,
          rawText: text,
          replyText: 'Bluetooth বন্ধ করছি...');
    }

    if (_banglishCameraPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.openCamera,
          rawText: text,
          replyText: 'ক্যামেরা খুলছি...');
    }

    if (_banglishClearChatPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.clearChat,
          rawText: text,
          replyText: 'চ্যাট ক্লিয়ার করছি...');
    }

    if (_banglishReopenPatterns.hasMatch(lower)) {
      return CommandIntent(
          type: IntentType.reopen, rawText: text, replyText: 'আবার খুলছি...');
    }

    if (_banglishYoutubePatterns.hasMatch(lower)) {
      final query = _extractBanglishYoutubeQuery(lower);
      if (query != null && query.isNotEmpty) {
        return CommandIntent(
            type: IntentType.youtubeSearch,
            rawText: text,
            searchQuery: query,
            replyText: 'YouTube এ "$query" খুঁজছি...');
      }
      return CommandIntent(
          type: IntentType.openApp,
          rawText: text,
          targetAppName: 'YouTube',
          replyText: 'YouTube খুলছি...');
    }

    if (_banglishCallPatterns.hasMatch(lower)) {
      final contact = _extractBanglishCallTarget(lower);
      if (contact != null && contact.isNotEmpty) {
        return CommandIntent(
            type: IntentType.makeCall,
            rawText: text,
            targetContact: contact,
            replyText: '$contact কে কল করছি...');
      }
    }

    if (_banglishOpenPatterns.hasMatch(lower)) {
      final appName = _extractBanglishAppName(lower);
      if (appName != null && appName.isNotEmpty) {
        return CommandIntent(
            type: IntentType.openApp,
            rawText: text,
            targetAppName: appName,
            replyText: '$appName খুলছি...');
      }
    }

    return null;
  }

  CommandIntent? _detectBanglaIntent(String text) {
    if (_banglaFlashlightOnPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOnFlashlight,
          rawText: text,
          replyText: 'টর্চ জ্বালাচ্ছি...');
    }
    if (_banglaFlashlightOffPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOffFlashlight,
          rawText: text,
          replyText: 'টর্চ বন্ধ করছি...');
    }

    if (_banglaWifiOnPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOnWifi,
          rawText: text,
          replyText: 'ওয়াইফাই চালু করছি...');
    }
    if (_banglaWifiOffPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOffWifi,
          rawText: text,
          replyText: 'ওয়াইফাই বন্ধ করছি...');
    }

    if (_banglaBluetoothOnPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOnBluetooth,
          rawText: text,
          replyText: 'ব্লুটুথ চালু করছি...');
    }
    if (_banglaBluetoothOffPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.turnOffBluetooth,
          rawText: text,
          replyText: 'ব্লুটুথ বন্ধ করছি...');
    }

    if (_banglaCameraPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.openCamera,
          rawText: text,
          replyText: 'ক্যামেরা খুলছি...');
    }

    if (_banglaClearChatPatterns.hasMatch(text)) {
      return CommandIntent(
          type: IntentType.clearChat,
          rawText: text,
          replyText: 'চ্যাট ক্লিয়ার করছি...');
    }

    if (_banglaCallPatterns.hasMatch(text)) {
      final contact = text
          .replaceAll(
              RegExp(
                  r'(কল কর|কল করো|ফোন কর|ফোন করো|কল দাও|কে কল কর|কে ফোন কর)'),
              '')
          .trim();
      if (contact.isNotEmpty) {
        return CommandIntent(
            type: IntentType.makeCall,
            rawText: text,
            targetContact: contact,
            replyText: '$contact কে কল করছি...');
      }
    }

    if (_banglaOpenPatterns.hasMatch(text)) {
      final appName = text
          .replaceAll(
              RegExp(
                  r'(খোলো|খুলুন|ওপেন কর|ওপেন করো|চালু কর|চালু করো|স্টার্ট কর)'),
              '')
          .trim();
      if (appName.isNotEmpty) {
        return CommandIntent(
            type: IntentType.openApp,
            rawText: text,
            targetAppName: appName,
            replyText: '$appName খুলছি...');
      }
    }

    return null;
  }

  String? _extractBanglishYoutubeQuery(String text) {
    final patterns = [
      RegExp(
          r'youtube\s+(?:e|te|theke)\s+(.+?)(?:\s+(?:khojo|search koro|dekhao|dekha|play koro))?$',
          caseSensitive: false),
      RegExp(r'youtube\s+search\s+koro\s+(.+)', caseSensitive: false),
      RegExp(r'youtube\s+(?:e|te)\s+(.+)', caseSensitive: false),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final q = m.group(1)?.trim() ?? '';
        if (q.isNotEmpty) return q;
      }
    }
    return null;
  }

  String? _extractBanglishCallTarget(String text) {
    final patterns = [
      RegExp(r'(?:call|phone)\s+(?:koro|kor|de|dao)\s+(.+)',
          caseSensitive: false),
      RegExp(r'(.+?)\s+ke\s+(?:call|phone)\s+(?:koro|kor|de|dao)',
          caseSensitive: false),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final name = m.group(1)?.trim() ?? '';
        if (name.isNotEmpty) return name;
      }
    }
    return null;
  }

  String? _extractBanglishAppName(String text) {
    final patterns = [
      RegExp(
          r'(.+?)\s+(?:kholo|khola|kholun|open koro|open kor|on koro|on kor|calu koro|chalu koro|start koro|start kor)',
          caseSensitive: false),
      RegExp(
          r'(?:kholo|khola|kholun|open koro|open kor|on koro|on kor|calu koro|chalu koro|start koro|start kor)\s+(.+)',
          caseSensitive: false),
    ];

    for (final p in patterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        final name = m.group(1)?.trim() ?? '';
        final cleaned = name
            .replaceAll(
                RegExp(r'\b(amake|ami|please|plz|pls|ektu|ta|er)\b',
                    caseSensitive: false),
                '')
            .trim();
        if (cleaned.isNotEmpty) return cleaned;
      }
    }
    return null;
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
            'Banglish: "Facebook kholo", "torch on koro", "wifi off koro"\n\n'
            'Just type or tap the mic to start!',
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
