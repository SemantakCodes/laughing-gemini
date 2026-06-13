import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../main.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/input_bar.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final SupabaseService _supabaseService = SupabaseService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  bool _isConnected = true;
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (mounted) {
        setState(() {
          _isConnected = !results.contains(ConnectivityResult.none);
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = !results.contains(ConnectivityResult.none);
      });
    }
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

  void _showErrorSnackBar(String errorText) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorText, style: GoogleFonts.dmSans(color: Colors.white)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty || _isBotTyping) return;

    final userMessage = Message(
      id: const Uuid().v4(),
      content: text.trim(),
      role: Role.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isBotTyping = true;
    });
    _scrollToBottom();

    final loadingId = const Uuid().v4();
    final loadingMessage = Message(
      id: loadingId,
      content: '',
      role: Role.bot,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(loadingMessage);
    });
    _scrollToBottom();

    try {
      // 1. Fetch AI Reply
      final response = await _apiService.sendMessage(
        userMessage.content,
        globalUserId,
      );

      // 2. Replace loading message with actual response
      setState(() {
        final index = _messages.indexWhere((m) => m.id == loadingId);
        if (index != -1) {
          _messages[index] = Message(
            id: loadingId,
            content: response.reply,
            role: Role.bot,
            timestamp: DateTime.now(),
          );
        }
        _isBotTyping = false;
      });
      _scrollToBottom();

      // 3. Save to Supabase
      await _supabaseService.saveMessage(globalUserId, 'user', userMessage.content);
      await _supabaseService.saveMessage(globalUserId, 'bot', response.reply);

    } catch (e) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == loadingId);
        if (index != -1) {
          _messages[index] = Message(
            id: loadingId,
            content: 'Error: Could not fetch response.',
            role: Role.bot,
            timestamp: DateTime.now(),
            isError: true,
          );
        }
        _isBotTyping = false;
      });
      _scrollToBottom();
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _clearChat() async {
    setState(() {
      _messages.clear();
    });
    try {
      await _supabaseService.clearHistory(globalUserId);
    } catch (e) {
      _showErrorSnackBar('Could not delete remote history.');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        onClearChat: _clearChat,
      ),
      body: Column(
        children: [
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppTheme.border,
              child: Text(
                'No connection · responses may be delayed',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppTheme.primaryDark, fontSize: 12),
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          InputBar(
            onSend: _handleSendMessage,
            isLoading: _isBotTyping,
            onFocus: _scrollToBottom,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'नमस्ते!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything in Nepali or English',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'नेपाली · Indic · English · Code · Math',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}