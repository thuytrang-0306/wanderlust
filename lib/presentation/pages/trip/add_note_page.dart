import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/presentation/controllers/trip/add_note_controller.dart';

class AddNotePage extends StatelessWidget {
  const AddNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddNoteController());
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: 32.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Ghi chú',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveNote,
            child: Text(
              'Sửa',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: TextField(
          controller: controller.noteController,
          autofocus: true,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontSize: 16.sp,
            color: const Color(0xFF111827),
            height: 1.6,
            decoration: TextDecoration.none,
          ),
          decoration: InputDecoration(
            hintText: 'Nhập ghi chú của bạn...',
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFF9CA3AF),
              height: 1.6,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            filled: false,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
          ),
          cursorColor: AppColors.primary,
          onChanged: (value) => controller.updateNote(value),
        ),
      ),
    );
  }
}