import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/data/models/blog_post_model.dart';
import 'package:wanderlust/shared/data/models/listing_model.dart';
import 'package:wanderlust/admin/services/admin_auth_service.dart';

enum ContentStatus {
  draft('draft', 'Nháp'),
  pending('pending', 'Chờ duyệt'),
  approved('approved', 'Đã duyệt'),
  rejected('rejected', 'Từ chối'),
  flagged('flagged', 'Báo cáo'),
  suspended('suspended', 'Tạm ngưng');

  final String value;
  final String displayName;

  const ContentStatus(this.value, this.displayName);

  static ContentStatus fromString(String value) {
    return ContentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentStatus.draft,
    );
  }
}

enum ContentType {
  blog('blog', 'Blog'),
  listing('listing', 'Listing');

  final String value;
  final String displayName;

  const ContentType(this.value, this.displayName);

  static ContentType fromString(String value) {
    return ContentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContentType.blog,
    );
  }
}

class ContentModerationItem {
  final String id;
  final ContentType type;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? moderatedAt;
  final String? moderatedBy;
  final String? moderationNotes;
  final String? rejectionReason;
  final List<String> images;
  final List<String> flags; // Reasons for flagging
  final int reportCount;
  final Map<String, dynamic> metadata;

  ContentModerationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.moderatedAt,
    this.moderatedBy,
    this.moderationNotes,
    this.rejectionReason,
    required this.images,
    required this.flags,
    this.reportCount = 0,
    required this.metadata,
  });

  factory ContentModerationItem.fromBlog(BlogPostModel blog) {
    return ContentModerationItem(
      id: blog.id,
      type: ContentType.blog,
      title: blog.title,
      content: blog.excerpt.isNotEmpty ? blog.excerpt : blog.content.substring(0, 200),
      authorId: blog.userId,
      authorName: blog.authorName,
      authorAvatar: blog.authorAvatar,
      status: _mapPostStatusToContentStatus(blog.status),
      createdAt: blog.createdAt,
      updatedAt: blog.updatedAt,
      images: [blog.coverImage, ...blog.images],
      flags: [],
      metadata: {
        'category': blog.category,
        'tags': blog.tags,
        'destinations': blog.destinations,
        'likes': blog.likes,
        'views': blog.views,
        'commentsCount': blog.commentsCount,
      },
    );
  }

  factory ContentModerationItem.fromListing(ListingModel listing) {
    return ContentModerationItem(
      id: listing.id,
      type: ContentType.listing,
      title: listing.title,
      content: listing.description,
      authorId: listing.businessId,
      authorName: listing.businessName,
      status: listing.isActive ? ContentStatus.approved : ContentStatus.suspended,
      createdAt: listing.createdAt,
      updatedAt: listing.updatedAt,
      images: listing.images,
      flags: [],
      metadata: {
        'price': listing.price,
        'priceUnit': listing.priceUnit,
        'type': listing.type.value,
        'rating': listing.rating,
        'reviews': listing.reviews,
        'bookings': listing.bookings,
      },
    );
  }

  static ContentStatus _mapPostStatusToContentStatus(PostStatus status) {
    switch (status) {
      case PostStatus.draft:
        return ContentStatus.draft;
      case PostStatus.published:
        return ContentStatus.approved;
      case PostStatus.archived:
        return ContentStatus.suspended;
    }
  }
}

class AdminContentService extends GetxService {
  static AdminContentService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _adminAuthService = Get.find<AdminAuthService>();
  
  // Collections
  final String _blogsCollection = 'blog_posts';
  final String _listingsCollection = 'listings';
  final String _moderationCollection = 'content_moderation';
  
  // Reactive lists
  final RxList<ContentModerationItem> allContent = <ContentModerationItem>[].obs;
  final RxList<ContentModerationItem> filteredContent = <ContentModerationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedType = 'all'.obs;
  
