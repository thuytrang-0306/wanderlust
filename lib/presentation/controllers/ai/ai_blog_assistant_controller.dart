import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/services/gemini_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/utils/ai_blog_prompt_builder.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/ai_conversation.dart';

/// Controller for AI Blog Assistant
/// Provides AI-powered features for blog creation and reading
class AiBlogAssistantController extends GetxController {
  final GeminiService _geminiService = GeminiService.to;

  // Current tab in bottom sheet
  final RxInt currentTab = 0.obs;

  // Loading states
  final RxBool isGeneratingTitles = false.obs;
  final RxBool isGeneratingBlog = false.obs;
  final RxBool isImprovingWriting = false.obs;
  final RxBool isGeneratingTags = false.obs;
  final RxBool isSummarizing = false.obs;
  final RxBool isExtractingInsights = false.obs;

  // Generated content
  final RxList<String> titleSuggestions = <String>[].obs;
  final RxString generatedBlog = ''.obs;
  final RxString improvedWriting = ''.obs;
  final RxList<String> generatedTags = <String>[].obs;
  final RxString blogSummary = ''.obs;
  final RxMap<String, dynamic> blogInsights = <String, dynamic>{}.obs;

  // Streaming state
  final RxString streamingContent = ''.obs;
  final RxBool isStreaming = false.obs;

  // Selected suggestion
  final RxInt selectedTitleIndex = (-1).obs;

  /// Generate title suggestions
  Future<void> generateTitles({
    required List<String> tags,
    required List<String> destinations,
    String? userContext,
  }) async {
    if (isGeneratingTitles.value) return;

    try {
      isGeneratingTitles.value = true;
      titleSuggestions.clear();
      selectedTitleIndex.value = -1;

      final prompt = AiBlogPromptBuilder.buildTitleGenerationPrompt(
        tags: tags,
        destinations: destinations,
        userContext: userContext,
      );

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      final response = await _geminiService.sendMessage(
        conversation: conversation,
        message: prompt,
      );

      // Parse titles (each line is a title)
      final titles = response
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line.length > 5)
          .take(5)
          .toList();

      titleSuggestions.value = titles;
      LoggerService.i('Generated ${titles.length} title suggestions');

      if (titles.isEmpty) {
        AppSnackbar.showWarning(
          title: 'Thông báo',
          message: 'Không tạo được tiêu đề. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      LoggerService.e('Error generating titles', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể tạo tiêu đề. Vui lòng thử lại.',
      );
    } finally {
      isGeneratingTitles.value = false;
    }
  }

