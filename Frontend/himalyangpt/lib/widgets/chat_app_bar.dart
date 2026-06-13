import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../screens/history_screen.dart';
import 'settings_dialog.dart';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 36,
                  height: 36,
                  color: AppTheme.primary,
                  child: const Center(child: Icon(Icons.person, color: Colors.white)),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sakshi AI',
                style: GoogleFonts.caveat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Helpful Assistant',
                style: GoogleFonts.nunito(
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
              } else if (value == 'settings') {
                showDialog(
                  context: context,
                  builder: (_) => const SettingsDialog(),
                );
              } else if (value == 'clear') {
                onClearChat();
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'Sakshi AI',
                  applicationVersion: '1.0.0',
                  applicationIcon: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/logo.png', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person)),
                  ),
                  children: [
                    Text('A helpful AI assistant.', style: GoogleFonts.nunito()),
                  ],
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'history',
                child: Text('Chat History', style: GoogleFonts.nunito(color: AppTheme.textPrimary)),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('API Settings', style: GoogleFonts.nunito(color: AppTheme.textPrimary)),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text('Clear Chat', style: GoogleFonts.nunito(color: AppTheme.textPrimary)),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text('About', style: GoogleFonts.nunito(color: AppTheme.textPrimary)),
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