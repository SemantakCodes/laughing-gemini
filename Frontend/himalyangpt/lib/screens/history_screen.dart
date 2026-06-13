import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/message.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  String? _error;
  Map<String, List<Message>> _groupedMessages = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final messages = await _supabaseService.loadHistory(globalUserId);
      final Map<String, List<Message>> grouped = {};
      
      for (var msg in messages) {
        final dateStr = DateFormat('yyyy-MM-dd').format(msg.timestamp);
        grouped.putIfAbsent(dateStr, () => []).add(msg);
      }

      setState(() {
        _groupedMessages = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load history. Please try again.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!, style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat History',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error != null && _groupedMessages.isEmpty) {
      return Center(
        child: Text(
          _error!,
          style: GoogleFonts.dmSans(color: AppTheme.textSecondary),
        ),
      );
    }

    if (_groupedMessages.isEmpty) {
      return Center(
        child: Text(
          'No history yet',
          style: GoogleFonts.dmSans(color: AppTheme.textMuted),
        ),
      );
    }

    final sortedDates = _groupedMessages.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest date first

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final messages = _groupedMessages[date]!;
        
        final DateTime parsedDate = DateTime.parse(date);
        final dateLabel = DateFormat('MMMM d, yyyy').format(parsedDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  dateLabel.toUpperCase(),
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
            ...messages.map((msg) => MessageBubble(
                  message: msg,
                  isCondensed: true,
                )),
          ],
        );
      },
    );
  }
}