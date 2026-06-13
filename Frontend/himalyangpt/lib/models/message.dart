enum Role { user, bot }

class Message {
  final String id;
  final String content;
  final Role role;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;

  Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] == 'user' ? Role.user : Role.bot,
      timestamp: DateTime.parse(json['created_at'] as String).toLocal(),
      isLoading: false,
      isError: false,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'role': role == Role.user ? 'user' : 'bot',
      'created_at': timestamp.toUtc().toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? content,
    Role? role,
    DateTime? timestamp,
    bool? isLoading,
    bool? isError,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}