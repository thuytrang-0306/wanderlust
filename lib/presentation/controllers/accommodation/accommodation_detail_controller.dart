import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/widgets/add_to_trip_bottom_sheet.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AccommodationDetailController extends BaseController {
  final AccommodationService _accommodationService = Get.find<AccommodationService>();
  final ListingService _listingService = Get.find<ListingService>();
  final TripService _tripService = Get.find<TripService>();

  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxString selectedDates = ''.obs;
  final RxInt roomCount = 1.obs;
  final RxInt guestCount = 2.obs;
  final RxInt quantity = 1.obs; // For Food/Service

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

        // ✅ OPTIMISTIC LOADING: Check if full listing object was passed
        final passedListing = args['listing'];
        if (passedListing != null && passedListing is ListingModel) {
          // Use the passed data immediately - NO LOADING SPINNER!
          listing.value = passedListing;
          _convertListingToAccommodation(passedListing);
          isListingSource = true;
          listingId = passedListing.id;

          // Check if favorited
          _listingService.isFavorited(listingId!).then((isFav) {
            isBookmarked.value = isFav;
          });

          // Mark as success immediately
          setSuccess();

          // Background refresh to sync latest data (non-blocking)
          Future.microtask(() => loadListingData());

          // Initialize dates and skip the regular loading flow
          _initializeDates();
          return;
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
      // Only show loading if we don't already have data (optimistic loading)
      final shouldShowLoading = listing.value == null;
      if (shouldShowLoading) {
        setLoading();
      }

      // Load listing from Firestore with cache-first + background refresh
      final listingData = await _listingService.getListingById(
        listingId!,
        onRefresh: (freshListing) {
          if (freshListing != null) {
            // Update with fresh data from server in background
            listing.value = freshListing;
            _convertListingToAccommodation(freshListing);
            LoggerService.d('📱 Listing Detail: Refreshed with fresh data from server');
          }
        },
      );

      if (listingData != null) {
        listing.value = listingData;

        // Convert listing to accommodation-like data for UI compatibility
        _convertListingToAccommodation(listingData);

        // Check if favorited (only if we showed loading)
        if (shouldShowLoading) {
          isBookmarked.value = await _listingService.isFavorited(listingId!);
        } else {
          // Update in background
          _listingService.isFavorited(listingId!).then((isFav) {
            isBookmarked.value = isFav;
          });
        }

        setSuccess();
      } else if (shouldShowLoading) {
        setError('Không tìm thấy thông tin');
      }
    } catch (e) {
      LoggerService.e('Error loading listing', error: e);
      if (listing.value == null) {
        // Only show error if we don't have cached data
        setError('Có lỗi xảy ra khi tải dữ liệu');
      } else {
        // Silently fail if we already have data
        LoggerService.w('Background refresh failed, using cached data');
      }
    }
  }
  
  // Helper method to convert ListingModel to AccommodationModel-like structure
  void _convertListingToAccommodation(ListingModel listingData) {
    // Build location smartly - only join non-empty parts
    final address = listingData.details['address']?.toString() ?? '';
    final city = listingData.details['city']?.toString() ?? '';
    final province = listingData.details['province']?.toString() ?? '';

    final List<String> locationParts = [];
    if (address.isNotEmpty) locationParts.add(address);
    if (city.isNotEmpty) locationParts.add(city);
    if (province.isNotEmpty) locationParts.add(province);

    final fullAddressText = locationParts.isNotEmpty ? locationParts.join(', ') : '';

    // Create a temporary accommodation model for UI compatibility
    accommodation.value = AccommodationModel(
      id: listingData.id,
      name: listingData.title,
      type: listingData.type == ListingType.room ? 'hotel' : 'other',
      description: listingData.description,
      address: fullAddressText,
      city: city,
      province: province,
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

  // Add listing to trip plan
  Future<void> addToTrip() async {
    try {
      // Check if listing data is available
      if (listing.value == null) {
        AppSnackbar.showError(message: 'Không có dữ liệu dịch vụ');
        return;
      }

      // Show bottom sheet to select trip and day
      final result = await AddToTripBottomSheet.show(
        context: Get.context!,
        listing: listing.value!,
      );

      if (result != null) {
        // Convert listing model to map for TripService
        final listingData = {
          'id': listing.value!.id,
          'title': listing.value!.title,
          'location': listing.value!.businessName, // Use business name as location
          'images': listing.value!.images,
          'businessName': listing.value!.businessName,
          'price': listing.value!.price,
          'type': listing.value!.type.toString().split('.').last,
        };

        // Add listing to selected trip day
        final success = await _tripService.addListingToTripDay(
          tripId: result['tripId'],
          dayIndex: result['dayIndex'],
          listingData: listingData,
        );

        if (success) {
          AppSnackbar.showSuccess(
            title: 'Thành công',
            message: 'Đã thêm vào ${result['tripName']} - Ngày ${result['dayIndex'] + 1}',
          );
          LoggerService.i('Listing added to trip: ${result['tripId']} day ${result['dayIndex']}');
        } else {
          AppSnackbar.showError(
            title: 'Lỗi',
            message: 'Không thể thêm vào kế hoạch',
          );
        }
      }
    } catch (e) {
      LoggerService.e('Error adding to trip', error: e);
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
    // Pick check-in date
    final checkIn = await showDatePicker(
      context: Get.context!,
      initialDate: checkInDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF9455FD),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (checkIn == null) return;

    // Pick check-out date (must be after check-in)
    final checkOut = await showDatePicker(
      context: Get.context!,
      initialDate: checkIn.add(const Duration(days: 1)),
      firstDate: checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF9455FD),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (checkOut == null) return;

    // Update dates
    checkInDate.value = checkIn;
    checkOutDate.value = checkOut;
    _updateSelectedDatesText();
  }

  void incrementRoomCount() {
    if (roomCount.value < 10) {
      roomCount.value++;
    }
  }

  void decrementRoomCount() {
    if (roomCount.value > 1) {
      roomCount.value--;
    }
  }

  void incrementGuestCount() {
    if (guestCount.value < 20) {
      guestCount.value++;
    }
  }

  void decrementGuestCount() {
    if (guestCount.value > 1) {
      guestCount.value--;
    }
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

  void incrementQuantity() {
    if (quantity.value < 99) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  void updateQuantity(int count) {
    if (count > 0 && count <= 99) {
      quantity.value = count;
    }
  }

  int get totalNights {
    if (checkInDate.value != null && checkOutDate.value != null) {
      return checkOutDate.value!.difference(checkInDate.value!).inDays;
    }
    return 1;
  }

  // Dynamic computed properties based on listing type
  ListingType? get listingType => listing.value?.type;

  bool get isRoomType => listingType == ListingType.room;
  bool get isTourType => listingType == ListingType.tour;
  bool get isFoodType => listingType == ListingType.food;
  bool get isServiceType => listingType == ListingType.service;

  // UI Text based on type
  String get bookingButtonText {
    switch (listingType) {
      case ListingType.room: return 'Đặt phòng';
      case ListingType.tour: return 'Đặt tour';
      case ListingType.food: return 'Đặt món';
      case ListingType.service: return 'Đặt dịch vụ';
      default: return 'Đặt ngay';
    }
  }

  String get priceUnit {
    if (isListingSource && listing.value != null) {
      return listing.value!.priceUnit;
    }
    return '/đêm';
  }

  // Correct total price calculation based on listing type
  double get totalPrice {
    if (accommodation.value == null) return 0;

    final basePrice = accommodation.value!.pricePerNight;

    if (!isListingSource) {
      // Old accommodation model - always room type
      return basePrice * roomCount.value * totalNights;
    }

    // New listing model - calculate based on type
    switch (listingType) {
      case ListingType.room:
        return basePrice * roomCount.value * totalNights;
      case ListingType.tour:
        return basePrice * guestCount.value;
      case ListingType.food:
        return basePrice * quantity.value;
      case ListingType.service:
        return basePrice * quantity.value;
      default:
        return basePrice;
    }
  }

  // Price breakdown for display
  String get priceBreakdown {
    if (accommodation.value == null) return '';

    final basePrice = accommodation.value!.pricePerNight;
    final formatter = NumberFormat('#,###', 'vi_VN');

    if (!isListingSource) {
      // Old accommodation - room type
      return '${formatter.format(basePrice)} VNĐ x ${roomCount.value} phòng x $totalNights đêm';
    }

    // New listing - dynamic breakdown
    switch (listingType) {
      case ListingType.room:
        return '${formatter.format(basePrice)} VNĐ x ${roomCount.value} phòng x $totalNights đêm';
      case ListingType.tour:
        return '${formatter.format(basePrice)} VNĐ x ${guestCount.value} người';
      case ListingType.food:
        return '${formatter.format(basePrice)} VNĐ x ${quantity.value} phần';
      case ListingType.service:
        return '${formatter.format(basePrice)} VNĐ x ${quantity.value} lần';
      default:
        return '${formatter.format(basePrice)} VNĐ';
    }
  }

  String get totalPriceFormatted {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(totalPrice)} VNĐ';
  }

  void bookRoom() {
    if (accommodation.value == null) return;

    // Navigate to booking info page with data from either source
    if (isListingSource && listing.value != null) {
      // Use listing data - dynamic arguments based on type
      final baseArgs = {
        'listingId': listing.value!.id,
        'listingType': listing.value!.type.value,
        'accommodationId': listing.value!.id,
        'accommodationName': listing.value!.title,
        'accommodationType': 'listing',
        'accommodationImage':
            listing.value!.images.isNotEmpty ? listing.value!.images.first : '',
        'location': '${listing.value!.details['address'] ?? ''}, ${listing.value!.details['city'] ?? ''}',
        'price': listing.value!.hasDiscount ? listing.value!.discountPrice! : listing.value!.price,
        'priceUnit': listing.value!.priceUnit,
        'totalPrice': totalPrice,
        'priceBreakdown': priceBreakdown,
        'businessId': listing.value!.businessId,
        'businessName': listing.value!.businessName,
        // Pass listing details - include type-specific fields
        'listingDetails': _buildListingDetails(),
      };

      // Add type-specific fields
      switch (listingType) {
        case ListingType.room:
          if (checkInDate.value != null && checkOutDate.value != null) {
            baseArgs.addAll({
              'dates': selectedDates.value,
              'checkIn': checkInDate.value!,
              'checkOut': checkOutDate.value!,
              'rooms': roomCount.value,
              'guests': guestCount.value,
              'nights': totalNights,
            });
          }
          break;
        case ListingType.tour:
          if (checkInDate.value != null) {
            baseArgs.addAll({
              'dates': selectedDates.value,
              'departureDate': checkInDate.value!,
              'guests': guestCount.value,
            });
          }
          break;
        case ListingType.food:
          if (checkInDate.value != null) {
            baseArgs.addAll({
              'quantity': quantity.value,
              'deliveryTime': checkInDate.value!,
            });
          }
          break;
        case ListingType.service:
          if (checkInDate.value != null) {
            baseArgs.addAll({
              'quantity': quantity.value,
              'appointmentDate': checkInDate.value!,
            });
          }
          break;
        default:
          break;
      }

      Get.toNamed('/booking-info', arguments: baseArgs);
    } else {
      // Use accommodation data (old model - always room type)
      if (checkInDate.value != null && checkOutDate.value != null) {
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
            'priceUnit': '/đêm',
            'dates': selectedDates.value,
            'checkIn': checkInDate.value!,
            'checkOut': checkOutDate.value!,
            'rooms': roomCount.value,
            'guests': guestCount.value,
            'nights': totalNights,
            'totalPrice': totalPrice,
            'priceBreakdown': priceBreakdown,
          },
        );
      }
    }
  }

  /// Build type-specific listing details to pass to BookingInfoPage
  Map<String, dynamic> _buildListingDetails() {
    if (listing.value == null) return {};

    final details = listing.value!.details;
    final Map<String, dynamic> listingDetails = {
      'cancellationPolicy': details['cancellationPolicy'],
    };

    // Add type-specific fields based on listing type
    switch (listingType) {
      case ListingType.room:
        listingDetails.addAll({
          'roomSize': details['roomSize'] ?? '25m²',
          'bedType': details['bedType'] ?? '1 giường đơn',
          'maxGuests': details['maxGuests'],
          'numberOfBeds': details['numberOfBeds'],
        });
        break;

      case ListingType.tour:
        listingDetails.addAll({
          'duration': details['duration'],
          'departure': details['departure'],
          'includeTransport': details['includeTransport'],
          'includeMeals': details['includeMeals'],
          'includeGuide': details['includeGuide'],
          'groupSize': details['groupSize'],
        });
        break;

      case ListingType.food:
        listingDetails.addAll({
          'category': details['category'],
          'serving': details['serving'],
          'isVegetarian': details['isVegetarian'],
          'isSpicy': details['isSpicy'],
          'prepTime': details['prepTime'],
        });
        break;

      case ListingType.service:
        listingDetails.addAll({
          'duration': details['duration'],
          'location': details['location'],
        });
        break;

      default:
        break;
    }

    return listingDetails;
  }
}
