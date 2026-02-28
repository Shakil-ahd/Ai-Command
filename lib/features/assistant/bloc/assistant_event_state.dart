import 'package:equatable/equatable.dart';
import '../domain/entities/app_info.dart';
import '../domain/entities/chat_message.dart';
import '../domain/entities/contact_info.dart';

// ═══════════════════════════════════════════════════════════════
//  EVENTS
// ═══════════════════════════════════════════════════════════════

abstract class AssistantEvent extends Equatable {
  const AssistantEvent();
  @override
  List<Object?> get props => [];
}

/// Called once on startup to load installed apps & warmup.
class AssistantInitializedEvent extends AssistantEvent {}

/// User submitted a text command.
class CommandSubmittedEvent extends AssistantEvent {
  final String command;
  const CommandSubmittedEvent(this.command);
  @override
  List<Object?> get props => [command];
}

/// Voice recording started.
class VoiceRecordingStartedEvent extends AssistantEvent {}

/// Voice recording stopped.
class VoiceRecordingStoppedEvent extends AssistantEvent {}

/// Partial speech result received (live transcription).
class SpeechPartialResultEvent extends AssistantEvent {
  final String partial;
  const SpeechPartialResultEvent(this.partial);
  @override
  List<Object?> get props => [partial];
}

/// User selected one contact from a multi-match list.
class ContactSelectedEvent extends AssistantEvent {
  final ContactInfo contact;
  const ContactSelectedEvent(this.contact);
  @override
  List<Object?> get props => [contact];
}

/// User toggled TTS on/off.
class TtsToggledEvent extends AssistantEvent {}

/// User requests to refresh the app list.
class RefreshAppsEvent extends AssistantEvent {}

// ═══════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════

enum AssistantStatus {
  loading,
  idle,
  listening,
  processing,
  error,
}

class AssistantState extends Equatable {
  final AssistantStatus status;
  final List<ChatMessage> messages;
  final List<AppInfo> installedApps;
  final String? partialSpeech;
  final bool ttsEnabled;
  final String? errorMessage;

  const AssistantState({
    this.status = AssistantStatus.loading,
    this.messages = const [],
    this.installedApps = const [],
    this.partialSpeech,
    this.ttsEnabled = true,
    this.errorMessage,
  });

  AssistantState copyWith({
    AssistantStatus? status,
    List<ChatMessage>? messages,
    List<AppInfo>? installedApps,
    String? partialSpeech,
    bool? ttsEnabled,
    String? errorMessage,
    bool clearPartial = false,
    bool clearError = false,
  }) {
    return AssistantState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      installedApps: installedApps ?? this.installedApps,
      partialSpeech:
          clearPartial ? null : (partialSpeech ?? this.partialSpeech),
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        installedApps,
        partialSpeech,
        ttsEnabled,
        errorMessage,
      ];
}
