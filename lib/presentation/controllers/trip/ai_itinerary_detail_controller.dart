import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/models/ai_itinerary_model.dart';
import 'package:share_plus/share_plus.dart';

/// Controller for AI Itinerary Detail Page
class AiItineraryDetailController extends GetxController {
  // Itinerary data
  late AiItineraryModel itinerary;

  // Expanded activity indexes
  final RxSet<int> expandedActivities = <int>{}.obs;

  // Initialize with itinerary
  void init(AiItineraryModel aiItinerary) {
    itinerary = aiItinerary;
    LoggerService.i('AI Itinerary Detail initialized: ${itinerary.activityCount} activities');
  }

  // Toggle activity expansion
  void toggleActivity(int index) {
    if (expandedActivities.contains(index)) {
      expandedActivities.remove(index);
    } else {
      expandedActivities.add(index);
    }
  }

  // Check if activity is expanded
  bool isExpanded(int index) {
    return expandedActivities.contains(index);
  }

  // Copy raw markdown to clipboard
  void copyMarkdown() {
    Clipboard.setData(ClipboardData(text: itinerary.rawMarkdown));
    AppSnackbar.showSuccess(
      title: 'Đã sao chép',
      message: 'Nội dung lịch trình đã được sao chép',
    );
  }

  // Share itinerary
  Future<void> shareItinerary() async {
    try {
      final text = '''
✨ Lịch trình AI - Ngày ${itinerary.dayNumber}

📍 ${itinerary.summary}
📊 ${itinerary.activityCount} hoạt động • ${itinerary.formattedTotalCost}

${itinerary.rawMarkdown}

---
Tạo bởi Wanderlust AI
''';

      await Share.share(text);
      LoggerService.i('Itinerary shared successfully');
    } catch (e) {
      LoggerService.e('Error sharing itinerary', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể chia sẻ lịch trình',
      );
    }
  }

  // Get activities grouped by time of day
  Map<String, List<AiActivity>> get activitiesByTimeOfDay {
    final groups = <String, List<AiActivity>>{
      'Sáng': [],
      'Trưa': [],
      'Chiều': [],
      'Tối': [],
    };

    for (final activity in itinerary.activities) {
      final timeGroup = _getTimeGroup(activity.time);
      groups[timeGroup]?.add(activity);
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);

    return groups;
  }

  // Get time group from time string
  String _getTimeGroup(String time) {
    // Extract hour from time string
    final timeStr = time.toLowerCase();

    if (timeStr.contains('sáng') || timeStr.contains('morning')) {
      return 'Sáng';
    }
    if (timeStr.contains('trưa') || timeStr.contains('noon') || timeStr.contains('lunch')) {
      return 'Trưa';
    }
    if (timeStr.contains('chiều') || timeStr.contains('afternoon')) {
      return 'Chiều';
    }
    if (timeStr.contains('tối') || timeStr.contains('evening') || timeStr.contains('night')) {
      return 'Tối';
    }

    // Try to parse hour
    final hourMatch = RegExp(r'(\d{1,2})[:h]').firstMatch(timeStr);
    if (hourMatch != null) {
      final hour = int.tryParse(hourMatch.group(1)!);
      if (hour != null) {
        if (hour >= 5 && hour < 11) return 'Sáng';
        if (hour >= 11 && hour < 13) return 'Trưa';
        if (hour >= 13 && hour < 17) return 'Chiều';
        if (hour >= 17 || hour < 5) return 'Tối';
      }
    }

    // Default to full day if can't determine
    return 'Cả ngày';
  }

  // Get color for time group
  Color getTimeGroupColor(String timeGroup) {
    switch (timeGroup) {
      case 'Sáng':
        return const Color(0xFFFFF4E0); // Light yellow
      case 'Trưa':
        return const Color(0xFFFFE8CC); // Light orange
      case 'Chiều':
        return const Color(0xFFFFDDD0); // Light coral
      case 'Tối':
        return const Color(0xFFE0E4FF); // Light purple
      default:
        return const Color(0xFFF0F0F0); // Light gray
    }
  }

  // Get icon for time group
  String getTimeGroupIcon(String timeGroup) {
    switch (timeGroup) {
      case 'Sáng':
        return '🌅';
      case 'Trưa':
        return '☀️';
      case 'Chiều':
        return '🌤️';
      case 'Tối':
        return '🌙';
      default:
        return '📅';
    }
  }
}
