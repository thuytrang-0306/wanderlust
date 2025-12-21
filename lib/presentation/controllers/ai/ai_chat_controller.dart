import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/core/services/ai_storage_service.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/core/services/unified_image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';
import 'package:wanderlust/data/models/user_profile_model.dart';
import 'package:wanderlust/data/services/user_profile_service.dart';
import 'package:wanderlust/presentation/controllers/auth_controller.dart';
import 'dart:convert';
import 'dart:io';

class AIChatController extends GetxController {
  // Services
  final AIStorageService _storageService = AIStorageService.to;
  final GeminiService _geminiService = GeminiService.to;
  late final AuthController _authController;
  late final UserProfileService _userProfileService;
  late final UnifiedImageService _imageService;

  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString streamingMessage = ''.obs;
  final RxString streamingMessageId = ''.obs; // Track which message is streaming
  final RxList<String> selectedImages = <String>[].obs;
  final Rx<ConversationContext> selectedContext = ConversationContext.general.obs;
  
  // User profile state
  final Rxn<Uint8List> userAvatarBytes = Rxn<Uint8List>();
  final RxString userDisplayName = 'User'.obs;
  
  // Current conversation
  Rx<AIConversation?> get currentConversation => _storageService.currentConversation;
  RxList<AIConversation> get allConversations => _storageService.conversations;

  // Suggestions based on context
  final RxList<String> suggestions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize controllers and services safely
    try {
      _authController = Get.find<AuthController>();
      // Update display name from Firebase
      final user = _authController.firebaseUser.value;
      if (user?.displayName != null) {
        userDisplayName.value = user!.displayName!;
      }
    } catch (e) {
      LoggerService.e('AuthController not found, using fallback', error: e);
    }
    
    try {
      _userProfileService = Get.find<UserProfileService>();
    } catch (e) {
      LoggerService.e('UserProfileService not found, using fallback', error: e);
    }
    
    try {
      _imageService = Get.find<UnifiedImageService>();
    } catch (e) {
      LoggerService.e('UnifiedImageService not found, using fallback', error: e);
    }
    
