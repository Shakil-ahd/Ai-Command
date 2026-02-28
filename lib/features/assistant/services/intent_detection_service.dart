import '../domain/entities/command_intent.dart';

/// Detects the user's intent from raw text input.
///
/// This is the "AI brain" layer — currently rule-based / regex.
/// Designed to be swapped out for Gemini API in a future upgrade.
class IntentDetectionService {
  // ── Pattern groups ────────────────────────────────────────────────────────
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

  // Multi-command connectors
  static final _multiCommandSplitter = RegExp(
    r'\s+(and then|then|and|also|after that|next|plus)\s+',
    caseSensitive: false,
  );

  IntentDetectionService();

  /// Parses [rawText] and returns the best-matching [CommandIntent].
  CommandIntent detect(String rawText) {
    final text = rawText.trim();

    // 1. Reopen check
    if (_reopenPatterns.hasMatch(text)) {
      return CommandIntent(type: IntentType.reopen, rawText: text);
    }

    // 2. Multi-command check — split on connectors then recurse
    final parts = text.split(_multiCommandSplitter);
    if (parts.length > 1) {
      final subIntents = parts
          .map((p) => detect(p.trim()))
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

    // 3. URL check
    final urlMatch = _urlPattern.firstMatch(text);
    if (urlMatch != null &&
        !_openPatterns
            .hasMatch(text.split(RegExp(r'\s+url\s+|\s+link\s+')).first)) {
      // If the text is predominantly a URL or starts/contains a URL-like string
      final isLikelyUrl = _looksLikeUrl(text);
      if (isLikelyUrl) {
        return CommandIntent(
          type: IntentType.openUrl,
          rawText: text,
          url: urlMatch.group(0),
        );
      }
    }

    // 4. YouTube search
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

    // 5. Call intent
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

    // 6. Open/launch intent
    if (_openPatterns.hasMatch(text)) {
      final appName = _extractEntityAfterVerb(text, _openPatterns);
      if (appName != null && appName.isNotEmpty) {
        // Check if the "app name" looks like a URL
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

    // 7. Bare URL (no verb)
    if (urlMatch != null) {
      return CommandIntent(
        type: IntentType.openUrl,
        rawText: text,
        url: urlMatch.group(0),
      );
    }

    // 8. Unknown
    return CommandIntent(type: IntentType.unknown, rawText: text);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extracts the entity (app name or contact name) that comes after the verb.
  String? _extractEntityAfterVerb(String text, RegExp verbPattern) {
    final match = verbPattern.firstMatch(text);
    if (match == null) return null;

    final afterVerb = text.substring(match.end).trim();
    // Remove filler words
    final cleaned = afterVerb
        .replaceAll(
            RegExp(r'^(the|a|an|my|that|this)\s+', caseSensitive: false), '')
        .trim();

    // Take up to first punctuation or connector
    final stop = RegExp(r'\s+(and|or|then|,|\.)\s+', caseSensitive: false);
    final stopMatch = stop.firstMatch(cleaned);
    return stopMatch == null ? cleaned : cleaned.substring(0, stopMatch.start);
  }

  /// Extracts the YouTube search query from text like:
  /// "search flutter tutorial on youtube" → "flutter tutorial"
  String? _extractYouTubeQuery(String text) {
    // Pattern: search <query> on youtube
    final pattern1 = RegExp(
      r'\b(?:search|find|look up|look for|play|watch)\s+(.+?)\s+(?:on|in|via|using|at)?\s*youtube\b',
      caseSensitive: false,
    );
    final m1 = pattern1.firstMatch(text);
    if (m1 != null) return m1.group(1)?.trim();

    // Pattern: youtube search for <query>
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
