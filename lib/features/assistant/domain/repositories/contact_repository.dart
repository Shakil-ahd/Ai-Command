import '../entities/contact_info.dart';

/// Contract for contacts data source.
abstract class ContactRepository {
  /// Returns all device contacts that have at least one phone number.
  Future<List<ContactInfo>> getContacts();

  /// Initiates a phone call to [phoneNumber].
  Future<bool> makeCall(String phoneNumber);
}
