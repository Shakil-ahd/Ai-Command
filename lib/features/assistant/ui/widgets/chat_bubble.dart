import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../bloc/assistant_bloc.dart';
import '../../bloc/assistant_event_state.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/contact_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;

  const ChatBubble({required this.message, this.onDelete, super.key});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool get isUser => widget.message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _AssistantAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: isUser
                ? _UserBubble(message: widget.message)
                : _AssistantBubble(message: widget.message),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _UserAvatar(),
        ],
      ),
    );
  }
}

// ── User bubble (static, no animation needed) ──────────────────
class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              color: Colors.white,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Assistant bubble with typewriter animation ──────────────────
class _AssistantBubble extends StatefulWidget {
  final ChatMessage message;
  const _AssistantBubble({required this.message});

  @override
  State<_AssistantBubble> createState() => _AssistantBubbleState();
}

class _AssistantBubbleState extends State<_AssistantBubble> {
  String _displayedText = '';
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.shouldAnimate) {
      _startTypewriter();
    } else {
      _displayedText = widget.message.text;
      _animationDone = true;
    }
  }

  void _startTypewriter() async {
    final words = widget.message.text.split(' ');
    final buffer = StringBuffer();
    for (final word in words) {
      if (!mounted) return;
      buffer.write('$word ');
      setState(() => _displayedText = buffer.toString().trimRight());
      await Future.delayed(const Duration(milliseconds: 40));
    }
    if (mounted) setState(() => _animationDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black45, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _displayedText,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
          if (!_animationDone)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _BlinkCursor(),
            ),
          if (_animationDone)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTime(widget.message.timestamp),
                style:
                    GoogleFonts.outfit(fontSize: 10, color: AppTheme.textHint),
              ),
            ),
          if (_animationDone && widget.message.contactChoices != null)
            _ContactChoicesList(choices: widget.message.contactChoices!),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: -0.05, end: 0, duration: 200.ms);
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// Blinking cursor like ChatGPT
class _BlinkCursor extends StatefulWidget {
  @override
  State<_BlinkCursor> createState() => _BlinkCursorState();
}

class _BlinkCursorState extends State<_BlinkCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value,
        child: Container(
          width: 2,
          height: 15,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

class _AssistantAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
      ),
      child: const Icon(Icons.person_rounded,
          color: AppTheme.accentColor, size: 18),
    );
  }
}

class _ContactChoicesList extends StatelessWidget {
  final List<ContactInfo> choices;
  const _ContactChoicesList({required this.choices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: choices.map((c) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.person_rounded,
                    color: AppTheme.primaryColor, size: 18),
              ),
              title: Text(
                c.name,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                c.phoneNumber,
                style: GoogleFonts.outfit(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              trailing: Icon(Icons.call_rounded,
                  color: AppTheme.successColor, size: 18),
              onTap: () {
                context.read<AssistantBloc>().add(ContactSelectedEvent(c));
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
