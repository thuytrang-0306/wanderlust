import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';

class BlogDetailController extends BaseController {
  // Services
  final BlogService _blogService = Get.find<BlogService>();
  
  // Lazy load SavedBlogsService
  SavedBlogsService get _savedBlogsService {
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    return Get.find<SavedBlogsService>();
  }

  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final RxInt commentCount = 0.obs;
  final RxBool isLoadingData = true.obs;

  // Lock to prevent concurrent toggleLike calls
  bool _isTogglingLike = false;

  // Blog data
  final Rx<BlogPostModel?> blogPost = Rx<BlogPostModel?>(null);
  final RxList<BlogComment> comments = <BlogComment>[].obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;

  // Post ID and Hero tag from route arguments
  String? postId;
  String? heroTag;

  @override
  void onInit() {
    super.onInit();
    // Get post ID, optional blogPost, and heroTag from arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      postId = args['postId'] as String?;
      heroTag = args['heroTag'] as String?;

      // Check if BlogPostModel was passed (optimistic loading)
      final passedBlogPost = args['blogPost'];
      if (passedBlogPost != null && passedBlogPost is BlogPostModel) {
        // Use the passed data immediately - no loading spinner!
        blogPost.value = passedBlogPost;
        likeCount.value = passedBlogPost.likes;
        commentCount.value = passedBlogPost.commentsCount;
        isLoadingData.value = false;

        // Check user interactions
        checkUserInteractions();

        // Background refresh to sync latest data (likes, comments, etc.)
        loadBlogData();
      } else {
        // Fallback: fetch from server
        loadBlogData();
      }

      loadComments();
    } else if (args != null && args is String) {
      postId = args;
      loadBlogData();
      loadComments();
    } else {
      LoggerService.e('No post ID provided to BlogDetailController');
      isLoadingData.value = false;
      setError('No post ID provided');
    }

