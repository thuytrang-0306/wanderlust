import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class BookingService extends GetxService {
  static BookingService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  final String _collection = 'bookings';

  // Get current user
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => currentUser?.uid;

  // Create new booking
  Future<String?> createBooking(BookingModel booking) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _firestore.collection(_collection).add(booking.toFirestore());

      LoggerService.i('Booking created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      LoggerService.e('Error creating booking', error: e);
      return null;
    }
  }

  // Update booking
  Future<bool> updateBooking(String bookingId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection(_collection).doc(bookingId).update(data);

      LoggerService.i('Booking updated successfully: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error updating booking', error: e);
      return false;
    }
  }

  // Confirm booking
  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.i('Booking confirmed: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error confirming booking', error: e);
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancellationDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.i('Booking completed: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error completing booking', error: e);
      return false;
    }
  }

  // Process payment
  Future<bool> processPayment(String bookingId, String paymentId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'paymentStatus': 'paid',
        'paymentId': paymentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.i('Payment processed for booking: $bookingId');
      return true;
    } catch (e) {
      LoggerService.e('Error processing payment', error: e);
      return false;
    }
  }

  // Get single booking
  Future<BookingModel?> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(bookingId).get();

      if (doc.exists && doc.data() != null) {
        return BookingModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      LoggerService.e('Error getting booking', error: e);
      return null;
    }
  }

  // Get user's bookings
  Stream<List<BookingModel>> getUserBookings() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get bookings by status
  Stream<List<BookingModel>> getBookingsByStatus(String status) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: status)
        .orderBy('checkIn', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get upcoming bookings
  Stream<List<BookingModel>> getUpcomingBookings() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final now = DateTime.now();

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'confirmed')
        .where('checkIn', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('checkIn')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get past bookings
  Stream<List<BookingModel>> getPastBookings() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final now = DateTime.now();

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: currentUserId)
        .where('status', whereIn: ['completed', 'cancelled'])
        .orderBy('checkIn', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Stream single booking (for real-time updates)
  Stream<BookingModel?> streamBooking(String bookingId) {
    return _firestore.collection(_collection).doc(bookingId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return BookingModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Create tour booking
  Future<String?> createTourBooking({
    required String tourId,
    required String tourName,
    required String tourImage,
    required DateTime departureDate,
    required int adults,
    required int children,
    required double unitPrice,
    required double totalPrice,
    required CustomerInfo customerInfo,
    required String paymentMethod,
    String? specialRequests,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final booking = BookingModel(
        id: '',
        userId: currentUserId!,
        userName: currentUser!.displayName ?? customerInfo.fullName,
        userEmail: currentUser!.email ?? customerInfo.email,
        userPhone: customerInfo.phone,
        bookingType: 'tour',
        itemId: tourId,
        itemName: tourName,
        itemImage: tourImage,
        checkIn: departureDate,
        checkOut: null, // Tours may not have checkout
        quantity: adults + children,
        adults: adults,
        children: children,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        discount: 0,
        discountCode: '',
        currency: 'VND',
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: paymentMethod,
        paymentId: null,
        customerInfo: customerInfo,
        metadata: {'tourId': tourId, 'departureDate': departureDate.toIso8601String()},
        specialRequests: specialRequests,
        cancellationReason: null,
        cancellationDate: null,
        refundAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createBooking(booking);
    } catch (e) {
      LoggerService.e('Error creating tour booking', error: e);
      return null;
    }
  }

  // Create accommodation booking
  Future<String?> createAccommodationBooking({
    required String accommodationId,
    required String accommodationName,
    required String accommodationImage,
    required DateTime checkIn,
    required DateTime checkOut,
    required int rooms,
    required int adults,
    required int children,
    required double unitPrice,
    required double totalPrice,
    required CustomerInfo customerInfo,
    required String paymentMethod,
    String? specialRequests,
  }) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final booking = BookingModel(
        id: '',
        userId: currentUserId!,
        userName: currentUser!.displayName ?? customerInfo.fullName,
        userEmail: currentUser!.email ?? customerInfo.email,
        userPhone: customerInfo.phone,
        bookingType: 'accommodation',
        itemId: accommodationId,
        itemName: accommodationName,
        itemImage: accommodationImage,
        checkIn: checkIn,
        checkOut: checkOut,
        quantity: rooms,
        adults: adults,
        children: children,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        discount: 0,
        discountCode: '',
        currency: 'VND',
        status: 'pending',
        paymentStatus: 'pending',
        paymentMethod: paymentMethod,
        paymentId: null,
        customerInfo: customerInfo,
        metadata: {
          'accommodationId': accommodationId,
          'nights': checkOut.difference(checkIn).inDays,
        },
        specialRequests: specialRequests,
        cancellationReason: null,
        cancellationDate: null,
        refundAmount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createBooking(booking);
    } catch (e) {
      LoggerService.e('Error creating accommodation booking', error: e);
      return null;
    }
  }

  // Auto-complete old bookings
  Future<void> autoCompleteOldBookings() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      final snapshot =
          await _firestore
              .collection(_collection)
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

  // Calculate refund amount based on cancellation policy
  double calculateRefundAmount(BookingModel booking) {
    if (booking.paymentStatus != 'paid') return 0;

    final now = DateTime.now();
    final daysUntilCheckIn = booking.checkIn.difference(now).inDays;

    // Example refund policy
    if (daysUntilCheckIn >= 7) {
      return booking.totalPrice; // 100% refund
    } else if (daysUntilCheckIn >= 3) {
      return booking.totalPrice * 0.5; // 50% refund
    } else {
      return 0; // No refund
    }
  }
}
