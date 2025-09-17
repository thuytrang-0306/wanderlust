import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/widgets/app_snackbar.dart';

class AddNoteController extends BaseController {
  // Text controller
  final TextEditingController noteController = TextEditingController();
  
  // Observable values
  final RxString noteText = ''.obs;
  final RxInt dayNumber = 1.obs;
  final RxBool hasChanges = false.obs;
  
  // Original note for comparison
  String originalNote = '';
  
  @override
  void onInit() {
    super.onInit();
    
    // Get day number from arguments
    if (Get.arguments != null) {
      if (Get.arguments['dayNumber'] != null) {
        dayNumber.value = Get.arguments['dayNumber'];
      }
      if (Get.arguments['existingNote'] != null) {
        originalNote = Get.arguments['existingNote'];
        noteController.text = originalNote;
        noteText.value = originalNote;
      }
    }
  }
  
  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
  
  void updateNote(String value) {
    noteText.value = value;
    hasChanges.value = value != originalNote;
  }
  
  void saveNote() {
    final note = noteController.text.trim();
    
    if (note.isEmpty) {
      AppSnackbar.showWarning(
        title: 'Thông báo',
        message: 'Ghi chú không được để trống',
      );
      return;
    }
    
    // Create note data
    final noteData = {
      'dayNumber': dayNumber.value,
      'note': note,
      'updatedAt': DateTime.now(),
    };
    
    // TODO: Save to database/repository
    
    AppSnackbar.showSuccess(
      title: 'Thành công',
      message: 'Đã lưu ghi chú',
    );
    
    // Return data to previous page
    Get.back(result: noteData);
  }
  
  // Check if there are unsaved changes
  bool onWillPop() {
    if (hasChanges.value) {
      Get.dialog(
        AlertDialog(
          title: Text(
            'Bạn có thay đổi chưa lưu',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Bạn có muốn hủy bỏ các thay đổi không?',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Tiếp tục chỉnh sửa',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Close note page
              },
              child: Text(
                'Hủy bỏ',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }
}