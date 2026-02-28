import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/result.dart';

/// Opens URLs intelligently:
/// - YouTube links → YouTube app (or browser fallback)
/// - Other links   → default browser
class OpenUrlUseCase {
  OpenUrlUseCase();

  Future<Result<String>> call(String url) async {
    try {
      String cleanUrl = url.trim();

      // Ensure protocol prefix, but allow custom schemes like spotify:
      final hasScheme =
          RegExp(r'^[a-z0-9]+:', caseSensitive: false).hasMatch(cleanUrl);
      if (!hasScheme) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);
      final isYouTubeSearch = _isYouTubeSearchUrl(uri);

      if (isYouTubeSearch) {
        // Build youtube:// deep link to open YouTube app directly
        final query = uri.queryParameters['search_query'] ?? '';
        if (query.isNotEmpty) {
          final ytAppUri = Uri.parse(
              'youtube://results?search_query=${Uri.encodeComponent(query)}');
          if (await canLaunchUrl(ytAppUri)) {
            await launchUrl(ytAppUri,
                mode: LaunchMode.externalNonBrowserApplication);
            return const Success('Opened in YouTube app');
          }
        }
        // Fallback: open YouTube in browser
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return Success('Opened YouTube in browser');
        }
        return Failure('Cannot open YouTube');
      }

      // For all other YouTube links (watch, etc.)
      if (_isYouTubeUrl(uri)) {
        final videoId = uri.queryParameters['v'];
        if (videoId != null) {
          final ytAppUri = Uri.parse('youtube://watch?v=$videoId');
          if (await canLaunchUrl(ytAppUri)) {
            await launchUrl(ytAppUri,
                mode: LaunchMode.externalNonBrowserApplication);
            return const Success('Opened in YouTube');
          }
        }
      }

      // Fallback to external browser
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return Success('Opened: $cleanUrl');
      }

      return Failure('Cannot open: $cleanUrl');
    } catch (e) {
      return Failure('Error opening URL: $e', error: e);
    }
  }

  bool _isYouTubeSearchUrl(Uri uri) {
    return (uri.host.contains('youtube.com') ||
            uri.host.contains('m.youtube.com')) &&
        uri.path.contains('/results');
  }

  bool _isYouTubeUrl(Uri uri) {
    return uri.host.contains('youtube.com') ||
        uri.host.contains('youtu.be') ||
        uri.host.contains('m.youtube.com');
  }
}
