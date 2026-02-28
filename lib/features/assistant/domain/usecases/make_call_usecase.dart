import '../entities/contact_info.dart';
import '../repositories/contact_repository.dart';
import '../../services/fuzzy_matcher_service.dart';
import '../../../../core/utils/result.dart';

/// Result type for call actions — may yield multiple matches.
sealed class CallResult {}

class CallSuccess extends CallResult {
  final ContactInfo contact;
  CallSuccess(this.contact);
}

class CallMultipleMatches extends CallResult {
  final List<ContactInfo> contacts;
  CallMultipleMatches(this.contacts);
}

class CallNotFound extends CallResult {
  final String query;
  CallNotFound(this.query);
}

class CallError extends CallResult {
  final String message;
  CallError(this.message);
}

/// Makes a phone call using fuzzy contact matching.
class MakeCallUseCase {
  final ContactRepository _contactRepository;
  final FuzzyMatcherService _fuzzyMatcher;

  MakeCallUseCase(this._contactRepository, this._fuzzyMatcher);

  Future<CallResult> call({
    required String contactName,
    List<ContactInfo>? cachedContacts,
  }) async {
    try {
      final contacts = cachedContacts ?? await _contactRepository.getContacts();

      if (contacts.isEmpty) {
        return CallError(
            'No contacts found. Please grant contacts permission.');
      }

      final matches = _fuzzyMatcher.findContactMatches(contactName, contacts);

      // Check if the input is already a number
      final isNumber = RegExp(r'^\+?[0-9]{5,}$')
          .hasMatch(contactName.replaceAll(RegExp(r'[\s\-\(\)]'), ''));

      if (matches.isEmpty && !isNumber) {
        return CallNotFound(contactName);
      }

      if (isNumber && (matches.isEmpty || matches.length > 1)) {
        final number = contactName.replaceAll(RegExp(r'[^\d+]'), '');
        await _contactRepository.makeCall(number);
        return CallSuccess(ContactInfo(name: contactName, phoneNumber: number));
      }

      if (matches.length == 1) {
        await _contactRepository.makeCall(matches.first.phoneNumber);
        return CallSuccess(matches.first);
      }

      // Multiple matches — let user pick
      return CallMultipleMatches(matches);
    } catch (e) {
      return CallError('Error making call: $e');
    }
  }

  /// Call a specific contact (after user selection from multiple matches).
  Future<Result<ContactInfo>> callExact(ContactInfo contact) async {
    try {
      await _contactRepository.makeCall(contact.phoneNumber);
      return Success(contact);
    } catch (e) {
      return Failure('Could not call ${contact.name}', error: e);
    }
  }
}