    loadSuggestions();
  }

  Future<void> loadBlogData() async {
    if (postId == null) return;

    try {
      // Only show loading if we don't already have data
      final shouldShowLoading = blogPost.value == null;
      if (shouldShowLoading) {
        isLoadingData.value = true;
        setLoading();
      }

      final post = await _blogService.getPost(postId!);

      if (post != null) {
        blogPost.value = post;
        likeCount.value = post.likes;
        commentCount.value = post.commentsCount;
        // Check if user has liked/bookmarked this post
        if (shouldShowLoading) {
          await checkUserInteractions();
        }
      } else if (shouldShowLoading) {
        AppSnackbar.showError(title: 'Lỗi', message: 'Không tìm thấy bài viết');
      }
    } catch (e) {
      LoggerService.e('Error loading blog post', error: e);
      if (blogPost.value == null) {
        // Only show error if we don't have cached data
        AppSnackbar.showError(title: 'Lỗi', message: 'Không thể tải bài viết');
      }
    } finally {
      isLoadingData.value = false;
      setIdle();
    }
  }

  void loadComments() {
    if (postId == null) return;

    // Listen to real-time comments
    _blogService
        .getPostComments(postId!)
        .listen(
          (commentList) {
            comments.value = commentList;
          },
          onError: (error) {
            LoggerService.e('Error loading comments', error: error);
          },
        );
  }

  void loadSuggestions() {
    // Load suggestions from services if needed in future
    suggestions.value = [];
  }

  Future<void> toggleBookmark() async {
    if (postId == null || blogPost.value == null) return;

    final blog = blogPost.value!;
    
    if (!isBookmarked.value) {
      // Show collection selector dialog
      showCollectionSelector(blog);
    } else {
      // Remove from all collections
      await _savedBlogsService.removeBlogFromCollection(blog.id, 'all');
      isBookmarked.value = false;
      AppSnackbar.showSuccess(message: 'Đã bỏ lưu bài viết');
    }
  }
  
  void showCollectionSelector(BlogPostModel blog) {
    // Refresh collections to get latest
    final collections = _savedBlogsService.collections;
    
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
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
                      color: AppColors.textPrimary,
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
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: AppColors.neutral200),
            
            // Collections list
            Flexible(
              child: Obx(() {
                if (collections.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.s6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 48.sp,
                            color: AppColors.neutral400,
                          ),
                          SizedBox(height: AppSpacing.s3),
                          Text(
                            'Chưa có bộ sưu tập nào',
                            style: AppTypography.bodyL.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
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
                          if (isSelected) {
                            await _savedBlogsService.removeBlogFromCollection(blog.id, collection.id);
                            AppSnackbar.showInfo(message: 'Đã xóa khỏi "${collection.name}"');
                          } else {
                            await _savedBlogsService.saveBlogToCollection(blog, collection.id);
                            AppSnackbar.showSuccess(message: 'Đã lưu vào "${collection.name}"');
                          }
                          
                          // Update bookmark status
                          isBookmarked.value = _savedBlogsService.isBlogSaved(blog.id);
                          
                          // Close bottom sheet if no collections selected
                          if (!isBookmarked.value) {
                            Get.back();
                          }
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
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
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            
            // Create new collection button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.neutral200),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(AppSpacing.s5),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => _showCreateCollectionDialog(blog),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 20.sp),
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
      enableDrag: true,
    );
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
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: AppSpacing.s4),
              TextField(
                controller: nameController,
                autofocus: true,
                style: AppTypography.bodyL,
                decoration: InputDecoration(
                  hintText: 'Tên bộ sưu tập',
                  hintStyle: AppTypography.bodyL.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppColors.neutral50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s4,
                    vertical: AppSpacing.s3,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Hủy',
                      style: AppTypography.bodyL.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s3),
                  ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final newCollection = await _savedBlogsService.createCollection(name);
                        await _savedBlogsService.saveBlogToCollection(blog, newCollection.id);
                        Get.back(); // Close dialog
                        Get.back(); // Close bottom sheet
                        isBookmarked.value = true;
                        AppSnackbar.showSuccess(message: 'Đã tạo và lưu vào "$name"');
                      } else {
                        AppSnackbar.showError(message: 'Vui lòng nhập tên bộ sưu tập');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tạo',
                      style: AppTypography.bodyL.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  Future<void> toggleLike() async {
    if (postId == null) return;

    // Prevent concurrent calls (debounce/lock mechanism)
    if (_isTogglingLike) {
      LoggerService.w('toggleLike already in progress, ignoring...');
      return;
    }

    try {
      _isTogglingLike = true;

      // Optimistic update - only update observable properties
      final previousState = isLiked.value;
      isLiked.value = !previousState;

      // Guard: never go below 0
      if (isLiked.value) {
        likeCount.value += 1;
      } else {
        likeCount.value = (likeCount.value - 1).clamp(0, double.infinity.toInt());
      }

      // Update in backend
      final newLikeStatus = await _blogService.toggleLike(postId!);

      // Sync with backend if needed (atomic update)
      if (newLikeStatus != isLiked.value) {
        isLiked.value = newLikeStatus;
      }

      // Background sync: fetch accurate count without triggering full reload
      final updatedPost = await _blogService.getPost(postId!);
      if (updatedPost != null) {
        // Atomic sync: update both like status and count together
        isLiked.value = await _blogService.isPostLiked(postId!);
        likeCount.value = updatedPost.likes;

        // Update cached post silently (no UI rebuild)
        if (blogPost.value != null) {
          blogPost.value = updatedPost;
        }
      }
    } finally {
      _isTogglingLike = false;
    }
  }

  Future<void> addComment(String comment) async {
    if (postId == null || comment.trim().isEmpty) return;

    final commentId = await _blogService.addCommentToPost(postId!, comment.trim());

    if (commentId != null) {
      // Comment will appear via stream listener
      commentCount.value++;
      AppSnackbar.showSuccess(message: 'Đã thêm bình luận');
    } else {
      AppSnackbar.showError(message: 'Không thể thêm bình luận');
    }
  }

  // Check user interactions
  Future<void> checkUserInteractions() async {
    if (postId == null) return;

    try {
      // Check if liked
      isLiked.value = await _blogService.isPostLiked(postId!);

      // Check if bookmarked using local storage
      isBookmarked.value = _savedBlogsService.isBlogSaved(postId!);
    } catch (e) {
      LoggerService.e('Error checking user interactions', error: e);
    }
  }

  Future<void> shareArticle() async {
    if (postId == null || blogPost.value == null) return;

    // Increment share count
    await _blogService.incrementShares(postId!);

    // Share functionality will be added with share_plus package
    AppSnackbar.showInfo(title: 'Chia sẻ', message: 'Tính năng chia sẻ sẽ sớm ra mắt');
  }
}
