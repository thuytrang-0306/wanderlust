import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/utils/ai_itinerary_parser.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';

/// Controller for AI Trip Planner Bottom Sheet
/// Provides AI-powered itinerary suggestions based on trip context
class AiTripPlannerController extends GetxController {
  // Services
  final GeminiService _geminiService = GeminiService.to;
  final TripService _tripService = Get.find<TripService>();

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Trip context
  TripModel? trip;
  int selectedDay = 0;
  List<Map<String, dynamic>> tripDays = [];

  // Callback when save successful
  Function(AiItineraryModel itinerary, int dayIndex)? onSaved;

  // Conversation state (in-memory, not persisted)
  final RxList<AIChatMessage> messages = <AIChatMessage>[].obs;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString streamingMessage = ''.obs;
  final RxString streamingMessageId = ''.obs;
  final RxString lastAssistantMessageId = ''.obs;

  // Initialize with trip context
  void initWithContext({
    required TripModel tripModel,
    required int dayIndex,
    required List<Map<String, dynamic>> days,
    Function(AiItineraryModel itinerary, int dayIndex)? onSavedCallback,
  }) {
    trip = tripModel;
    selectedDay = dayIndex;
    tripDays = days;
    onSaved = onSavedCallback;
    isInitialized.value = true;

    LoggerService.i('AI Trip Planner initialized for ${tripModel.title}, Day ${dayIndex + 1}');

    // Auto-generate itinerary on open
    _autoGenerateItinerary();
  }

  // Auto-generate itinerary when sheet opens
  Future<void> _autoGenerateItinerary() async {
    if (trip == null) return;

    final prompt = _buildItineraryPrompt();
    await _sendMessageToAI(prompt, isAutoGenerate: true);
  }

  // Build detailed prompt for itinerary generation
  String _buildItineraryPrompt() {
    if (trip == null) return '';

    final dayNumber = selectedDay + 1;
    final dayData = tripDays.isNotEmpty && selectedDay < tripDays.length
        ? tripDays[selectedDay]
        : null;

    // Get existing locations for this day
    final existingLocations = dayData?['locations'] as List? ?? [];
    final existingNote = dayData?['note'] as String? ?? '';

    // Build context string
    final buffer = StringBuffer();
    buffer.writeln('Hãy lên lịch trình chi tiết cho NGÀY $dayNumber của chuyến đi:');
    buffer.writeln('');
    buffer.writeln('📍 **Thông tin chuyến đi:**');
    buffer.writeln('- Tên: ${trip!.title}');
    buffer.writeln('- Điểm đến: ${trip!.destination}');
    buffer.writeln('- Thời gian: ${trip!.durationText}');
    buffer.writeln('- Số người: ${trip!.travelers.length} người');
    if (trip!.budget > 0) {
      buffer.writeln('- Ngân sách: ${_formatBudget(trip!.budget)} VND');
    }
    buffer.writeln('');

    if (existingLocations.isNotEmpty) {
      buffer.writeln('📌 **Các địa điểm đã có trong ngày này:**');
      for (final loc in existingLocations) {
        buffer.writeln('- ${loc['title']} (${loc['time'] ?? 'Chưa xác định giờ'})');
      }
      buffer.writeln('');
      buffer.writeln('Hãy bổ sung thêm các hoạt động khác và sắp xếp lại theo thứ tự hợp lý.');
    }

    if (existingNote.isNotEmpty) {
      buffer.writeln('📝 **Ghi chú của người dùng:** $existingNote');
      buffer.writeln('');
    }

    buffer.writeln('');
    buffer.writeln('**Yêu cầu:**');
    buffer.writeln('- Lên lịch trình từ sáng đến tối');
    buffer.writeln('- Mỗi hoạt động ghi rõ: thời gian, địa điểm, mô tả ngắn');
    buffer.writeln('- Gợi ý ăn sáng, trưa, tối phù hợp');
    buffer.writeln('- Ước tính chi phí cho mỗi hoạt động (nếu có)');
    buffer.writeln('- Thời gian di chuyển giữa các địa điểm');

    return buffer.toString();
  }

  // Format budget to readable string
  String _formatBudget(double budget) {
    if (budget >= 1000000) {
      return '${(budget / 1000000).toStringAsFixed(1)}M';
    } else if (budget >= 1000) {
      return '${(budget / 1000).toStringAsFixed(0)}K';
    }
    return budget.toStringAsFixed(0);
  }

