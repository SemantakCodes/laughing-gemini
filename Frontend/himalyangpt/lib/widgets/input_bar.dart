import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class InputBar extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;
  final VoidCallback onFocus;

  const InputBar({
    super.key,
    required this.onSend,
    required this.isLoading,
    required this.onFocus,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = _hasText && !widget.isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Type in Nepali or English...',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canSend ? null : AppTheme.border,
                  gradient: canSend
                      ? const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 1.0],
                          transform: GradientRotation(135 * 3.14159 / 180),
                        )
                      : null,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: canSend ? Colors.white : AppTheme.textMuted,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}