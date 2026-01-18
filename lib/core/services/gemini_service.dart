import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';

class GeminiService extends GetxService {
  static GeminiService get to => Get.find();

  // Gemini API configuration - Load from .env for security
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _modelName = 'gemini-2.5-flash';

  // Gemini model instance
  late GenerativeModel _model;
  ChatSession? _currentSession;

  // Service state
  final RxBool isInitialized = false.obs;
  final RxBool isGenerating = false.obs;
  final RxString lastError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeGemini();
  }

  // Initialize Gemini model
  void _initializeGemini() {
    try {
      // Validate API key
      if (_apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not found. Please add GEMINI_API_KEY to .env file',
        );
      }

      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.9, // Increased for more creative and engaging responses
          maxOutputTokens: 8192, // MAX for Gemini Flash - full detailed responses
          topK: 40,
          topP: 0.95,
          stopSequences: [],
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      isInitialized.value = true;
      LoggerService.i('Gemini service initialized successfully');
    } catch (e) {
      LoggerService.e('Failed to initialize Gemini', error: e);
      lastError.value = e.toString();
    }
  }

  // Initialize or get chat session for a conversation
  ChatSession _getOrCreateSession(AIConversation conversation) {
    // Create history from existing messages
    final history = <Content>[];

    // Add system prompt based on context
    final systemPrompt = _getSystemPrompt(conversation.context);
    if (systemPrompt.isNotEmpty) {
      history.add(Content.text(systemPrompt));
    }

    // OPTIMIZATION: Limit history to avoid input token overflow
    // Keep only last 20 messages (10 exchanges) for context efficiency
    final messages = conversation.messages;
    final startIndex = messages.length > 20 ? messages.length - 20 : 0;
    final recentMessages = messages.sublist(startIndex);

    // Add recent messages to history
    for (final message in recentMessages) {
      if (message.role == MessageRole.user) {
        history.add(Content.text(message.content));
      } else if (message.role == MessageRole.assistant) {
        history.add(Content.model([TextPart(message.content)]));
      }
    }

    LoggerService.i('📝 Session created with ${history.length} history items (${recentMessages.length} recent messages)');

    // Create new session with history
    _currentSession = _model.startChat(history: history);
    return _currentSession!;
  }

  // Send message and get streaming response
  Stream<String> sendMessageStream({
    required AIConversation conversation,
    required String message,
    List<String>? imageBase64List,
  }) async* {
    if (!isInitialized.value) {
      throw Exception('Gemini service not initialized');
    }

    isGenerating.value = true;
    lastError.value = '';

    try {
      // Get or create session
      final session = _getOrCreateSession(conversation);

      // Prepare content parts
      final contentParts = <Part>[];
      
      // Add text message
      contentParts.add(TextPart(message));

      // Add images if provided
      if (imageBase64List != null && imageBase64List.isNotEmpty) {
        for (final base64Image in imageBase64List) {
          try {
            // Remove data URL prefix if present
            final base64Data = base64Image.contains(',')
                ? base64Image.split(',')[1]
                : base64Image;

            // Convert base64 to bytes
            final bytes = base64Decode(base64Data);
            contentParts.add(DataPart('image/jpeg', Uint8List.fromList(bytes)));
          } catch (e) {
            LoggerService.e('Error processing image', error: e);
          }
        }
      }

      // Create content
      final content = Content.multi(contentParts);

      // Send message and get streaming response
      final response = session.sendMessageStream(content);

      // Stream response chunks with AUTO-CONTINUE on MAX_TOKENS
      String fullResponse = '';
      bool shouldContinue = false;

      await for (final chunk in response) {
        final text = chunk.text ?? '';
        fullResponse += text;
        yield fullResponse;

        // Check finish reason - AUTO CONTINUE if hit max tokens
        if (chunk.candidates.isNotEmpty) {
          final candidate = chunk.candidates.first;
          final finishReason = candidate.finishReason?.toString() ?? '';

          // Log if response is blocked or stopped
          if (text.isEmpty) {
            LoggerService.w('Empty response - Safety ratings: ${candidate.safetyRatings}, Finish reason: $finishReason');
          }

          // Check if stopped due to MAX_TOKENS - need to continue
          if (finishReason.contains('MAX_TOKENS') || finishReason.contains('LENGTH')) {
            shouldContinue = true;
            LoggerService.i('⚠️ Hit MAX_TOKENS, will auto-continue...');
          }
        }
      }

      // AUTO-CONTINUE if stopped due to max tokens (up to 3 times for safety)
      int continueCount = 0;
      while (shouldContinue && continueCount < 3) {
        continueCount++;
        shouldContinue = false;

        LoggerService.i('🔄 Auto-continuing response (attempt $continueCount/3)...');

        // Send "continue" message to get rest of response
        final continueContent = Content.text('Hãy tiếp tục phần còn lại.');
        final continueResponse = session.sendMessageStream(continueContent);

        await for (final chunk in continueResponse) {
          final text = chunk.text ?? '';
          fullResponse += text;
          yield fullResponse;

          // Check if need to continue again
          if (chunk.candidates.isNotEmpty) {
            final candidate = chunk.candidates.first;
            final finishReason = candidate.finishReason?.toString() ?? '';
            if (finishReason.contains('MAX_TOKENS') || finishReason.contains('LENGTH')) {
              shouldContinue = true;
            }
          }
        }
      }

      if (fullResponse.isEmpty) {
        LoggerService.w('Warning: Gemini returned empty response');
      }
      LoggerService.i('✅ Message sent successfully, response length: ${fullResponse.length}');
    } catch (e) {
      LoggerService.e('Error sending message', error: e);
      lastError.value = e.toString();
      yield 'Xin lỗi, đã có lỗi xảy ra: ${e.toString()}';
    } finally {
      isGenerating.value = false;
    }
  }

  // Send message and get complete response (non-streaming)
  Future<String> sendMessage({
    required AIConversation conversation,
    required String message,
    List<String>? imageBase64List,
  }) async {
    if (!isInitialized.value) {
      throw Exception('Gemini service not initialized');
    }

    isGenerating.value = true;
    lastError.value = '';

    try {
      // Get or create session
      final session = _getOrCreateSession(conversation);

      // Prepare content parts
      final contentParts = <Part>[];
      
      // Add text message
      contentParts.add(TextPart(message));

      // Add images if provided
      if (imageBase64List != null && imageBase64List.isNotEmpty) {
        for (final base64Image in imageBase64List) {
          try {
            // Remove data URL prefix if present
            final base64Data = base64Image.contains(',')
                ? base64Image.split(',')[1]
                : base64Image;

            // Convert base64 to bytes
            final bytes = base64Decode(base64Data);
            contentParts.add(DataPart('image/jpeg', Uint8List.fromList(bytes)));
          } catch (e) {
            LoggerService.e('Error processing image', error: e);
          }
        }
      }

      // Create content
      final content = Content.multi(contentParts);

      // Send message and get response
      final response = await session.sendMessage(content);
      final responseText = response.text ?? '';

      LoggerService.i('Message sent successfully, response: $responseText');
      return responseText;
    } catch (e) {
      LoggerService.e('Error sending message', error: e);
      lastError.value = e.toString();
      return 'Xin lỗi, đã có lỗi xảy ra: ${e.toString()}';
    } finally {
      isGenerating.value = false;
    }
  }

  // Generate title for conversation
  Future<String> generateTitle(String firstMessage) async {
    try {
      final prompt = '''
Tạo một tiêu đề ngắn gọn (tối đa 5 từ) cho cuộc trò chuyện bắt đầu với tin nhắn này. 
Chỉ trả lời tiêu đề, không giải thích:

"$firstMessage"
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final title = response.text?.trim() ?? 'Chat mới';
      return title.length > 50 ? '${title.substring(0, 47)}...' : title;
    } catch (e) {
      LoggerService.e('Error generating title', error: e);
      return 'Chat ${DateTime.now().day}/${DateTime.now().month}';
    }
  }

  // Get system prompt based on conversation context
  String _getSystemPrompt(ConversationContext context) {
    const basePrompt = '''
Bạn là Wanderlust AI Assistant, một trợ lý du lịch thông minh giúp người dùng:
- Lập kế hoạch chuyến đi
- Tìm kiếm điểm đến và chỗ ở
- Tư vấn văn hóa và ẩm thực địa phương
- Hỗ trợ trong trường hợp khẩn cấp
- Dịch thuật và giao tiếp

Hãy trả lời bằng tiếng Việt một cách thân thiện, hữu ích và chính xác.
''';

    switch (context) {
      case ConversationContext.tripPlanning:
        return '''
$basePrompt
Tập trung vào việc lập kế hoạch chuyến đi chi tiết, bao gồm:
- Lịch trình theo ngày
- Điểm tham quan và hoạt động
- Thời gian di chuyển
- Chi phí ước tính
- Lời khuyên hữu ích
''';

      case ConversationContext.accommodation:
        return '''
$basePrompt
Tập trung vào việc tìm kiếm và tư vấn chỗ ở:
- Khách sạn, homestay, resort phù hợp
- So sánh giá cả và tiện nghi
- Vị trí thuận lợi
- Đánh giá và review
''';

      case ConversationContext.emergency:
        return '''
$basePrompt
ƯU TIÊN: Hỗ trợ khẩn cấp
- Cung cấp thông tin liên hệ khẩn cấp
- Hướng dẫn xử lý tình huống
- Bệnh viện, đồn cảnh sát gần nhất
- Đại sứ quán và lãnh sự quán
Hãy phản hồi nhanh chóng và rõ ràng.
''';

      case ConversationContext.translation:
        return '''
$basePrompt
Tập trung vào dịch thuật và giao tiếp:
- Dịch chính xác giữa các ngôn ngữ
- Giải thích ngữ cảnh văn hóa
- Cung cấp cách phát âm
- Từ vựng và cụm từ hữu ích
''';

      case ConversationContext.budget:
        return '''
$basePrompt
Tập trung vào quản lý ngân sách du lịch:
- Ước tính chi phí chi tiết
- Mẹo tiết kiệm
- So sánh giá cả
- Lập kế hoạch tài chính cho chuyến đi
''';

      case ConversationContext.cultural:
        return '''
$basePrompt
Tập trung vào văn hóa và phong tục:
- Giới thiệu văn hóa địa phương
- Taboo và điều cần tránh
- Lễ hội và sự kiện
- Nghi thức và phép lịch sự
''';

      case ConversationContext.food:
        return '''
$basePrompt
Tập trung vào ẩm thực:
- Món ăn địa phương nổi tiếng
- Nhà hàng và quán ăn được đề xuất
- Hướng dẫn thưởng thức
- Lưu ý về dị ứng và chế độ ăn
''';

      case ConversationContext.weather:
        return '''
$basePrompt
Tập trung vào thời tiết và khí hậu:
- Dự báo thời tiết
- Thời điểm du lịch tốt nhất
- Trang phục phù hợp
- Cảnh báo thời tiết xấu
''';

      case ConversationContext.general:
        return basePrompt;
    }
  }

  // Clear current session
  void clearSession() {
    _currentSession = null;
    LoggerService.i('Chat session cleared');
  }

  // Update generation config
  void updateGenerationConfig({
    double? temperature,
    int? maxTokens,
    double? topP,
    int? topK,
  }) {
    try {
      _model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: temperature ?? 0.9, // Default to 0.9 for creative responses
          maxOutputTokens: maxTokens ?? 8192, // Default to MAX tokens
          topK: topK ?? 40,
          topP: topP ?? 0.95,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      // Clear current session to use new config
      clearSession();

      LoggerService.i('Generation config updated');
    } catch (e) {
      LoggerService.e('Error updating generation config', error: e);
    }
  }

  // Check service health
  Future<bool> checkHealth() async {
    try {
      final response = await _model.generateContent([
        Content.text('Hello')
      ]);
      return response.text != null;
    } catch (e) {
      LoggerService.e('Health check failed', error: e);
      return false;
    }
  }

  @override
  void onClose() {
    clearSession();
    super.onClose();
  }
}

// Helper function for base64 decoding
List<int> base64Decode(String source) {
  // Import at top: import 'dart:convert';
  return const Base64Decoder().convert(source);
}