import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/assistant_bloc.dart';
import '../../bloc/assistant_event_state.dart';
import '../../bloc/permission_bloc.dart';
import '../../bloc/permission_event_state.dart';
import '../../domain/entities/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/command_input_bar.dart';
import '../widgets/listening_indicator.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _bgController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    _bgController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          _AnimatedBackground(controller: _bgController),
          SafeArea(
            child: Column(
              children: [
                _AppBar(pulseController: _pulseController),
                Expanded(
                  child: BlocConsumer<AssistantBloc, AssistantState>(
                    listener: (ctx, state) {
                      _scrollToBottom();
                      if (state.notificationMessage != null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.notificationMessage!,
                              style: GoogleFonts.outfit(color: Colors.white),
                            ),
                            backgroundColor: AppTheme.bgSurface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        context
                            .read<AssistantBloc>()
                            .add(ClearNotificationEvent());
                      }
                    },
                    builder: (ctx, state) {
                      if (state.status == AssistantStatus.loading) {
                        return const _LoadingView();
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: _ChatList(
                              messages: state.messages,
                              scrollController: _scrollController,
                            ),
                          ),
                          if (state.partialSpeech != null &&
                              state.partialSpeech!.isNotEmpty)
                            _PartialSpeechPreview(text: state.partialSpeech!),
                          if (state.status == AssistantStatus.listening)
                            const ListeningIndicator(),
                          if (state.status == AssistantStatus.processing)
                            const _ProcessingDots(),
                          if (state.status == AssistantStatus.idle)
                            _SuggestionChips(
                              onTap: (text) {
                                context
                                    .read<AssistantBloc>()
                                    .add(CommandSubmittedEvent(text));
                              },
                            ),
                          CommandInputBar(
                            textController: _textController,
                            focusNode: _focusNode,
                            isListening:
                                state.status == AssistantStatus.listening,
                            isProcessing:
                                state.status == AssistantStatus.processing,
                            ttsEnabled: state.ttsEnabled,
                            onSubmit: (text) {
                              context
                                  .read<AssistantBloc>()
                                  .add(CommandSubmittedEvent(text));
                              _textController.clear();
                            },
                            onVoiceTap: () {
                              final bloc = context.read<AssistantBloc>();
                              if (state.status == AssistantStatus.listening) {
                                bloc.add(VoiceRecordingStoppedEvent());
                              } else {
                                bloc.add(VoiceRecordingStartedEvent());
                              }
                            },
                            onTtsToggle: () {
                              context
                                  .read<AssistantBloc>()
                                  .add(TtsToggledEvent());
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<PermissionBloc, PermissionState>(
            builder: (ctx, permState) {
              if (permState.isChecking) return const SizedBox.shrink();
              if (!permState.micGranted) {
                return _PermissionOverlay(
                  onGrant: () => context
                      .read<PermissionBloc>()
                      .add(RequestPermissionsEvent()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final AnimationController pulseController;
  const _AppBar({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseController,
            builder: (_, __) => Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor
                        .withOpacity(0.3 + pulseController.value * 0.2),
                    blurRadius: 12 + pulseController.value * 8,
                    spreadRadius: 1 + pulseController.value * 2,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 22)
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(delay: 2000.ms, duration: 2000.ms)
                      .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.1, 1.1),
                          duration: 1000.ms,
                          curve: Curves.easeInOut),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SakoAI',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                BlocBuilder<AssistantBloc, AssistantState>(
                  builder: (ctx, state) {
                    final statusText = switch (state.status) {
                      AssistantStatus.idle => '● Online',
                      AssistantStatus.listening => '🎙️ Listening…',
                      AssistantStatus.processing => '⚙️ Processing…',
                      AssistantStatus.loading => '⏳ Loading…',
                      AssistantStatus.error => '⚠️ Error',
                    };
                    return Text(
                      statusText,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: state.status == AssistantStatus.idle
                            ? AppTheme.successColor
                            : AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AssistantBloc>().add(RefreshAppsEvent());
              context.read<AssistantBloc>().add(ClearChatHistoryEvent());
            },
            icon: const Icon(Icons.refresh_rounded, size: 22),
            color: AppTheme.textSecondary,
            tooltip: 'Refresh & Clear Chat',
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1500.ms, color: Colors.white30)
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                  curve: Curves.easeInOut)
              .rotate(duration: 5000.ms)
              .animate()
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 32),
          Text(
            'SakoAI',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Your Personal AI',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _ChatList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (ctx, index) {
        final msg = messages[index];
        return ChatBubble(
          message: msg,
          key: ValueKey(msg.id),
        ).animate().fadeIn(duration: 300.ms).slideY(
            begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _PartialSpeechPreview extends StatelessWidget {
  final String text;
  const _PartialSpeechPreview({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.mic, color: AppTheme.accentColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 150.ms);
  }
}

class _ProcessingDots extends StatelessWidget {
  const _ProcessingDots();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(
                begin: 0.5,
                end: 1.2,
                delay: Duration(milliseconds: i * 150),
                duration: const Duration(milliseconds: 600),
              )
              .then()
              .scaleXY(
                  begin: 1.2,
                  end: 0.5,
                  duration: const Duration(milliseconds: 600));
        }),
      ),
    );
  }
}

class _PermissionOverlay extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionOverlay({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgDeep.withOpacity(0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: AppTheme.primaryColor, size: 36),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                'Permissions Required',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'AI Assistant needs microphone access for voice commands. Contacts and Phone permissions enable calling features.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onGrant,
                  icon: const Icon(Icons.security_rounded),
                  label: const Text('Grant Permissions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _BgPainter(controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF080818), Color(0xFF0D0D28), Color(0xFF080818)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    _drawOrb(canvas, size, Color(0xFF6C63FF), 0.2, 0.15, 200, t);
    _drawOrb(canvas, size, Color(0xFF00D4FF), 0.8, 0.5, 150, 1 - t);
    _drawOrb(canvas, size, Color(0xFF6C63FF), 0.5, 0.9, 100, t * 0.7);
  }

  void _drawOrb(Canvas canvas, Size size, Color color, double xFrac,
      double yFrac, double radius, double alpha) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..color = color.withOpacity(0.08 + alpha * 0.06);

    canvas.drawCircle(
      Offset(size.width * xFrac, size.height * yFrac),
      radius + alpha * 30,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _SuggestionChips extends StatelessWidget {
  final Function(String) onTap;

  const _SuggestionChips({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Who is SakoAI?',
      'What can you do?',
      'Open YouTube',
      'Play sad song',
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: AppTheme.bgSurface.withOpacity(0.8),
              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text(
                suggestions[index],
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => onTap(suggestions[index]),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }
}
