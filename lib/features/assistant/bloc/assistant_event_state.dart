import 'package:equatable/equatable.dart';
import '../domain/entities/app_info.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/contact_info.dart';

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();
  @override
  List<Object?> get props => [];
}

class AssistantInitializedEvent extends AssistantEvent {}

class CallEndedEvent extends AssistantEvent {}

class IncomingCallEvent extends AssistantEvent {
  final String callerName;
  const IncomingCallEvent({required this.callerName});

  @override
  List<Object?> get props => [callerName];
}

class CommandSubmittedEvent extends AssistantEvent {
  final String command;
  final bool isVoice;
  const CommandSubmittedEvent(this.command, {this.isVoice = false});
  @override
  List<Object?> get props => [command, isVoice];
}

class VoiceRecordingStartedEvent extends AssistantEvent {}

class VoiceRecordingStoppedEvent extends AssistantEvent {}

class SpeechPartialResultEvent extends AssistantEvent {
  final String partial;
  const SpeechPartialResultEvent(this.partial);
  @override
  List<Object?> get props => [partial];
}

class ContactSelectedEvent extends AssistantEvent {
  final ContactInfo contact;
  const ContactSelectedEvent(this.contact);
  @override
  List<Object?> get props => [contact];
}

class TtsToggledEvent extends AssistantEvent {}

class RefreshAppsEvent extends AssistantEvent {}

class ClearNotificationEvent extends AssistantEvent {}

class ClearChatHistoryEvent extends AssistantEvent {}

class DeleteMessageEvent extends AssistantEvent {
  final String messageId;
  const DeleteMessageEvent(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

enum AssistantStatus { idle, listening, processing, loading, error }

class AssistantState extends Equatable {
  final AssistantStatus status;
  final String? errorMessage;
  final List<ChatMessage> messages;
  final List<AppInfo> installedApps;
  final String? partialSpeech;
  final bool ttsEnabled;
  final String? notificationMessage;

  const AssistantState({
    this.status = AssistantStatus.loading,
    this.errorMessage,
    this.messages = const [],
    this.installedApps = const [],
    this.partialSpeech,
    this.ttsEnabled = true,
    this.notificationMessage,
  });

  AssistantState copyWith({
    AssistantStatus? status,
    String? errorMessage,
    List<ChatMessage>? messages,
    List<AppInfo>? installedApps,
    String? partialSpeech,
    bool? ttsEnabled,
    String? notificationMessage,
    bool clearError = false,
    bool clearPartial = false,
    bool clearNotification = false,
  }) {
    return AssistantState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      messages: messages ?? this.messages,
      installedApps: installedApps ?? this.installedApps,
      partialSpeech:
          clearPartial ? null : (partialSpeech ?? this.partialSpeech),
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      notificationMessage: clearNotification
          ? null
          : (notificationMessage ?? this.notificationMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        messages,
        installedApps,
        partialSpeech,
        ttsEnabled,
        notificationMessage,
      ];
}
