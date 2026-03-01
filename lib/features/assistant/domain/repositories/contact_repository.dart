import '../entities/contact_info.dart';

abstract class ContactRepository {
  Future<List<ContactInfo>> getContacts();
  Future<bool> makeCall(String phoneNumber);
}
