import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/community/community_page.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/data/services/blog_service.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class CommunityController extends GetxController {
  // Services
  final BlogService _blogService = Get.put(BlogService());
  final AccommodationService _accommodationService = Get.put(AccommodationService());
  final ListingService _listingService = Get.find<ListingService>();

  // Observable lists
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxList<ListingModel> businessPosts = <ListingModel>[].obs;
  final RxBool isLoading = false.obs;

  // User interaction tracking
  final RxSet<String> likedPostIds = <String>{}.obs;
  final RxSet<String> bookmarkedPostIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRealPosts();
    _loadRealReviews();
    _loadBusinessPosts();
    _trackUserInteractions();
  }

  void _trackUserInteractions() {
    // Track liked posts
    _blogService.getUserLikedPosts().listen((likedIds) {
      likedPostIds.value = likedIds;
      // Update post models with like status
      _updatePostLikeStatus();
    });

    // Track bookmarked posts
    _blogService.getUserBookmarkedPosts().listen((bookmarkedIds) {
      bookmarkedPostIds.value = bookmarkedIds;
      // Update post models with bookmark status
      _updatePostBookmarkStatus();
    });
  }

  void _updatePostLikeStatus() {
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final isLiked = likedPostIds.contains(post.id);
      if (post.isLiked != isLiked) {
        posts[i] = PostModel(
          id: post.id,
          userName: post.userName,
          userAvatar: post.userAvatar,
          timeAndLocation: post.timeAndLocation,
          content: post.content,
          images: post.images,
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          isLiked: isLiked,
          isBookmarked: post.isBookmarked,
        );
      }
    }
  }

  void _updatePostBookmarkStatus() {
    for (int i = 0; i < posts.length; i++) {
      final post = posts[i];
      final isBookmarked = bookmarkedPostIds.contains(post.id);
      if (post.isBookmarked != isBookmarked) {
        posts[i] = PostModel(
          id: post.id,
          userName: post.userName,
          userAvatar: post.userAvatar,
          timeAndLocation: post.timeAndLocation,
          content: post.content,
          images: post.images,
          likeCount: post.likeCount,
          commentCount: post.commentCount,
          isLiked: post.isLiked,
          isBookmarked: isBookmarked,
        );
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
              // Convert BlogPostModel to PostModel for UI
              posts.value =
                  blogPosts.map((blog) {
                    // Calculate relative time
                    String timeAndLocation = _getRelativeTime(blog.publishedAt ?? blog.createdAt);
                    if (blog.destinations.isNotEmpty) {
                      timeAndLocation += ' · ${blog.destinations.first}';
                    }

                    return PostModel(
                      id: blog.id,
                      userName: blog.authorName,
                      userAvatar:
                          blog.authorAvatar.isEmpty
                              ? 'https://i.pravatar.cc/150?img=${blog.id.hashCode % 10}'
                              : blog.authorAvatar,
                      timeAndLocation: timeAndLocation,
                      content: '${blog.title}\n${blog.excerpt}',
                      images:
                          [blog.coverImage, ...blog.images].where((img) => img.isNotEmpty).toList(),
                      likeCount: blog.likes,
                      commentCount: blog.commentsCount,
                      isLiked: likedPostIds.contains(blog.id),
                      isBookmarked: bookmarkedPostIds.contains(blog.id),
                    );
                  }).toList();

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

  // REMOVED: _loadDemoPosts() - No more demo data
  // REMOVED: _checkAndAddDemoPosts() - No automatic demo creation

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

  // REMOVED: _loadDemoReviews() - No more demo data
  // REMOVED: _checkAndAddDemoAccommodations() - No automatic demo creation

  Future<void> toggleLike(String postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = posts[index];
      // Optimistic update
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

      // Update backend
      final newStatus = await _blogService.toggleLike(postId);

      // Update local tracking
      if (newStatus) {
        likedPostIds.add(postId);
      } else {
        likedPostIds.remove(postId);
      }
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = posts[index];
      // Optimistic update
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

      // Update backend
      final newStatus = await _blogService.toggleBookmark(postId);

      // Update local tracking
      if (newStatus) {
        bookmarkedPostIds.add(postId);
      } else {
        bookmarkedPostIds.remove(postId);
      }
    }
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
