import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_assets.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/typing_indicator.dart';
import 'package:wanderlust/data/models/ai_chat_message.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/presentation/controllers/trip/ai_trip_planner_controller.dart';

/// AI Trip Planner Bottom Sheet
/// A mini chatbot for trip itinerary planning with streaming responses
class AiTripPlannerSheet extends StatefulWidget {
  final TripModel trip;
  final int selectedDay;
  final List<Map<String, dynamic>> tripDays;
  final Function(String note)? onSaveNote;
  final Function(AiItineraryModel itinerary, int dayIndex)? onSaved;

  const AiTripPlannerSheet({
    super.key,
    required this.trip,
    required this.selectedDay,
    required this.tripDays,
    this.onSaveNote,
    this.onSaved,
  });

  /// Show the AI Trip Planner bottom sheet
  static Future<void> show({
    required TripModel trip,
    required int selectedDay,
    required List<Map<String, dynamic>> tripDays,
    Function(String note)? onSaveNote,
    Function(AiItineraryModel itinerary, int dayIndex)? onSaved,
  }) async {
    await Get.bottomSheet(
      AiTripPlannerSheet(
        trip: trip,
        selectedDay: selectedDay,
        tripDays: tripDays,
        onSaveNote: onSaveNote,
        onSaved: onSaved,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<AiTripPlannerSheet> createState() => _AiTripPlannerSheetState();
}

class _AiTripPlannerSheetState extends State<AiTripPlannerSheet> {
  late AiTripPlannerController controller;

  @override
  void initState() {
    super.initState();
    // Create controller
    controller = Get.put(AiTripPlannerController());

    // Initialize with context
    controller.initWithContext(
      tripModel: widget.trip,
      dayIndex: widget.selectedDay,
      days: widget.tripDays,
      onSavedCallback: widget.onSaved,
    );
  }

  @override
  void dispose() {
    Get.delete<AiTripPlannerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          _buildHeader(),

          // Divider
          Divider(height: 1, color: AppColors.neutral200),

          // Chat content
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty && controller.isSending.value) {
                return _buildLoadingState();
              }
              return _buildChatContent();
            }),
          ),

          // Action bar (Regenerate, Copy, Save)
          _buildActionBar(),

          // Input section
          _buildInputSection(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          // AI Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              AppAssets.aiFabIcon,
              width: 40.r,
              height: 40.r,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    size: 24.sp,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Lịch trình',
                  style: AppTypography.bodyL.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                ),
                Text(
                  'Ngày ${widget.selectedDay + 1} - ${widget.trip.destination}',
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),

          // Close button
          IconButton(
            icon: Icon(Icons.close, color: AppColors.neutral600),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Avatar with animation
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: Image.asset(
                  AppAssets.aiFabIcon,
                  width: 60.r,
                  height: 60.r,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.smart_toy,
                      size: 40.sp,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Đang tạo lịch trình...',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          SizedBox(height: 8.h),
          const TypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return ListView.builder(
      controller: controller.scrollController,
      padding: EdgeInsets.all(AppSpacing.s4),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(AIChatMessage message) {
    final isUser = message.role == MessageRole.user;
    final isStreaming = message.isStreaming;

    // For streaming assistant messages, use Obx for reactivity
    if (isStreaming && message.role == MessageRole.assistant) {
      return Obx(() {
        String displayContent = message.content;
        if (controller.streamingMessageId.value == message.id) {
          displayContent = controller.streamingMessage.value;
        }
        return _buildMessageContent(message, isUser, displayContent);
      });
    }

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
                  if (message.error != null)
                    _buildErrorMessage(message.error!)
                  else if (message.role == MessageRole.assistant && displayContent.isEmpty)
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
                          height: 1.5,
                        ),
                        h1: AppTypography.h3.copyWith(
                          color: AppColors.neutral800,
                        ),
                        h2: AppTypography.h4.copyWith(
                          color: AppColors.neutral800,
                        ),
                        h3: AppTypography.bodyL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                        ),
                        listBullet: AppTypography.bodyM.copyWith(
                          color: AppColors.primary,
                        ),
                        code: AppTypography.bodyS.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: AppColors.neutral200,
                        ),
                        strong: AppTypography.bodyM.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral800,
                        ),
                        em: AppTypography.bodyM.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.neutral700,
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
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: AppSpacing.s2),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.neutral300,
              child: Icon(
                Icons.person,
                size: 20.sp,
                color: AppColors.neutral600,
              ),
            ),
          ],
        ],
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

  Widget _buildActionBar() {
    return Obx(() {
      // Only show action bar if there's content
      final hasContent = controller.messages.any(
        (m) => m.role == MessageRole.assistant && m.content.isNotEmpty,
      );

      if (!hasContent) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.neutral200, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Regenerate button
            _buildActionButton(
              icon: Icons.refresh,
              label: 'Tạo lại',
              onTap: controller.isSending.value ? null : controller.regenerate,
              isLoading: controller.isSending.value,
            ),

            // Copy button
            _buildActionButton(
              icon: Icons.copy,
              label: 'Sao chép',
              onTap: controller.copyLastResponse,
            ),

            // Save to itinerary button
            _buildActionButton(
              icon: Icons.save_alt,
              label: 'Lưu lịch trình',
              onTap: () => controller.saveToItinerary(),
              isPrimary: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neutral500,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18.sp,
                  color: isPrimary ? AppColors.primary : AppColors.neutral600,
                ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: AppTypography.bodyS.copyWith(
                  color: isPrimary ? AppColors.primary : AppColors.neutral600,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
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
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Hỏi thêm về lịch trình...',
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
                            key: const ValueKey('loading'),
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20.sp,
                          key: const ValueKey('send'),
                        ),
                ),
                onPressed: controller.isSending.value
                    ? null
                    : () => controller.sendMessage(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
