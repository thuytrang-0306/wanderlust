import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/community/community_page.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class CommunityController extends GetxController {
  // Services
  final BlogService _blogService = Get.put(BlogService());
  final AccommodationService _accommodationService = Get.put(AccommodationService());
  
  // Observable lists
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadRealPosts();
    _loadRealReviews();
  }
  
  void _loadRealPosts() {
    try {
      isLoading.value = true;
      
      // Listen to real-time updates from Firestore
      _blogService.getPublishedPosts(limit: 20).listen((blogPosts) {
        // Convert BlogPostModel to PostModel for UI
        posts.value = blogPosts.map((blog) {
          // Calculate relative time
          String timeAndLocation = _getRelativeTime(blog.publishedAt ?? blog.createdAt);
          if (blog.destinations.isNotEmpty) {
            timeAndLocation += ' · ${blog.destinations.first}';
          }
          
          return PostModel(
            id: blog.id,
            userName: blog.authorName,
            userAvatar: blog.authorAvatar.isEmpty 
                ? 'https://i.pravatar.cc/150?img=${blog.id.hashCode % 10}'
                : blog.authorAvatar,
            timeAndLocation: timeAndLocation,
            content: '${blog.title}\n${blog.excerpt}',
            images: [blog.coverImage, ...blog.images].where((img) => img.isNotEmpty).toList(),
            likeCount: blog.likes,
            commentCount: blog.commentsCount,
            isLiked: false, // TODO: Track user's liked posts
            isBookmarked: false, // TODO: Track user's bookmarked posts
          );
        }).toList();
        
        isLoading.value = false;
      }, onError: (error) {
        LoggerService.e('Error loading posts', error: error);
        isLoading.value = false;
        // Fallback to demo posts if error
        _loadDemoPosts();
      });
      
      // Add demo posts if collection is empty
      _checkAndAddDemoPosts();
      
    } catch (e) {
      LoggerService.e('Error in _loadRealPosts', error: e);
      isLoading.value = false;
      _loadDemoPosts();
    }
  }
  
  void _loadDemoPosts() {
    // Fallback demo posts for development/testing
    posts.value = [
      PostModel(
        id: 'demo1',
        userName: 'Nguyễn Văn Du Lịch',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        timeAndLocation: '2 giờ trước · Hà Giang',
        content: 'Khám phá vẻ đẹp hoang sơ của Hà Giang\nNhững con đường đèo uốn lượn, ruộng bậc thang tuyệt đẹp và văn hóa độc đáo của người dân tộc...',
        images: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1454391304352-2bf4678b1a7a?w=800',
        ],
        likeCount: 234,
        commentCount: 45,
        isLiked: false,
        isBookmarked: false,
      ),
      PostModel(
        id: 'demo2',
        userName: 'Trần Thị Phượt',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        timeAndLocation: 'Hôm qua · Ninh Bình',
        content: 'Ninh Bình - Hạ Long trên cạn\nTràng An với hệ thống hang động kỳ vĩ, Tam Cốc với cảnh quan sông nước hữu tình...',
        images: [
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
        ],
        likeCount: 567,
        commentCount: 89,
        isLiked: true,
        isBookmarked: true,
      ),
    ];
  }
  
  Future<void> _checkAndAddDemoPosts() async {
    try {
      // Check if there are any posts
      final snapshot = await _blogService.getPublishedPosts(limit: 1).first;
      if (snapshot.isEmpty) {
        // Add demo posts if collection is empty
        await _blogService.addDemoPosts();
      }
    } catch (e) {
      LoggerService.e('Error checking posts', error: e);
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
  
  void _loadRealReviews() {
    try {
      // Load featured accommodations as reviews
      _accommodationService.getFeaturedAccommodations(limit: 10).listen((accommodations) {
        reviews.value = accommodations.map((acc) {
          // Format price
          String priceText = '${(acc.pricing.basePrice / 1000).toStringAsFixed(0)}.000 VND';
          
          return ReviewModel(
            id: acc.id,
            name: acc.name,
            location: acc.location.city,
            imageUrl: acc.images.isNotEmpty 
                ? acc.images.first 
                : 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
            rating: acc.rating,
            price: priceText,
            duration: null, // Accommodations don't have duration
          );
        }).toList();
      }, onError: (error) {
        LoggerService.e('Error loading reviews', error: error);
        // Fallback to demo reviews
        _loadDemoReviews();
      });
      
      // Add demo accommodations if collection is empty
      _checkAndAddDemoAccommodations();
      
    } catch (e) {
      LoggerService.e('Error in _loadRealReviews', error: e);
      _loadDemoReviews();
    }
  }
  
  void _loadDemoReviews() {
    // Fallback demo reviews
    reviews.value = [
      ReviewModel(
        id: 'demo1',
        name: 'Homestay Son Thuy',
        location: 'Hà Giang',
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        rating: 4.4,
        price: '600.000 VND',
        duration: '4N/5D',
      ),
      ReviewModel(
        id: 'demo2',
        name: 'Khách sạn Mường Thanh',
        location: 'Đà Nẵng',
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        rating: 4.6,
        price: '800.000 VND',
        duration: null,
      ),
    ];
  }
  
  Future<void> _checkAndAddDemoAccommodations() async {
    try {
      // Check if there are any accommodations
      final snapshot = await _accommodationService.getFeaturedAccommodations(limit: 1).first;
      if (snapshot.isEmpty) {
        // Add demo accommodations if collection is empty
        await _accommodationService.addDemoAccommodations();
      }
    } catch (e) {
      LoggerService.e('Error checking accommodations', error: e);
    }
  }
  
  void toggleLike(String postId) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = posts[index];
      posts[index] = PostModel(
        id: post.id,
        userName: post.userName,
        userAvatar: post.userAvatar,
        timeAndLocation: post.timeAndLocation,
        content: post.content,
        images: post.images,
        likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        commentCount: post.commentCount,
        isLiked: !post.isLiked,
        isBookmarked: post.isBookmarked,
      );
    }
  }
  
  void toggleBookmark(String postId) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = posts[index];
      posts[index] = PostModel(
        id: post.id,
        userName: post.userName,
        userAvatar: post.userAvatar,
        timeAndLocation: post.timeAndLocation,
        content: post.content,
        images: post.images,
        likeCount: post.likeCount,
        commentCount: post.commentCount,
        isLiked: post.isLiked,
        isBookmarked: !post.isBookmarked,
      );
    }
  }
  
  void openComments(String postId) {
    // TODO: Navigate to comments page
    Get.snackbar(
      'Comments',
      'Opening comments for post $postId',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
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
        Get.snackbar(
          'Thành công',
          'Đã đăng bài viết mới',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
  
  void openBookmarks() {
    Get.toNamed('/saved-collections');
  }
}