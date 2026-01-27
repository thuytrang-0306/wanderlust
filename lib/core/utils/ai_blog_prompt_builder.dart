/// AI Blog Prompt Builder
/// Centralized prompt templates for blog-related AI features
class AiBlogPromptBuilder {
  AiBlogPromptBuilder._();

  /// Generate 5 catchy blog titles
  static String buildTitleGenerationPrompt({
    required List<String> tags,
    required List<String> destinations,
    String? userContext,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Generate 5 catchy Vietnamese blog titles for a travel blog post.');
    buffer.writeln('');

    if (destinations.isNotEmpty) {
      buffer.writeln('Destinations: ${destinations.join(", ")}');
    }

    if (tags.isNotEmpty) {
      buffer.writeln('Tags: ${tags.join(", ")}');
    }

    if (userContext != null && userContext.isNotEmpty) {
      buffer.writeln('User context: $userContext');
    }

    buffer.writeln('');
    buffer.writeln('Requirements:');
    buffer.writeln('- Hấp dẫn, SEO-friendly');
    buffer.writeln('- Dài 8-15 từ');
    buffer.writeln('- Varied styles:');
    buffer.writeln('  1. Question-based (Có nên...?)');
    buffer.writeln('  2. Number-based (Top 5, 3 ngày...)');
    buffer.writeln('  3. Emotional hook (Tuyệt vời, Đáng kinh ngạc...)');
    buffer.writeln('  4. Practical guide (Hướng dẫn, Cẩm nang...)');
    buffer.writeln('  5. Story-based (Trải nghiệm, Hành trình...)');
    buffer.writeln('');
    buffer.writeln('Output format: Plain text, mỗi title một dòng, không số thứ tự.');

    return buffer.toString();
  }

  /// Generate full blog post content
  static String buildBlogGenerationPrompt({
    required String title,
    List<String>? tags,
    List<String>? destinations,
    int? imageCount,
    String? userDraft,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Bạn là AI travel writing assistant của Wanderlust app.');
    buffer.writeln('');
    buffer.writeln('Context:');
    buffer.writeln('- Tiêu đề: "$title"');

    if (destinations != null && destinations.isNotEmpty) {
      buffer.writeln('- Điểm đến: ${destinations.join(", ")}');
    }

    if (tags != null && tags.isNotEmpty) {
      buffer.writeln('- Tags: ${tags.join(", ")}');
    }

    if (imageCount != null && imageCount > 0) {
      buffer.writeln('- Có $imageCount ảnh đính kèm');
    }

    if (userDraft != null && userDraft.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('User đã viết một phần:');
      buffer.writeln('"""');
      buffer.writeln(userDraft);
      buffer.writeln('"""');
      buffer.writeln('');
      buffer.writeln('Hãy expand và enhance bài viết này.');
    }

    buffer.writeln('');
    buffer.writeln('Yêu cầu viết blog post:');
    buffer.writeln('- Độ dài: 800-1200 từ bằng tiếng Việt');
    buffer.writeln('- Giọng văn: Thân thiện, nhiệt tình, cá nhân hóa (dùng "mình", "bạn")');
    buffer.writeln('- Cấu trúc:');
    buffer.writeln('  1. **Intro** (2-3 câu): Hook reader, giới thiệu điểm đến');
    buffer.writeln('  2. **Trải nghiệm chính** (3-4 đoạn): Kể chi tiết về các hoạt động, địa điểm');
    buffer.writeln('  3. **Tips hữu ích** (bullet points): Lời khuyên practical');
    buffer.writeln('  4. **Kết luận** (2-3 câu): Tóm tắt và call-to-action');
    buffer.writeln('');
    buffer.writeln('Lưu ý:');
    buffer.writeln('- Sử dụng emoji phù hợp (🌅 🏖️ 🍜 🏨 ✨)');
    buffer.writeln('- Include thông tin practical: giá cả, giờ mở cửa, tips');
    buffer.writeln('- Kết thúc bằng câu hỏi để encourage engagement');
    buffer.writeln('- Format markdown với heading (##), bold (**), bullet points (-)');
    buffer.writeln('');
    buffer.writeln('Hãy viết blog post hoàn chỉnh ngay bây giờ:');

    return buffer.toString();
  }

  /// Improve existing writing
  static String buildWritingImprovementPrompt(String draft) {
    final buffer = StringBuffer();

    buffer.writeln('Cải thiện bài viết du lịch sau, giữ nguyên ý chính và giọng điệu cá nhân:');
    buffer.writeln('');
    buffer.writeln('"""');
    buffer.writeln(draft);
    buffer.writeln('"""');
    buffer.writeln('');
    buffer.writeln('Improvements cần:');
    buffer.writeln('1. ✅ Grammar & spelling (sửa lỗi chính tả, ngữ pháp)');
    buffer.writeln('2. ✅ Flow & transitions (cải thiện luồng ý, nối câu mượt mà)');
    buffer.writeln('3. ✅ Engaging language (thêm ngôn ngữ hấp dẫn, sinh động)');
    buffer.writeln('4. ✅ Emotional hooks (thêm cảm xúc, trải nghiệm cá nhân)');
    buffer.writeln('5. ✅ Better structure (cấu trúc rõ ràng hơn)');
    buffer.writeln('6. ✅ Add relevant emoji (thêm emoji phù hợp)');
    buffer.writeln('');
    buffer.writeln('IMPORTANT:');
    buffer.writeln('- Keep Vietnamese natural tone (giữ giọng văn tự nhiên)');
    buffer.writeln('- Preserve user\'s personal stories & experiences');
    buffer.writeln('- Don\'t change facts or main points');
    buffer.writeln('- Format markdown');
    buffer.writeln('');
    buffer.writeln('Output: Improved version only, no explanation.');

    return buffer.toString();
  }

  /// Generate relevant tags
  static String buildTagGenerationPrompt({
    required String title,
    required String content,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Analyze this travel blog post and generate relevant tags:');
    buffer.writeln('');
    buffer.writeln('Title: $title');
    buffer.writeln('');
    buffer.writeln('Content preview:');
    buffer.writeln(content.length > 500 ? '${content.substring(0, 500)}...' : content);
    buffer.writeln('');
    buffer.writeln('Generate 5-8 relevant Vietnamese tags in format #tag');
    buffer.writeln('');
    buffer.writeln('Categories to consider:');
    buffer.writeln('- Type: #dulich #phuotbalo #nghidưỡng #adventure');
    buffer.writeln('- Activity: #beach #mountain #food #culture #shopping');
    buffer.writeln('- Season: #summer #winter #tetholiday');
    buffer.writeln('- Budget: #savings #luxury #midrange');
    buffer.writeln('- Group: #solo #couple #family #friends');
    buffer.writeln('');
    buffer.writeln('Output format: Space-separated tags, lowercase, no numbering.');
    buffer.writeln('Example: #beach #danang #seafood #sunset #3ngay2dem');

    return buffer.toString();
  }

  /// Summarize blog post (TL;DR)
  static String buildSummarizationPrompt(String content) {
    final buffer = StringBuffer();

    buffer.writeln('Tóm tắt bài viết du lịch sau thành các điểm chính:');
    buffer.writeln('');
    buffer.writeln('"""');
    buffer.writeln(content.length > 3000 ? '${content.substring(0, 3000)}...' : content);
    buffer.writeln('"""');
    buffer.writeln('');
    buffer.writeln('Output format (markdown):');
    buffer.writeln('## 📝 Tóm tắt');
    buffer.writeln('');
    buffer.writeln('**📍 Điểm đến:** [nơi]');
    buffer.writeln('**⏰ Thời gian:** [số ngày]');
    buffer.writeln('**💰 Chi phí:** [budget estimate]');
    buffer.writeln('**🌟 Highlights:**');
    buffer.writeln('- [điểm nổi bật 1]');
    buffer.writeln('- [điểm nổi bật 2]');
    buffer.writeln('- [điểm nổi bật 3]');
    buffer.writeln('');
    buffer.writeln('**💡 Tips:**');
    buffer.writeln('- [tip 1]');
    buffer.writeln('- [tip 2]');
    buffer.writeln('');
    buffer.writeln('Keep it concise (6-8 bullet points max).');

    return buffer.toString();
  }

  /// Extract key insights from blog
  static String buildInsightsExtractionPrompt(String content) {
    final buffer = StringBuffer();

    buffer.writeln('Extract key travel insights from this blog post:');
    buffer.writeln('');
    buffer.writeln('"""');
    buffer.writeln(content.length > 2000 ? '${content.substring(0, 2000)}...' : content);
    buffer.writeln('"""');
    buffer.writeln('');
    buffer.writeln('Extract and return JSON format:');
    buffer.writeln('{');
    buffer.writeln('  "budget": "Budget estimate in VND or range",');
    buffer.writeln('  "duration": "Trip duration (e.g., 3 ngày 2 đêm)",');
    buffer.writeln('  "bestTime": "Best time to visit (e.g., Tháng 3-8)",');
    buffer.writeln('  "accommodation": "Recommended accommodation type",');
    buffer.writeln('  "mustTry": ["Food 1", "Food 2", "Food 3"],');
    buffer.writeln('  "highlights": ["Place 1", "Place 2", "Place 3"]');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('If information not found, use "Không đề cập" for that field.');
    buffer.writeln('Output: Valid JSON only, no explanation.');

    return buffer.toString();
  }

  /// Generate excerpt from content
  static String buildExcerptGenerationPrompt(String content) {
    final buffer = StringBuffer();

    buffer.writeln('Generate a compelling excerpt (2-3 sentences, ~100-150 characters) for this blog:');
    buffer.writeln('');
    buffer.writeln('"""');
    buffer.writeln(content.length > 1000 ? '${content.substring(0, 1000)}...' : content);
    buffer.writeln('"""');
    buffer.writeln('');
    buffer.writeln('Requirements:');
    buffer.writeln('- Hook reader\'s interest');
    buffer.writeln('- Summarize main point');
    buffer.writeln('- 100-150 characters');
    buffer.writeln('- Vietnamese, casual tone');
    buffer.writeln('');
    buffer.writeln('Output: Excerpt text only, no quotes or explanation.');

    return buffer.toString();
  }
}
