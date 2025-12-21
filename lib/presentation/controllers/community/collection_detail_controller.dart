import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/services/saved_blogs_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/services/blog_service.dart';

class CollectionDetailController extends BaseController {
  // Services
  SavedBlogsService get _savedBlogsService {
    if (!Get.isRegistered<SavedBlogsService>()) {
      Get.put(SavedBlogsService());
    }
    return Get.find<SavedBlogsService>();
  }
  
  final BlogService _blogService = Get.put(BlogService());
  
  // Data
  final RxString collectionId = ''.obs;
  final RxString collectionName = ''.obs;
  final RxList<BlogPostModel> blogPosts = <BlogPostModel>[].obs;
  final RxBool isLoadingData = false.obs;

  // Cache for navigation
  final RxMap<String, BlogPostModel> blogPostsCache = <String, BlogPostModel>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // CRITICAL: Clear all state first to prevent pollution from previous instance
    blogPosts.clear();
    blogPostsCache.clear();
    isLoadingData.value = false;

    final args = Get.arguments;
    if (args != null) {
      collectionId.value = args['collectionId'] ?? '';
      collectionName.value = args['collectionName'] ?? 'Bộ sưu tập';
      loadPosts();
    }
  }

  @override
  void onClose() {
    // Clean up resources
    blogPosts.clear();
    blogPostsCache.clear();
    super.onClose();
  }

  void loadPosts() async {
    if (collectionId.value.isEmpty) return;

    try {
      // IMPORTANT: Set loading immediately to prevent flash of old data
      isLoadingData.value = true;

      // Get saved blogs IDs from service
      final savedBlogs = _savedBlogsService.getSavedBlogsForCollection(collectionId.value);

      // Early return if collection is empty
      if (savedBlogs.isEmpty) {
        blogPosts.clear();
        isLoadingData.value = false;
        return;
      }

      // OPTIMIZATION: Check cache first for instant display
      final cachedBlogs = <BlogPostModel>[];
      final needsFetch = <String>[];

      for (final savedBlog in savedBlogs) {
        final cached = _savedBlogsService.blogPostsCache[savedBlog.id];
        if (cached != null) {
          cachedBlogs.add(cached);
          blogPostsCache[savedBlog.id] = cached; // Local cache
        } else {
          needsFetch.add(savedBlog.id);
        }
      }

      // Instant display with cached data (no spinner!)
      if (cachedBlogs.isNotEmpty) {
        blogPosts.value = cachedBlogs;
        isLoadingData.value = false;
      }
      // Else: keep loading = true until fetch completes

      // Background fetch for blogs not in cache + refresh cached ones
      if (savedBlogs.isNotEmpty) {
        final futures = savedBlogs.map((savedBlog) => _blogService.getPost(savedBlog.id)).toList();
        final results = await Future.wait(futures);

        // Filter out null values
        final validBlogs = results.where((blog) => blog != null).cast<BlogPostModel>().toList();

        // Update both local and service cache
        for (final blog in validBlogs) {
          blogPostsCache[blog.id] = blog;
          _savedBlogsService.blogPostsCache[blog.id] = blog; // Update service cache
        }

        blogPosts.value = validBlogs;
      }
    } finally {
      isLoadingData.value = false;
    }
  }
  
  Future<void> refreshPosts() async {
    loadPosts();
  }
  
  Future<void> toggleLike(String postId) async {
    await _blogService.toggleLike(postId);
    // Refresh the specific blog to get updated like count
    final index = blogPosts.indexWhere((b) => b.id == postId);
    if (index != -1) {
      final updatedBlog = await _blogService.getPost(postId);
      if (updatedBlog != null) {
        blogPosts[index] = updatedBlog;
        // Update both local and service cache
        blogPostsCache[postId] = updatedBlog;
        _savedBlogsService.blogPostsCache[postId] = updatedBlog;
      }
    }
  }

  void openBlogDetail(String postId) {
    // Pass cached BlogPostModel to avoid loading spinner
    final blogPost = blogPostsCache[postId];
    Get.toNamed('/blog-detail', arguments: {
      'postId': postId,
      if (blogPost != null) 'blogPost': blogPost,
      'heroTag': 'saved-blog-image-$postId', // Unique hero tag for saved blogs
    });
  }

  void toggleBookmark(String postId) async {
    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Xóa khỏi bộ sưu tập?',
      middleText: 'Bài viết này sẽ được xóa khỏi bộ sưu tập "${collectionName.value}"',
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        await _savedBlogsService.removeBlogFromCollection(postId, collectionId.value);
        blogPosts.removeWhere((blog) => blog.id == postId);
        Get.back();
        Get.snackbar(
          'Đã xóa',
          'Bài viết đã được xóa khỏi bộ sưu tập',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
