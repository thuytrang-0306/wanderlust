import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';

class SavedBlogsService extends GetxService {
  static SavedBlogsService get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  static const String _collectionsKey = 'saved_collections';
  static const String _savedBlogsKey = 'saved_blogs_data';
  
  // Observable collections and saved blogs
  final RxList<BlogCollection> collections = <BlogCollection>[].obs;
  final RxMap<String, SavedBlogData> savedBlogsCache = <String, SavedBlogData>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedData();
    _initDefaultCollection();
  }
  
  void _initDefaultCollection() {
    // Create default collection if not exists
    if (collections.isEmpty || !collections.any((c) => c.id == 'all')) {
      final defaultCollection = BlogCollection(
        id: 'all',
        name: 'Tất cả bài viết',
        isDefault: true,
        createdAt: DateTime.now(),
        blogIds: [],
      );
      collections.insert(0, defaultCollection);
      _saveCollections();
    }
  }
  
  void loadSavedData() {
    // Load collections
    final collectionsData = _storage.read<List<dynamic>>(_collectionsKey);
    if (collectionsData != null) {
      collections.value = collectionsData
          .map((json) => BlogCollection.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    
    // Load saved blogs cache
    final savedBlogsData = _storage.read<Map<String, dynamic>>(_savedBlogsKey);
    if (savedBlogsData != null) {
      savedBlogsCache.value = savedBlogsData.map(
        (key, value) => MapEntry(key, SavedBlogData.fromJson(Map<String, dynamic>.from(value))),
      );
    }
  }
  
  Future<void> _saveCollections() async {
    await _storage.write(_collectionsKey, collections.map((c) => c.toJson()).toList());
  }
  
  Future<void> _saveBlogsCache() async {
    await _storage.write(_savedBlogsKey, savedBlogsCache.map((key, value) => MapEntry(key, value.toJson())));
  }
  
  // Create new collection
  Future<BlogCollection> createCollection(String name) async {
    final collection = BlogCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isDefault: false,
      createdAt: DateTime.now(),
      blogIds: [],
    );
    
    collections.add(collection);
    await _saveCollections();
    return collection;
  }
  
  // Delete collection (except default)
  Future<bool> deleteCollection(String collectionId) async {
    if (collectionId == 'all') return false;
    
    collections.removeWhere((c) => c.id == collectionId);
    await _saveCollections();
    return true;
  }
  
  // Save blog to collection
  Future<void> saveBlogToCollection(BlogPostModel blog, String collectionId) async {
    // Find collection
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;
    
    final collection = collections[collectionIndex];
    
    // Add to collection if not exists
    if (!collection.blogIds.contains(blog.id)) {
      // Clone collection to trigger reactive update
      final updatedCollection = collection.copyWith(
        blogIds: [...collection.blogIds, blog.id],
      );
      collections[collectionIndex] = updatedCollection;
      
      // Also add to default collection if not saving to default
      if (collectionId != 'all') {
        final defaultIndex = collections.indexWhere((c) => c.id == 'all');
        if (defaultIndex != -1 && !collections[defaultIndex].blogIds.contains(blog.id)) {
          final defaultCollection = collections[defaultIndex];
          collections[defaultIndex] = defaultCollection.copyWith(
            blogIds: [...defaultCollection.blogIds, blog.id],
          );
        }
      }
      
      // Cache blog STATIC data only (no likes/comments - those are fetched fresh)
      savedBlogsCache[blog.id] = SavedBlogData(
        id: blog.id,
        title: blog.title,
        coverImage: blog.coverImage,
        authorName: blog.authorName,
        authorAvatar: blog.authorAvatar,
        location: blog.destinations.isNotEmpty ? blog.destinations.first : '',
        savedAt: DateTime.now(),
      );
      
      // Save to storage asynchronously to avoid blocking UI
      Future.microtask(() async {
        await _saveCollections();
        await _saveBlogsCache();
      });
    }
  }
  
  // Remove blog from collection
  Future<void> removeBlogFromCollection(String blogId, String collectionId) async {
    final collectionIndex = collections.indexWhere((c) => c.id == collectionId);
    if (collectionIndex == -1) return;
    
    // Clone and update collection
    final collection = collections[collectionIndex];
    final updatedBlogIds = List<String>.from(collection.blogIds)..remove(blogId);
    collections[collectionIndex] = collection.copyWith(blogIds: updatedBlogIds);
    
    // If removing from default collection, remove from all collections
    if (collectionId == 'all') {
      for (int i = 0; i < collections.length; i++) {
        final col = collections[i];
        if (col.blogIds.contains(blogId)) {
          collections[i] = col.copyWith(
            blogIds: List<String>.from(col.blogIds)..remove(blogId),
          );
        }
      }
      // Remove from cache
      savedBlogsCache.remove(blogId);
    }
    
    // Check if blog is still in any collection
    final stillSaved = collections.any((c) => c.blogIds.contains(blogId));
    if (!stillSaved) {
      savedBlogsCache.remove(blogId);
    }
    
    // Save to storage asynchronously
    Future.microtask(() async {
      await _saveCollections();
      await _saveBlogsCache();
    });
  }
  
  // Check if blog is saved in any collection
  bool isBlogSaved(String blogId) {
    return collections.any((c) => c.blogIds.contains(blogId));
  }
  
  // Check if blog is in specific collection
  bool isBlogInCollection(String blogId, String collectionId) {
    final collection = collections.firstWhereOrNull((c) => c.id == collectionId);
    return collection?.blogIds.contains(blogId) ?? false;
  }
  
  // Get collections that contain a blog
  List<BlogCollection> getCollectionsForBlog(String blogId) {
    return collections.where((c) => c.blogIds.contains(blogId)).toList();
  }
  
  // Get saved blogs for collection
  List<SavedBlogData> getSavedBlogsForCollection(String collectionId) {
    final collection = collections.firstWhereOrNull((c) => c.id == collectionId);
    if (collection == null) return [];
    
    return collection.blogIds
        .map((id) => savedBlogsCache[id])
        .where((blog) => blog != null)
        .cast<SavedBlogData>()
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // Sort by saved date
  }
  
  // Update collection name
  Future<void> updateCollectionName(String collectionId, String newName) async {
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index != -1 && collectionId != 'all') {
      collections[index] = collections[index].copyWith(name: newName);
      await _saveCollections();
    }
  }
  
  // Get total saved blogs count
  int get totalSavedBlogs => savedBlogsCache.length;
  
  // Clear all data (for logout)
  Future<void> clearAllData() async {
    collections.clear();
    savedBlogsCache.clear();
    await _storage.remove(_collectionsKey);
    await _storage.remove(_savedBlogsKey);
    _initDefaultCollection();
  }
}

