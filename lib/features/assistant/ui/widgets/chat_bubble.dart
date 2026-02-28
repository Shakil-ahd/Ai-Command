import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';

/// A single chat bubble in the conversation.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({required this.message, super.key});

  bool get isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _AssistantAvatar(),
          if (!isUser) const SizedBox(width: 8),
          Flexible(child: _BubbleContent(message: message, isUser: isUser)),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _UserAvatar(),
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _BubbleContent({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: isUser ? AppTheme.primaryGradient : null,
        color: isUser ? null : AppTheme.bgElevated,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
        border: isUser
            ? null
            : Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? AppTheme.primaryColor.withOpacity(0.25)
                : Colors.black38,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            message.text,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              color: isUser ? Colors.white : AppTheme.textPrimary,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: isUser ? Colors.white54 : AppTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 8,
          ),
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
