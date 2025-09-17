import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';

class BlogDetailController extends BaseController {
  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isLiked = false.obs;
  final RxInt likeCount = 5000.obs;
  final RxInt commentCount = 700.obs;
  
  // Blog data
  final RxMap<String, dynamic> blogData = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> comments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> suggestions = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadBlogData();
    loadComments();
    loadSuggestions();
  }
  
  void loadBlogData() {
    // Mock data - in real app, load from API/database
    blogData.value = {
      'id': '1',
      'title': 'Lorem ipsum dolor sit amet, consectetur.',
      'content': '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta. Lorem adipiscing mus vestibulum consequat porta eu ultrices feugiat. Et, faucibus ut amet turpis. Facilisis faucibus semper cras purus.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta.

Fermentum et eget libero lectus. Amet, tellus aliquam, dignissim enim placerat purus nunc, ac ipsum. Ac pretium.''',
      'author': {
        'name': 'Hiếu Thứ Hai',
        'avatar': 'https://i.pravatar.cc/150?img=3',
      },
      'location': 'Hà Giang',
      'time': '2 giờ trước',
      'images': [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400',
      ],
      'likes': 5000,
      'comments': 700,
    };
  }
  
  void loadComments() {
    // Mock comments data
    comments.value = [
      {
        'id': '1',
        'author': {
          'name': 'Jake',
          'avatar': 'https://i.pravatar.cc/150?img=5',
        },
        'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        'time': '5 phút',
        'likes': 5000,
      },
    ];
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
  
  void toggleLike() {
    if (isLiked.value) {
      isLiked.value = false;
      likeCount.value--;
    } else {
      isLiked.value = true;
      likeCount.value++;
    }
    // TODO: Update like status in backend
  }
  
  void addComment(String comment) {
    // TODO: Add comment to backend
  }
  
  void shareArticle() {
    // TODO: Implement share functionality
  }
}