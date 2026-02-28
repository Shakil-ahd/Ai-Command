import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/contact_info.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../platform/android_app_launcher.dart';

/// Implements [ContactRepository] using the flutter_contacts package.
class ContactRepositoryImpl implements ContactRepository {
  @override
  Future<List<ContactInfo>> getContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      return contacts
          .where((c) => c.phones.isNotEmpty)
          .map((c) => ContactInfo(
                name: c.displayName,
                phoneNumber: c.phones.first.number,
              ))
          .toList();
    } catch (e) {
      print('[ContactRepositoryImpl] getContacts error: $e');
      return [];
    }
  }

  @override
  Future<bool> makeCall(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return false;

    // Try direct call first (no dialer)
    try {
      final success = await AndroidAppLauncher().directCall(cleaned);
      if (success) return true;
    } catch (_) {}

    // Fallback to standard dialer
    final uri = Uri.parse('tel:$cleaned');
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return success;
    } catch (e) {
      print('[ContactRepositoryImpl] makeCall error: $e');
      return false;
    }
  }
}
