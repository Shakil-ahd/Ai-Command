import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/context_repository.dart';
import '../domain/usecases/get_installed_apps_usecase.dart';
import '../domain/usecases/process_command_usecase.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'assistant_event_state.dart';
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
    on<TtsToggledEvent>(_onTtsToggled);
    on<RefreshAppsEvent>(_onRefreshApps);
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

    List<ChatMessage> messages = await contextRepository.getMessages();

    if (messages.isEmpty) {
      messages = [
        _makeAssistantMessage(
          '👋 Hi, I am SakoAI, how can I help you?\n\n'
          'Here are some tips on what you can ask me to do:\n\n'
          '📱 Open apps (e.g. "open WhatsApp" or "ফেসবুক ওপেন করো")\n'
          '📞 Call contacts (e.g. "call mom" or "বাবাকে কল করো")\n'
          '🌐 Open websites (e.g. "open google.com")\n'
          '▶️ Search YouTube (e.g. "search funny cats on youtube")\n'
          '🔦 Control flashlight (e.g. "turn on flashlight" or "টর্চ জ্বালাও")\n'
          '⚙️ Open Settings (e.g. "open wifi settings" or "ওয়াইফাই অন করো")\n'
          '📷 Open Camera (e.g. "take a photo" or "ক্যামেরা ওপেন করো")\n\n'
          'Tap the mic or type your command to get started!',
        )
      ];
      await contextRepository.saveMessages(messages);
    }

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
        // Keep only the first welcome message
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
      localeId:
          contextRepository.getPreferredLanguage() == 'bn' ? 'bn_BD' : 'en_US',
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
    final command = 'call ${event.contact.phoneNumber}';
    add(CommandSubmittedEvent(command));
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
    final msg = _makeAssistantMessage(
        '🔄 App list refreshed! Found ${apps.length} apps.');

    final updated = [...state.messages, msg];
    emit(state.copyWith(
      status: AssistantStatus.idle,
      installedApps: apps,
      messages: updated,
    ));
    await contextRepository.saveMessages(updated);
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

    // Keep only the first welcome message
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

  ChatMessage _makeAssistantMessage(String text, {List? contactChoices}) =>
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
      );

  @override
  Future<void> close() {
    speechService.dispose();
    ttsService.dispose();
    return super.close();
  }
}
