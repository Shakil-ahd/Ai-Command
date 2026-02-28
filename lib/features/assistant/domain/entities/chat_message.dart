import 'package:equatable/equatable.dart';

/// Represents a single user ↔ assistant message in the chat.
class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.delivered,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, text, sender, timestamp, status];
}

enum MessageSender { user, assistant }

enum MessageStatus { sending, delivered, error }
