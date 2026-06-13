import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../theme/app_theme.dart';
import 'typing_indicator.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCondensed;

  const MessageBubble({
    super.key,
    required this.message,
    this.isCondensed = false,
  });

  void _copyToClipboard(BuildContext context) {
    if (message.isLoading) return;
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message copied', style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeString = DateFormat('hh:mm a').format(message.timestamp);

    Widget bubbleContent = Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.userBubble : AppTheme.botBubble,
            borderRadius: isUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
            boxShadow: isUser
                ? []
                : [
                    const BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black12,
                    )
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser && !message.isLoading) ...[
                Text(
                  'himalaya',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (message.isLoading)
                const TypingIndicator()
              else
                Text(
                  message.content,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: message.isError
                        ? AppTheme.error
                        : (isUser ? AppTheme.userBubbleText : AppTheme.botBubbleText),
                    height: 1.4,
                  ),
                ),
            ],
          ),
        ),
        if (!isCondensed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              timeString,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );

    if (!isCondensed) {
      bubbleContent = bubbleContent
          .animate()
          .slideY(begin: 0.2, end: 0, duration: 250.ms, curve: Curves.easeOut)
          .fadeIn(duration: 250.ms);
    }

    return GestureDetector(
      onLongPress: () => _copyToClipboard(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: alignment,
          children: [bubbleContent],
        ),
      ),
    );
  }
}