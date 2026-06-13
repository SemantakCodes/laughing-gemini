import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// API response model from the backend
class ChatApiResponse {
  final String reply;
  final String userId;
  final String model;
  final int? tokensUsed;
  final String? conversationId;

  ChatApiResponse({
    required this.reply,
    required this.userId,
    required this.model,
    this.tokensUsed,
    this.conversationId,
  });

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      reply: json['reply'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      model: json['model'] as String? ?? 'gemini-2.0-flash',
      tokensUsed: json['tokens_used'] as int?,
      conversationId: json['conversation_id'] as String?,
    );
  }
}

class ApiService {
  /// Base URL configuration for different environments
  /// For local development on Android emulator: http://10.0.2.2:8000
  /// For local development on iOS simulator: http://localhost:8000
  /// For production: your Railway/deployed URL
  static String get _baseUrl {
    // Try to load from environment or use default
    // Default to Android emulator address
    return const String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'laughing-gemini-production.up.railway.app',
    );
  }

  static const String _chatEndpoint = '/api/chat';
  static const String _healthEndpoint = '/api/health';
  static const int _timeoutSeconds = 30;

  /// Health check to verify backend connectivity
  Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$_healthEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw Exception('Health check timed out'),
          );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send a message to the backend and receive a reply
  ///
  /// Throws exceptions with user-friendly messages:
  /// - "Rate limit reached. Please wait a moment before sending more messages."
  /// - "Backend API error. Please try again."
  /// - "Network error. Please check your connection."
  /// - "Request timed out. Please try again."
  Future<ChatApiResponse> sendMessage(
    String message,
    String userId, {
    String? conversationId,
    String? apiKey,
  }) async {
    if (message.trim().isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    if (userId.isEmpty) {
      throw Exception('User ID is required.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_chatEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': message.trim(),
              'user_id': userId,
              if (conversationId != null) 'conversation_id': conversationId,
              if (apiKey != null && apiKey.trim().isNotEmpty)
                'api_key': apiKey.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () =>
                throw Exception('Request timed out. Please try again.'),
          );

      // Handle different HTTP status codes
      switch (response.statusCode) {
        case 200:
          // Success
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            return ChatApiResponse.fromJson(data);
          } catch (e) {
            throw Exception('Failed to parse response from backend.');
          }

        case 429:
          // Rate limit exceeded
          throw Exception(
            'Rate limit reached. Please wait a moment before sending more messages. (Max 12 requests per minute on free tier)',
          );

        case 422:
          // Validation error
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final detail = data['detail'];
            if (detail is List && detail.isNotEmpty) {
              final error = detail[0] as Map<String, dynamic>?;
              throw Exception(
                'Invalid input: ${error?['msg'] ?? 'Unknown validation error'}',
              );
            } else if (detail is String) {
              throw Exception('Invalid input: $detail');
            } else {
              throw Exception('Invalid request format.');
            }
          } catch (e) {
            throw Exception('Invalid request format.');
          }

        case 502:
          // Bad gateway (Gemini API error)
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final detail = data['detail'] as String?;
            throw Exception(
              'Backend API error: ${detail ?? 'Please try again.'}',
            );
          } catch (e) {
            throw Exception('Backend API error. Please try again.');
          }

        case 500:
          // Internal server error
          try {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final detail = data['detail'] as String?;
            throw Exception(
              'Server error: ${detail ?? 'Please try again later.'}',
            );
          } catch (e) {
            throw Exception('Server error. Please try again later.');
          }

        default:
          throw Exception(
            'Failed to get response (HTTP ${response.statusCode}). Please check your backend.',
          );
      }
    } on SocketException {
      throw Exception('Network error. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      // Re-throw our custom exceptions, otherwise wrap generic ones
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      throw Exception(
        'Network error. Please check your connection and backend URL.',
      );
    }
  }

  /// Get the configured backend URL (useful for debugging)
  String getBackendUrl() => _baseUrl;
}
