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

      // Ensure protocol prefix
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);
      final isYouTube = _isYouTubeUrl(uri);

      if (isYouTube) {
        // Try YouTube native app first
        final ytUri = Uri.parse(cleanUrl);
        if (await canLaunchUrl(ytUri)) {
          await launchUrl(ytUri,
              mode: LaunchMode.externalNonBrowserApplication);
          return const Success('Opened in YouTube');
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

  bool _isYouTubeUrl(Uri uri) {
    return uri.host.contains('youtube.com') ||
        uri.host.contains('youtu.be') ||
        uri.host.contains('m.youtube.com');
  }
}
