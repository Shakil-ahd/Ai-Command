import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/context_repository.dart';
import '../domain/usecases/get_installed_apps_usecase.dart';
import '../domain/usecases/process_command_usecase.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'assistant_event_state.dart';
import '../domain/entities/contact_info.dart';
import '../../../../core/utils/result.dart';

class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  final ProcessCommandUseCase processCommandUseCase;
  final GetInstalledAppsUseCase getInstalledAppsUseCase;
  final SpeechService speechService;
  final TtsService ttsService;
  final ContextRepository contextRepository;

  AssistantBloc({
    required this.processCommandUseCase,
    required this.getInstalledAppsUseCase,
    required this.speechService,
    required this.ttsService,
    required this.contextRepository,
  }) : super(const AssistantState()) {
    on<AssistantInitializedEvent>(_onInitialized);
    on<CommandSubmittedEvent>(_onCommandSubmitted);
    on<VoiceRecordingStartedEvent>(_onVoiceStarted);
    on<VoiceRecordingStoppedEvent>(_onVoiceStopped);
    on<SpeechPartialResultEvent>(_onSpeechPartial);
    on<ContactSelectedEvent>(_onContactSelected);
    on<CallEndedEvent>(_onCallEnded);
    on<IncomingCallEvent>(_onIncomingCall);
    on<TtsToggledEvent>(_onTtsToggled);
    on<RefreshAppsEvent>(_onRefreshApps);
    on<ClearNotificationEvent>(_onClearNotification);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
    on<DeleteMessageEvent>(_onDeleteMessage);
  }

  Future<void> _onInitialized(
    AssistantInitializedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    emit(state.copyWith(status: AssistantStatus.loading));

    final result = await getInstalledAppsUseCase();
    final apps = result is Success ? (result as Success).data : [];

    speechService.initialize();

    // Listen for call state from native
    const MethodChannel('com.assistant/call_state')
        .setMethodCallHandler((call) async {
      if (call.method == 'onCallEnded') {
        add(CallEndedEvent());
      } else if (call.method == 'onIncomingCall') {
        final callerName = call.arguments as String?;
        add(IncomingCallEvent(callerName: callerName ?? 'Unknown'));
      }
    });

    List<ChatMessage> messages = await contextRepository.getMessages();

    if (messages.isEmpty) {
      messages = [
        _makeAssistantMessage(
          'Hi, I am SakoAI. How can I help you today?',
          shouldAnimate: true,
        )
      ];
      await contextRepository.saveMessages(messages);
    }

    await Future.delayed(const Duration(milliseconds: 1200));

    emit(state.copyWith(
      status: AssistantStatus.idle,
      installedApps: apps,
      messages: messages,
      clearError: true,
    ));
  }

  Future<void> _onCommandSubmitted(
    CommandSubmittedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final command = event.command.trim();
    if (command.isEmpty) return;

    final userMsg = _makeUserMessage(command);
    final userMessages = [...state.messages, userMsg];
    emit(state.copyWith(
      status: AssistantStatus.processing,
      messages: userMessages,
      clearPartial: true,
    ));
    await contextRepository.saveMessages(userMessages);

    try {
      final response = await processCommandUseCase(command);
      final assistantMsg = _makeAssistantMessage(response.message);

      List<ChatMessage> finalMessages;
      if (response.clearChat) {
        final welcomeMsg =
            state.messages.isNotEmpty ? state.messages.first : assistantMsg;
        finalMessages = [welcomeMsg, assistantMsg];
      } else {
        finalMessages = [...userMessages, assistantMsg];
      }

      emit(state.copyWith(
        status: AssistantStatus.idle,
        messages: finalMessages,
      ));
      await contextRepository.saveMessages(finalMessages);

      if (state.ttsEnabled && event.isVoice) {
        ttsService.speak(
            response.message.replaceAll(RegExp(r'[✅📞❌▶️🌐📱👋•🤔❓🔦]'), ''));
      }

      if (response.contactChoices != null &&
          response.contactChoices!.isNotEmpty) {
        final selectionMsg = _makeAssistantMessage(
          '📋 Multiple matches:\n${response.contactChoices!.map((c) => '• ${c.name} (${c.phoneNumber})').join('\n')}\n\nTap a contact above to call.',
          contactChoices: response.contactChoices,
        );
        final finalWithChoice = [...finalMessages, selectionMsg];
        emit(state.copyWith(messages: finalWithChoice));
        await contextRepository.saveMessages(finalWithChoice);
      }
    } catch (e) {
      final errMsg = _makeAssistantMessage('⚠️ Something went wrong: $e');
      final errorMessages = [...userMessages, errMsg];
      emit(state.copyWith(
        status: AssistantStatus.idle,
        messages: errorMessages,
      ));
      await contextRepository.saveMessages(errorMessages);
    }
  }

  Future<void> _onVoiceStarted(
    VoiceRecordingStartedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    if (!speechService.isAvailable) {
      final ok = await speechService.initialize();
      if (!ok) {
        final errMsg = _makeAssistantMessage(
            '🎙️ Microphone not available. Please check permissions.');
        final updated = [...state.messages, errMsg];
        emit(state.copyWith(messages: updated));
        await contextRepository.saveMessages(updated);
        return;
      }
    }

    emit(state.copyWith(status: AssistantStatus.listening));

    await speechService.startListening(
      localeId: 'en_US',
      onResult: (text, isFinal) {
        if (isFinal && text.isNotEmpty) {
          add(CommandSubmittedEvent(text, isVoice: true));
        } else {
          add(SpeechPartialResultEvent(text));
        }
      },
      onDone: () {
        add(VoiceRecordingStoppedEvent());
      },
    );
  }

  Future<void> _onVoiceStopped(
    VoiceRecordingStoppedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    await speechService.stopListening();
    if (state.status == AssistantStatus.listening) {
      emit(state.copyWith(status: AssistantStatus.idle, clearPartial: true));
    }
  }

  void _onSpeechPartial(
    SpeechPartialResultEvent event,
    Emitter<AssistantState> emit,
  ) {
    emit(state.copyWith(partialSpeech: event.partial));
  }

  Future<void> _onContactSelected(
    ContactSelectedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final contact = event.contact;

    // 1. Log the selection in chat
    final userMsg = _makeUserMessage('Call ${contact.name}');
    List<ChatMessage> updated = [...state.messages, userMsg];

    emit(state.copyWith(
      status: AssistantStatus.processing,
      messages: updated,
    ));
    await contextRepository.saveMessages(updated);

    // 2. Perform the direct call
    try {
      await processCommandUseCase.makeCallUseCase.callExact(contact);

      final assistantMsg = _makeAssistantMessage('📞 Calling ${contact.name}…');
      final finalMessages = [...updated, assistantMsg];

      emit(state.copyWith(
        status: AssistantStatus.idle,
        messages: finalMessages,
      ));
      await contextRepository.saveMessages(finalMessages);

      if (state.ttsEnabled) {
        ttsService.speak('Calling ${contact.name}');
      }
    } catch (e) {
      final errMsg = _makeAssistantMessage('⚠️ Error making call: $e');
      final errMessages = [...updated, errMsg];
      emit(state.copyWith(status: AssistantStatus.idle, messages: errMessages));
    }
  }

  Future<void> _onCallEnded(
    CallEndedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final msg = _makeAssistantMessage('📞 Call Ended');
    final updated = [...state.messages, msg];
    emit(state.copyWith(messages: updated));
    await contextRepository.saveMessages(updated);
  }

  Future<void> _onIncomingCall(
    IncomingCallEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final callerText =
        event.callerName.trim().isEmpty ? 'Unknown' : event.callerName;
    final msg = _makeAssistantMessage('📲 Incoming Call from $callerText');
    final updated = [...state.messages, msg];
    emit(state.copyWith(messages: updated));
    await contextRepository.saveMessages(updated);
  }

  void _onTtsToggled(
    TtsToggledEvent event,
    Emitter<AssistantState> emit,
  ) {
    ttsService.toggle();
    emit(state.copyWith(ttsEnabled: !state.ttsEnabled));
  }

  Future<void> _onRefreshApps(
    RefreshAppsEvent event,
    Emitter<AssistantState> emit,
  ) async {
    emit(state.copyWith(status: AssistantStatus.loading));
    await processCommandUseCase.refreshCaches();
    final result = await getInstalledAppsUseCase();
    final apps =
        result is Success ? (result as Success).data : state.installedApps;

    emit(state.copyWith(
      status: AssistantStatus.idle,
      installedApps: apps,
      notificationMessage: '🔄 App list refreshed! Found ${apps.length} apps.',
    ));
  }

  void _onClearNotification(
    ClearNotificationEvent event,
    Emitter<AssistantState> emit,
  ) {
    emit(state.copyWith(clearNotification: true));
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final updated = List<ChatMessage>.from(state.messages)
      ..removeWhere((m) => m.id == event.messageId);

    emit(state.copyWith(messages: updated));
    await contextRepository.saveMessages(updated);
  }

  Future<void> _onClearChatHistory(
    ClearChatHistoryEvent event,
    Emitter<AssistantState> emit,
  ) async {
    if (state.messages.isEmpty) return;

    final welcomeMsg = state.messages.first;
    final updated = [welcomeMsg];

    emit(state.copyWith(messages: updated));
    await contextRepository.saveMessages(updated);
  }

  ChatMessage _makeUserMessage(String text) => ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );

  ChatMessage _makeAssistantMessage(String text,
          {List<ContactInfo>? contactChoices, bool shouldAnimate = false}) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            text.length.toString(),
        text: text,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        shouldAnimate: shouldAnimate,
        contactChoices: contactChoices,
      );

  @override
  Future<void> close() {
    speechService.dispose();
    ttsService.dispose();
    return super.close();
  }
}