  /// Generate full blog post with streaming
  Future<void> generateBlogPost({
    required String title,
    List<String>? tags,
    List<String>? destinations,
    int? imageCount,
    String? userDraft,
  }) async {
    if (isGeneratingBlog.value) return;

    try {
      isGeneratingBlog.value = true;
      isStreaming.value = true;
      generatedBlog.value = '';
      streamingContent.value = '';

      final prompt = AiBlogPromptBuilder.buildBlogGenerationPrompt(
        title: title,
        tags: tags,
        destinations: destinations,
        imageCount: imageCount,
        userDraft: userDraft,
      );

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      final responseStream = _geminiService.sendMessageStream(
        conversation: conversation,
        message: prompt,
      );

      String latestContent = '';

      await for (final chunk in responseStream) {
        streamingContent.value = chunk;
        latestContent = chunk;
      }

      // Finish streaming
      generatedBlog.value = latestContent;
      isStreaming.value = false;

      LoggerService.i('Generated blog post: ${latestContent.length} characters');
    } catch (e) {
      LoggerService.e('Error generating blog post', error: e);
      isStreaming.value = false;
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể tạo bài viết. Vui lòng thử lại.',
      );
    } finally {
      isGeneratingBlog.value = false;
    }
  }

  /// Stop streaming
  void stopStreaming() {
    isStreaming.value = false;
    if (streamingContent.value.isNotEmpty) {
      generatedBlog.value = streamingContent.value;
    }
  }

  /// Improve user's writing
  Future<void> improveWriting(String draft) async {
    if (isImprovingWriting.value) return;

    if (draft.trim().isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thông báo',
        message: 'Vui lòng nhập nội dung cần cải thiện',
      );
      return;
    }

    try {
      isImprovingWriting.value = true;
      improvedWriting.value = '';

      final prompt = AiBlogPromptBuilder.buildWritingImprovementPrompt(draft);

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      final response = await _geminiService.sendMessage(
        conversation: conversation,
        message: prompt,
      );

      improvedWriting.value = response;
      LoggerService.i('Improved writing: ${response.length} characters');
    } catch (e) {
      LoggerService.e('Error improving writing', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể cải thiện bài viết. Vui lòng thử lại.',
      );
    } finally {
      isImprovingWriting.value = false;
    }
  }

  /// Generate tags from title and content
  Future<void> generateTags({
    required String title,
    required String content,
  }) async {
    if (isGeneratingTags.value) return;

    if (title.trim().isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thông báo',
        message: 'Vui lòng nhập tiêu đề trước',
      );
      return;
    }

    try {
      isGeneratingTags.value = true;
      generatedTags.clear();

      final prompt = AiBlogPromptBuilder.buildTagGenerationPrompt(
        title: title,
        content: content,
      );

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      final response = await _geminiService.sendMessage(
        conversation: conversation,
        message: prompt,
      );

      // Parse tags (space-separated, with # prefix)
      final tags = response
          .split(RegExp(r'\s+'))
          .map((tag) => tag.trim())
          .where((tag) => tag.startsWith('#') && tag.length > 2)
          .take(8)
          .toList();

      generatedTags.value = tags;
      LoggerService.i('Generated ${tags.length} tags');
    } catch (e) {
      LoggerService.e('Error generating tags', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể tạo tags. Vui lòng thử lại.',
      );
    } finally {
      isGeneratingTags.value = false;
    }
  }

  /// Summarize blog post (for reading)
  Future<void> summarizeBlog(String content) async {
    if (isSummarizing.value) return;

    if (content.trim().isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thông báo',
        message: 'Không có nội dung để tóm tắt',
      );
      return;
    }

    try {
      isSummarizing.value = true;
      blogSummary.value = '';

      final prompt = AiBlogPromptBuilder.buildSummarizationPrompt(content);

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      // Retry mechanism for 503 errors
      int retries = 0;
      const maxRetries = 3;
      String? response;

      while (retries < maxRetries) {
        try {
          response = await _geminiService.sendMessage(
            conversation: conversation,
            message: prompt,
          );
          break; // Success, exit retry loop
        } catch (e) {
          retries++;
          LoggerService.w('Retry attempt $retries/$maxRetries for summarizeBlog');

          if (retries >= maxRetries) {
            rethrow; // Final failure
          }

          // Wait before retry (exponential backoff)
          await Future.delayed(Duration(seconds: 2 * retries));
        }
      }

      if (response != null) {
        blogSummary.value = response;
        LoggerService.i('Summarized blog: ${response.length} characters');
      }
    } catch (e) {
      LoggerService.e('Error summarizing blog', error: e);

      // Better error message for 503
      final errorMsg = e.toString().contains('503') || e.toString().contains('overloaded')
          ? 'Server AI đang quá tải. Vui lòng thử lại sau ít phút.'
          : 'Không thể tóm tắt bài viết. Vui lòng thử lại.';

      AppSnackbar.showError(
        title: 'Lỗi',
        message: errorMsg,
      );
    } finally {
      isSummarizing.value = false;
    }
  }

  /// Extract insights from blog post
  Future<void> extractInsights(String content) async {
    if (isExtractingInsights.value) return;

    if (content.trim().isEmpty) {
      return;
    }

    try {
      isExtractingInsights.value = true;
      blogInsights.clear();

      final prompt = AiBlogPromptBuilder.buildInsightsExtractionPrompt(content);

      // Create temporary conversation
      final conversation = AIConversation.create(
        context: ConversationContext.general,
      );

      // Retry mechanism for 503 errors
      int retries = 0;
      const maxRetries = 3;
      String? response;

      while (retries < maxRetries) {
        try {
          response = await _geminiService.sendMessage(
            conversation: conversation,
            message: prompt,
          );
          break; // Success
        } catch (e) {
          retries++;
          LoggerService.w('Retry attempt $retries/$maxRetries for extractInsights');

          if (retries >= maxRetries) {
            rethrow;
          }

          await Future.delayed(Duration(seconds: 2 * retries));
        }
      }

      if (response == null) {
        throw Exception('No response after retries');
      }

      // Parse JSON response
      try {
        // Clean response (remove markdown code blocks if present)
        String cleanedResponse = response.trim();
        if (cleanedResponse.startsWith('```json')) {
          cleanedResponse = cleanedResponse
              .replaceFirst('```json', '')
              .replaceFirst('```', '')
              .trim();
        } else if (cleanedResponse.startsWith('```')) {
          cleanedResponse = cleanedResponse
              .replaceFirst('```', '')
              .replaceFirst('```', '')
              .trim();
        }

        final insights = jsonDecode(cleanedResponse) as Map<String, dynamic>;
        blogInsights.value = insights;
        LoggerService.i('Extracted insights: ${insights.keys.length} fields');
      } catch (parseError) {
        LoggerService.e('Error parsing insights JSON', error: parseError);
        // Fallback: create default structure
        blogInsights.value = {
          'budget': 'Không đề cập',
          'duration': 'Không đề cập',
          'bestTime': 'Không đề cập',
          'accommodation': 'Không đề cập',
          'mustTry': [],
          'highlights': [],
        };
      }
    } catch (e) {
      LoggerService.e('Error extracting insights', error: e);
      // Silent fail for insights (not critical)
      blogInsights.value = {
        'budget': 'Không đề cập',
        'duration': 'Không đề cập',
        'bestTime': 'Không đề cập',
        'accommodation': 'Không đề cập',
        'mustTry': [],
        'highlights': [],
      };
    } finally {
      isExtractingInsights.value = false;
    }
  }

  /// Select a title suggestion
  void selectTitle(int index) {
    selectedTitleIndex.value = index;
  }

  /// Copy content to clipboard
  void copyToClipboard(String content) {
    if (content.isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thông báo',
        message: 'Không có nội dung để sao chép',
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: content));
    AppSnackbar.showSuccess(
      title: 'Thành công',
      message: 'Đã sao chép vào clipboard',
    );
  }

  /// Change tab
  void changeTab(int index) {
    currentTab.value = index;
  }

  /// Reset all state
  void reset() {
    titleSuggestions.clear();
    generatedBlog.value = '';
    improvedWriting.value = '';
    generatedTags.clear();
    blogSummary.value = '';
    blogInsights.clear();
    streamingContent.value = '';
    selectedTitleIndex.value = -1;
    currentTab.value = 0;
    isStreaming.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
