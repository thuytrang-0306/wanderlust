import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String authorAvatar;
  final String title;
  final String content;
  final String excerpt;
  final String coverImage;
  final List<String> images;
  final List<String> videos;
  final String category;
  final List<String> tags;
  final List<String> destinations;
  final int likes;
  final int views;
  final int shares;
  final int commentsCount;
  final PostStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  BlogPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.authorAvatar,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.coverImage,
    required this.images,
    required this.videos,
    required this.category,
    required this.tags,
    required this.destinations,
    this.likes = 0,
    this.views = 0,
    this.shares = 0,
    this.commentsCount = 0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory BlogPostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BlogPostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorAvatar: data['authorAvatar'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      excerpt: data['excerpt'] ?? '',
      coverImage: data['coverImage'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      destinations: List<String>.from(data['destinations'] ?? []),
      likes: data['likes'] ?? 0,
      views: data['views'] ?? 0,
      shares: data['shares'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      status: PostStatus.fromString(data['status'] ?? 'draft'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publishedAt: data['publishedAt'] != null 
          ? (data['publishedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'coverImage': coverImage,
      'images': images,
      'videos': videos,
      'category': category,
      'tags': tags,
      'destinations': destinations,
      'likes': likes,
      'views': views,
      'shares': shares,
      'commentsCount': commentsCount,
      'status': status.value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'publishedAt': publishedAt != null 
          ? Timestamp.fromDate(publishedAt!) 
          : null,
    };
  }

  // Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(publishedAt ?? createdAt);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${diff.inMinutes} phút trước';
      }
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).round()} tuần trước';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).round()} tháng trước';
    } else {
      return '${(diff.inDays / 365).round()} năm trước';
    }
  }

  // Format views count
  String get formattedViews {
    if (views < 1000) {
      return views.toString();
    } else if (views < 1000000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    }
  }

  // Format likes count
  String get formattedLikes {
    if (likes < 1000) {
      return likes.toString();
    } else if (likes < 1000000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    }
  }

  // Generate slug from title
  String get slug {
    return title.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

enum PostStatus {
  draft('draft', 'Nháp'),
  published('published', 'Đã xuất bản'),
  archived('archived', 'Lưu trữ');

  final String value;
  final String displayName;
  
  const PostStatus(this.value, this.displayName);

  static PostStatus fromString(String value) {
    return PostStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PostStatus.draft,
    );
  }
}

class BlogComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final int likes;
  final DateTime createdAt;
  final String? parentId; // For nested comments

  BlogComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.likes = 0,
    required this.createdAt,
    this.parentId,
  });

  factory BlogComment.fromMap(Map<String, dynamic> map, String id) {
    return BlogComment(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      content: map['content'] ?? '',
      likes: map['likes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      parentId: map['parentId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'parentId': parentId,
    };
  }
}