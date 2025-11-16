import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';

class AIStorageService extends GetxService {
  static AIStorageService get to => Get.find();

  // Box names
  static const String _conversationsBoxName = 'ai_conversations';
  static const String _messagesBoxName = 'ai_messages';
  static const String _settingsBoxName = 'ai_settings';

  // Hive boxes
  late Box<AIConversation> _conversationsBox;
  late Box<AIChatMessage> _messagesBox;
  late Box _settingsBox;

  // Reactive state
  final RxBool isInitialized = false.obs;
  final RxList<AIConversation> conversations = <AIConversation>[].obs;
  final Rx<AIConversation?> currentConversation = Rx<AIConversation?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
  }

  // Initialize Hive storage
  Future<void> _initializeStorage() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(AIChatMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(MessageRoleAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(MessageTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(AIConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(14)) {
        Hive.registerAdapter(ConversationContextAdapter());
      }

      // Open boxes
      _conversationsBox = await Hive.openBox<AIConversation>(_conversationsBoxName);
      _messagesBox = await Hive.openBox<AIChatMessage>(_messagesBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      // Load conversations
      await loadConversations();

      isInitialized.value = true;
      LoggerService.i('AI Storage service initialized successfully');
    } catch (e) {
      LoggerService.e('Failed to initialize AI storage', error: e);
    }
  }

  // Load all conversations
  Future<void> loadConversations() async {
    try {
      final allConversations = _conversationsBox.values.toList();
      
      // Sort by updated date (newest first)
      allConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Move pinned conversations to top
      allConversations.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });

      conversations.value = allConversations;
      LoggerService.i('Loaded ${allConversations.length} conversations');
    } catch (e) {
      LoggerService.e('Error loading conversations', error: e);
    }
  }

  // Create new conversation
  Future<AIConversation> createConversation({
    String? title,
    ConversationContext context = ConversationContext.general,
    String? tripId,
    String? userId,
  }) async {
    try {
      final conversation = AIConversation.create(
        title: title,
        context: context,
        tripId: tripId,
        userId: userId,
      );

      await _conversationsBox.put(conversation.id, conversation);

      // Insert new conversation at the correct position
      // New conversations go to top unless there are pinned conversations
      final pinnedCount = conversations.where((c) => c.isPinned).length;
      conversations.insert(pinnedCount, conversation);

      currentConversation.value = conversation;
      LoggerService.i('Created new conversation: ${conversation.id}');

      return conversation;
    } catch (e) {
      LoggerService.e('Error creating conversation', error: e);
      rethrow;
    }
  }

  // Get conversation by ID
  AIConversation? getConversation(String id) {
    return _conversationsBox.get(id);
  }

  // Update conversation
  Future<void> updateConversation(AIConversation conversation) async {
    try {
      conversation.updatedAt = DateTime.now();
      await _conversationsBox.put(conversation.id, conversation);

      // Update in-memory list without reloading from storage
      final index = conversations.indexWhere((c) => c.id == conversation.id);
      if (index != -1) {
        conversations[index] = conversation;
      }

      if (currentConversation.value?.id == conversation.id) {
        currentConversation.value = conversation;
      }

      LoggerService.i('Updated conversation: ${conversation.id}');
    } catch (e) {
      LoggerService.e('Error updating conversation', error: e);
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String id) async {
    try {
      // Delete associated messages
      final conversation = _conversationsBox.get(id);
      if (conversation != null) {
        for (final message in conversation.messages) {
          await _messagesBox.delete(message.id);
        }
      }

      // Delete conversation
      await _conversationsBox.delete(id);
      await loadConversations();
      
      if (currentConversation.value?.id == id) {
        currentConversation.value = null;
      }
      
      LoggerService.i('Deleted conversation: $id');
    } catch (e) {
      LoggerService.e('Error deleting conversation', error: e);
    }
  }

  // Toggle pin status
  Future<void> togglePinConversation(String id) async {
    try {
      final conversation = _conversationsBox.get(id);
      if (conversation != null) {
        conversation.isPinned = !conversation.isPinned;
        await updateConversation(conversation);
      }
    } catch (e) {
      LoggerService.e('Error toggling pin status', error: e);
    }
  }

  // Add message to conversation
  Future<void> addMessageToConversation(
    String conversationId,
    AIChatMessage message,
  ) async {
    try {
      final conversation = _conversationsBox.get(conversationId);
      if (conversation != null) {
        // Save message to messages box
        await _messagesBox.put(message.id, message);
        
        // Add to conversation
        conversation.addMessage(message);
        await updateConversation(conversation);
        
        LoggerService.i('Added message to conversation: $conversationId');
      }
    } catch (e) {
      LoggerService.e('Error adding message', error: e);
    }
  }

  // Update message (for streaming)
  Future<void> updateMessage(
    String conversationId,
    String messageId,
    String content,
  ) async {
    try {
      final conversation = _conversationsBox.get(conversationId);
      if (conversation != null) {
        conversation.updateLastMessage(content);
        await _conversationsBox.put(conversationId, conversation);
        
        // Update in current conversation if it's the active one
        if (currentConversation.value?.id == conversationId) {
          currentConversation.value = conversation;
        }
      }
    } catch (e) {
      LoggerService.e('Error updating message', error: e);
    }
  }

  // Finish streaming
  Future<void> finishStreaming(String conversationId) async {
    try {
      final conversation = _conversationsBox.get(conversationId);
      if (conversation != null) {
        conversation.finishStreaming();
        await updateConversation(conversation);
      }
    } catch (e) {
      LoggerService.e('Error finishing streaming', error: e);
    }
  }

  // Clear all messages in conversation
  Future<void> clearConversationMessages(String id) async {
    try {
      final conversation = _conversationsBox.get(id);
      if (conversation != null) {
        // Delete messages from messages box
        for (final message in conversation.messages) {
          await _messagesBox.delete(message.id);
        }
        
        // Clear messages in conversation
        conversation.clearMessages();
        await updateConversation(conversation);
      }
    } catch (e) {
      LoggerService.e('Error clearing messages', error: e);
    }
  }

  // Search conversations
  List<AIConversation> searchConversations(String query) {
    if (query.isEmpty) return conversations;

    final lowerQuery = query.toLowerCase();
    return conversations.where((conv) {
      return conv.title.toLowerCase().contains(lowerQuery) ||
          conv.messages.any((msg) => 
            msg.content.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Get conversations by context
  List<AIConversation> getConversationsByContext(ConversationContext context) {
    return conversations.where((conv) => conv.context == context).toList();
  }

  // Get conversations for a specific trip
  List<AIConversation> getConversationsForTrip(String tripId) {
    return conversations.where((conv) => conv.tripId == tripId).toList();
  }

  // Save AI settings
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
      LoggerService.i('Saved setting: $key = $value');
    } catch (e) {
      LoggerService.e('Error saving setting', error: e);
    }
  }

  // Get AI setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settingsBox.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      LoggerService.e('Error getting setting', error: e);
      return defaultValue;
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      await _conversationsBox.clear();
      await _messagesBox.clear();
      await _settingsBox.clear();
      
      conversations.clear();
      currentConversation.value = null;
      
      LoggerService.i('Cleared all AI data');
    } catch (e) {
      LoggerService.e('Error clearing data', error: e);
    }
  }

  // Export conversations to JSON
  Map<String, dynamic> exportToJson() {
    return {
      'conversations': conversations.map((c) => c.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  // Import conversations from JSON
  Future<void> importFromJson(Map<String, dynamic> json) async {
    try {
      final conversationsList = json['conversations'] as List;
      
      for (final convJson in conversationsList) {
        final conversation = AIConversation.fromJson(convJson);
        await _conversationsBox.put(conversation.id, conversation);
        
        // Save messages
        for (final message in conversation.messages) {
          await _messagesBox.put(message.id, message);
        }
      }
      
      await loadConversations();
      LoggerService.i('Imported ${conversationsList.length} conversations');
    } catch (e) {
      LoggerService.e('Error importing conversations', error: e);
    }
  }

  // Get storage statistics
  Map<String, dynamic> getStorageStats() {
    final totalConversations = _conversationsBox.length;
    final totalMessages = _messagesBox.length;
    
    int totalCharacters = 0;
    for (final conv in conversations) {
      for (final msg in conv.messages) {
        totalCharacters += msg.content.length;
      }
    }

    return {
      'totalConversations': totalConversations,
      'totalMessages': totalMessages,
      'totalCharacters': totalCharacters,
      'oldestConversation': conversations.isNotEmpty 
          ? conversations.last.createdAt 
          : null,
      'newestConversation': conversations.isNotEmpty 
          ? conversations.first.createdAt 
          : null,
    };
  }

  @override
  void onClose() {
    _conversationsBox.close();
    _messagesBox.close();
    _settingsBox.close();
    super.onClose();
  }
}