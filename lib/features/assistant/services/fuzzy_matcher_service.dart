import 'package:string_similarity/string_similarity.dart';
import '../domain/entities/app_info.dart';
import '../domain/entities/contact_info.dart';

/// Provides fuzzy string matching for app names and contacts.
/// Uses Dice coefficient similarity via the string_similarity package.
class FuzzyMatcherService {
  /// Minimum similarity score (0.0–1.0) to consider a match valid.
  static const double _appThreshold = 0.55;
  static const double _contactThreshold = 0.50;

  /// Finds the single best-matching app for [query] or null if below threshold.
  AppInfo? findBestAppMatch(String query, List<AppInfo> apps) {
    if (apps.isEmpty) return null;

    final normalized = _normalize(query);

    double bestScore = 0.0;
    AppInfo? bestMatch;

    for (final app in apps) {
      final appNorm = _normalize(app.name);

      double score = StringSimilarity.compareTwoStrings(normalized, appNorm);

      // Bonus for prefix / contains match
      if (appNorm.startsWith(normalized) || appNorm.contains(normalized)) {
        score = (score + 1.0) / 2; // boost towards 1.0
      }
      if (normalized.contains(appNorm) && appNorm.length > 3) {
        score = (score + 0.9) / 2;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = app;
      }
    }

    if (bestScore >= _appThreshold) {
      return bestMatch;
    }
    return null;
  }

  /// Returns all contacts with similarity above threshold.
  List<ContactInfo> findContactMatches(
      String query, List<ContactInfo> contacts) {
    final normalized = _normalize(query);
    final results = <MapEntry<ContactInfo, double>>[];

    for (final contact in contacts) {
      final nameParts = contact.normalizedName.split(' ');

      // Score against full name
      double score = StringSimilarity.compareTwoStrings(
          normalized, contact.normalizedName);

      // Also check each part (first/last name separately)
      for (final part in nameParts) {
        final partScore = StringSimilarity.compareTwoStrings(normalized, part);
        if (partScore > score) score = partScore;
      }

      // Boost if query is contained in name
      if (contact.normalizedName.contains(normalized)) {
        score = (score + 1.0) / 2;
      }

      if (score >= _contactThreshold) {
        results.add(MapEntry(contact, score));
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.value.compareTo(a.value));

    return results.map((e) => e.key).toList();
  }

  String _normalize(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }
}
