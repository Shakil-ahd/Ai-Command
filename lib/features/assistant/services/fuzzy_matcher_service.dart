import 'package:string_similarity/string_similarity.dart';
import '../domain/entities/app_info.dart';
import '../domain/entities/contact_info.dart';

class FuzzyMatcherService {
  static const double _appThreshold = 0.55;
  static const double _contactThreshold = 0.50;
  AppInfo? findBestAppMatch(String query, List<AppInfo> apps) {
    if (apps.isEmpty) return null;

    final normalized = _normalize(query);

    double bestScore = 0.0;
    AppInfo? bestMatch;

    for (final app in apps) {
      final appNorm = _normalize(app.name);

      double score = StringSimilarity.compareTwoStrings(normalized, appNorm);
      if (appNorm.startsWith(normalized) || appNorm.contains(normalized)) {
        score = (score + 1.0) / 2;
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

  List<ContactInfo> findContactMatches(
      String query, List<ContactInfo> contacts) {
    if (query.isEmpty) return [];
    String cleanedQuery = _normalize(query);
    cleanedQuery =
        cleanedQuery.replaceAll(RegExp(r'\b(tx|xt|call|to)\b'), '').trim();
    if (cleanedQuery.isEmpty) cleanedQuery = _normalize(query);

    final results = <MapEntry<ContactInfo, double>>[];

    for (final contact in contacts) {
      final fullName = contact.normalizedName;
      final nameParts = fullName.split(' ');

      double score = 0.0;
      if (fullName == cleanedQuery) {
        score = 1.0;
      } else if (fullName.startsWith(cleanedQuery)) {
        score = 0.95;
      } else if (RegExp('\\b$cleanedQuery\\b').hasMatch(fullName)) {
        score = 0.9;
      } else {
        score = StringSimilarity.compareTwoStrings(cleanedQuery, fullName);
        for (final part in nameParts) {
          final partScore =
              StringSimilarity.compareTwoStrings(cleanedQuery, part);
          if (partScore > score) score = partScore * 0.9;
        }
        if (fullName.contains(cleanedQuery)) {
          score = (score + 1.0) / 2;
        }
      }

      if (score >= _contactThreshold) {
        results.add(MapEntry(contact, score));
      }
    }
    results.sort((a, b) => b.value.compareTo(a.value));
    final double maxScore = results.isNotEmpty ? results.first.value : 0.0;
    if (maxScore >= 0.9) {
      return results.where((e) => e.value >= 0.9).map((e) => e.key).toList();
    }

    return results.map((e) => e.key).toList();
  }

  String _normalize(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }
}
