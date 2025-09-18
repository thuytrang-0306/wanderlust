import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/blog_post_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class BlogService extends GetxService {
  static BlogService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  CollectionReference get _postsCollection => _firestore.collection('blog_posts');
  CollectionReference get _usersCollection => _firestore.collection('users');
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.uid;
  
  // Create new blog post
  Future<BlogPostModel?> createPost({
    required String title,
    required String content,
    required String excerpt,
    required String coverImage,
    required String category,
    List<String> tags = const [],
    List<String> destinations = const [],
    List<String> images = const [],
    bool publish = false,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get user data
      final userDoc = await _usersCollection.doc(currentUserId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final postData = {
        'userId': currentUserId,
        'authorName': userData?['displayName'] ?? currentUser?.displayName ?? 'Anonymous',
        'authorAvatar': userData?['photoURL'] ?? currentUser?.photoURL ?? '',
        'title': title,
        'content': content,
        'excerpt': excerpt,
        'coverImage': coverImage,
        'images': images,
        'videos': [],
        'category': category,
        'tags': tags,
        'destinations': destinations,
        'likes': 0,
        'views': 0,
        'shares': 0,
        'commentsCount': 0,
        'status': publish ? 'published' : 'draft',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'publishedAt': publish ? FieldValue.serverTimestamp() : null,
      };
      
      final docRef = await _postsCollection.add(postData);
      final doc = await docRef.get();
      
      LoggerService.i('Blog post created successfully: ${docRef.id}');
      return BlogPostModel.fromFirestore(doc);
      
    } catch (e) {
      LoggerService.e('Error creating blog post', error: e);
      return null;
    }
  }
  
  // Update blog post
  Future<bool> updatePost(String postId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _postsCollection.doc(postId).update(data);
      
      LoggerService.i('Blog post updated successfully: $postId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating blog post', error: e);
      return false;
    }
  }
  
  // Delete blog post
  Future<bool> deletePost(String postId) async {
    try {
      // Delete comments first
      await _deletePostComments(postId);
      
      // Delete the post
      await _postsCollection.doc(postId).delete();
      
      LoggerService.i('Blog post deleted successfully: $postId');
      return true;
    } catch (e) {
      LoggerService.e('Error deleting blog post', error: e);
      return false;
    }
  }
  
  // Publish draft post
  Future<bool> publishPost(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'status': 'published',
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      LoggerService.e('Error publishing post', error: e);
      return false;
    }
  }
  
  // Get all published posts
  Stream<List<BlogPostModel>> getPublishedPosts({int limit = 20}) {
    return _postsCollection
        .where('status', isEqualTo: 'published')
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlogPostModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get recent posts (non-stream version)
  Future<List<BlogPostModel>> getRecentPosts({int limit = 10}) async {
    try {
      final snapshot = await _postsCollection
          .where('status', isEqualTo: 'published')
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => BlogPostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.e('Error getting recent posts', error: e);
      return [];
    }
  }
  
  // Get trending posts
  Stream<List<BlogPostModel>> getTrendingPosts({int limit = 10}) {
    return _postsCollection
        .where('status', isEqualTo: 'published')
        .orderBy('views', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlogPostModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get posts by category
  Stream<List<BlogPostModel>> getPostsByCategory(String category, {int limit = 20}) {
    return _postsCollection
        .where('status', isEqualTo: 'published')
        .where('category', isEqualTo: category)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlogPostModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get user's posts
  Stream<List<BlogPostModel>> getUserPosts(String? userId) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      return Stream.value([]);
    }
    
    return _postsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlogPostModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get single post
  Future<BlogPostModel?> getPost(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      
      if (doc.exists) {
        // Increment view count
        await _incrementViews(postId);
        return BlogPostModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting post', error: e);
      return null;
    }
  }
  
  // Like/Unlike post
  Future<bool> toggleLike(String postId, bool isLiked) async {
    try {
      await _postsCollection.doc(postId).update({
        'likes': FieldValue.increment(isLiked ? 1 : -1),
      });
      
      return true;
    } catch (e) {
      LoggerService.e('Error toggling like', error: e);
      return false;
    }
  }
  
  // Increment views
  Future<void> _incrementViews(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      LoggerService.e('Error incrementing views', error: e);
    }
  }
  
  // Increment shares
  Future<bool> incrementShares(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'shares': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      LoggerService.e('Error incrementing shares', error: e);
      return false;
    }
  }
  
  // Add comment
  Future<bool> addComment(String postId, String content) async {
    try {
      if (currentUserId == null) return false;
      
      // Get user data
      final userDoc = await _usersCollection.doc(currentUserId).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      
      final comment = BlogComment(
        id: '',
        postId: postId,
        userId: currentUserId!,
        userName: userData?['displayName'] ?? 'Anonymous',
        userAvatar: userData?['photoURL'] ?? '',
        content: content,
        createdAt: DateTime.now(),
      );
      
      await _postsCollection
          .doc(postId)
          .collection('comments')
          .add(comment.toMap());
      
      // Increment comment count
      await _postsCollection.doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
      
      return true;
    } catch (e) {
      LoggerService.e('Error adding comment', error: e);
      return false;
    }
  }
  
  // Get post comments
  Stream<List<BlogComment>> getPostComments(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BlogComment.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
  
  // Delete all comments of a post
  Future<void> _deletePostComments(String postId) async {
    final commentsCollection = _postsCollection.doc(postId).collection('comments');
    final commentsDocs = await commentsCollection.get();
    
    for (final doc in commentsDocs.docs) {
      await doc.reference.delete();
    }
  }
  
  // Search posts
  Future<List<BlogPostModel>> searchPosts(String query) async {
    try {
      if (query.isEmpty) return [];
      
      // Simple text search - for production use Algolia
      final snapshot = await _postsCollection
          .where('status', isEqualTo: 'published')
          .get();
      
      final posts = snapshot.docs
          .map((doc) => BlogPostModel.fromFirestore(doc))
          .where((post) => 
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.excerpt.toLowerCase().contains(query.toLowerCase()) ||
              post.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
      
      return posts;
    } catch (e) {
      LoggerService.e('Error searching posts', error: e);
      return [];
    }
  }
  
  // Add demo posts (for testing)
  Future<void> addDemoPosts() async {
    try {
      final demoPosts = [
        {
          'title': 'Khám phá vẻ đẹp hoang sơ của Phú Quốc',
          'excerpt': 'Hòn đảo ngọc Phú Quốc với những bãi biển tuyệt đẹp và thiên nhiên hoang sơ',
          'content': 'Phú Quốc được mệnh danh là hòn đảo ngọc của Việt Nam...',
          'coverImage': 'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800',
          'category': 'Du lịch biển',
          'tags': ['phú quốc', 'biển', 'island'],
          'destinations': ['Phú Quốc'],
        },
        {
          'title': 'Sapa - Thiên đường trong mây',
          'excerpt': 'Khám phá vẻ đẹp hùng vĩ của Sapa với những thửa ruộng bậc thang',
          'content': 'Sapa nằm ở độ cao 1600m so với mực nước biển...',
          'coverImage': 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800',
          'category': 'Du lịch núi',
          'tags': ['sapa', 'núi', 'trekking'],
          'destinations': ['Sapa'],
        },
      ];
      
      for (final postData in demoPosts) {
        await createPost(
          title: postData['title'] as String,
          content: postData['content'] as String,
          excerpt: postData['excerpt'] as String,
          coverImage: postData['coverImage'] as String,
          category: postData['category'] as String,
          tags: postData['tags'] as List<String>,
          destinations: postData['destinations'] as List<String>,
          publish: true,
        );
      }
      
      LoggerService.i('Demo posts added successfully');
    } catch (e) {
      LoggerService.e('Error adding demo posts', error: e);
    }
  }
}