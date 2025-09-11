import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

abstract class BaseRepository<T> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> collection;
  
  String get collectionName;
  
  BaseRepository() {
    collection = firestore.collection(collectionName);
  }
  
  // Abstract methods to implement in child classes
  T fromJson(Map<String, dynamic> json, String id);
  Map<String, dynamic> toJson(T item);
  String getId(T item);
  
  // CREATE
  Future<String> create(T item) async {
    try {
      final data = toJson(item);
      LoggerService.firebase(
        operation: 'CREATE',
        collection: collectionName,
        data: data,
      );
      
      final docRef = await collection.add(data);
      return docRef.id;
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'CREATE',
        collection: collectionName,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  Future<void> createWithId(String id, T item) async {
    try {
      final data = toJson(item);
      LoggerService.firebase(
        operation: 'CREATE_WITH_ID',
        collection: collectionName,
        documentId: id,
        data: data,
      );
      
      await collection.doc(id).set(data);
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'CREATE_WITH_ID',
        collection: collectionName,
        documentId: id,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  // READ
  Future<T?> getById(String id) async {
    try {
      LoggerService.firebase(
        operation: 'GET_BY_ID',
        collection: collectionName,
        documentId: id,
      );
      
      final doc = await collection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'GET_BY_ID',
        collection: collectionName,
        documentId: id,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  Future<List<T>> getAll({
    int? limit,
    DocumentSnapshot? startAfter,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection;
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = filter.apply(query);
        }
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      LoggerService.firebase(
        operation: 'GET_ALL',
        collection: collectionName,
        data: {
          'limit': limit,
          'orderBy': orderBy,
          'descending': descending,
          'filters': filters?.length,
        },
      );
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => fromJson(doc.data(), doc.id))
          .toList();
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'GET_ALL',
        collection: collectionName,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  // UPDATE
  Future<void> update(String id, T item) async {
    try {
      final data = toJson(item);
      LoggerService.firebase(
        operation: 'UPDATE',
        collection: collectionName,
        documentId: id,
        data: data,
      );
      
      await collection.doc(id).update(data);
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'UPDATE',
        collection: collectionName,
        documentId: id,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  Future<void> updateFields(String id, Map<String, dynamic> fields) async {
    try {
      LoggerService.firebase(
        operation: 'UPDATE_FIELDS',
        collection: collectionName,
        documentId: id,
        data: fields,
      );
      
      await collection.doc(id).update(fields);
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'UPDATE_FIELDS',
        collection: collectionName,
        documentId: id,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  // DELETE
  Future<void> delete(String id) async {
    try {
      LoggerService.firebase(
        operation: 'DELETE',
        collection: collectionName,
        documentId: id,
      );
      
      await collection.doc(id).delete();
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'DELETE',
        collection: collectionName,
        documentId: id,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  // REAL-TIME
  Stream<T?> streamById(String id) {
    LoggerService.firebase(
      operation: 'STREAM_BY_ID',
      collection: collectionName,
      documentId: id,
    );
    
    return collection.doc(id).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }
  
  Stream<List<T>> streamAll({
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = collection;
    
    if (filters != null) {
      for (final filter in filters) {
        query = filter.apply(query);
      }
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    LoggerService.firebase(
      operation: 'STREAM_ALL',
      collection: collectionName,
      data: {
        'orderBy': orderBy,
        'descending': descending,
        'limit': limit,
        'filters': filters?.length,
      },
    );
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => fromJson(doc.data(), doc.id))
          .toList();
    });
  }
  
  // BATCH OPERATIONS
  Future<void> batchCreate(List<T> items) async {
    try {
      final batch = firestore.batch();
      
      for (final item in items) {
        final docRef = collection.doc();
        batch.set(docRef, toJson(item));
      }
      
      LoggerService.firebase(
        operation: 'BATCH_CREATE',
        collection: collectionName,
        data: {'count': items.length},
      );
      
      await batch.commit();
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'BATCH_CREATE',
        collection: collectionName,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  Future<void> batchDelete(List<String> ids) async {
    try {
      final batch = firestore.batch();
      
      for (final id in ids) {
        batch.delete(collection.doc(id));
      }
      
      LoggerService.firebase(
        operation: 'BATCH_DELETE',
        collection: collectionName,
        data: {'count': ids.length},
      );
      
      await batch.commit();
    } catch (e, s) {
      LoggerService.firebase(
        operation: 'BATCH_DELETE',
        collection: collectionName,
        error: e,
      );
      throw _handleError(e, s);
    }
  }
  
  // Error handling
  Exception _handleError(dynamic error, StackTrace stackTrace) {
    LoggerService.e(
      'Repository error in $collectionName',
      error: error,
      stackTrace: stackTrace,
    );
    
    if (error is FirebaseException) {
      return Exception('Firebase error: ${error.message}');
    }
    return Exception('Unknown error: $error');
  }
}

// Query Filter Helper
class QueryFilter {
  final String field;
  final dynamic value;
  final FilterOperator operator;
  
  QueryFilter({
    required this.field,
    required this.value,
    this.operator = FilterOperator.isEqualTo,
  });
  
  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> query) {
    switch (operator) {
      case FilterOperator.isEqualTo:
        return query.where(field, isEqualTo: value);
      case FilterOperator.isNotEqualTo:
        return query.where(field, isNotEqualTo: value);
      case FilterOperator.isLessThan:
        return query.where(field, isLessThan: value);
      case FilterOperator.isLessThanOrEqualTo:
        return query.where(field, isLessThanOrEqualTo: value);
      case FilterOperator.isGreaterThan:
        return query.where(field, isGreaterThan: value);
      case FilterOperator.isGreaterThanOrEqualTo:
        return query.where(field, isGreaterThanOrEqualTo: value);
      case FilterOperator.arrayContains:
        return query.where(field, arrayContains: value);
      case FilterOperator.arrayContainsAny:
        return query.where(field, arrayContainsAny: value);
      case FilterOperator.whereIn:
        return query.where(field, whereIn: value);
      case FilterOperator.whereNotIn:
        return query.where(field, whereNotIn: value);
      case FilterOperator.isNull:
        return query.where(field, isNull: value);
    }
  }
}

enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}