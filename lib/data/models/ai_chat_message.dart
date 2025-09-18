import 'package:hive/hive.dart';

part 'ai_chat_message.g.dart';

@HiveType(typeId: 10)
class AIChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final MessageRole role;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final MessageType type;

  @HiveField(5)
  final Map<String, dynamic>? metadata;

  @HiveField(6)
  final List<String>? attachments; // Base64 images

  @HiveField(7)
  final bool isStreaming;

  @HiveField(8)
  final String? error;

  AIChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.type = MessageType.text,
    this.metadata,
    this.attachments,
    this.isStreaming = false,
    this.error,
  });

  // Factory constructor for creating user messages
  factory AIChatMessage.user({
    required String content,
    MessageType type = MessageType.text,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      type: type,
      attachments: attachments,
      metadata: metadata,
    );
  }

  // Factory constructor for creating assistant messages
  factory AIChatMessage.assistant({
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
    bool isStreaming = false,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
      isStreaming: isStreaming,
    );
  }

  // Factory constructor for creating system messages
  factory AIChatMessage.system({
    required String content,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.system,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  // Factory constructor for error messages
  factory AIChatMessage.error({
    required String error,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Xin lỗi, đã có lỗi xảy ra.',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      type: MessageType.text,
      error: error,
    );
  }

  // Copy with method for updating messages
  AIChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
    List<String>? attachments,
    bool? isStreaming,
    String? error,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error ?? this.error,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'metadata': metadata,
      'attachments': attachments,
      'isStreaming': isStreaming,
      'error': error,
    };
  }

  // Create from JSON
  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      isStreaming: json['isStreaming'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}

@HiveType(typeId: 11)
enum MessageRole {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system,
}

@HiveType(typeId: 12)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  location,
  @HiveField(3)
  suggestion,
  @HiveField(4)
  tripPlan,
  @HiveField(5)
  accommodation,
  @HiveField(6)
  tour,
  @HiveField(7)
  budget,
}