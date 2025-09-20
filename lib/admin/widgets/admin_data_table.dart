import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/admin/theme/admin_theme.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class AdminDataTable<T> extends StatelessWidget {
  final List<T> data;
  final List<DataColumn> columns;
  final DataRow Function(T item) buildRow;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool)? onSort;

  const AdminDataTable({
    super.key,
    required this.data,
    required this.columns,
    required this.buildRow,
    this.isLoading = false,
    this.onRefresh,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: Column(
        children: [
          if (isLoading) _buildLoadingIndicator(),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: columns,
                rows: data.map((item) => buildRow(item)).toList(),
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                showCheckboxColumn: false,
                columnSpacing: AppSpacing.s4.toDouble(),
                horizontalMargin: AppSpacing.s6.toDouble(),
                dataRowMinHeight: 60.h,
                dataRowMaxHeight: 80.h,
                headingRowHeight: 56.h,
                headingTextStyle: AdminTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                dataTextStyle: AdminTheme.textTheme.bodyMedium,
                border: TableBorder.all(
                  color: AdminTheme.borderColor,
                  width: 1,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          if (data.isEmpty && !isLoading) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s4),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.primaryColor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSpacing.s3),
          Text(
            'No data available',
            style: AdminTheme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppSpacing.s2),
          if (onRefresh != null)
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
        ],
      ),
    );
  }
}