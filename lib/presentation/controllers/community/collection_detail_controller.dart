import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/presentation/pages/community/collection_detail_page.dart';

class CollectionDetailController extends BaseController {
  final RxString collectionName = ''.obs;
  final RxList<SavedPostModel> posts = <SavedPostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      collectionName.value = args['collectionName'] ?? 'Bộ sưu tập';
      loadPosts(args['collectionId']);
    }
  }

  void loadPosts(String collectionId) {
    // Mock data - in real app, load from database based on collectionId
    posts.value = [
      SavedPostModel(
        id: '1',
        authorName: 'Hiếu Thứ Hai',
        authorAvatar: 'https://i.pravatar.cc/150?img=3',
        timeAgo: '2 giờ trước',
        location: 'Hà Giang',
        title: 'Chia sẻ kinh nghiệm du lịch Hà Giang',
        content:
            'Nội dung bài viết đang được tải. Khám phá vùng đất tuyệt đẹp này cùng những kinh nghiệm thú vị...',
        images: ['', ''],
        likeCount: 5000,
        commentCount: 700,
      ),
      SavedPostModel(
        id: '2',
        authorName: 'Thế Hưng',
        authorAvatar: 'https://i.pravatar.cc/150?img=8',
        timeAgo: 'Hôm qua',
        location: 'Nha Trang',
        title: 'Hướng dẫn du lịch Nha Trang',
        content:
            'Nội dung bài viết đang được tải. Trải nghiệm tuyệt vời tại biển Nha Trang cùng những địa điểm tham quan nổi tiếng...',
        images: [''],
        likeCount: 3200,
        commentCount: 450,
      ),
    ];
  }

  void openBlogDetail(SavedPostModel post) {
    Get.toNamed('/blog-detail', arguments: {'postId': post.id});
  }

  void toggleBookmark(String postId) {
    // Show confirmation dialog
    Get.defaultDialog(
      title: 'Xóa khỏi bộ sưu tập?',
      middleText: 'Bài viết này sẽ được xóa khỏi bộ sưu tập "${collectionName.value}"',
      textCancel: 'Hủy',
      textConfirm: 'Xóa',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () {
        posts.removeWhere((post) => post.id == postId);
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