// Models
class BlogCollection {
  final String id;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final List<String> blogIds;
  
  BlogCollection({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    required this.blogIds,
  });
  
  BlogCollection copyWith({
    String? name,
    List<String>? blogIds,
  }) {
    return BlogCollection(
      id: id,
      name: name ?? this.name,
      isDefault: isDefault,
      createdAt: createdAt,
      blogIds: blogIds ?? this.blogIds,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'blogIds': blogIds,
  };
  
  factory BlogCollection.fromJson(Map<String, dynamic> json) => BlogCollection(
    id: json['id'],
    name: json['name'],
    isDefault: json['isDefault'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    blogIds: List<String>.from(json['blogIds'] ?? []),
  );
  
  // Helper getters
  int get postCount => blogIds.length;
  bool get isEmpty => blogIds.isEmpty;
}

class SavedBlogData {
  final String id;
  final String title;
  final String coverImage;
  final String authorName;
  final String authorAvatar;
  final String location;
  final DateTime savedAt;
  // REMOVED: likeCount and commentCount - these are dynamic and should be fetched fresh

  SavedBlogData({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.authorName,
    required this.authorAvatar,
    required this.location,
    required this.savedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'coverImage': coverImage,
    'authorName': authorName,
    'authorAvatar': authorAvatar,
    'location': location,
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedBlogData.fromJson(Map<String, dynamic> json) => SavedBlogData(
    id: json['id'],
    title: json['title'],
    coverImage: json['coverImage'] ?? '',
    authorName: json['authorName'] ?? '',
    authorAvatar: json['authorAvatar'] ?? '',
    location: json['location'] ?? '',
    savedAt: DateTime.parse(json['savedAt']),
  );
  
  // Helper getter for time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(savedAt);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}