import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/community/community_page.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class CommunityController extends GetxController {
  // Observable lists
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadFakePosts();
    _loadFakeReviews();
  }
  
  void _loadFakePosts() {
    posts.value = [
      PostModel(
        id: '1',
        userName: 'Hiếu Thứ Hai',
        userAvatar: 'https://i.pravatar.cc/150?img=1',
        timeAndLocation: '2 giờ trước · Hà Giang',
        content: 'Lorem ipsum dolor sit amet, cons.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi pharetra ornare libero non imperdiet...',
        images: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
          'https://images.unsplash.com/photo-1454391304352-2bf4678b1a7a?w=800',
        ],
        likeCount: 5000,
        commentCount: 700,
        isLiked: false,
        isBookmarked: false,
      ),
      PostModel(
        id: '2',
        userName: 'Thế Hùng',
        userAvatar: 'https://i.pravatar.cc/150?img=2',
        timeAndLocation: 'Hôm qua · Ninh Bình Trang',
        content: 'Lorem ipsum dolor sit amet, cons.\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi pharetra ornare libero non imperdiet...',
        images: [
          'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
        ],
        likeCount: 5000,
        commentCount: 300,
        isLiked: true,
        isBookmarked: true,
      ),
      PostModel(
        id: '3',
        userName: 'Trung Phúc',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        timeAndLocation: '3 giờ trước · Đà Nẵng',
        content: 'Lorem ipsum dolor sit amet, cons.\nLorem ipsum dolor sit amet, consectetur',
        images: [],
        likeCount: 200,
        commentCount: 50,
        isLiked: false,
        isBookmarked: false,
      ),
    ];
  }
  
  void _loadFakeReviews() {
    reviews.value = [
      ReviewModel(
        id: '1',
        name: 'Homestay Son Thuy',
        location: 'Hà Giang',
        imageUrl: 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        rating: 4.4,
        price: '600.000 VND',
        duration: '4N/5D',
      ),
      ReviewModel(
        id: '2',
        name: 'Khách sạn GG',
        location: 'Hà Giang',
        imageUrl: 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        rating: 4.4,
        price: '400.000 VND',
        duration: null,
      ),
      ReviewModel(
        id: '3',
        name: 'Resort Paradise',
        location: 'Phú Quốc',
        imageUrl: 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
        rating: 4.8,
        price: '1.200.000 VND',
        duration: '3N/4D',
      ),
    ];
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
    
    if (result != null) {
      // Refresh posts list after creating new post
      _loadFakePosts();
    }
  }
  
  void openBookmarks() {
    Get.toNamed('/saved-collections');
  }
}