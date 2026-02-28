import 'package:equatable/equatable.dart';

/// Represents a device contact.
class ContactInfo extends Equatable {
  final String name;
  final String phoneNumber;
  final String? thumbnailPath;

  const ContactInfo({
    required this.name,
    required this.phoneNumber,
    this.thumbnailPath,
  });

  /// Normalized lowercase name for fuzzy matching.
  String get normalizedName => name.toLowerCase().trim();

  @override
  List<Object?> get props => [phoneNumber];

  @override
  String toString() => 'ContactInfo(name: $name, phone: $phoneNumber)';
}
