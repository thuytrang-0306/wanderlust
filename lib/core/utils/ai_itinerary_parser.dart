import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';

/// Parser to extract structured AiItineraryModel from AI markdown response
class AiItineraryParser {
  // Common emoji to activity type mapping
  static const Map<String, String> _emojiToType = {
    '🍜': 'food',
    '🍽️': 'food',
    '☕': 'food',
    '🥐': 'food',
    '🍕': 'food',
    '🍱': 'food',
    '🏛️': 'sightseeing',
    '🏯': 'sightseeing',
    '⛩️': 'sightseeing',
    '🗿': 'sightseeing',
    '🖼️': 'sightseeing',
    '🚗': 'transport',
    '🚕': 'transport',
    '🚌': 'transport',
    '✈️': 'transport',
    '🚆': 'transport',
    '🏨': 'accommodation',
    '🏠': 'accommodation',
    '🛏️': 'accommodation',
    '🎭': 'entertainment',
    '🎪': 'entertainment',
    '🎬': 'entertainment',
    '🎵': 'entertainment',
    '🛍️': 'shopping',
    '🏖️': 'beach',
    '⛱️': 'beach',
    '🌊': 'beach',
    '🌳': 'nature',
    '🏞️': 'nature',
    '⛰️': 'nature',
    '🌄': 'nature',
  };

  // Keywords to activity type mapping (Vietnamese)
  static const Map<String, String> _keywordToType = {
    'ăn sáng': 'food',
    'ăn trưa': 'food',
    'ăn tối': 'food',
    'ăn uống': 'food',
    'nhà hàng': 'food',
    'quán': 'food',
    'café': 'food',
    'cà phê': 'food',
    'tham quan': 'sightseeing',
    'viếng': 'sightseeing',
    'chùa': 'sightseeing',
    'đền': 'sightseeing',
    'bảo tàng': 'sightseeing',
    'di tích': 'sightseeing',
    'di chuyển': 'transport',
    'đi taxi': 'transport',
    'đi xe': 'transport',
    'bay': 'transport',
    'khách sạn': 'accommodation',
    'homestay': 'accommodation',
    'resort': 'accommodation',
    'check-in': 'accommodation',
    'giải trí': 'entertainment',
    'xem': 'entertainment',
    'biểu diễn': 'entertainment',
    'mua sắm': 'shopping',
    'chợ': 'shopping',
    'biển': 'beach',
    'bãi biển': 'beach',
    'tắm biển': 'beach',
    'công viên': 'nature',
    'rừng': 'nature',
    'núi': 'nature',
  };

  /// Parse AI markdown response to AiItineraryModel
  static AiItineraryModel parse({
    required String markdown,
    required String tripId,
    required int dayNumber,
    required DateTime date,
  }) {
    try {
      LoggerService.i('Parsing AI itinerary markdown (${markdown.length} chars)');

      final activities = <AiActivity>[];
      String summary = '';

      // Split into lines
      final lines = markdown.split('\n');

      // Extract summary (look for patterns like "Tóm tắt:", "Summary:", or first paragraph)
      summary = _extractSummary(lines);

      // Parse activities
      activities.addAll(_parseActivities(lines));

      // If no activities found, try simpler parsing
      if (activities.isEmpty) {
        LoggerService.w('No activities found with structured parsing, trying simple mode');
        activities.addAll(_parseActivitiesSimple(markdown));
      }

      // If still no activities, create a generic one from the entire text
      if (activities.isEmpty) {
        LoggerService.w('No activities parsed, creating generic activity');
        activities.add(AiActivity(
          time: 'Cả ngày',
          title: 'Hoạt động được đề xuất',
          type: 'other',
          description: markdown.length > 500 ? '${markdown.substring(0, 500)}...' : markdown,
        ));
      }

      final itinerary = AiItineraryModel.create(
        tripId: tripId,
        dayNumber: dayNumber,
        date: date,
        activities: activities,
        summary: summary.isNotEmpty ? summary : 'Lịch trình ngày $dayNumber',
        rawMarkdown: markdown,
      );

      LoggerService.i('Parsed ${activities.length} activities, total cost: ${itinerary.formattedTotalCost}');
      return itinerary;
    } catch (e) {
      LoggerService.e('Error parsing AI itinerary', error: e);
      // Return a fallback itinerary
      return AiItineraryModel.create(
        tripId: tripId,
        dayNumber: dayNumber,
        date: date,
        activities: [
          AiActivity(
            time: 'Cả ngày',
            title: 'Lịch trình được AI tạo',
            type: 'other',
            description: markdown.length > 500 ? '${markdown.substring(0, 500)}...' : markdown,
          ),
        ],
        summary: 'Lịch trình ngày $dayNumber',
        rawMarkdown: markdown,
      );
    }
  }

