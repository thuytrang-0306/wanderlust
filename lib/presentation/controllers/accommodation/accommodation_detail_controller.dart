import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AccommodationDetailController extends BaseController {
  final AccommodationService _accommodationService = Get.find<AccommodationService>();
  final ListingService _listingService = Get.find<ListingService>();

  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxString selectedDates = ''.obs;
  final RxInt roomCount = 1.obs;
  final RxInt guestCount = 2.obs;

  // Dates for booking
  final Rx<DateTime?> checkInDate = Rx<DateTime?>(null);
  final Rx<DateTime?> checkOutDate = Rx<DateTime?>(null);

  // Accommodation data (can be either old accommodation or new listing)
  final Rxn<AccommodationModel> accommodation = Rxn<AccommodationModel>();
  final Rxn<ListingModel> listing = Rxn<ListingModel>();
  
  // ID passed from arguments (either accommodation or listing)
  String? accommodationId;
  String? listingId;
  
  // Track data source
  bool isListingSource = false;

  @override
  void onInit() {
    super.onInit();

    // Get ID from arguments - can be either accommodation or listing
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        // Check if it's a listing ID (from listing flow)
        if (Get.previousRoute == '/listing-detail') {
          listingId = args;
          isListingSource = true;
        } else {
          accommodationId = args;
        }
      } else if (args is Map) {
        // Check for listing ID
        if (args['listingId'] != null) {
          listingId = args['listingId'];
          isListingSource = true;
        }
        // Check for accommodation ID
        else if (args['accommodationId'] != null) {
          accommodationId = args['accommodationId'];
        } else if (args['id'] != null) {
          accommodationId = args['id'];
        }
      }
    }

    // Initialize dates
    _initializeDates();

    // Load data based on source
    if (isListingSource && listingId != null) {
      loadListingData();
    } else if (accommodationId != null) {
      loadAccommodationData();
    } else {
      // No data to load
      setError('Không có dữ liệu để hiển thị');
    }
  }

  void _initializeDates() {
    // Set default check-in to tomorrow and check-out to day after
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayAfter = DateTime.now().add(const Duration(days: 2));

    checkInDate.value = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    checkOutDate.value = DateTime(dayAfter.year, dayAfter.month, dayAfter.day);

    _updateSelectedDatesText();
  }

  void _updateSelectedDatesText() {
    if (checkInDate.value != null && checkOutDate.value != null) {
      final formatter = DateFormat('dd/MM');
      selectedDates.value =
          '${formatter.format(checkInDate.value!)} - ${formatter.format(checkOutDate.value!)}';
    }
  }


  // Load listing data (from business listing flow)
  Future<void> loadListingData() async {
    if (listingId == null) {
      setError('Không có ID listing');
      return;
    }

    try {
      setLoading();

      // Load listing from Firestore
      final listingData = await _listingService.getListingById(listingId!);

      if (listingData != null) {
        listing.value = listingData;

        // Convert listing to accommodation-like data for UI compatibility
        _convertListingToAccommodation(listingData);

        // Check if favorited
        isBookmarked.value = await _listingService.isFavorited(listingId!);

        setSuccess();
      } else {
        setError('Không tìm thấy thông tin');
      }
    } catch (e) {
      LoggerService.e('Error loading listing', error: e);
      setError('Có lỗi xảy ra khi tải dữ liệu');
    }
  }
  
  // Helper method to convert ListingModel to AccommodationModel-like structure
  void _convertListingToAccommodation(ListingModel listingData) {
    // Create a temporary accommodation model for UI compatibility
    accommodation.value = AccommodationModel(
      id: listingData.id,
      name: listingData.title,
      type: listingData.type == ListingType.room ? 'hotel' : 'other',
      description: listingData.description,
      address: listingData.details['address'] ?? '',
      city: listingData.details['city'] ?? '',
      province: listingData.details['province'] ?? '',
      country: 'Vietnam',
      location: const GeoPoint(0, 0),
      rating: listingData.rating,
      totalReviews: listingData.reviews,
      pricePerNight: listingData.hasDiscount ? listingData.discountPrice! : listingData.price,
      originalPrice: listingData.price,
      currency: 'VND',
      images: listingData.images,
      amenities: (listingData.details['amenities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      roomTypes: [],
      policy: AccommodationPolicy.defaultPolicy(),
      hostId: listingData.businessId,
      hostName: listingData.businessName,
      hostAvatar: '',
      isVerified: listingData.isActive,
      isFeatured: listingData.views > 100,
      createdAt: listingData.createdAt,
      updatedAt: listingData.updatedAt,
    );
  }

  Future<void> loadAccommodationData() async {
    if (accommodationId == null) {
      setError('Không có ID chỗ ở');
      return;
    }

    try {
      setLoading();

      // Load accommodation from Firestore
      final acc = await _accommodationService.getAccommodation(accommodationId!);

      if (acc != null) {
        accommodation.value = acc;

        // Check if favorited
        isBookmarked.value = await _accommodationService.isFavorited(accommodationId!);

        setSuccess();
      } else {
        setError('Không tìm thấy thông tin chỗ ở');
      }
    } catch (e) {
      LoggerService.e('Error loading accommodation', error: e);
      setError('Có lỗi xảy ra khi tải dữ liệu');
    }
  }

  Future<void> toggleBookmark() async {
    try {
      bool success;

      // Use listing service if from listing flow, otherwise use accommodation service
      if (isListingSource && listingId != null) {
        success = await _listingService.toggleFavorite(listingId!);
      } else if (accommodationId != null) {
        success = await _accommodationService.toggleFavorite(accommodationId!);
      } else {
        LoggerService.w('No ID available to toggle bookmark');
        return;
      }

      isBookmarked.value = success;

      if (success) {
        AppSnackbar.showSuccess(message: 'Đã thêm vào danh sách yêu thích');
      } else {
        AppSnackbar.showInfo(message: 'Đã xóa khỏi danh sách yêu thích');
      }
    } catch (e) {
      LoggerService.e('Error toggling favorite', error: e);
      AppSnackbar.showError(message: 'Có lỗi xảy ra');
    }
  }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void openGallery() {
    if (accommodation.value == null) return;

    // Navigate to gallery with images
    Get.toNamed(
      '/gallery',
      arguments: {'images': accommodation.value!.images, 'title': accommodation.value!.name},
    );
  }

  Future<void> selectDates() async {
    final result = await Get.dialog<Map<String, DateTime>>(
      _buildDatePickerDialog(),
      barrierDismissible: false,
    );

    if (result != null) {
      checkInDate.value = result['checkIn'];
      checkOutDate.value = result['checkOut'];
      _updateSelectedDatesText();
    }
  }

  Widget _buildDatePickerDialog() {
    // Simple date picker dialog
    DateTime tempCheckIn = checkInDate.value ?? DateTime.now().add(const Duration(days: 1));
    DateTime tempCheckOut = checkOutDate.value ?? DateTime.now().add(const Duration(days: 2));

    return AlertDialog(
      title: const Text('Chọn ngày'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Ngày nhận phòng'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(tempCheckIn)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              // In real app, use date picker
            },
          ),
          ListTile(
            title: const Text('Ngày trả phòng'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(tempCheckOut)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              // In real app, use date picker
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
        TextButton(
          onPressed: () => Get.back(result: {'checkIn': tempCheckIn, 'checkOut': tempCheckOut}),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }

  void updateRoomCount(int count) {
    if (count > 0 && count <= 10) {
      roomCount.value = count;
    }
  }

  void updateGuestCount(int count) {
    if (count > 0 && count <= 20) {
      guestCount.value = count;
    }
  }

  int get totalNights {
    if (checkInDate.value != null && checkOutDate.value != null) {
      return checkOutDate.value!.difference(checkInDate.value!).inDays;
    }
    return 1;
  }

  double get totalPrice {
    if (accommodation.value != null) {
      return accommodation.value!.pricePerNight * roomCount.value * totalNights;
    }
    return 0;
  }

  void bookRoom() {
    if (accommodation.value == null) return;

    // Navigate to booking info page with data from either source
    if (isListingSource && listing.value != null) {
      // Use listing data
      Get.toNamed(
        '/booking-info',
        arguments: {
          'listingId': listing.value!.id,
          'listingType': listing.value!.type.value,
          'accommodationId': listing.value!.id,
          'accommodationName': listing.value!.title,
          'accommodationType': 'listing',
          'accommodationImage':
              listing.value!.images.isNotEmpty ? listing.value!.images.first : '',
          'location': '${listing.value!.details['address'] ?? ''}, ${listing.value!.details['city'] ?? ''}',
          'price': listing.value!.hasDiscount ? listing.value!.discountPrice! : listing.value!.price,
          'dates': selectedDates.value,
          'checkIn': checkInDate.value,
          'checkOut': checkOutDate.value,
          'rooms': roomCount.value,
          'guests': guestCount.value,
          'nights': totalNights,
          'totalPrice': totalPrice,
          'businessId': listing.value!.businessId,
          'businessName': listing.value!.businessName,
        },
      );
    } else {
      // Use accommodation data
      Get.toNamed(
        '/booking-info',
        arguments: {
          'accommodationId': accommodation.value!.id,
          'accommodationName': accommodation.value!.name,
          'accommodationType': accommodation.value!.type,
          'accommodationImage':
              accommodation.value!.images.isNotEmpty ? accommodation.value!.images.first : '',
          'location': accommodation.value!.fullAddress,
          'price': accommodation.value!.pricePerNight,
          'dates': selectedDates.value,
          'checkIn': checkInDate.value,
          'checkOut': checkOutDate.value,
          'rooms': roomCount.value,
          'guests': guestCount.value,
          'nights': totalNights,
          'totalPrice': totalPrice,
        },
      );
    }
  }
}
