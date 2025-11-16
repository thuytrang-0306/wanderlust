import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wanderlust/data/models/booking_model.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/core/services/connectivity_service.dart';
import 'package:wanderlust/shared/core/services/notification_service.dart';
import 'package:wanderlust/shared/data/models/notification_model.dart';

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
    return await ConnectivityService.to.executeWithConnectivity<String?>(
      () async {
        if (currentUserId == null) {
          throw Exception('User not authenticated');
        }

        final docRef = await _firestore.collection(_collection).add(booking.toFirestore());

        LoggerService.i('Booking created successfully: ${docRef.id}');
        return docRef.id;
      },
      errorMessage: 'Unable to create booking without internet connection',
    );
  }

  // Update booking
  Future<bool> updateBooking(String bookingId, Map<String, dynamic> data) async {
    final result = await ConnectivityService.to.executeWithConnectivity<bool>(
      () async {
        data['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection(_collection).doc(bookingId).update(data);
        LoggerService.i('Booking updated successfully: $bookingId');
        return true;
      },
      errorMessage: 'Unable to update booking without internet connection',
    );
    return result ?? false;
  }

  // Confirm booking
  Future<bool> confirmBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': 'confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send booking confirmation notification
      _sendBookingConfirmationNotification(bookingId);

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

      // Send booking cancellation notification
      _sendBookingCancellationNotification(bookingId, reason);

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

      // Send payment confirmation notification
      _sendPaymentConfirmationNotification(bookingId, paymentId);

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

      // Get business ID from arguments if available
      final businessId = Get.arguments?['businessId'] as String?;
      
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
          'businessId': businessId ?? '',
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

  // Get bookings for business owner
  Stream<List<BookingModel>> getBusinessBookings(String businessId) {
    return _firestore
        .collection(_collection)
        .where('metadata.businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
  }

  // Get bookings for a specific listing
  Stream<List<BookingModel>> getListingBookings(String listingId) {
    return _firestore
        .collection(_collection)
        .where('itemId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc.data(), doc.id))
              .toList();
        });
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

  // ============ NOTIFICATION HELPERS ============

  /// Send booking confirmation notification (non-blocking)
  void _sendBookingConfirmationNotification(String bookingId) async {
    try {
      // Get booking data
      final booking = await getBooking(bookingId);
      if (booking == null) return;

      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.sendBookingConfirmationNotification(
          userId: booking.userId,
          bookingId: bookingId,
          serviceName: booking.itemName,
          checkInDate: booking.checkIn,
        );
        LoggerService.d('Booking confirmation notification sent for: ${booking.itemName}');
      }
    } catch (e) {
      LoggerService.w('Failed to send booking confirmation notification', error: e);
    }
  }

  /// Send booking cancellation notification (non-blocking)
  void _sendBookingCancellationNotification(String bookingId, String reason) async {
    try {
      // Get booking data
      final booking = await getBooking(bookingId);
      if (booking == null) return;

      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.createNotification(
          recipientId: booking.userId,
          title: 'Đặt chỗ đã bị hủy ❌',
          body: 'Booking cho "${booking.itemName}" đã bị hủy: $reason',
          type: NotificationType.bookingCancelled,
          priority: NotificationPriority.high,
          actionUrl: '/bookings/$bookingId',
          metadata: {
            'bookingId': bookingId,
            'serviceName': booking.itemName,
            'cancellationReason': reason,
            'refundAmount': calculateRefundAmount(booking),
          },
        );
        LoggerService.d('Booking cancellation notification sent for: ${booking.itemName}');
      }
    } catch (e) {
      LoggerService.w('Failed to send booking cancellation notification', error: e);
    }
  }

  /// Send payment confirmation notification (non-blocking)
  void _sendPaymentConfirmationNotification(String bookingId, String paymentId) async {
    try {
      // Get booking data
      final booking = await getBooking(bookingId);
      if (booking == null) return;

      if (Get.isRegistered<NotificationService>()) {
        NotificationService.to.createNotification(
          recipientId: booking.userId,
          title: 'Thanh toán thành công! 💳',
          body: 'Thanh toán cho "${booking.itemName}" đã được xử lý. Mã giao dịch: $paymentId',
          type: NotificationType.paymentConfirmed,
          priority: NotificationPriority.high,
          actionUrl: '/bookings/$bookingId',
          metadata: {
            'bookingId': bookingId,
            'serviceName': booking.itemName,
            'paymentId': paymentId,
            'amount': booking.totalPrice,
            'currency': booking.currency,
          },
        );
        LoggerService.d('Payment confirmation notification sent for: ${booking.itemName}');
      }
    } catch (e) {
      LoggerService.w('Failed to send payment confirmation notification', error: e);
    }
  }

  /// Send booking reminder notification (for upcoming bookings)
  Future<void> sendBookingReminder(String bookingId) async {
    try {
      final booking = await getBooking(bookingId);
      if (booking == null) return;

      // Check if booking is upcoming (1-3 days from now)
      final now = DateTime.now();
      final daysUntilCheckIn = booking.checkIn.difference(now).inDays;
      
      if (daysUntilCheckIn > 0 && daysUntilCheckIn <= 3) {
        if (Get.isRegistered<NotificationService>()) {
          NotificationService.to.createNotification(
            recipientId: booking.userId,
            title: 'Nhắc nhở booking sắp tới! ⏰',
            body: 'Booking cho "${booking.itemName}" sẽ bắt đầu trong $daysUntilCheckIn ngày nữa.',
            type: NotificationType.bookingReminder,
            priority: NotificationPriority.normal,
            actionUrl: '/bookings/$bookingId',
            metadata: {
              'bookingId': bookingId,
              'serviceName': booking.itemName,
              'checkInDate': booking.checkIn.toIso8601String(),
              'daysUntil': daysUntilCheckIn,
            },
          );
          LoggerService.d('Booking reminder notification sent for: ${booking.itemName}');
        }
      }
    } catch (e) {
      LoggerService.w('Failed to send booking reminder notification', error: e);
    }
  }
}
