import 'package:get/get.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/core/utils/logger_service.dart';

class AdminExportService extends GetxService {
  static AdminExportService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Export users data to CSV
  Future<void> exportUsersToCSV() async {
    try {
      final users = await _firestore.collection('users').get();
      
      final csvData = <List<String>>[];
      
      // Headers
      csvData.add([
        'ID',
        'Name',
        'Email',
        'Phone',
        'Created At',
        'Last Active',
        'Is Verified',
        'Status',
      ]);
      
      // Data rows
      for (final doc in users.docs) {
        final data = doc.data();
        csvData.add([
          doc.id,
          data['name'] ?? '',
          data['email'] ?? '',
          data['phone'] ?? '',
          _formatTimestamp(data['createdAt']),
          _formatTimestamp(data['lastActiveAt']),
          (data['isVerified'] ?? false).toString(),
          data['status'] ?? 'active',
        ]);
      }
      
      final csvString = _convertToCSV(csvData);
      _downloadFile(csvString, 'users_export_${DateTime.now().millisecondsSinceEpoch}.csv', 'text/csv');
      
      LoggerService.i('Users data exported to CSV');
    } catch (e) {
      LoggerService.e('Error exporting users to CSV', error: e);
      rethrow;
    }
  }
  
  // Export businesses data to CSV
  Future<void> exportBusinessesToCSV() async {
    try {
      final businesses = await _firestore.collection('businesses').get();
      
      final csvData = <List<String>>[];
      
      // Headers
      csvData.add([
        'ID',
        'Name',
        'Email',
        'Phone',
        'Category',
        'Address',
        'Verification Status',
        'Created At',
        'Total Listings',
        'Rating',
      ]);
      
      // Data rows
      for (final doc in businesses.docs) {
        final data = doc.data();
        csvData.add([
          doc.id,
          data['name'] ?? '',
          data['email'] ?? '',
          data['phone'] ?? '',
          data['category'] ?? '',
          data['address'] ?? '',
          data['verificationStatus'] ?? 'pending',
          _formatTimestamp(data['createdAt']),
          (data['totalListings'] ?? 0).toString(),
          (data['rating'] ?? 0.0).toString(),
        ]);
      }
      
      final csvString = _convertToCSV(csvData);
      _downloadFile(csvString, 'businesses_export_${DateTime.now().millisecondsSinceEpoch}.csv', 'text/csv');
      
      LoggerService.i('Businesses data exported to CSV');
    } catch (e) {
      LoggerService.e('Error exporting businesses to CSV', error: e);
      rethrow;
    }
  }
  
  // Export bookings data to CSV
  Future<void> exportBookingsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('bookings');
      
      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }
      
      final bookings = await query.get();
      
      final csvData = <List<String>>[];
      
      // Headers
      csvData.add([
        'ID',
        'User ID',
        'Business ID',
        'Listing ID',
        'Check In',
        'Check Out',
        'Guests',
        'Total Amount',
        'Commission',
        'Status',
        'Payment Status',
        'Created At',
      ]);
      
      // Data rows
      for (final doc in bookings.docs) {
        final data = doc.data() as Map<String, dynamic>;
        csvData.add([
          doc.id,
          data['userId'] ?? '',
          data['businessId'] ?? '',
          data['listingId'] ?? '',
          _formatTimestamp(data['checkInDate']),
          _formatTimestamp(data['checkOutDate']),
          (data['guests'] ?? 0).toString(),
          (data['totalAmount'] ?? 0.0).toString(),
          (data['commission'] ?? 0.0).toString(),
          data['status'] ?? '',
          data['paymentStatus'] ?? '',
          _formatTimestamp(data['createdAt']),
        ]);
      }
      
      final csvString = _convertToCSV(csvData);
      final filename = 'bookings_export_${startDate != null ? '${startDate.millisecondsSinceEpoch}_' : ''}${DateTime.now().millisecondsSinceEpoch}.csv';
      _downloadFile(csvString, filename, 'text/csv');
      
      LoggerService.i('Bookings data exported to CSV');
    } catch (e) {
      LoggerService.e('Error exporting bookings to CSV', error: e);
      rethrow;
    }
  }
  
  // Export blogs data to CSV
  Future<void> exportBlogsToCSV() async {
    try {
      final blogs = await _firestore.collection('blogs').get();
      
      final csvData = <List<String>>[];
      
      // Headers
      csvData.add([
        'ID',
        'Title',
        'Author ID',
        'Author Name',
        'Category',
        'Status',
        'Likes',
        'Comments',
        'Views',
        'Created At',
        'Published At',
      ]);
      
      // Data rows
      for (final doc in blogs.docs) {
        final data = doc.data();
        csvData.add([
          doc.id,
          data['title'] ?? '',
          data['authorId'] ?? '',
          data['authorName'] ?? '',
          data['category'] ?? '',
          data['status'] ?? 'published',
          (data['likes'] ?? 0).toString(),
          (data['commentsCount'] ?? 0).toString(),
          (data['views'] ?? 0).toString(),
          _formatTimestamp(data['createdAt']),
          _formatTimestamp(data['publishedAt']),
        ]);
      }
      
      final csvString = _convertToCSV(csvData);
      _downloadFile(csvString, 'blogs_export_${DateTime.now().millisecondsSinceEpoch}.csv', 'text/csv');
      
      LoggerService.i('Blogs data exported to CSV');
    } catch (e) {
      LoggerService.e('Error exporting blogs to CSV', error: e);
      rethrow;
    }
  }
  
  // Export analytics data to JSON
  Future<void> exportAnalyticsToJSON(Map<String, dynamic> analyticsData) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(analyticsData);
      _downloadFile(jsonString, 'analytics_export_${DateTime.now().millisecondsSinceEpoch}.json', 'application/json');
      
      LoggerService.i('Analytics data exported to JSON');
    } catch (e) {
      LoggerService.e('Error exporting analytics to JSON', error: e);
      rethrow;
    }
  }
  
  // Helper method to convert 2D array to CSV string
  String _convertToCSV(List<List<String>> data) {
    return data.map((row) {
      return row.map((cell) {
        // Escape quotes and wrap in quotes if contains comma, quote, or newline
        final escapedCell = cell.replaceAll('"', '""');
        if (escapedCell.contains(',') || escapedCell.contains('"') || escapedCell.contains('\n')) {
          return '"$escapedCell"';
        }
        return escapedCell;
      }).join(',');
    }).join('\n');
  }
  
  // Helper method to format Firestore timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final date = timestamp is Timestamp 
          ? timestamp.toDate() 
          : DateTime.parse(timestamp.toString());
      return date.toIso8601String();
    } catch (e) {
      return '';
    }
  }
  
  // Helper method to download file in web browser
  void _downloadFile(String content, String filename, String mimeType) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
  
  // Get export statistics
  Map<String, dynamic> getExportStats() {
    return {
      'lastExportDate': DateTime.now().toIso8601String(),
      'supportedFormats': ['CSV', 'JSON'],
      'availableExports': [
        'Users',
        'Businesses', 
        'Bookings',
        'Blogs',
        'Analytics',
      ],
    };
  }
}