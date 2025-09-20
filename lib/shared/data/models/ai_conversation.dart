import 'package:hive/hive.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';

part 'ai_conversation.g.dart';

@HiveType(typeId: 13)
class AIConversation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<AIChatMessage> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  ConversationContext context;

  @HiveField(6)
  Map<String, dynamic> settings;

  @HiveField(7)
  bool isPinned;

  @HiveField(8)
  String? tripId; // Link to a specific trip

  @HiveField(9)
  String? userId;

  @HiveField(10)
  Map<String, dynamic>? metadata;

  AIConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.context,
    Map<String, dynamic>? settings,
    this.isPinned = false,
    this.tripId,
    this.userId,
    this.metadata,
  }) : settings = settings ?? _defaultSettings();

  // Factory constructor for creating new conversation
  factory AIConversation.create({
    String? title,
    ConversationContext context = ConversationContext.general,
    String? tripId,
    String? userId,
  }) {
    final now = DateTime.now();
    return AIConversation(
      id: now.millisecondsSinceEpoch.toString(),
      title: title ?? _getDefaultTitle(context),
      messages: [],
      createdAt: now,
      updatedAt: now,
      context: context,
      tripId: tripId,
      userId: userId,
    );
  }

  // Add message to conversation
  void addMessage(AIChatMessage message) {
    messages.add(message);
    updatedAt = DateTime.now();
    
    // Auto-generate title from first user message if not set
    if (title.startsWith('Chat ') && 
        message.role == MessageRole.user && 
        messages.length == 1) {
      final preview = message.content.length > 50 
          ? '${message.content.substring(0, 50)}...'
          : message.content;
      title = preview;
    }
    
    save(); // Hive auto-save
  }

  // Update last message (for streaming)
  void updateLastMessage(String content) {
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      if (lastMessage.role == MessageRole.assistant) {
        messages[messages.length - 1] = lastMessage.copyWith(
          content: content,
          isStreaming: true,
        );
        save();
      }
    }
  }

  // Finish streaming message
  void finishStreaming() {
    if (messages.isNotEmpty) {
      final lastMessage = messages.last;
      if (lastMessage.isStreaming) {
        messages[messages.length - 1] = lastMessage.copyWith(
          isStreaming: false,
        );
        save();
      }
    }
  }

  // Clear all messages
  void clearMessages() {
    messages.clear();
    updatedAt = DateTime.now();
    save();
  }

  // Get message count
  int get messageCount => messages.length;

  // Get last message preview
  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    final lastMessage = messages.last;
    final content = lastMessage.content;
    return content.length > 100 
        ? '${content.substring(0, 100)}...'
        : content;
  }

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
    }
  }

  // Copy with method
  AIConversation copyWith({
    String? id,
    String? title,
    List<AIChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationContext? context,
    Map<String, dynamic>? settings,
    bool? isPinned,
    String? tripId,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return AIConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      context: context ?? this.context,
      settings: settings ?? this.settings,
      isPinned: isPinned ?? this.isPinned,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'context': context.name,
      'settings': settings,
      'isPinned': isPinned,
      'tripId': tripId,
      'userId': userId,
      'metadata': metadata,
    };
  }

  // Create from JSON
  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((m) => AIChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      context: ConversationContext.values.firstWhere(
        (e) => e.name == json['context'],
        orElse: () => ConversationContext.general,
      ),
      settings: json['settings'] as Map<String, dynamic>? ?? _defaultSettings(),
      isPinned: json['isPinned'] as bool? ?? false,
      tripId: json['tripId'] as String?,
      userId: json['userId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Default settings
  static Map<String, dynamic> _defaultSettings() {
    return {
      'temperature': 0.7,
      'maxTokens': 1024,
      'language': 'vi',
      'streamResponse': true,
    };
  }

  // Get default title based on context
  static String _getDefaultTitle(ConversationContext context) {
    switch (context) {
      case ConversationContext.general:
        return 'Chat ${DateTime.now().day}/${DateTime.now().month}';
      case ConversationContext.tripPlanning:
        return 'Lập kế hoạch chuyến đi';
      case ConversationContext.accommodation:
        return 'Tìm chỗ ở';
      case ConversationContext.emergency:
        return 'Hỗ trợ khẩn cấp';
      case ConversationContext.translation:
        return 'Dịch thuật';
      case ConversationContext.budget:
        return 'Tính toán chi phí';
      case ConversationContext.cultural:
        return 'Văn hóa & phong tục';
      case ConversationContext.food:
        return 'Ẩm thực địa phương';
      case ConversationContext.weather:
        return 'Thời tiết';
    }
  }
}

@HiveType(typeId: 14)
enum ConversationContext {
  @HiveField(0)
  general,
  @HiveField(1)
  tripPlanning,
  @HiveField(2)
  accommodation,
  @HiveField(3)
  emergency,
  @HiveField(4)
  translation,
  @HiveField(5)
  budget,
  @HiveField(6)
  cultural,
  @HiveField(7)
  food,
  @HiveField(8)
  weather,
}