  // Send message to user input
  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    messageController.clear();
    await _sendMessageToAI(message);
  }

  // Core method to send message to AI
  Future<void> _sendMessageToAI(String message, {bool isAutoGenerate = false}) async {
    if (isSending.value) return;

    try {
      isSending.value = true;

      // Unfocus keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // Add user message (skip for auto-generate to keep UI clean)
      if (!isAutoGenerate) {
        final userMessage = AIChatMessage.user(content: message);
        messages.add(userMessage);
      }

      // Force UI update
      await Future.delayed(const Duration(milliseconds: 50));
      _scrollToBottom();

      // Create assistant message for streaming
      final assistantMessage = AIChatMessage.assistant(
        content: '',
        isStreaming: true,
      );
      messages.add(assistantMessage);
      lastAssistantMessageId.value = assistantMessage.id;

      // Get streaming response
      streamingMessage.value = '';
      streamingMessageId.value = assistantMessage.id;

      // Create temporary conversation for context
      final tempConversation = AIConversation.create(
        context: ConversationContext.tripPlanning,
        tripId: trip?.id,
      );

      // Add previous messages to conversation for context
      for (final msg in messages) {
        if (msg.id != assistantMessage.id) {
          tempConversation.messages.add(msg);
        }
      }

      final responseStream = _geminiService.sendMessageStream(
        conversation: tempConversation,
        message: message,
      );

      String latestContent = '';

      await for (final chunk in responseStream) {
        streamingMessage.value = chunk;
        latestContent = chunk;

        // Update message in list
        final index = messages.indexWhere((m) => m.id == assistantMessage.id);
        if (index != -1) {
          messages[index] = assistantMessage.copyWith(
            content: chunk,
            isStreaming: true,
          );
        }

        await Future.delayed(const Duration(milliseconds: 10));
        _scrollToBottom();
      }

      // Finish streaming
      final index = messages.indexWhere((m) => m.id == assistantMessage.id);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          content: latestContent,
          isStreaming: false,
        );
      }

      LoggerService.i('AI Trip Planner response completed: ${latestContent.length} chars');
    } catch (e) {
      LoggerService.e('Error in AI Trip Planner', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể kết nối với AI. Vui lòng thử lại.',
      );

      // Add error message
      final errorMessage = AIChatMessage.error(error: e.toString());
      messages.add(errorMessage);
    } finally {
      isSending.value = false;
      streamingMessage.value = '';
      streamingMessageId.value = '';
    }
  }

  // Regenerate the last AI response
  Future<void> regenerate() async {
    if (messages.isEmpty) return;

    // Find the last user message
    String? lastUserMessage;
    int lastAssistantIndex = -1;

    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.assistant && lastAssistantIndex == -1) {
        lastAssistantIndex = i;
      }
      if (messages[i].role == MessageRole.user) {
        lastUserMessage = messages[i].content;
        break;
      }
    }

    // If no user message found, regenerate the auto-generated content
    if (lastUserMessage == null || lastUserMessage.isEmpty) {
      // Clear all messages and regenerate
      messages.clear();
      await _autoGenerateItinerary();
      return;
    }

    // Remove the last assistant message
    if (lastAssistantIndex != -1) {
      messages.removeAt(lastAssistantIndex);
    }

    // Resend the last user message
    await _sendMessageToAI(lastUserMessage);
  }

  // Copy last AI response to clipboard
  void copyLastResponse() {
    if (messages.isEmpty) return;

    // Find the last assistant message
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.assistant && messages[i].content.isNotEmpty) {
        Clipboard.setData(ClipboardData(text: messages[i].content));
        AppSnackbar.showSuccess(
          title: 'Đã sao chép',
          message: 'Nội dung đã được sao chép vào clipboard',
        );
        return;
      }
    }
  }

  // Save AI response to AI Itinerary
  Future<void> saveToItinerary() async {
    if (messages.isEmpty || trip == null) return;

    try {
      // Find the last assistant message
      String? aiContent;
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].role == MessageRole.assistant && messages[i].content.isNotEmpty) {
          aiContent = messages[i].content;
          break;
        }
      }

      if (aiContent == null || aiContent.isEmpty) {
        AppSnackbar.showWarning(
          title: 'Thông báo',
          message: 'Không có nội dung lịch trình để lưu',
        );
        return;
      }

      // Parse markdown to AiItineraryModel
      final dayData = tripDays.isNotEmpty && selectedDay < tripDays.length
          ? tripDays[selectedDay]
          : null;

      final date = dayData?['date'] as DateTime? ?? DateTime.now();

      final itinerary = AiItineraryParser.parse(
        markdown: aiContent,
        tripId: trip!.id,
        dayNumber: selectedDay + 1, // 1-based
        date: date,
      );

      LoggerService.i('Parsed ${itinerary.activityCount} activities from AI response');

      // Save to Firestore
      final success = await _tripService.saveAiItinerary(
        tripId: trip!.id,
        dayIndex: selectedDay.toString(),
        itinerary: itinerary,
      );

      if (success) {
        // ✅ Close sheet FIRST for immediate UX feedback
        Get.back();

        // ✅ Show success message immediately
        AppSnackbar.showSuccess(
          title: 'Thành công',
          message: 'Đã lưu lịch trình AI với ${itinerary.activityCount} hoạt động',
        );

        // ✅ Call callback AFTER closing (UI update happens in background)
        if (onSaved != null) {
          // Run callback without awaiting to prevent blocking
          onSaved!(itinerary, selectedDay);
        }
      } else {
        AppSnackbar.showError(
          title: 'Lỗi',
          message: 'Không thể lưu lịch trình. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      LoggerService.e('Error saving AI itinerary', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Đã có lỗi xảy ra khi lưu lịch trình',
      );
    }
  }

  // Scroll to bottom of chat
  void _scrollToBottom({bool animated = true}) {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          if (animated) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        }
      });
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
