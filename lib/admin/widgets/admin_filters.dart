import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/admin/theme/admin_theme.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

class FilterValue {
  final String value;
  final String label;

  const FilterValue(this.value, this.label);
}

class FilterOption {
  final String key;
  final String label;
  final List<FilterValue> options;
  final String selectedValue;
  final Function(String) onChanged;

  const FilterOption({
    required this.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });
}

class AdminFilters extends StatelessWidget {
  final List<FilterOption> filters;

  const AdminFilters({
    super.key,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.map((filter) => 
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: AppSpacing.s3),
            child: _buildFilterDropdown(filter),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildFilterDropdown(FilterOption filter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AdminTheme.borderColor),
      ),
      child: DropdownButtonFormField<String>(
        value: filter.selectedValue,
        onChanged: (value) {
          if (value != null) {
            filter.onChanged(value);
          }
        },
        decoration: InputDecoration(
          labelText: filter.label,
          labelStyle: AdminTheme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s3,
            vertical: AppSpacing.s2,
          ),
        ),
        style: AdminTheme.textTheme.bodyMedium,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[600],
          size: 20.r,
        ),
        items: filter.options.map((option) => 
          DropdownMenuItem<String>(
            value: option.value,
            child: Text(
              option.label,
              style: AdminTheme.textTheme.bodyMedium,
            ),
          ),
        ).toList(),
      ),
    );
  }
}