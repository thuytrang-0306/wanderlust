import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/community/community_page.dart';
import 'package:wanderlust/presentation/view_models/post_view_model.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class CommunityController extends GetxController {
  // Services
  final BlogService _blogService = Get.put(BlogService());
  final AccommodationService _accommodationService = Get.put(AccommodationService());
  final ListingService _listingService = Get.find<ListingService>();
  
  // Lazy load SavedBlogsService
  SavedBlogsService get _savedBlogsService {
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    return Get.find<SavedBlogsService>();
  }

  // Observable lists
  final RxList<PostViewModel> posts = <PostViewModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxList<ListingModel> businessPosts = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  // Store BlogPostModel for navigation
  final RxMap<String, BlogPostModel> blogPostsCache = <String, BlogPostModel>{}.obs;

  // User interaction tracking
  final RxSet<String> likedPostIds = <String>{}.obs;
  final RxSet<String> bookmarkedPostIds = <String>{}.obs;

  // Lock to prevent concurrent toggleLike on same post
  final Set<String> _togglingLikeIds = {};

  @override
  void onInit() {
    super.onInit();
    _loadRealPosts();
    _loadRealReviews();
    _loadBusinessPosts();
    _trackUserInteractions();
    _trackSavedBlogs();
  }

  void _trackUserInteractions() {
    // Track liked posts
    _blogService.getUserLikedPosts().listen((likedIds) {
      likedPostIds.assignAll(likedIds);
      // Update post models with like status
      _updatePostLikeStatus();
    });
  }
  
  void _trackSavedBlogs() {
    // Track saved blogs from SavedBlogsService
    ever(_savedBlogsService.savedBlogsCache, (_) {
      // Update bookmarked state based on saved blogs
      _updateBookmarkStatusFromSavedBlogs();
    });
    
    // Initial update
    _updateBookmarkStatusFromSavedBlogs();
  }
  
  void _updateBookmarkStatusFromSavedBlogs() {
    final savedBlogIds = _savedBlogsService.savedBlogsCache.keys.toSet();
    bookmarkedPostIds.assignAll(savedBlogIds);
    _updatePostBookmarkStatus();
  }

  void _updatePostLikeStatus() {
    for (final post in posts) {
      final shouldBeLiked = likedPostIds.contains(post.id);
      if (post.isLiked.value != shouldBeLiked) {
        post.syncLikeStatus(shouldBeLiked);
      }
    }
  }

  void _updatePostBookmarkStatus() {
    for (final post in posts) {
      final shouldBeBookmarked = bookmarkedPostIds.contains(post.id);
      if (post.isBookmarked.value != shouldBeBookmarked) {
        post.syncBookmarkStatus(shouldBeBookmarked);
      }
    }
  }

  void _loadRealPosts() {
    try {
      isLoading.value = true;

      // Listen to real-time updates from Firestore
      _blogService
          .getPublishedPosts(limit: 20)
          .listen(
            (blogPosts) {
              // Cache BlogPostModel for navigation
              for (final blog in blogPosts) {
                blogPostsCache[blog.id] = blog;
              }

              // OPTIMIZATION: Update existing PostViewModel instead of recreating
              final existingPostsMap = <String, PostViewModel>{};
              for (final post in posts) {
                existingPostsMap[post.id] = post;
              }

              final updatedPosts = <PostViewModel>[];

              for (final blog in blogPosts) {
                // Calculate relative time
                String timeAndLocation = _getRelativeTime(blog.publishedAt ?? blog.createdAt);
                if (blog.destinations.isNotEmpty) {
                  timeAndLocation += ' · ${blog.destinations.first}';
                }

                // Check if PostViewModel already exists
                final existingPost = existingPostsMap[blog.id];

                if (existingPost != null) {
                  // UPDATE existing PostViewModel - NO rebuild images!
                  existingPost.syncLikeCount(blog.likes);
                  existingPost.syncLikeStatus(likedPostIds.contains(blog.id));
                  existingPost.syncBookmarkStatus(_savedBlogsService.isBlogSaved(blog.id));
                  updatedPosts.add(existingPost);
                } else {
                  // CREATE new PostViewModel only for new posts
                  updatedPosts.add(
                    PostViewModel.fromBlogPost(
                      id: blog.id,
                      authorName: blog.authorName,
                      authorAvatar: blog.authorAvatar,
                      timeAndLocation: timeAndLocation,
                      content: '${blog.title}\n${blog.excerpt}',
                      images:
                          [blog.coverImage, ...blog.images].where((img) => img.isNotEmpty).toList(),
                      commentCount: blog.commentsCount,
                      likes: blog.likes,
                      isLiked: likedPostIds.contains(blog.id),
                      isBookmarked: _savedBlogsService.isBlogSaved(blog.id),
                    ),
                  );
                }
              }

              // Only assign if list ACTUALLY changed (deep check)
              bool hasChanged = posts.length != updatedPosts.length;

              if (!hasChanged) {
                // Check if any PostViewModel instance is different (by reference)
                for (int i = 0; i < posts.length; i++) {
                  if (!identical(posts[i], updatedPosts[i])) {
                    hasChanged = true;
                    break;
                  }
                }
              }

              if (hasChanged) {
                posts.value = updatedPosts;
              }
              // Else: Same instances, no need to reassign → NO rebuild!

              isLoading.value = false;
            },
            onError: (error) {
              LoggerService.e('Error loading posts', error: error);
              isLoading.value = false;
              // No fallback - show empty state
            },
          );
    } catch (e) {
      LoggerService.e('Error in _loadRealPosts', error: e);
      isLoading.value = false;
      // No fallback - show empty state
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _loadBusinessPosts() async {
    try {
      // Load business listings with high ratings
      final listings = await _listingService.searchListings();
      
      // Filter for listings with good ratings and reviews
      final topListings = listings
          .where((l) => l.isActive && l.rating >= 4.0 && l.reviews > 0)
          .toList()
        ..sort((a, b) {
          // Sort by rating and reviews
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.reviews.compareTo(a.reviews);
        });
      
      // Take top 5 for community showcase
      businessPosts.value = topListings.take(5).toList();
      
      LoggerService.i('Loaded ${businessPosts.length} business posts');
    } catch (e) {
      LoggerService.e('Error loading business posts', error: e);
      businessPosts.value = [];
    }
  }

  void _loadRealReviews() async {
    try {
      // Load featured accommodations as reviews
      final accommodations = await _accommodationService.getFeaturedAccommodations();
      reviews.value =
          accommodations.map((acc) {
            // Format price
            String priceText = '${(acc.pricePerNight / 1000).toStringAsFixed(0)}.000 VND';

            return ReviewModel(
              id: acc.id,
              name: acc.name,
              location: acc.city,
              imageUrl:
                  acc.images.isNotEmpty
                      ? acc.images.first
                      : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
              rating: acc.rating,
              price: priceText,
              duration: null, // Accommodations don't have duration
            );
          }).toList();
    } catch (e) {
      LoggerService.e('Error in _loadRealReviews', error: e);
      // No fallback - show empty state
    }
  }

  Future<void> toggleLike(String postId) async {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;

    // Prevent concurrent toggles on same post
    if (_togglingLikeIds.contains(postId)) {
      LoggerService.w('toggleLike already in progress for $postId, ignoring...');
      return;
    }

    try {
      _togglingLikeIds.add(postId);

      // Optimistic update - only updates observable properties
      post.toggleLike();

      // Update backend
      final newStatus = await _blogService.toggleLike(postId);

      // Update local tracking
      if (newStatus) {
        likedPostIds.add(postId);
      } else {
        likedPostIds.remove(postId);
      }

      // Note: NO need to re-fetch post here!
      // The Firestore stream listener will automatically sync the actual like count
      // This prevents double updates and image flickering
    } finally {
      _togglingLikeIds.remove(postId);
    }
  }

  Future<void> toggleBookmark(String postId) async {
    // Get blog post from cache or fetch
    BlogPostModel? blogPost = blogPostsCache[postId];
    if (blogPost == null) {
      blogPost = await _blogService.getPost(postId);
      if (blogPost == null) {
        AppSnackbar.showError(message: 'Không thể tải bài viết');
        return;
      }
      blogPostsCache[postId] = blogPost;
    }

    final post = posts.firstWhereOrNull((p) => p.id == postId);

    // Check if already saved
    final isSaved = _savedBlogsService.isBlogSaved(postId);

    if (isSaved) {
      // If saved, remove from all collections
      await _savedBlogsService.removeBlogFromCollection(postId, 'all');

      // Update UI
      if (post != null) {
        post.syncBookmarkStatus(false);
      }

      AppSnackbar.showInfo(message: 'Đã bỏ lưu bài viết');
    } else {
      // Show collection selector
      _showCollectionSelector(blogPost);
    }
  }
  
  void _showCollectionSelector(BlogPostModel blog) {
    final collections = _savedBlogsService.collections;
    
    // If no collections exist (except default), auto-save to default
    if (collections.length <= 1) {
      _saveBlogToDefault(blog);
      return;
    }
    
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s3),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.all(AppSpacing.s5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lưu vào bộ sưu tập',
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: AppColors.neutral200),
            
            // Collections list
            Flexible(
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  final collection = collections[index];
                  final isSelected = _savedBlogsService.isBlogInCollection(blog.id, collection.id);
                  
                  return Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        await _savedBlogsService.saveBlogToCollection(blog, collection.id);
                        Get.back();
                        
                        // Update UI
                        _updateBookmarkInUI(blog.id, true);
                        
                        AppSnackbar.showSuccess(
                          message: 'Đã lưu vào "${collection.name}"',
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s5,
                          vertical: AppSpacing.s3,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.neutral100,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                isSelected ? Icons.bookmark : Icons.bookmark_border,
                                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: AppSpacing.s4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    collection.name,
                                    style: AppTypography.bodyL.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${collection.postCount} bài viết',
                                    style: AppTypography.bodyS.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
            ),
            
            // Create new collection button
            Container(
              padding: EdgeInsets.all(AppSpacing.s5),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.neutral200)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close bottom sheet first
                      // Small delay to ensure bottom sheet is closed
                      Future.delayed(Duration(milliseconds: 300), () {
                        _showCreateCollectionDialog(blog);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 20.sp),
                        SizedBox(width: AppSpacing.s2),
                        Text(
                          'Tạo bộ sưu tập mới',
                          style: AppTypography.bodyL.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }
  
  void _saveBlogToDefault(BlogPostModel blog) async {
    // Auto save to default collection
    await _savedBlogsService.saveBlogToCollection(blog, 'all');
    
    // Update UI
    _updateBookmarkInUI(blog.id, true);
    
    AppSnackbar.showSuccess(
      message: 'Đã lưu vào "Tất cả bài viết"',
    );
  }
  
  void _updateBookmarkInUI(String postId, bool isBookmarked) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post != null) {
      post.syncBookmarkStatus(isBookmarked);
    }
  }
  
  void _showCreateCollectionDialog(BlogPostModel blog) {
    final TextEditingController nameController = TextEditingController();
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo bộ sưu tập mới',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tên bộ sưu tập',
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  SizedBox(
                    width: 80.w, // Fix infinite width constraint
                    child: ElevatedButton(
                      onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final newCollection = await _savedBlogsService.createCollection(name);
                        await _savedBlogsService.saveBlogToCollection(blog, newCollection.id);
                        Get.back(); // Close dialog
                        
                        // Update UI
                        _updateBookmarkInUI(blog.id, true);
                        
                        AppSnackbar.showSuccess(
                          message: 'Đã tạo và lưu vào "$name"',
                        );
                      }
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text('Tạo', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openComments(String postId) {
    // Navigate to blog detail page
    Get.toNamed(Routes.BLOG_DETAIL, arguments: {'postId': postId});
  }

  void createPost() async {
    // Navigate to create post page
    final result = await Get.toNamed(Routes.CREATE_POST);

    if (result != null && result is Map<String, dynamic>) {
      // Create post via BlogService
      final post = await _blogService.createPost(
        title: result['title'] ?? '',
        content: result['content'] ?? '',
        excerpt: result['excerpt'] ?? '',
        coverImage: result['coverImage'] ?? '',
        category: result['category'] ?? 'Du lịch',
        tags: result['tags'] ?? [],
        destinations: result['destinations'] ?? [],
        images: result['images'] ?? [],
        publish: true,
      );

      if (post != null) {
        Get.snackbar('Thành công', 'Đã đăng bài viết mới', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void openBookmarks() {
    Get.toNamed('/saved-collections');
  }
}
