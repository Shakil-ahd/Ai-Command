import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/contact_info.dart';
import '../../domain/repositories/contact_repository.dart';

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
    // Sanitize phone number
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      return false;
    } catch (e) {
      print('[ContactRepositoryImpl] makeCall error: $e');
      return false;
    }
  }
}
