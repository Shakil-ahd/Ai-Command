import 'package:connectivity_plus/connectivity_plus.dart';
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
    r'\b(turn on flashlight|flashlight on|torch on|turn on torch)\b',
    caseSensitive: false,
  );

  static final _flashlightOffPatterns = RegExp(
    r'\b(turn off flashlight|flashlight off|torch off|turn off torch)\b',
    caseSensitive: false,
  );

  IntentDetectionService(this.geminiService);

  Future<CommandIntent> detect(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty)
      return CommandIntent(type: IntentType.unknown, rawText: text);

    // Hybrid Mode: Check Internet
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      final geminiIntent = await geminiService.detectIntentWithGemini(text);
      if (geminiIntent != null && geminiIntent.type != IntentType.unknown) {
        return geminiIntent;
      }
    }

    // Fallback: Local rule-based NLP
    return _fallbackDetect(text);
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
    final pattern1 = RegExp(
      r'\b(?:search|find|look up|look for|play|watch)\s+(.+?)\s+(?:on|in|via|using|at)?\s*youtube\b',
      caseSensitive: false,
    );
    final m1 = pattern1.firstMatch(text);
    if (m1 != null) return m1.group(1)?.trim();

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
