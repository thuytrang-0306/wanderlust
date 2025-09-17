import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class BlogDetailController extends BaseController {
  // Services
  final BlogService _blogService = Get.find<BlogService>();
  
  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final RxInt commentCount = 0.obs;
  final RxBool isLoadingData = true.obs;
  
  // Blog data
  final Rx<BlogPostModel?> blogPost = Rx<BlogPostModel?>(null);
  final RxList<BlogComment> comments = <BlogComment>[].obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  
  // Post ID from route arguments
  String? postId;
  
  @override
  void onInit() {
    super.onInit();
    // Get post ID from arguments
    final args = Get.arguments;
    if (args != null && args is Map) {
      postId = args['postId'] as String?;
    } else if (args != null && args is String) {
      postId = args;
    }
    
    if (postId != null) {
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
      isLoadingData.value = true;
      setLoading();
      final post = await _blogService.getPost(postId!);
      
      if (post != null) {
        blogPost.value = post;
        likeCount.value = post.likes;
        commentCount.value = post.commentsCount;
        // TODO: Check if user has liked/bookmarked this post
      } else {
        AppSnackbar.showError(
          title: 'Lỗi',
          message: 'Không tìm thấy bài viết',
        );
      }
    } catch (e) {
      LoggerService.e('Error loading blog post', error: e);
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể tải bài viết',
      );
    } finally {
      isLoadingData.value = false;
      setIdle();
    }
  }
  
  void loadComments() {
    if (postId == null) return;
    
    // Listen to real-time comments
    _blogService.getPostComments(postId!).listen((commentList) {
      comments.value = commentList;
    }, onError: (error) {
      LoggerService.e('Error loading comments', error: error);
    });
  }
  
  void loadSuggestions() {
    // Mock suggestions data
    suggestions.value = [
      {
        'id': '1',
        'title': 'Homestay Sơn Thủy',
        'location': 'Hà Giang',
        'price': '400.000',
        'rating': 4.4,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400',
      },
      {
        'id': '2', 
        'title': 'Khách sạn GG',
        'location': 'Hà Giang',
        'price': '600.000',
        'rating': 4.4,
        'duration': '4N/5D',
        'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      },
    ];
  }
  
  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    // TODO: Save bookmark state
  }
  
  Future<void> toggleLike() async {
    if (postId == null) return;
    
    final newLikeStatus = !isLiked.value;
    
    // Optimistic update
    isLiked.value = newLikeStatus;
    likeCount.value += newLikeStatus ? 1 : -1;
    
    // Update in backend
    final success = await _blogService.toggleLike(postId!, newLikeStatus);
    
    if (!success) {
      // Revert if failed
      isLiked.value = !newLikeStatus;
      likeCount.value += newLikeStatus ? -1 : 1;
      
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể thực hiện',
      );
    }
  }
  
  Future<void> addComment(String comment) async {
    if (postId == null || comment.trim().isEmpty) return;
    
    final success = await _blogService.addComment(postId!, comment.trim());
    
    if (success) {
      // Comment will appear via stream listener
      AppSnackbar.showSuccess(
        title: 'Thành công',
        message: 'Đã thêm bình luận',
      );
    } else {
      AppSnackbar.showError(
        title: 'Lỗi',
        message: 'Không thể thêm bình luận',
      );
    }
  }
  
  Future<void> shareArticle() async {
    if (postId == null || blogPost.value == null) return;
    
    // Increment share count
    await _blogService.incrementShares(postId!);
    
    // TODO: Implement actual share functionality (share_plus package)
    AppSnackbar.showInfo(
      title: 'Chia sẻ',
      message: 'Tính năng chia sẻ sẽ sớm ra mắt',
    );
  }
}