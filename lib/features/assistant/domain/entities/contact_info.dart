import 'package:equatable/equatable.dart';

class ContactInfo extends Equatable {
  final String name;
  final String phoneNumber;
  final String? thumbnailPath;

  const ContactInfo({
    required this.name,
    required this.phoneNumber,
    this.thumbnailPath,
  });
  String get normalizedName => name.toLowerCase().trim();

  @override
  List<Object?> get props => [phoneNumber];

  @override
  String toString() => 'ContactInfo(name: $name, phone: $phoneNumber)';
}
