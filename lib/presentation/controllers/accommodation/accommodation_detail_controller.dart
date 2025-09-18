import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class AccommodationDetailController extends BaseController {
  final AccommodationService _accommodationService = Get.find<AccommodationService>();
  
  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxString selectedDates = ''.obs;
  final RxInt roomCount = 1.obs;
  final RxInt guestCount = 2.obs;
  
  // Dates for booking
  final Rx<DateTime?> checkInDate = Rx<DateTime?>(null);
  final Rx<DateTime?> checkOutDate = Rx<DateTime?>(null);
  
  // Accommodation data
  final Rxn<AccommodationModel> accommodation = Rxn<AccommodationModel>();
  
  // Accommodation ID passed from arguments
  String? accommodationId;
  
  @override
  void onInit() {
    super.onInit();
    
    // Get accommodation ID from arguments
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        accommodationId = args;
      } else if (args is Map && args['accommodationId'] != null) {
        accommodationId = args['accommodationId'];
      } else if (args is Map && args['id'] != null) {
        accommodationId = args['id'];
      }
    }
    
    // Initialize dates
    _initializeDates();
    
    // Load accommodation data
    if (accommodationId != null) {
      loadAccommodationData();
    } else {
      // If no ID provided, create sample and load first one
      _createSampleAndLoad();
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
      selectedDates.value = '${formatter.format(checkInDate.value!)} - ${formatter.format(checkOutDate.value!)}';
    }
  }
  
  Future<void> _createSampleAndLoad() async {
    try {
      setLoading();
      
      // Check if there are any accommodations
      final existingAccommodations = await _accommodationService.getAllAccommodations();
      
      if (existingAccommodations.isNotEmpty) {
        // Use first existing accommodation
        accommodationId = existingAccommodations.first.id;
        await loadAccommodationData();
      } else {
        // Create a sample accommodation
        final sampleAccommodation = await _createSampleAccommodation();
        if (sampleAccommodation != null) {
          accommodationId = sampleAccommodation;
          await loadAccommodationData();
        } else {
          setError('Không thể tạo dữ liệu mẫu');
        }
      }
    } catch (e) {
      LoggerService.e('Error creating sample', error: e);
      setError('Có lỗi xảy ra');
    }
  }
  
  Future<String?> _createSampleAccommodation() async {
    final sample = AccommodationModel(
      id: '',
      name: 'Vinpearl Resort & Spa Nha Trang',
      type: 'resort',
      description: 'Khu nghỉ dưỡng 5 sao sang trọng với view biển tuyệt đẹp, hồ bơi vô cực và nhiều tiện nghi cao cấp. Phù hợp cho kỳ nghỉ gia đình hoặc nghỉ dưỡng lãng mạn.',
      address: '12 Trần Phú',
      city: 'Nha Trang',
      province: 'Khánh Hòa',
      country: 'Vietnam',
      location: const GeoPoint(12.2388, 109.1967),
      rating: 4.8,
      totalReviews: 1250,
      pricePerNight: 2500000,
      originalPrice: 3200000,
      currency: 'VND',
      images: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
      ],
      amenities: [
        'WiFi miễn phí',
        'Hồ bơi',
        'Spa & Massage',
        'Phòng Gym',
        'Nhà hàng',
        'Bar',
        'Bãi biển riêng',
        'Điều hòa',
        'Ti vi',
        'Minibar',
      ],
      roomTypes: [
        RoomType(
          id: '1',
          name: 'Deluxe Ocean View',
          description: 'Phòng rộng rãi với ban công view biển',
          maxGuests: 2,
          beds: 1,
          bedType: 'King',
          size: 45,
          pricePerNight: 2500000,
          available: 5,
          amenities: ['AC', 'TV', 'Minibar', 'Safe', 'Balcony'],
          images: [],
        ),
      ],
      policy: AccommodationPolicy.defaultPolicy(),
      hostId: 'system',
      hostName: 'Vinpearl Group',
      hostAvatar: '',
      isVerified: true,
      isFeatured: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    return await _accommodationService.createAccommodation(sample);
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
    if (accommodationId == null) return;
    
    try {
      final success = await _accommodationService.toggleFavorite(accommodationId!);
      isBookmarked.value = success;
      
      if (success) {
        AppSnackbar.showSuccess(
          message: 'Đã thêm vào danh sách yêu thích',
        );
      } else {
        AppSnackbar.showInfo(
          message: 'Đã xóa khỏi danh sách yêu thích',
        );
      }
    } catch (e) {
      LoggerService.e('Error toggling favorite', error: e);
      AppSnackbar.showError(
        message: 'Có lỗi xảy ra',
      );
    }
  }
  
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
  
  void openGallery() {
    if (accommodation.value == null) return;
    
    // Navigate to gallery with images
    Get.toNamed('/gallery', arguments: {
      'images': accommodation.value!.images,
      'title': accommodation.value!.name,
    });
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
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Get.back(result: {
            'checkIn': tempCheckIn,
            'checkOut': tempCheckOut,
          }),
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
    
    // Navigate to booking info page with real data
    Get.toNamed('/booking-info', arguments: {
      'accommodationId': accommodation.value!.id,
      'accommodationName': accommodation.value!.name,
      'accommodationType': accommodation.value!.type,
      'accommodationImage': accommodation.value!.images.isNotEmpty ? accommodation.value!.images.first : '',
      'location': accommodation.value!.fullAddress,
      'price': accommodation.value!.pricePerNight,
      'dates': selectedDates.value,
      'checkIn': checkInDate.value,
      'checkOut': checkOutDate.value,
      'rooms': roomCount.value,
      'guests': guestCount.value,
      'nights': totalNights,
      'totalPrice': totalPrice,
    });
  }
}