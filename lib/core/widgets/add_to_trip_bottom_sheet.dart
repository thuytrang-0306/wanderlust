import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/models/trip_model.dart';
import 'package:wanderlust/data/services/trip_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

/// Bottom sheet to select trip and day for adding a listing
class AddToTripBottomSheet extends StatefulWidget {
  final ListingModel listing;

  const AddToTripBottomSheet({
    super.key,
    required this.listing,
  });

  static Future<Map<String, dynamic>?> show({
    required BuildContext context,
    required ListingModel listing,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToTripBottomSheet(listing: listing),
    );
  }

  @override
  State<AddToTripBottomSheet> createState() => _AddToTripBottomSheetState();
}

class _AddToTripBottomSheetState extends State<AddToTripBottomSheet> {
  final TripService _tripService = Get.find<TripService>();

  bool isLoading = true;
  List<TripModel> trips = [];
  TripModel? selectedTrip;
  int? selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      setState(() => isLoading = true);
      final userTrips = await _tripService.getUserTrips();

      // Show ALL trips - user can add to any trip for planning
      setState(() {
        trips = userTrips;
        isLoading = false;
      });

      LoggerService.i('Loaded ${trips.length} trips');
    } catch (e) {
      LoggerService.e('Error loading trips', error: e);
      setState(() => isLoading = false);
    }
  }

  void _selectTrip(TripModel trip) {
    setState(() {
      selectedTrip = trip;
      selectedDayIndex = null; // Reset day selection
    });
  }

  void _selectDay(int dayIndex) {
    setState(() {
      selectedDayIndex = dayIndex;
    });
  }

  void _confirm() {
    if (selectedTrip != null && selectedDayIndex != null) {
      Navigator.pop(context, {
        'tripId': selectedTrip!.id,
        'tripName': selectedTrip!.title,
        'dayIndex': selectedDayIndex!,
        'listing': widget.listing,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedTrip == null
                          ? 'Chọn chuyến đi'
                          : 'Chọn ngày',
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selectedTrip != null)
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 24.sp),
                      onPressed: () {
                        setState(() {
                          selectedTrip = null;
                          selectedDayIndex = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(height: 1.h),

            // Content
            Flexible(
              child: isLoading
                  ? _buildLoading()
                  : selectedTrip == null
                      ? _buildTripList()
                      : _buildDayList(),
            ),

            // Confirm button (show when day selected)
            if (selectedDayIndex != null) ...[
              Divider(height: 1.h),
              Padding(
                padding: EdgeInsets.all(AppSpacing.s4),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Xác nhận thêm vào kế hoạch',
                      style: AppTypography.bodyM.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s8),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildTripList() {
    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 48.sp, color: AppColors.neutral400),
              SizedBox(height: AppSpacing.s3),
              Text(
                'Chưa có chuyến đi nào',
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              SizedBox(height: AppSpacing.s2),
              Text(
                'Tạo kế hoạch để thêm địa điểm',
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.all(AppSpacing.s4),
      itemCount: trips.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.s3),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripItem(trip);
      },
    );
  }

  Widget _buildTripItem(TripModel trip) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final dateRange = '${formatter.format(trip.startDate)} - ${formatter.format(trip.endDate)}';

    return InkWell(
      onTap: () => _selectTrip(trip),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.luggage,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: AppSpacing.s3),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    dateRange,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${trip.duration} ngày • ${trip.travelers.length} người',
                    style: AppTypography.bodyXS.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }

  Widget _buildDayList() {
    if (selectedTrip == null) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.all(AppSpacing.s4),
      itemCount: selectedTrip!.duration,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.s3),
      itemBuilder: (context, index) {
        return _buildDayItem(index);
      },
    );
  }

  Widget _buildDayItem(int dayIndex) {
    if (selectedTrip == null) return const SizedBox.shrink();

    final isSelected = selectedDayIndex == dayIndex;
    final dayDate = selectedTrip!.startDate.add(Duration(days: dayIndex));
    final DateFormat formatter = DateFormat('E, dd/MM', 'vi_VN');

    return InkWell(
      onTap: () => _selectDay(dayIndex),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.s3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Day number
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.neutral200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  'Ngày\n${dayIndex + 1}',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyXS.copyWith(
                    color: isSelected ? Colors.white : AppColors.neutral700,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s3),

            // Date info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatter.format(dayDate),
                    style: AppTypography.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.neutral900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Thêm vào lịch trình ngày này',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
