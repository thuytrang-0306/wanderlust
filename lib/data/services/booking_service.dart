import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class BookingService extends GetxService {
  static BookingService get to => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _bookingsCollection => _firestore.collection('bookings');
  
  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Create new booking
  Future<BookingModel?> createBooking({
    required String accommodationId,
    required DateTime checkIn,
    required DateTime checkOut,
    required GuestData guests,
    required CustomerData customer,
    required double basePrice,
    required String paymentMethod,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      // Calculate nights
      final nights = checkOut.difference(checkIn).inDays;
      
      // Calculate pricing
      final subtotal = basePrice * nights;
      final taxes = subtotal * 0.1; // 10% tax
      final fees = 50000; // Service fee
      final discount = 0.0; // Can add promo codes later
      final total = subtotal + taxes + fees - discount;
      
      // Generate booking code
      final bookingCode = BookingModel.generateBookingCode();
      
      // Generate QR code data
      final qrCode = 'wanderlust:booking:$bookingCode';
      
      final bookingData = {
        'userId': currentUserId,
        'type': 'accommodation',
        'referenceId': accommodationId,
        'bookingCode': bookingCode,
        'status': 'pending',
        'checkIn': Timestamp.fromDate(checkIn),
        'checkOut': Timestamp.fromDate(checkOut),
        'nights': nights,
        'guests': guests.toMap(),
        'pricing': {
          'subtotal': subtotal,
          'taxes': taxes,
          'fees': fees,
          'discount': discount,
          'total': total,
          'currency': 'VND',
          'paymentMethod': paymentMethod,
          'paymentStatus': 'pending',
        },
        'customer': customer.toMap(),
        'qrCode': qrCode,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await _bookingsCollection.add(bookingData);
      final doc = await docRef.get();
      
      LoggerService.i('Booking created successfully: ${docRef.id}');
      
      // Auto-confirm after 5 seconds (for demo)
      Future.delayed(const Duration(seconds: 5), () {
        confirmBooking(docRef.id);
      });
      
      return BookingModel.fromFirestore(doc);
      
    } catch (e) {
      LoggerService.e('Error creating booking', error: e);
      return null;
    }
  }
  
  // Confirm booking
  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
        'pricing.paymentStatus': 'paid',
      });
      
      LoggerService.i('Booking confirmed: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error confirming booking', error: e);
      return false;
    }
  }
  
  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.i('Booking cancelled: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error cancelling booking', error: e);
      return false;
    }
  }
  
  // Complete booking
  Future<bool> completeBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      
      LoggerService.i('Booking completed: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error completing booking', error: e);
      return false;
    }
  }
  
  // Get user's bookings
  Stream<List<BookingModel>> getUserBookings() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _bookingsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get bookings by status
  Stream<List<BookingModel>> getBookingsByStatus(BookingStatus status) {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _bookingsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status.value)
        .orderBy('checkIn', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get upcoming bookings
  Stream<List<BookingModel>> getUpcomingBookings() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    final now = DateTime.now();
    
    return _bookingsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'confirmed')
        .where('checkIn', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('checkIn')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }
  
  // Get single booking
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting booking', error: e);
      return null;
    }
  }
  
  // Stream single booking (for real-time updates)
  Stream<BookingModel?> streamBooking(String bookingId) {
    return _bookingsCollection.doc(bookingId).snapshots().map((doc) {
      if (doc.exists) {
        return BookingModel.fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Auto-complete old bookings
  Future<void> autoCompleteOldBookings() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      final snapshot = await _bookingsCollection
          .where('status', isEqualTo: 'confirmed')
          .where('checkOut', isLessThan: Timestamp.fromDate(yesterday))
          .get();
      
      for (final doc in snapshot.docs) {
        await completeBooking(doc.id);
      }
      
      LoggerService.i('Auto-completed ${snapshot.docs.length} old bookings');
    } catch (e) {
      LoggerService.e('Error auto-completing bookings', error: e);
    }
  }
}