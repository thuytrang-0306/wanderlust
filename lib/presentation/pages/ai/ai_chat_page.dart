import 'dart:convert' show base64Decode;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_assets.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/services/ai_storage_service.dart';
import 'package:wanderlust/core/widgets/typing_indicator.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';
import 'package:wanderlust/presentation/controllers/ai/ai_chat_controller.dart';

class AIChatPage extends GetView<AIChatController> {
  const AIChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildContextSelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              final conversation = controller.currentConversation.value;
              if (conversation == null) {
                return _buildEmptyState();
              }

              return _buildChatContent(conversation);
            }),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.neutral800, size: 20.sp),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final conversation = controller.currentConversation.value;
        return Column(
          children: [
            Text(
              conversation?.title ?? 'AI Assistant',
              style: AppTypography.bodyL.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
            if (conversation != null)
              Text(
                '${conversation.messageCount} tin nhắn',
                style: AppTypography.bodyXS.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
          ],
        );
      }),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.neutral800),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'new',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 20.sp),
                  SizedBox(width: AppSpacing.s3),
                  Text('Cuộc trò chuyện mới'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20.sp),
                  SizedBox(width: AppSpacing.s3),
                  Text('Lịch sử'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all, size: 20.sp),
                  SizedBox(width: AppSpacing.s3),
                  Text('Xóa tin nhắn'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20.sp),
                  SizedBox(width: AppSpacing.s3),
                  Text('Cài đặt'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContextSelector() {
    return Container(
      height: 44.h,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s2),
        children: ConversationContext.values.map((context) {
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.s2),
            child: Obx(() => ChoiceChip(
              label: Text(_getContextLabel(context)),
              selected: controller.selectedContext.value == context,
              onSelected: (selected) {
                if (selected) {
                  controller.changeContext(context);
                }
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: AppTypography.bodyS.copyWith(
                color: controller.selectedContext.value == context
                    ? AppColors.primary
                    : AppColors.neutral600,
                fontWeight: controller.selectedContext.value == context
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            )),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatContent(AIConversation conversation) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: controller.scrollController,
            padding: EdgeInsets.all(AppSpacing.s4),
            itemCount: conversation.messages.length + (controller.suggestions.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && controller.suggestions.isNotEmpty && conversation.messages.isEmpty) {
                return _buildSuggestions();
              }
              
              final messageIndex = controller.suggestions.isNotEmpty && conversation.messages.isEmpty
                  ? index - 1
                  : index;
              
              if (messageIndex < 0 || messageIndex >= conversation.messages.length) {
                return const SizedBox.shrink();
              }
              
              final message = conversation.messages[messageIndex];
              return _buildMessageBubble(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(AIChatMessage message) {
    final isUser = message.role == MessageRole.user;
    final isStreaming = message.isStreaming;

    // Only wrap streaming assistant messages in Obx for reactivity
    // After streaming finishes, isStreaming is set to false, so no Obx overhead
    if (isStreaming && message.role == MessageRole.assistant) {
      return Obx(() {
        // Only use streaming content if this is the active streaming message
        String displayContent = message.content;
        if (controller.streamingMessageId.value == message.id) {
          displayContent = controller.streamingMessage.value;
        }
        return _buildMessageContent(message, isUser, displayContent);
      });
    }

    // Non-streaming messages don't need Obx wrapper
    return _buildMessageContent(message, isUser, message.content);
  }
  
  Widget _buildMessageContent(AIChatMessage message, bool isUser, String displayContent) {
      
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s3),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                AppAssets.aiFabIcon,
                width: 32.r,
                height: 32.r,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.smart_toy,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: AppSpacing.s2),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: isUser ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: isUser ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.attachments != null && message.attachments!.isNotEmpty)
                    _buildAttachedImages(message.attachments!),

                  if (message.error != null)
                    _buildErrorMessage(message.error!)
                  else if (message.role == MessageRole.assistant && displayContent.isEmpty)
                    // Show typing indicator when AI is processing
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s2),
                      child: const TypingIndicator(),
                    )
                  else if (message.role == MessageRole.assistant && displayContent.isNotEmpty)
                    MarkdownBody(
                      data: displayContent,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTypography.bodyM.copyWith(
                          color: isUser ? Colors.white : AppColors.neutral800,
                        ),
                        code: AppTypography.bodyS.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: AppColors.neutral200,
                        ),
                      ),
                    )
                  else if (displayContent.isNotEmpty)
                    Text(
                      displayContent,
                      style: AppTypography.bodyM.copyWith(
                        color: isUser ? Colors.white : AppColors.neutral800,
                      ),
                    ),
                  
                  // Removed circular progress indicator to fix state issues
                  // The typing animation effect is already shown through streaming text

                  // Only show timestamp if there's actual content
                  if (displayContent.isNotEmpty || message.error != null) ...[
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      _formatTime(message.timestamp),
                      style: AppTypography.bodyXS.copyWith(
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.neutral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: AppSpacing.s2),
            Obx(() {
              final avatarBytes = controller.userAvatarBytes.value;
              if (avatarBytes != null) {
                return CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.neutral300,
                  backgroundImage: MemoryImage(avatarBytes),
                );
              } else {
                // Fallback to initials or icon
                final name = controller.userDisplayName.value;
                if (name != 'User' && name.isNotEmpty) {
                  final initials = _getInitials(name);
                  return CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.neutral300,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral600,
                      ),
                    ),
                  );
                }
                return CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppColors.neutral300,
                  child: Icon(
                    Icons.person,
                    size: 20.sp,
                    color: AppColors.neutral600,
                  ),
                );
              }
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachedImages(List<String> images) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.s2),
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final base64Image = images[index];
          final imageData = base64Image.split(',').last;
          
          return Container(
            width: 100.w,
            margin: EdgeInsets.only(right: AppSpacing.s2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.memory(
                base64Decode(imageData),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Text(
              'Lỗi: $error',
              style: AppTypography.bodyS.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s3),
          child: Text(
            'Gợi ý câu hỏi:',
            style: AppTypography.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
        ),
        ...controller.suggestions.map<Widget>((suggestion) => GestureDetector(
          onTap: () => controller.useSuggestion(suggestion),
          child: Container(
            margin: EdgeInsets.only(bottom: AppSpacing.s2),
            padding: EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, 
                  color: AppColors.primary, 
                  size: 20.sp,
                ),
                SizedBox(width: AppSpacing.s2),
                Expanded(
                  child: Text(
                    suggestion,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, 
                  color: AppColors.neutral400, 
                  size: 16.sp,
                ),
              ],
            ),
          ),
        )).toList(),
      ],
    ));
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Obx(() {
              if (controller.selectedImages.isNotEmpty) {
                return _buildSelectedImages();
              }
              return const SizedBox.shrink();
            }),
            
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: AppColors.neutral600),
                  onPressed: () => _showAttachmentOptions(),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: controller.messageController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: AppTypography.bodyM.copyWith(
                          color: AppColors.neutral500,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4,
                          vertical: AppSpacing.s3,
                        ),
                      ),
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s2),
                Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: controller.isSending.value 
                        ? AppColors.neutral300 
                        : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: controller.isSending.value 
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                              key: ValueKey('loading'),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20.sp,
                            key: ValueKey('send'),
                          ),
                    ),
                    onPressed: controller.isSending.value 
                        ? null 
                        : () => controller.sendMessage(),
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return Container(
      height: 80.h,
      margin: EdgeInsets.only(bottom: AppSpacing.s3),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.selectedImages.length,
        itemBuilder: (context, index) {
          final base64Image = controller.selectedImages[index];
          final imageData = base64Image.split(',').last;
          
          return Stack(
            children: [
              Container(
                width: 80.w,
                margin: EdgeInsets.only(right: AppSpacing.s2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.memory(
                    base64Decode(imageData),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 8,
                child: GestureDetector(
                  onTap: () => controller.removeImage(index),
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: AppColors.neutral400,
          ),
          SizedBox(height: AppSpacing.s4),
          Text(
            'Bắt đầu cuộc trò chuyện mới',
            style: AppTypography.bodyL.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          Text(
            'Hỏi tôi bất cứ điều gì về du lịch!',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Chọn từ thư viện'),
              onTap: () {
                Get.back();
                controller.pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Chụp ảnh'),
              onTap: () {
                Get.back();
                controller.takePhoto();
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: AppColors.neutral500),
              title: Text('Hủy'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new':
        controller.createNewConversation();
        break;
      case 'history':
        _showConversationHistory();
        break;
      case 'clear':
        _confirmClearConversation();
        break;
      case 'settings':
        _showSettings();
        break;
    }
  }

  void _showConversationHistory() {
    Get.bottomSheet(
      Container(
        height: 0.7.sh,
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Lịch sử trò chuyện',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.allConversations.length,
                itemBuilder: (context, index) {
                  final conversation = controller.allConversations[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getContextColor(conversation.context),
                      child: Icon(
                        _getContextIcon(conversation.context),
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      conversation.title,
                      style: AppTypography.bodyM.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${conversation.messageCount} tin nhắn • ${conversation.formattedDate}',
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (conversation.isPinned)
                          Icon(Icons.push_pin, size: 16.sp, color: AppColors.primary),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20.sp),
                          onPressed: () => controller.deleteConversation(conversation.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.back();
                      controller.switchConversation(conversation.id);
                    },
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearConversation() {
    Get.dialog(
      AlertDialog(
        title: Text('Xóa tin nhắn'),
        content: Text('Bạn có chắc muốn xóa tất cả tin nhắn trong cuộc trò chuyện này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCurrentConversation();
            },
            child: Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    final stats = controller.getStorageStats();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cài đặt AI Chat',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            ListTile(
              leading: Icon(Icons.storage, color: AppColors.primary),
              title: Text('Dung lượng sử dụng'),
              subtitle: Text(
                '${stats['totalConversations']} cuộc trò chuyện • ${stats['totalMessages']} tin nhắn',
              ),
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppColors.primary),
              title: Text('Xuất dữ liệu'),
              onTap: () {
                Get.back();
                controller.exportConversations();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: AppColors.error),
              title: Text('Xóa tất cả dữ liệu'),
              onTap: () {
                Get.back();
                _confirmClearAllData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAllData() {
    Get.dialog(
      AlertDialog(
        title: Text('Xóa tất cả dữ liệu'),
        content: Text('Hành động này sẽ xóa vĩnh viễn tất cả cuộc trò chuyện và không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              AIStorageService.to.clearAllData();
              controller.createNewConversation();
            },
            child: Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _getContextLabel(ConversationContext context) {
    switch (context) {
      case ConversationContext.general:
        return 'Tổng quan';
      case ConversationContext.tripPlanning:
        return 'Lập kế hoạch';
      case ConversationContext.accommodation:
        return 'Chỗ ở';
      case ConversationContext.emergency:
        return 'Khẩn cấp';
      case ConversationContext.translation:
        return 'Dịch thuật';
      case ConversationContext.budget:
        return 'Ngân sách';
      case ConversationContext.cultural:
        return 'Văn hóa';
      case ConversationContext.food:
        return 'Ẩm thực';
      case ConversationContext.weather:
        return 'Thời tiết';
    }
  }

  Color _getContextColor(ConversationContext context) {
    switch (context) {
      case ConversationContext.general:
        return AppColors.primary;
      case ConversationContext.tripPlanning:
        return Colors.blue;
      case ConversationContext.accommodation:
        return Colors.orange;
      case ConversationContext.emergency:
        return Colors.red;
      case ConversationContext.translation:
        return Colors.purple;
      case ConversationContext.budget:
        return Colors.green;
      case ConversationContext.cultural:
        return Colors.teal;
      case ConversationContext.food:
        return Colors.amber;
      case ConversationContext.weather:
        return Colors.indigo;
    }
  }

  IconData _getContextIcon(ConversationContext context) {
    switch (context) {
      case ConversationContext.general:
        return Icons.chat;
      case ConversationContext.tripPlanning:
        return Icons.map;
      case ConversationContext.accommodation:
        return Icons.hotel;
      case ConversationContext.emergency:
        return Icons.warning;
      case ConversationContext.translation:
        return Icons.translate;
      case ConversationContext.budget:
        return Icons.attach_money;
      case ConversationContext.cultural:
        return Icons.museum;
      case ConversationContext.food:
        return Icons.restaurant;
      case ConversationContext.weather:
        return Icons.wb_sunny;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.day}/${time.month}';
    }
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words.last.substring(0, 1)}'.toUpperCase();
  }

}