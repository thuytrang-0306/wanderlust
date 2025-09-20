import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/services/admin_content_service.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/core/widgets/app_snackbar.dart';

class ContentStats {
  final int totalContent;
  final int pendingReview;
  final int approvedContent;
  final int rejectedContent;
  final int flaggedContent;

  ContentStats({
    this.totalContent = 0,
    this.pendingReview = 0,
    this.approvedContent = 0,
    this.rejectedContent = 0,
    this.flaggedContent = 0,
  });
}

class AdminContentController extends GetxController {
  final AdminContentService _contentService = Get.find<AdminContentService>();

  // UI State
  final RxBool isLoading = false.obs;
  final RxList<ContentModerationItem> content = <ContentModerationItem>[].obs;
  final RxList<ContentModerationItem> allContent = <ContentModerationItem>[].obs;
  final Rx<ContentStats> contentStats = ContentStats().obs;

  // Search and Filters
  final TextEditingController searchController = TextEditingController();
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedDateRange = 'all'.obs;

  // Selection
  final RxSet<String> selectedContent = <String>{}.obs;

  // Current content for details view
  final Rxn<ContentModerationItem> selectedContentItem = Rxn<ContentModerationItem>();
  final RxList<Map<String, dynamic>> contentHistory = <Map<String, dynamic>>[].obs;

  // Moderation form
  final TextEditingController moderationNotesController = TextEditingController();
  final TextEditingController rejectionReasonController = TextEditingController();
  final TextEditingController flagReasonController = TextEditingController();

