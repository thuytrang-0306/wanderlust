import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';

class AppDateTimePicker {
  // Factory for date picker
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    DateTime selectedDate = initialDate ?? DateTime.now();
    DateTime? result;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 320.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Header with Cancel and Done buttons
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.neutral200, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: AppTypography.bodyL.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                    Text(
                      'Chọn ngày',
                      style: AppTypography.bodyL.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        result = selectedDate;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Xong',
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Date picker wheel
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 20.sp,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumDate: firstDate ?? DateTime(1900),
                      maximumDate: lastDate ?? DateTime(2100),
                      onDateTimeChanged: (DateTime newDate) {
                        selectedDate = newDate;
                      },
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  // Factory for time picker
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();
    TimeOfDay? result;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 320.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Header with Cancel and Done buttons
              Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.neutral200, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Hủy',
                        style: AppTypography.bodyL.copyWith(color: AppColors.neutral500),
                      ),
                    ),
                    Text(
                      'Chọn giờ',
                      style: AppTypography.bodyL.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        result = selectedTime;
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Xong',
                        style: AppTypography.bodyL.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Time picker wheel
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 20.sp,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: DateTime(2000, 1, 1, selectedTime.hour, selectedTime.minute),
                      use24hFormat: false,
                      onDateTimeChanged: (DateTime newTime) {
                        selectedTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
                      },
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  // Factory for datetime picker (both date and time)
  static Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // First pick date
    final date = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date == null) return null;

    // Then pick time
    final time = await showTimePicker(
      context: context,
      initialTime:
          initialDateTime != null ? TimeOfDay.fromDateTime(initialDateTime) : TimeOfDay.now(),
    );

    if (time == null) return null;

    // Combine date and time
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

// Date picker field widget that shows the picker on tap
class AppDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final Function(DateTime?) onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;
  final String dateFormat;

  const AppDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hintText,
    this.dateFormat = 'dd/MM/yyyy',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () async {
            final date = await AppDateTimePicker.showDatePicker(
              context: context,
              initialDate: value,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: value != null ? AppColors.primary : AppColors.neutral200,
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat(dateFormat).format(value!)
                        : (hintText ?? 'Chọn ngày'),
                    style: AppTypography.bodyM.copyWith(
                      color: value != null ? AppColors.neutral900 : AppColors.neutral400,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 20.sp, color: AppColors.neutral500),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
