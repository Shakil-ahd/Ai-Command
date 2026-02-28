import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// The bottom input bar with text field, voice button, and TTS toggle.
class CommandInputBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isListening;
  final bool isProcessing;
  final bool ttsEnabled;
  final void Function(String) onSubmit;
  final VoidCallback onVoiceTap;
  final VoidCallback onTtsToggle;

  const CommandInputBar({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isListening,
    required this.isProcessing,
    required this.ttsEnabled,
    required this.onSubmit,
    required this.onVoiceTap,
    required this.onTtsToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          // TTS toggle
          _IconBtn(
            icon:
                ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: ttsEnabled ? AppTheme.accentColor : AppTheme.textHint,
            tooltip: ttsEnabled ? 'Mute assistant' : 'Unmute assistant',
            onTap: onTtsToggle,
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isListening
                      ? AppTheme.accentColor.withOpacity(0.6)
                      : AppTheme.primaryColor.withOpacity(0.25),
                  width: isListening ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      focusNode: focusNode,
                      enabled: !isListening && !isProcessing,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) onSubmit(val.trim());
                      },
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            isListening ? 'Listening…' : 'Type a command…',
                        hintStyle: GoogleFonts.outfit(
                          color: isListening
                              ? AppTheme.accentColor.withOpacity(0.7)
                              : AppTheme.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  // Send button (only when text is present)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textController,
                    builder: (_, val, __) {
                      final hasText = val.text.trim().isNotEmpty;
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: hasText
                            ? GestureDetector(
                                key: const ValueKey('send'),
                                onTap: () {
                                  if (textController.text.trim().isNotEmpty) {
                                    onSubmit(textController.text.trim());
                                    textController.clear();
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 18),
                                ),
                              )
                            : const SizedBox(key: ValueKey('empty'), width: 8),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Voice button
          _VoiceButton(
            isListening: isListening,
            onTap: onVoiceTap,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const _VoiceButton({required this.isListening, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: isListening
              ? const LinearGradient(
                  colors: [Color(0xFFFF4081), Color(0xFFFF6B35)],
                )
              : AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening
                      ? const Color(0xFFFF4081)
                      : AppTheme.primaryColor)
                  .withOpacity(0.45),
              blurRadius: isListening ? 20 : 10,
              spreadRadius: isListening ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.stop_rounded : Icons.mic_rounded,
          color: Colors.white,
          size: 24,
        ),
      )
          .animate(target: isListening ? 1 : 0)
          .scaleXY(begin: 1.0, end: 1.08, duration: 600.ms)
          .then()
          .scaleXY(begin: 1.08, end: 1.0, duration: 600.ms),
    );
  }
}
