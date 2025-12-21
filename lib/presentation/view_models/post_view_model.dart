import 'package:get/get.dart';

/// ViewModel for Post UI with reactive state management
/// Prevents full widget rebuild when only like/bookmark state changes
class PostViewModel {
  // Immutable data
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAndLocation;
  final String content;
  final List<String> images;
  final int commentCount;

  // Observable state - only these trigger UI updates
  final RxInt likeCount;
  final RxBool isLiked;
  final RxBool isBookmarked;

  PostViewModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAndLocation,
    required this.content,
    required this.images,
    required this.commentCount,
    required int initialLikeCount,
    required bool initialIsLiked,
    required bool initialIsBookmarked,
  })  : // Sanitize: ensure like count never negative (fix legacy bad data)
        likeCount = (initialLikeCount < 0 ? 0 : initialLikeCount).obs,
        isLiked = initialIsLiked.obs,
        isBookmarked = initialIsBookmarked.obs;

  /// Factory constructor from BlogPostModel
  factory PostViewModel.fromBlogPost({
    required String id,
    required String authorName,
    required String authorAvatar,
    required String timeAndLocation,
    required String content,
    required List<String> images,
    required int commentCount,
    required int likes,
    required bool isLiked,
    required bool isBookmarked,
  }) {
    return PostViewModel(
      id: id,
      userName: authorName,
      userAvatar: authorAvatar.isEmpty
          ? 'https://i.pravatar.cc/150?img=${id.hashCode % 10}'
          : authorAvatar,
      timeAndLocation: timeAndLocation,
      content: content,
      images: images,
      commentCount: commentCount,
      initialLikeCount: likes,
      initialIsLiked: isLiked,
      initialIsBookmarked: isBookmarked,
    );
  }

  /// Update like state (optimistic update)
  void toggleLike() {
    isLiked.toggle();
    if (isLiked.value) {
      likeCount.value += 1;
    } else {
      // Guard: never go below 0
      likeCount.value = (likeCount.value - 1).clamp(0, double.infinity.toInt());
    }
  }

  /// Update bookmark state
  void toggleBookmark() {
    isBookmarked.toggle();
  }

  /// Sync with actual like count from backend
  void syncLikeCount(int actualCount) {
    // Sanitize: ensure like count never negative (fix legacy bad data)
    likeCount.value = actualCount < 0 ? 0 : actualCount;
  }

  /// Sync like status
  void syncLikeStatus(bool status) {
    isLiked.value = status;
  }

  /// Sync bookmark status
  void syncBookmarkStatus(bool status) {
    isBookmarked.value = status;
  }
}
