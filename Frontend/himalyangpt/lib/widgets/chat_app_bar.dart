import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../screens/history_screen.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onClearChat;

  const ChatAppBar({super.key, required this.onClearChat});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                'ह',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HimalayaGPT',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '0.5B Instruct',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Tooltip(
          message: 'Options',
          child: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: AppTheme.textMuted),
            ),
            child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.surface,
            onSelected: (value) {
              if (value == 'history') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              } else if (value == 'clear') {
                onClearChat();
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'HimalayaGPT',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Text('ह', style: TextStyle(color: AppTheme.primary, fontSize: 24)),
                  children: [
                    Text('A Nepali-focused AI assistant.', style: GoogleFonts.dmSans()),
                  ],
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'history',
                child: Text('Chat History', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear Chat', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About', style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
              ),
            ],
          ),
        ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}