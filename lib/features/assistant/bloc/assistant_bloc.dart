import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/context_repository.dart';
import '../domain/usecases/get_installed_apps_usecase.dart';
import '../domain/usecases/process_command_usecase.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import 'assistant_event_state.dart';
import '../../../../core/utils/result.dart';

/// The main BLoC that powers the assistant UI.
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
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
    AssistantInitializedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    emit(state.copyWith(status: AssistantStatus.loading));

    // Load installed apps
    final result = await getInstalledAppsUseCase();
    final apps = result is Success ? (result as Success).data : [];

    // Initialize speech recognizer in background
    speechService.initialize();

    // Welcome message
    final welcome = _makeAssistantMessage(
      '👋 Hi! I\'m your AI Assistant.\n\n'
      'I can help you:\n'
      '• 📱 Open any app — "open whatsapp"\n'
      '• 📞 Call contacts — "call mom"\n'
      '• 🌐 Open websites — "open google.com"\n'
      '• ▶️ Search YouTube — "search dart tutorial on youtube"\n\n'
      'Tap the mic or type your command!',
    );

    emit(state.copyWith(
      status: AssistantStatus.idle,
      installedApps: apps,
      messages: [welcome],
      clearError: true,
    ));
  }

  Future<void> _onCommandSubmitted(
    CommandSubmittedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final command = event.command.trim();
    if (command.isEmpty) return;

    // Add user message
    final userMsg = _makeUserMessage(command);
    emit(state.copyWith(
      status: AssistantStatus.processing,
      messages: [...state.messages, userMsg],
      clearPartial: true,
    ));

    // Process the command
    try {
      final response = await processCommandUseCase(command);

      final assistantMsg = _makeAssistantMessage(response.message);

      emit(state.copyWith(
        status: AssistantStatus.idle,
        messages: [...state.messages, assistantMsg],
      ));

      // Speak the response
      if (state.ttsEnabled) {
        ttsService.speak(
            response.message.replaceAll(RegExp(r'[✅📞❌▶️🌐📱👋•🤔❓]'), ''));
      }

      // If multiple contacts, show selection
      if (response.contactChoices != null &&
          response.contactChoices!.isNotEmpty) {
        // BLoC doesn't directly show dialogs — this is handled in the UI layer
        // by checking messages for contactChoices indicator
        final selectionMsg = _makeAssistantMessage(
          '📋 Multiple matches:\n${response.contactChoices!.map((c) => '• ${c.name} (${c.phoneNumber})').join('\n')}\n\nTap a contact above to call.',
          contactChoices: response.contactChoices,
        );
        emit(state.copyWith(
          messages: [...state.messages, selectionMsg],
        ));
      }
    } catch (e) {
      final errMsg = _makeAssistantMessage('⚠️ Something went wrong: $e');
      emit(state.copyWith(
        status: AssistantStatus.idle,
        messages: [...state.messages, errMsg],
      ));
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
        emit(state.copyWith(messages: [...state.messages, errMsg]));
        return;
      }
    }

    emit(state.copyWith(status: AssistantStatus.listening));

    await speechService.startListening(
      onResult: (text, isFinal) {
        if (isFinal && text.isNotEmpty) {
          add(CommandSubmittedEvent(text));
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
    emit(state.copyWith(
      status: AssistantStatus.idle,
      installedApps: apps,
      messages: [...state.messages, msg],
    ));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
