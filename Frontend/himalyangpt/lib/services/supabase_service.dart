import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> saveMessage(String userId, String role, String content) async {
    try {
      await _client.from('messages').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'role': role,
        'content': content,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save message to history.');
    }
  }

  Future<List<Message>> loadHistory(String userId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      final List<dynamic> data = response;
      return data.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to load chat history.');
    }
  }

  Future<void> clearHistory(String userId) async {
    try {
      await _client.from('messages').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear chat history.');
    }
  }
}