  /// Extract summary from markdown
  static String _extractSummary(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Look for summary markers
      if (line.toLowerCase().contains('tóm tắt') ||
          line.toLowerCase().contains('summary') ||
          line.toLowerCase().contains('overview')) {
        // Get next non-empty line
        for (var j = i + 1; j < lines.length; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isNotEmpty && !nextLine.startsWith('#')) {
            // Clean markdown
            return nextLine
                .replaceAll(RegExp(r'\*\*'), '')
                .replaceAll(RegExp(r'##'), '')
                .replaceAll(RegExp(r'###'), '')
                .trim();
          }
        }
      }
    }

    // If no summary found, use first paragraph
    for (final line in lines) {
      final cleaned = line.trim();
      if (cleaned.isNotEmpty &&
          !cleaned.startsWith('#') &&
          !cleaned.contains('###') &&
          cleaned.length > 20 &&
          cleaned.length < 200) {
        return cleaned
            .replaceAll(RegExp(r'\*\*'), '')
            .trim();
      }
    }

    return '';
  }

  /// Parse activities from structured markdown
  static List<AiActivity> _parseActivities(List<String> lines) {
    final activities = <AiActivity>[];
    AiActivity? currentActivity;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Check if this is an activity header (contains time and title)
      final activityMatch = _matchActivityHeader(line);
      if (activityMatch != null) {
        // Save previous activity
        if (currentActivity != null) {
          activities.add(currentActivity);
        }

        // Create new activity
        currentActivity = AiActivity(
          time: activityMatch['time']!,
          title: activityMatch['title']!,
          type: activityMatch['type']!,
          emoji: activityMatch['emoji']!,
        );
        continue;
      }

      // If we have a current activity, parse additional info
      if (currentActivity != null) {
        // Location line (📍)
        if (line.startsWith('📍') || line.toLowerCase().contains('địa điểm')) {
          final location = line
              .replaceAll('📍', '')
              .replaceAll(RegExp(r'đ[ịi]a đi[ểe]m:', caseSensitive: false), '')
              .replaceAll('**', '')
              .trim();
          currentActivity = currentActivity.copyWith(location: location);
          continue;
        }

        // Cost line (💰)
        if (line.startsWith('💰') || line.toLowerCase().contains('chi phí')) {
          final cost = _extractCost(line);
          currentActivity = currentActivity.copyWith(estimatedCost: cost);
          continue;
        }

        // Description (any other line that's not empty and not a marker)
        if (!line.startsWith('#') &&
            !line.startsWith('**') &&
            !line.startsWith('-') &&
            !line.startsWith('*') &&
            line.length > 10) {
          final existingDesc = currentActivity.description ?? '';
          final newDesc = existingDesc.isEmpty
              ? line
              : '$existingDesc\n$line';
          currentActivity = currentActivity.copyWith(description: newDesc);
        }
      }
    }

    // Add last activity
    if (currentActivity != null) {
      activities.add(currentActivity);
    }

    return activities;
  }

  /// Simple parsing when structured parsing fails
  static List<AiActivity> _parseActivitiesSimple(String markdown) {
    final activities = <AiActivity>[];

    // Split by common section markers
    final sections = markdown.split(RegExp(r'###|##|\n\n'));

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty || trimmed.length < 10) continue;

      // Try to extract time and title from first line
      final lines = trimmed.split('\n');
      final firstLine = lines.first.trim();

      final timeMatch = RegExp(r'(\d{1,2}[h:]\d{0,2}|\d{1,2}h|\w+)').firstMatch(firstLine);
      if (timeMatch != null) {
        final time = timeMatch.group(0)!;
        final title = firstLine.replaceAll(time, '').replaceAll('-', '').trim();

        if (title.isNotEmpty) {
          final emoji = _extractEmoji(firstLine);
          final type = _detectType(firstLine, emoji);
          final description = lines.length > 1 ? lines.skip(1).join('\n').trim() : null;
          final cost = _extractCost(trimmed);
          final location = _extractLocation(trimmed);

          activities.add(AiActivity(
            time: time,
            title: title,
            type: type,
            emoji: emoji,
            location: location,
            description: description,
            estimatedCost: cost,
          ));
        }
      }
    }

    return activities;
  }

  /// Match activity header line
  static Map<String, String>? _matchActivityHeader(String line) {
    // Pattern: ### 🌅 08:00 - Ăn sáng
    // Or: **08:00 - 🍜 Ăn sáng**
    // Or: 08:00 Ăn sáng tại quán ABC

    // Remove markdown symbols
    var cleaned = line
        .replaceAll('###', '')
        .replaceAll('**', '')
        .trim();

    // Extract time (08:00, 8h, 8:30-10:00, Sáng, Morning)
    final timePattern = RegExp(
      r'(\d{1,2}:\d{2}(?:\s*-\s*\d{1,2}:\d{2})?|\d{1,2}h(?:\d{2})?|s[áa]ng|trưa|chi[ểe]u|t[ốo]i|morning|afternoon|evening|night)',
      caseSensitive: false,
    );

    final timeMatch = timePattern.firstMatch(cleaned);
    if (timeMatch == null) return null;

    final time = timeMatch.group(0)!.trim();

    // Extract emoji
    final emoji = _extractEmoji(cleaned);

    // Get title (everything after time, remove emoji and separators)
    var title = cleaned
        .substring(timeMatch.end)
        .replaceAll(emoji, '')
        .replaceAll('-', '')
        .replaceAll('–', '')
        .trim();

    if (title.isEmpty) return null;

    // Detect type
    final type = _detectType(cleaned, emoji);

    return {
      'time': time,
      'title': title,
      'type': type,
      'emoji': emoji.isNotEmpty ? emoji : _getEmojiForType(type),
    };
  }

  /// Extract emoji from text
  static String _extractEmoji(String text) {
    final emojiPattern = RegExp(
      r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
      unicode: true,
    );

    final match = emojiPattern.firstMatch(text);
    return match?.group(0) ?? '';
  }

  /// Detect activity type from text and emoji
  static String _detectType(String text, String emoji) {
    final lowerText = text.toLowerCase();

    // Check emoji first
    if (emoji.isNotEmpty && _emojiToType.containsKey(emoji)) {
      return _emojiToType[emoji]!;
    }

    // Check keywords
    for (final entry in _keywordToType.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'other';
  }

  /// Get emoji for activity type
  static String _getEmojiForType(String type) {
    switch (type) {
      case 'food':
        return '🍜';
      case 'sightseeing':
        return '🏛️';
      case 'transport':
        return '🚗';
      case 'accommodation':
        return '🏨';
      case 'entertainment':
        return '🎭';
      case 'shopping':
        return '🛍️';
      case 'beach':
        return '🏖️';
      case 'nature':
        return '🌳';
      default:
        return '📍';
    }
  }

  /// Extract cost from text (50K, 100.000 VND, $10, Miễn phí)
  static double? _extractCost(String text) {
    final lowerText = text.toLowerCase();

    // Free patterns
    if (lowerText.contains('miễn phí') ||
        lowerText.contains('free') ||
        lowerText.contains('0 vnd') ||
        lowerText.contains('0đ')) {
      return 0.0;
    }

    // VND patterns
    // 50K, 50k, 50.000, 50,000
    final vndPattern = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(?:k|K|triệu|million|m|M|tr|nghìn|ngàn|thousand)?\s*(?:vnd|VND|đ|dong)?',
      caseSensitive: false,
    );

    final match = vndPattern.firstMatch(text);
    if (match != null) {
      final numberStr = match.group(1)!.replaceAll(',', '.').replaceAll('.', '');
      final number = double.tryParse(numberStr);
      if (number != null) {
        final unit = match.group(0)!.toLowerCase();

        // Determine multiplier
        if (unit.contains('k') || unit.contains('nghìn') || unit.contains('ngàn') || unit.contains('thousand')) {
          return number * 1000;
        } else if (unit.contains('triệu') || unit.contains('million') || unit.contains('m') || unit.contains('tr')) {
          return number * 1000000;
        } else {
          return number;
        }
      }
    }

    return null;
  }

  /// Extract location from text
  static String? _extractLocation(String text) {
    // Look for location marker
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.startsWith('📍') || line.toLowerCase().contains('địa điểm')) {
        return line
            .replaceAll('📍', '')
            .replaceAll(RegExp(r'đ[ịi]a đi[ểe]m:', caseSensitive: false), '')
            .replaceAll('**', '')
            .trim();
      }
    }
    return null;
  }
}
