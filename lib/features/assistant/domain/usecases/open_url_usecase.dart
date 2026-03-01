import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/result.dart';

class OpenUrlUseCase {
  OpenUrlUseCase();

  Future<Result<String>> call(String url) async {
    try {
      String cleanUrl = url.trim();
      final hasScheme =
          RegExp(r'^[a-z0-9]+:', caseSensitive: false).hasMatch(cleanUrl);
      if (!hasScheme) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);
      final isYouTubeSearch = _isYouTubeSearchUrl(uri);

      if (isYouTubeSearch) {
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
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return Success('Opened YouTube in browser');
        }
        return Failure('Cannot open YouTube');
      }
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