  // Statistics
  final RxInt totalContent = 0.obs;
  final RxInt pendingContent = 0.obs;
  final RxInt approvedContent = 0.obs;
  final RxInt rejectedContent = 0.obs;
  final RxInt flaggedContent = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadAllContent();
    _setupRealtimeListener();
    _setupSearchListener();
    LoggerService.i('AdminContentService initialized');
  }
  
  // Load all content from both blogs and listings
  Future<void> loadAllContent() async {
    try {
      isLoading.value = true;
      LoggerService.i('Loading all content for moderation');
      
      final List<ContentModerationItem> content = [];
      
      // Load blogs
      final blogsSnapshot = await _firestore
          .collection(_blogsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      for (final doc in blogsSnapshot.docs) {
        try {
          final blog = BlogPostModel.fromFirestore(doc);
          content.add(ContentModerationItem.fromBlog(blog));
        } catch (e) {
          LoggerService.w('Error parsing blog ${doc.id}', error: e);
        }
      }
      
      // Load listings
      final listingsSnapshot = await _firestore
          .collection(_listingsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      for (final doc in listingsSnapshot.docs) {
        try {
          final listing = ListingModel.fromJson(doc.data(), doc.id);
          content.add(ContentModerationItem.fromListing(listing));
        } catch (e) {
          LoggerService.w('Error parsing listing ${doc.id}', error: e);
        }
      }
      
      allContent.value = content;
      _applyFilters();
      _updateStatistics();
      
      LoggerService.i('Loaded ${content.length} content items successfully');
    } catch (e, stackTrace) {
      LoggerService.e('Error loading content', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to load content: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Setup real-time listener for content changes
  void _setupRealtimeListener() {
    // Listen to blogs
    _firestore.collection(_blogsCollection).snapshots().listen(
      (snapshot) {
        LoggerService.d('Real-time blog update received: ${snapshot.docs.length} blogs');
        _refreshContent();
      },
      onError: (error) {
        LoggerService.e('Real-time blog listener error', error: error);
      },
    );

    // Listen to listings
    _firestore.collection(_listingsCollection).snapshots().listen(
      (snapshot) {
        LoggerService.d('Real-time listing update received: ${snapshot.docs.length} listings');
        _refreshContent();
      },
      onError: (error) {
        LoggerService.e('Real-time listing listener error', error: error);
      },
    );
  }

  // Setup search listener
  void _setupSearchListener() {
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedStatus, (_) => _applyFilters());
    ever(selectedType, (_) => _applyFilters());
  }

  // Apply search and filter
  void _applyFilters() {
    List<ContentModerationItem> filtered = List.from(allContent);
    
    // Apply content type filter
    if (selectedType.value != 'all') {
      filtered = filtered.where((content) => 
          content.type.value == selectedType.value).toList();
    }
    
    // Apply status filter
    if (selectedStatus.value != 'all') {
      filtered = filtered.where((content) => 
          content.status.value == selectedStatus.value).toList();
    }
    
    // Apply search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((content) {
        return content.title.toLowerCase().contains(query) ||
            content.content.toLowerCase().contains(query) ||
            content.authorName.toLowerCase().contains(query);
      }).toList();
    }
    
    filteredContent.value = filtered;
    LoggerService.d('Applied filters: ${filtered.length} content items after filtering');
  }

  // Update statistics
  void _updateStatistics() {
    totalContent.value = allContent.length;
    pendingContent.value = allContent.where((content) => 
        content.status == ContentStatus.pending).length;
    approvedContent.value = allContent.where((content) => 
        content.status == ContentStatus.approved).length;
    rejectedContent.value = allContent.where((content) => 
        content.status == ContentStatus.rejected).length;
    flaggedContent.value = allContent.where((content) => 
        content.status == ContentStatus.flagged).length;
        
    LoggerService.d('Content statistics updated: Total: ${totalContent.value}, Pending: ${pendingContent.value}');
  }

  // Approve content
  Future<bool> approveContent(String contentId, ContentType type, {String? notes}) async {
    try {
      LoggerService.i('Approving content: $contentId (${type.value})');
      
      final collection = type == ContentType.blog ? _blogsCollection : _listingsCollection;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (type == ContentType.blog) {
        updates['status'] = PostStatus.published.value;
        updates['publishedAt'] = FieldValue.serverTimestamp();
      } else {
        updates['isActive'] = true;
      }
      
      await _firestore.collection(collection).doc(contentId).update(updates);
      
      // Log moderation activity
      await _logModerationActivity(
        contentId: contentId,
        contentType: type,
        action: 'content_approved',
        notes: notes,
      );
      
      LoggerService.i('Content approved successfully: $contentId');
      Get.snackbar('Success', 'Content approved successfully');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error approving content', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to approve content: ${e.toString()}');
      return false;
    }
  }

  // Reject content
  Future<bool> rejectContent(String contentId, ContentType type, {required String reason}) async {
    try {
      LoggerService.i('Rejecting content: $contentId (${type.value})');
      
      final collection = type == ContentType.blog ? _blogsCollection : _listingsCollection;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': _adminAuthService.currentAdmin?.id,
      };

      if (type == ContentType.blog) {
        updates['status'] = PostStatus.archived.value;
      } else {
        updates['isActive'] = false;
      }
      
      await _firestore.collection(collection).doc(contentId).update(updates);
      
      // Log moderation activity
      await _logModerationActivity(
        contentId: contentId,
        contentType: type,
        action: 'content_rejected',
        reason: reason,
      );
      
      LoggerService.i('Content rejected successfully: $contentId');
      Get.snackbar('Success', 'Content rejected');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error rejecting content', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to reject content: ${e.toString()}');
      return false;
    }
  }

  // Flag content for review
  Future<bool> flagContent(String contentId, ContentType type, {required String reason}) async {
    try {
      LoggerService.i('Flagging content: $contentId (${type.value})');
      
      // Add flag to moderation collection
      await _firestore.collection(_moderationCollection).add({
        'contentId': contentId,
        'contentType': type.value,
        'flag': reason,
        'flaggedBy': _adminAuthService.currentAdmin?.id,
        'flaggedAt': FieldValue.serverTimestamp(),
        'status': 'pending_review',
      });
      
      // Log moderation activity
      await _logModerationActivity(
        contentId: contentId,
        contentType: type,
        action: 'content_flagged',
        reason: reason,
      );
      
      LoggerService.i('Content flagged successfully: $contentId');
      Get.snackbar('Success', 'Content flagged for review');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error flagging content', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to flag content: ${e.toString()}');
      return false;
    }
  }

  // Get content details
  Future<ContentModerationItem?> getContentDetails(String contentId, ContentType type) async {
    try {
      LoggerService.d('Fetching content details: $contentId (${type.value})');
      
      final collection = type == ContentType.blog ? _blogsCollection : _listingsCollection;
      final doc = await _firestore.collection(collection).doc(contentId).get();
      
      if (!doc.exists) {
        LoggerService.w('Content not found: $contentId');
        return null;
      }
      
      if (type == ContentType.blog) {
        final blog = BlogPostModel.fromFirestore(doc);
        return ContentModerationItem.fromBlog(blog);
      } else {
        final listing = ListingModel.fromJson(doc.data()!, doc.id);
        return ContentModerationItem.fromListing(listing);
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching content details', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Get content moderation history
  Future<List<Map<String, dynamic>>> getContentHistory(String contentId) async {
    try {
      LoggerService.d('Fetching content history: $contentId');
      
      final snapshot = await _firestore
          .collection('admin_activities')
          .where('targetId', isEqualTo: contentId)
          .where('action', whereIn: [
            'content_approved',
            'content_rejected',
            'content_flagged',
            'content_suspended'
          ])
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      final history = snapshot.docs
          .map((doc) => doc.data())
          .toList();
      
      LoggerService.d('Content history loaded: ${history.length} records');
      return history;
    } catch (e, stackTrace) {
      LoggerService.e('Error fetching content history', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Log moderation activity
  Future<void> _logModerationActivity({
    required String contentId,
    required ContentType contentType,
    required String action,
    String? notes,
    String? reason,
  }) async {
    try {
      await _firestore.collection('admin_activities').add({
        'adminId': _adminAuthService.currentAdmin?.id,
        'adminEmail': _adminAuthService.currentAdmin?.email,
        'action': action,
        'targetType': 'content',
        'targetId': contentId,
        'details': {
          'contentType': contentType.value,
          'notes': notes,
          'reason': reason,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': 'admin_panel',
      });
    } catch (e) {
      LoggerService.e('Error logging moderation activity', error: e);
    }
  }

  // Refresh content data
  void _refreshContent() {
    // Debounce rapid updates
    Future.delayed(const Duration(milliseconds: 500), () {
      loadAllContent();
    });
  }

  // Search methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
  }

  void updateTypeFilter(String type) {
    selectedType.value = type;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // Bulk operations
  Future<bool> bulkApproveContent(List<String> contentIds, List<ContentType> types) async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < contentIds.length; i++) {
        final contentId = contentIds[i];
        final type = types[i];
        final collection = type == ContentType.blog ? _blogsCollection : _listingsCollection;
        final docRef = _firestore.collection(collection).doc(contentId);
        
        if (type == ContentType.blog) {
          batch.update(docRef, {
            'status': PostStatus.published.value,
            'publishedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          batch.update(docRef, {
            'isActive': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      await batch.commit();
      
      LoggerService.i('Bulk approved ${contentIds.length} content items');
      Get.snackbar('Success', '${contentIds.length} content items approved');
      return true;
    } catch (e, stackTrace) {
      LoggerService.e('Error bulk approving content', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Failed to bulk approve content');
      return false;
    }
  }

  // Export content data
  Future<List<Map<String, dynamic>>> getExportData() async {
    try {
      LoggerService.i('Preparing content export data');
      
      return filteredContent.map((content) => {
        'ID': content.id,
        'Type': content.type.displayName,
        'Title': content.title,
        'Author': content.authorName,
        'Status': content.status.displayName,
        'Created At': content.createdAt.toIso8601String(),
        'Updated At': content.updatedAt.toIso8601String(),
        'Moderated At': content.moderatedAt?.toIso8601String() ?? 'Not moderated',
        'Moderated By': content.moderatedBy ?? 'N/A',
        'Report Count': content.reportCount,
        'Flags': content.flags.join(', '),
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.e('Error preparing export data', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    LoggerService.i('Refreshing content data');
    await loadAllContent();
  }
}