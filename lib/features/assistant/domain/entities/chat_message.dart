import 'package:equatable/equatable.dart';
import 'contact_info.dart';

/// Represents a single user ↔ assistant message in the chat.
class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;
  final bool shouldAnimate;
  final List<ContactInfo>? contactChoices;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.delivered,
    this.shouldAnimate = false,
    this.contactChoices,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    bool? shouldAnimate,
    List<ContactInfo>? contactChoices,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
      shouldAnimate: shouldAnimate ?? this.shouldAnimate,
      contactChoices: contactChoices ?? this.contactChoices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'shouldAnimate': shouldAnimate,
      'contactChoices': contactChoices
          ?.map((c) => {
                'name': c.name,
                'phoneNumber': c.phoneNumber,
              })
          .toList(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => MessageSender.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.delivered,
      ),
      shouldAnimate: json['shouldAnimate'] as bool? ?? false,
      contactChoices: (json['contactChoices'] as List?)
          ?.map((c) => ContactInfo(
                name: c['name'],
                phoneNumber: c['phoneNumber'],
              ))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [id, text, sender, timestamp, status, shouldAnimate, contactChoices];
}

enum MessageSender { user, assistant }

enum MessageStatus { sending, delivered, error }