    _loadInitialData();
    _loadUserProfile(); // Load user profile on init
  }
  
  @override
  void onReady() {
    super.onReady();
    // Ensure scroll position after widget is ready
    if (currentConversation.value?.messages.isNotEmpty ?? false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(animated: false);
      });
    }
  }
  
  // Load user profile (name and avatar)
  Future<void> _loadUserProfile() async {
    try {
      // Load profile from Firestore
      final profile = await _userProfileService.getCurrentUserProfile();
      
      if (profile != null) {
        // Update display name
        if (profile.displayName.isNotEmpty) {
          userDisplayName.value = profile.displayName;
        }
        
        // Load avatar bytes - prefer thumbnail for performance
        if (profile.avatarThumbnail != null) {
          userAvatarBytes.value = _imageService.base64ToImage(profile.avatarThumbnail);
        } else if (profile.avatar != null) {
          userAvatarBytes.value = _imageService.base64ToImage(profile.avatar);
        } else {
          userAvatarBytes.value = null;
        }
      } else {
        // Fallback to Firebase Auth if no profile
        final firebaseUser = _authController.firebaseUser.value;
        if (firebaseUser != null && firebaseUser.displayName != null) {
          userDisplayName.value = firebaseUser.displayName!;
        }
      }
    } catch (e) {
      LoggerService.e('Error loading user profile', error: e);
    }
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    try {
      // Wait for storage to be ready
      int retries = 0;
      while (!_storageService.isInitialized.value && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
      }
      
      // Reload conversations from storage
      await _storageService.loadConversations();
      
      // Only show loading for first time (no conversations)
      if (allConversations.isEmpty) {
        isLoading.value = true;
        // Create first conversation for new users
        await createNewConversation();
      } else {
        // Load existing conversation
        if (currentConversation.value == null) {
          currentConversation.value = allConversations.first;
          selectedContext.value = currentConversation.value!.context;
        }
      }
      
      // Load context suggestions
      _loadContextSuggestions();
    } catch (e) {
      LoggerService.e('Error loading initial data', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  // Create new conversation
  Future<void> createNewConversation({
    ConversationContext context = ConversationContext.general,
    String? tripId,
  }) async {
    try {
      final conversation = await _storageService.createConversation(
        context: context,
        tripId: tripId,
      );
      
      currentConversation.value = conversation;
      selectedContext.value = context;
      _loadContextSuggestions();
      
      // Clear any selected images
      selectedImages.clear();
      
      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      LoggerService.e('Error creating conversation', error: e);
      Get.snackbar(
        'Lỗi',
        'Không thể tạo cuộc trò chuyện mới',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Switch conversation
  void switchConversation(String conversationId) {
    final conversation = _storageService.getConversation(conversationId);
    if (conversation != null) {
      currentConversation.value = conversation;
      selectedContext.value = conversation.context;
      _loadContextSuggestions();
      selectedImages.clear();
      _scrollToBottom();
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _storageService.deleteConversation(conversationId);
      
      // If deleted current conversation, switch to another or create new
      if (currentConversation.value?.id == conversationId) {
        if (allConversations.isNotEmpty) {
          currentConversation.value = allConversations.first;
        } else {
          await createNewConversation();
        }
      }
      
      Get.snackbar(
        'Thành công',
        'Đã xóa cuộc trò chuyện',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      LoggerService.e('Error deleting conversation', error: e);
    }
  }

  // Toggle pin conversation
  Future<void> togglePinConversation(String conversationId) async {
    await _storageService.togglePinConversation(conversationId);
  }

  // Send message
  Future<void> sendMessage() async {
    final message = messageController.text.trim();
    if (message.isEmpty && selectedImages.isEmpty) return;

    if (isSending.value) return;

    try {
      isSending.value = true;

      // Unfocus keyboard to show AI response clearly
      FocusManager.instance.primaryFocus?.unfocus();

      messageController.clear();
      
      // Create conversation if needed
      if (currentConversation.value == null) {
        await createNewConversation(context: selectedContext.value);
      }
      
      final conversation = currentConversation.value!;
      
      // Add user message
      final userMessage = AIChatMessage.user(
        content: message,
        attachments: selectedImages.isNotEmpty ? List.from(selectedImages) : null,
      );

      await _storageService.addMessageToConversation(
        conversation.id,
        userMessage,
      );

      // Force UI update to show user message immediately
      currentConversation.refresh();

      // Clear selected images after sending
      final imagesToSend = List<String>.from(selectedImages);
      selectedImages.clear();

      // Scroll to bottom after UI updated
      await Future.delayed(const Duration(milliseconds: 50));
      _scrollToBottom();
      
      // Create assistant message for streaming
      final assistantMessage = AIChatMessage.assistant(
        content: '',
        isStreaming: true,
      );
      
      await _storageService.addMessageToConversation(
        conversation.id,
        assistantMessage,
      );
      
      // Get streaming response
      streamingMessage.value = '';
      streamingMessageId.value = assistantMessage.id;

      final responseStream = _geminiService.sendMessageStream(
        conversation: conversation,
        message: message,
        imageBase64List: imagesToSend.isNotEmpty ? imagesToSend : null,
      );

      // Process stream with optimized batch updates
      DateTime lastSave = DateTime.now();
      String latestContent = '';

      await for (final chunk in responseStream) {
        streamingMessage.value = chunk;
        latestContent = chunk;

        // Batch Hive updates - only save every 500ms for performance
        final now = DateTime.now();
        if (now.difference(lastSave).inMilliseconds > 500) {
          await _storageService.updateMessage(
            conversation.id,
            assistantMessage.id,
            chunk,
          );
          lastSave = now;
        }

        // Small delay for smoother animation
        await Future.delayed(const Duration(milliseconds: 10));
        _scrollToBottom();
      }

      // Final save to ensure latest content is persisted
      await _storageService.updateMessage(
        conversation.id,
        assistantMessage.id,
        latestContent,
      );

      // Finish streaming
      await _storageService.finishStreaming(conversation.id);
      
      // Auto-generate title if first message
      if (conversation.messages.length <= 2 && message.isNotEmpty) {
        // Run title generation in background
        _generateConversationTitle(conversation, message);
      }
      
    } catch (e) {
      LoggerService.e('Error sending message', error: e);
      Get.snackbar(
        'Lỗi',
        'Không thể gửi tin nhắn. Vui lòng thử lại.',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Add error message
      final errorMessage = AIChatMessage.error(
        error: e.toString(),
      );
      
      if (currentConversation.value != null) {
        await _storageService.addMessageToConversation(
          currentConversation.value!.id,
          errorMessage,
        );
      }
    } finally {
      isSending.value = false;
      streamingMessage.value = '';
      streamingMessageId.value = '';
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image != null) {
        await _addImageToSelection(image);
      }
    } catch (e) {
      LoggerService.e('Error picking image', error: e);
      Get.snackbar(
        'Lỗi',
        'Không thể chọn ảnh',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Take photo with camera
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (photo != null) {
        await _addImageToSelection(photo);
      }
    } catch (e) {
      LoggerService.e('Error taking photo', error: e);
      Get.snackbar(
        'Lỗi',
        'Không thể chụp ảnh',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add image to selection
  Future<void> _addImageToSelection(XFile image) async {
    try {
      // Read image as bytes
      final bytes = await File(image.path).readAsBytes();
      
      // Convert to base64
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      // Add to selection (max 3 images)
      if (selectedImages.length < 3) {
        selectedImages.add(base64Image);
      } else {
        Get.snackbar(
          'Giới hạn',
          'Chỉ có thể gửi tối đa 3 ảnh',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      LoggerService.e('Error processing image', error: e);
    }
  }

  // Remove image from selection
  void removeImage(int index) {
    if (index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  // Clear conversation messages
  Future<void> clearCurrentConversation() async {
    if (currentConversation.value != null) {
      await _storageService.clearConversationMessages(
        currentConversation.value!.id,
      );
      
      Get.snackbar(
        'Đã xóa',
        'Tất cả tin nhắn đã được xóa',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Change context
  void changeContext(ConversationContext context) {
    selectedContext.value = context;
    _loadContextSuggestions();
    
    // Update current conversation context if exists
    if (currentConversation.value != null) {
      currentConversation.value!.context = context;
      _storageService.updateConversation(currentConversation.value!);
    }
  }

  // Load context-based suggestions
  void _loadContextSuggestions() {
    switch (selectedContext.value) {
      case ConversationContext.general:
        suggestions.value = [
          'Tôi muốn đi du lịch Đà Lạt',
          'Cho tôi gợi ý điểm đến mùa hè',
          'Kinh nghiệm du lịch một mình',
          'Chuẩn bị gì cho chuyến đi biển?',
        ];
        break;
      
      case ConversationContext.tripPlanning:
        suggestions.value = [
          'Lập kế hoạch 3 ngày 2 đêm ở Phú Quốc',
          'Lịch trình chi tiết du lịch Sapa',
          'Budget 10 triệu cho 2 người đi Nha Trang',
          'Thời gian tốt nhất đến Hội An?',
        ];
        break;
        
      case ConversationContext.accommodation:
        suggestions.value = [
          'Khách sạn view đẹp ở Đà Nẵng',
          'Homestay giá rẻ ở Tam Đảo',
          'Resort cho gia đình ở Phú Quốc',
          'So sánh hotel và Airbnb',
        ];
        break;
        
      case ConversationContext.food:
        suggestions.value = [
          'Món ăn phải thử ở Huế',
          'Quán ăn ngon ở phố cổ Hà Nội',
          'Hải sản tươi sống ở Vũng Tàu',
          'Ẩm thực đường phố Sài Gòn',
        ];
        break;
        
      case ConversationContext.emergency:
        suggestions.value = [
          'Mất hộ chiếu khi du lịch',
          'Bị ốm cần tìm bệnh viện',
          'Số điện thoại khẩn cấp',
          'Bảo hiểm du lịch',
        ];
        break;
        
      default:
        suggestions.value = [];
    }
  }

  // Use suggestion
  void useSuggestion(String suggestion) {
    messageController.text = suggestion;
    sendMessage();
  }

  // Scroll to bottom
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

  // Search conversations
  List<AIConversation> searchConversations(String query) {
    return _storageService.searchConversations(query);
  }

  // Export conversations
  Future<void> exportConversations() async {
    try {
      final json = _storageService.exportToJson();
      // TODO: Implement file saving/sharing with jsonEncode(json)
      LoggerService.i('Exported ${json['conversations'].length} conversations');
      
      Get.snackbar(
        'Thành công',
        'Đã xuất ${json['conversations'].length} cuộc trò chuyện',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      LoggerService.e('Error exporting conversations', error: e);
    }
  }

  // Get storage stats
  Map<String, dynamic> getStorageStats() {
    return _storageService.getStorageStats();
  }

  // Generate conversation title in background
  Future<void> _generateConversationTitle(AIConversation conversation, String firstMessage) async {
    try {
      final title = await _geminiService.generateTitle(firstMessage);
      if (title.isNotEmpty && title != conversation.title) {
        conversation.title = title;
        await _storageService.updateConversation(conversation);
      }
    } catch (e) {
      LoggerService.e('Error generating title', error: e);
    }
  }
  
  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}