  // Computed properties
  bool get isAllSelected => selectedContent.length == content.length && content.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    loadContent();
  }

  @override
  void onClose() {
    searchController.dispose();
    moderationNotesController.dispose();
    rejectionReasonController.dispose();
    flagReasonController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    // Listen to real-time content changes
    ever(_contentService.allContent, (contentList) {
      allContent.value = contentList as List<ContentModerationItem>;
      _updateStats();
      _applyFilters();
      LoggerService.i('Real-time content update: ${contentList.length} content items');
    });
  }

  Future<void> loadContent() async {
    try {
      isLoading.value = true;
      
      // Load content via service
      await _contentService.loadAllContent();
      allContent.value = _contentService.allContent;
      
      _updateStats();
      _applyFilters();
      
      LoggerService.i('Loaded ${allContent.length} content items successfully');
    } catch (e) {
      LoggerService.e('Error loading content', error: e);
      AppSnackbar.showError(message: 'Failed to load content');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    final total = allContent.length;
    final pending = allContent.where((c) => 
        c.status == ContentStatus.pending).length;
    final approved = allContent.where((c) => 
        c.status == ContentStatus.approved).length;
    final rejected = allContent.where((c) => 
        c.status == ContentStatus.rejected).length;
    final flagged = allContent.where((c) => 
        c.status == ContentStatus.flagged).length;
    
    contentStats.value = ContentStats(
      totalContent: total,
      pendingReview: pending,
      approvedContent: approved,
      rejectedContent: rejected,
      flaggedContent: flagged,
    );
  }

  void _applyFilters() {
    var filteredContent = List<ContentModerationItem>.from(allContent);

    // Apply search filter
    final searchQuery = searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filteredContent = filteredContent.where((contentItem) {
        return contentItem.title.toLowerCase().contains(searchQuery) ||
               contentItem.content.toLowerCase().contains(searchQuery) ||
               contentItem.authorName.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'all') {
      filteredContent = filteredContent.where((contentItem) => 
          contentItem.status.value == selectedStatus.value).toList();
    }

    // Apply type filter
    if (selectedType.value != 'all') {
      filteredContent = filteredContent.where((contentItem) => 
          contentItem.type.value == selectedType.value).toList();
    }

    // Apply date range filter
    if (selectedDateRange.value != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (selectedDateRange.value) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(1970);
      }
      
      filteredContent = filteredContent.where((contentItem) => 
          contentItem.createdAt.isAfter(startDate)).toList();
    }

    // Sort by creation date (newest first)
    filteredContent.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    content.value = filteredContent;
    
    // Clear selection if content changed
    selectedContent.removeWhere((id) => !content.any((contentItem) => contentItem.id == id));
  }

  // Search and Filter Methods
  void onSearchChanged(String query) {
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void onTypeFilterChanged(String type) {
    selectedType.value = type;
    _applyFilters();
  }

  void onDateRangeFilterChanged(String dateRange) {
    selectedDateRange.value = dateRange;
    _applyFilters();
  }

  // Selection Methods
  void toggleContentSelection(String contentId) {
    if (selectedContent.contains(contentId)) {
      selectedContent.remove(contentId);
    } else {
      selectedContent.add(contentId);
    }
  }

  void toggleSelectAll(bool? selectAll) {
    if (selectAll == true) {
      selectedContent.addAll(content.map((contentItem) => contentItem.id));
    } else {
      selectedContent.clear();
    }
  }

  // Content Detail Methods
  Future<void> viewContentDetails(String contentId, ContentType type) async {
    try {
      isLoading.value = true;
      
      // Get content details
      final contentItem = await _contentService.getContentDetails(contentId, type);
      if (contentItem != null) {
        selectedContentItem.value = contentItem;
        
        // Load content history
        final history = await _contentService.getContentHistory(contentId);
        contentHistory.value = history;
        
        LoggerService.i('Content details loaded: ${contentItem.title}');
      }
    } catch (e) {
      LoggerService.e('Error loading content details', error: e);
      AppSnackbar.showError(message: 'Failed to load content details');
    } finally {
      isLoading.value = false;
    }
  }

  // Content Action Methods
  Future<void> approveContent(String contentId, ContentType type, {String? notes}) async {
    try {
      isLoading.value = true;
      
      final success = await _contentService.approveContent(
        contentId,
        type,
        notes: notes ?? moderationNotesController.text.trim(),
      );

      if (success) {
        LoggerService.i('Content approved: $contentId');
        AppSnackbar.showSuccess(message: 'Content approved successfully');
        moderationNotesController.clear();
        
        // Refresh details if viewing this content
        if (selectedContentItem.value?.id == contentId) {
          await viewContentDetails(contentId, type);
        }
      }
    } catch (e) {
      LoggerService.e('Error approving content', error: e);
      AppSnackbar.showError(message: 'Failed to approve content');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectContent(String contentId, ContentType type, {String? reason}) async {
    try {
      isLoading.value = true;
      
      final rejectionReason = reason ?? rejectionReasonController.text.trim();
      if (rejectionReason.isEmpty) {
        AppSnackbar.showError(message: 'Rejection reason is required');
        return;
      }
      
      final success = await _contentService.rejectContent(
        contentId,
        type,
        reason: rejectionReason,
      );

      if (success) {
        LoggerService.i('Content rejected: $contentId');
        AppSnackbar.showSuccess(message: 'Content rejected');
        rejectionReasonController.clear();
        
        // Refresh details if viewing this content
        if (selectedContentItem.value?.id == contentId) {
          await viewContentDetails(contentId, type);
        }
      }
    } catch (e) {
      LoggerService.e('Error rejecting content', error: e);
      AppSnackbar.showError(message: 'Failed to reject content');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> flagContent(String contentId, ContentType type, {String? reason}) async {
    try {
      isLoading.value = true;
      
      final flagReason = reason ?? flagReasonController.text.trim();
      if (flagReason.isEmpty) {
        AppSnackbar.showError(message: 'Flag reason is required');
        return;
      }
      
      final success = await _contentService.flagContent(
        contentId,
        type,
        reason: flagReason,
      );

      if (success) {
        LoggerService.i('Content flagged: $contentId');
        AppSnackbar.showSuccess(message: 'Content flagged for review');
        flagReasonController.clear();
        
        // Refresh details if viewing this content
        if (selectedContentItem.value?.id == contentId) {
          await viewContentDetails(contentId, type);
        }
      }
    } catch (e) {
      LoggerService.e('Error flagging content', error: e);
      AppSnackbar.showError(message: 'Failed to flag content');
    } finally {
      isLoading.value = false;
    }
  }

  // Bulk Action Methods
  Future<void> bulkApproveContent() async {
    if (selectedContent.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      final contentIds = selectedContent.toList();
      final types = contentIds.map((id) {
        final contentItem = content.firstWhere((c) => c.id == id);
        return contentItem.type;
      }).toList();
      
      final success = await _contentService.bulkApproveContent(contentIds, types);

      if (success) {
        LoggerService.i('Bulk approved ${selectedContent.length} content items');
        AppSnackbar.showSuccess(message: '${selectedContent.length} content items approved');
        selectedContent.clear();
      }
    } catch (e) {
      LoggerService.e('Error bulk approving content', error: e);
      AppSnackbar.showError(message: 'Failed to approve selected content');
    } finally {
      isLoading.value = false;
    }
  }

  // Export Methods
  Future<void> exportContent() async {
    try {
      await _exportContentToCSV(content);
      
      LoggerService.i('Exported ${content.length} content items to CSV');
      AppSnackbar.showSuccess(message: 'Content exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting content', error: e);
      AppSnackbar.showError(message: 'Failed to export content');
    }
  }

  Future<void> exportSelectedContent() async {
    if (selectedContent.isEmpty) return;
    
    try {
      final selectedContentList = content.where((contentItem) => 
          selectedContent.contains(contentItem.id)).toList();
      await _exportContentToCSV(selectedContentList);
      
      LoggerService.i('Exported ${selectedContent.length} selected content items to CSV');
      AppSnackbar.showSuccess(message: '${selectedContent.length} content items exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting selected content', error: e);
      AppSnackbar.showError(message: 'Failed to export selected content');
    }
  }

  Future<void> _exportContentToCSV(List<ContentModerationItem> contentToExport) async {
    final csvData = StringBuffer();
    
    // Add header
    csvData.writeln('ID,Type,Title,Author,Status,Created At,Updated At,Report Count,Flags');
    
    // Add data rows
    for (final contentItem in contentToExport) {
      csvData.writeln([
        contentItem.id,
        contentItem.type.displayName,
        '"${contentItem.title}"',
        '"${contentItem.authorName}"',
        contentItem.status.displayName,
        contentItem.createdAt.toIso8601String(),
        contentItem.updatedAt.toIso8601String(),
        contentItem.reportCount,
        '"${contentItem.flags.join(', ')}"',
      ].join(','));
    }
    
    // Create and download file
    final bytes = utf8.encode(csvData.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final filename = 'wanderlust_content_$timestamp.csv';
    
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }

  // Utility Methods
  Future<void> refreshContent() async {
    selectedContent.clear();
    await loadContent();
  }

  void clearFilters() {
    searchController.clear();
    selectedStatus.value = 'all';
    selectedType.value = 'all';
    selectedDateRange.value = 'all';
    _applyFilters();
  }

  // Get status color
  Color getStatusColor(ContentStatus status) {
    switch (status) {
      case ContentStatus.approved:
        return const Color(0xFF10B981); // Green
      case ContentStatus.pending:
        return const Color(0xFFF59E0B); // Orange
      case ContentStatus.rejected:
        return const Color(0xFFEF4444); // Red
      case ContentStatus.flagged:
        return const Color(0xFFDC2626); // Dark Red
      case ContentStatus.suspended:
        return const Color(0xFF6B7280); // Gray
      case ContentStatus.draft:
        return const Color(0xFF9CA3AF); // Light Gray
    }
  }

  // Get type color
  Color getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.blog:
        return const Color(0xFF3B82F6); // Blue
      case ContentType.listing:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  // Get type icon
  String getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.blog:
        return '📝';
      case ContentType.listing:
        return '🏨';
    }
  }
}