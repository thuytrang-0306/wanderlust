import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/widgets/typing_indicator.dart';
import 'package:wanderlust/presentation/controllers/ai/ai_blog_assistant_controller.dart';

/// AI Blog Assistant Bottom Sheet
/// Provides AI-powered features for blog creation
class AiBlogAssistantSheet extends StatelessWidget {
  final String? title;
  final String? content;
  final List<String> tags;
  final List<String> destinations;
  final int imageCount;
  final Function(String title)? onTitleSelected;
  final Function(String content)? onBlogGenerated;
  final Function(String content)? onContentImproved;
  final Function(List<String> tags)? onTagsGenerated;

  const AiBlogAssistantSheet({
    super.key,
    this.title,
    this.content,
    this.tags = const [],
    this.destinations = const [],
    this.imageCount = 0,
    this.onTitleSelected,
    this.onBlogGenerated,
    this.onContentImproved,
    this.onTagsGenerated,
  });

  static Future<void> show({
    String? title,
    String? content,
    List<String> tags = const [],
    List<String> destinations = const [],
    int imageCount = 0,
    Function(String title)? onTitleSelected,
    Function(String content)? onBlogGenerated,
    Function(String content)? onContentImproved,
    Function(List<String> tags)? onTagsGenerated,
  }) async {
    await Get.bottomSheet(
      AiBlogAssistantSheet(
        title: title,
        content: content,
        tags: tags,
        destinations: destinations,
        imageCount: imageCount,
        onTitleSelected: onTitleSelected,
        onBlogGenerated: onBlogGenerated,
        onContentImproved: onContentImproved,
        onTagsGenerated: onTagsGenerated,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiBlogAssistantController());

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
          _buildHeader(controller),

          // Tab bar
          _buildTabBar(controller),

          Divider(height: 1, color: AppColors.neutral200),

          // Tab content
          Expanded(
            child: Obx(() {
              switch (controller.currentTab.value) {
                case 0:
                  return _buildTitleTab(controller);
                case 1:
                  return _buildBlogTab(controller);
                case 2:
                  return _buildImproveTab(controller);
                case 3:
                  return _buildTagsTab(controller);
                default:
                  return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AiBlogAssistantController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: AppColors.gradient101,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.auto_awesome, size: 24.sp, color: AppColors.primary),
          ),
          SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              'AI Trợ lý viết',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 24.sp),
            onPressed: () {
              controller.reset();
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AiBlogAssistantController controller) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTab(controller, 0, '📝', 'Tiêu đề'),
              _buildTab(controller, 1, '✨', 'Viết blog'),
              _buildTab(controller, 2, '✏️', 'Cải thiện'),
              _buildTab(controller, 3, '🏷️', 'Tags'),
            ],
          ),
        ));
  }

  Widget _buildTab(AiBlogAssistantController controller, int index, String emoji, String label) {
    final isSelected = controller.currentTab.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTypography.bodyS.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.neutral600,
            ),
          ),
          SizedBox(height: 6.h),
          if (isSelected)
            Container(
              width: 40.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleTab(AiBlogAssistantController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isGeneratingTitles.value) {
              return _buildLoadingState('Đang tạo tiêu đề...');
            }

            if (controller.titleSuggestions.isEmpty) {
              return _buildEmptyState(
                icon: Icons.lightbulb_outline,
                title: 'Tạo tiêu đề với AI',
                subtitle: 'AI sẽ gợi ý 5 tiêu đề hấp dẫn dựa trên tags và điểm đến của bạn',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(AppSpacing.s4),
              itemCount: controller.titleSuggestions.length,
              itemBuilder: (context, index) {
                final title = controller.titleSuggestions[index];
                final isSelected = controller.selectedTitleIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.selectTitle(index),
                  child: Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.s3),
                    padding: EdgeInsets.all(AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral200,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primary : AppColors.neutral400,
                          size: 24.sp,
                        ),
                        SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.bodyM.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        _buildActionButtons(
          controller: controller,
          onGenerate: () async {
            await controller.generateTitles(
              tags: tags,
              destinations: destinations,
              userContext: content,
            );
          },
          onApply: controller.titleSuggestions.isNotEmpty &&
                  controller.selectedTitleIndex.value >= 0
              ? () {
                  final selected =
                      controller.titleSuggestions[controller.selectedTitleIndex.value];
                  onTitleSelected?.call(selected);
                  Get.back();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildBlogTab(AiBlogAssistantController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isGeneratingBlog.value || controller.isStreaming.value) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const TypingIndicator(),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Đang viết blog...',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.s4),
                    MarkdownBody(
                      data: controller.streamingContent.value,
                      styleSheet: _markdownStyleSheet(),
                    ),
                  ],
                ),
              );
            }

            if (controller.generatedBlog.value.isEmpty) {
              return _buildEmptyState(
                icon: Icons.article_outlined,
                title: 'Viết blog với AI',
                subtitle: 'AI sẽ viết một bài blog hoàn chỉnh 800-1200 từ dựa trên tiêu đề và context của bạn',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: MarkdownBody(
                data: controller.generatedBlog.value,
                styleSheet: _markdownStyleSheet(),
              ),
            );
          }),
        ),
        _buildActionButtons(
          controller: controller,
          onGenerate: () async {
            if (title == null || title!.trim().isEmpty) {
              Get.snackbar('Thông báo', 'Vui lòng nhập tiêu đề trước');
              return;
            }
            await controller.generateBlogPost(
              title: title!,
              tags: tags,
              destinations: destinations,
              imageCount: imageCount,
              userDraft: content,
            );
          },
          onApply: controller.generatedBlog.value.isNotEmpty
              ? () {
                  onBlogGenerated?.call(controller.generatedBlog.value);
                  Get.back();
                }
              : null,
          showStop: controller.isStreaming.value,
          onStop: () => controller.stopStreaming(),
        ),
      ],
    );
  }

  Widget _buildImproveTab(AiBlogAssistantController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isImprovingWriting.value) {
              return _buildLoadingState('Đang cải thiện bài viết...');
            }

            if (controller.improvedWriting.value.isEmpty) {
              return _buildEmptyState(
                icon: Icons.edit_note,
                title: 'Cải thiện bài viết',
                subtitle: 'AI sẽ cải thiện grammar, flow, và ngôn ngữ để bài viết hấp dẫn hơn',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before/After labels
                  Container(
                    padding: EdgeInsets.all(AppSpacing.s3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 20.sp),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Bản cải thiện',
                          style: AppTypography.bodyM.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.s4),
                  MarkdownBody(
                    data: controller.improvedWriting.value,
                    styleSheet: _markdownStyleSheet(),
                  ),
                ],
              ),
            );
          }),
        ),
        _buildActionButtons(
          controller: controller,
          onGenerate: () async {
            if (content == null || content!.trim().isEmpty) {
              Get.snackbar('Thông báo', 'Vui lòng nhập nội dung cần cải thiện');
              return;
            }
            await controller.improveWriting(content!);
          },
          onApply: controller.improvedWriting.value.isNotEmpty
              ? () {
                  onContentImproved?.call(controller.improvedWriting.value);
                  Get.back();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildTagsTab(AiBlogAssistantController controller) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isGeneratingTags.value) {
              return _buildLoadingState('Đang tạo tags...');
            }

            if (controller.generatedTags.isEmpty) {
              return _buildEmptyState(
                icon: Icons.label_outline,
                title: 'Tạo tags với AI',
                subtitle: 'AI sẽ phân tích nội dung và tạo các tags phù hợp cho bài viết',
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tags gợi ý:',
                    style: AppTypography.bodyL.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s3),
                  Wrap(
                    spacing: AppSpacing.s2,
                    runSpacing: AppSpacing.s2,
                    children: controller.generatedTags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s3,
                          vertical: AppSpacing.s2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ),
        _buildActionButtons(
          controller: controller,
          onGenerate: () async {
            await controller.generateTags(
              title: title ?? '',
              content: content ?? '',
            );
          },
          onApply: controller.generatedTags.isNotEmpty
              ? () {
                  onTagsGenerated?.call(controller.generatedTags);
                  Get.back();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons({
    required AiBlogAssistantController controller,
    required VoidCallback onGenerate,
    VoidCallback? onApply,
    bool showStop = false,
    VoidCallback? onStop,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showStop) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStop,
                  icon: Icon(Icons.stop, size: 20.sp),
                  label: const Text('Dừng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGenerate,
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: const Text('Tạo mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s3),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: Icon(Icons.check, size: 20.sp),
                  label: const Text('Áp dụng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const TypingIndicator(),
          SizedBox(height: AppSpacing.s4),
          Text(
            message,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80.sp, color: AppColors.neutral300),
            SizedBox(height: AppSpacing.s4),
            Text(
              title,
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
            SizedBox(height: AppSpacing.s2),
            Text(
              subtitle,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyleSheet() {
    return MarkdownStyleSheet(
      p: AppTypography.bodyM.copyWith(
        color: AppColors.neutral800,
        height: 1.6,
      ),
      h1: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w700,
      ),
      h2: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h3: AppTypography.bodyL.copyWith(
        fontWeight: FontWeight.w600,
      ),
      listBullet: AppTypography.bodyM.copyWith(
        color: AppColors.primary,
      ),
      strong: AppTypography.bodyM.copyWith(
        fontWeight: FontWeight.w700,
      ),
      em: AppTypography.bodyM.copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
