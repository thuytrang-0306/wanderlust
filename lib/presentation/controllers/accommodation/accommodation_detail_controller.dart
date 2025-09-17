import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';

class AccommodationDetailController extends BaseController {
  // Observable values
  final RxBool isBookmarked = false.obs;
  final RxBool isDescriptionExpanded = false.obs;
  final RxString selectedDates = '1 tháng 1 - 2 tháng 1'.obs;
  final RxInt roomCount = 1.obs;
  final RxInt guestCount = 1.obs;
  
  // Accommodation data
  final RxMap<String, dynamic> accommodationData = <String, dynamic>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadAccommodationData();
  }
  
  void loadAccommodationData() {
    // Mock data - in real app, load from API/database
    accommodationData.value = {
      'id': '1',
      'name': 'Homestay Sơn Thủy',
      'location': 'Mèo Vạc, Hà Giang',
      'rating': 4.8,
      'price': 480000,
      'currency': 'VND',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas id sit eu tellus sed cursus eleifend id porta. Lorem adipiscing mus vestibulum consequat porta eu ultrices feugiat. Et, faucibus ut amet turpis.',
      'amenities': [
        'Wifi miễn phí',
        'Ti vi',
        'Bể bơi', 
        'Điều hòa',
        'Bữa sáng',
        'Bãi đỗ xe',
      ],
      'images': [
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      ],
    };
  }
  
  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    if (isBookmarked.value) {
      Get.snackbar(
        'Đã lưu',
        'Homestay đã được thêm vào danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }
  
  void openGallery() {
    // TODO: Navigate to gallery page
    Get.snackbar(
      'Xem ảnh',
      'Mở gallery với tất cả ảnh',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void selectDates() {
    // TODO: Open date picker
    Get.snackbar(
      'Chọn ngày',
      'Mở date picker',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  void updateRoomCount(int count) {
    if (count > 0) {
      roomCount.value = count;
    }
  }
  
  void updateGuestCount(int count) {
    if (count > 0) {
      guestCount.value = count;
    }
  }
  
  void bookRoom() {
    // Navigate to payment page
    Get.toNamed('/payment', arguments: {
      'accommodationId': accommodationData['id'],
      'accommodationName': accommodationData['name'],
      'price': accommodationData['price'],
      'dates': selectedDates.value,
      'rooms': roomCount.value,
      'guests': guestCount.value,
    });
  }
}