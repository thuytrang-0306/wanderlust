import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/admin/services/admin_business_service.dart';
import 'package:wanderlust/shared/data/models/business_profile_model.dart';
import 'package:wanderlust/shared/core/utils/logger_service.dart';
import 'package:wanderlust/shared/core/widgets/app_snackbar.dart';

class BusinessStats {
  final int totalBusinesses;
  final int pendingVerification;
  final int verifiedBusinesses;
  final int rejectedBusinesses;
  final int newToday;

  BusinessStats({
    this.totalBusinesses = 0,
    this.pendingVerification = 0,
    this.verifiedBusinesses = 0,
    this.rejectedBusinesses = 0,
    this.newToday = 0,
  });
}

class AdminBusinessController extends GetxController {
  final AdminBusinessService _businessService = Get.find<AdminBusinessService>();

  // UI State
  final RxBool isLoading = false.obs;
  final RxList<BusinessProfileModel> businesses = <BusinessProfileModel>[].obs;
  final RxList<BusinessProfileModel> allBusinesses = <BusinessProfileModel>[].obs;
  final Rx<BusinessStats> businessStats = BusinessStats().obs;

  // Search and Filters
  final TextEditingController searchController = TextEditingController();
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedType = 'all'.obs;
  final RxString selectedDateRange = 'all'.obs;

  // Selection
  final RxSet<String> selectedBusinesses = <String>{}.obs;

  // Current business for details view
  final Rxn<BusinessProfileModel> selectedBusiness = Rxn<BusinessProfileModel>();
  final RxList<Map<String, dynamic>> businessHistory = <Map<String, dynamic>>[].obs;

  // Verification form
  final TextEditingController verificationNotesController = TextEditingController();
  final TextEditingController rejectionReasonController = TextEditingController();
  final TextEditingController suspensionReasonController = TextEditingController();

  // Computed properties
  bool get isAllSelected => selectedBusinesses.length == businesses.length && businesses.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    loadBusinesses();
  }

  @override
  void onClose() {
    searchController.dispose();
    verificationNotesController.dispose();
    rejectionReasonController.dispose();
    suspensionReasonController.dispose();
    super.onClose();
  }

  void _setupListeners() {
    // Listen to real-time business changes
    ever(_businessService.allBusinesses, (businessList) {
      allBusinesses.value = businessList as List<BusinessProfileModel>;
      _updateStats();
      _applyFilters();
      LoggerService.i('Real-time business update: ${businessList.length} businesses');
    });
  }

  Future<void> loadBusinesses() async {
    try {
      isLoading.value = true;
      
      // Load businesses via service
      await _businessService.loadAllBusinesses();
      allBusinesses.value = _businessService.allBusinesses;
      
      _updateStats();
      _applyFilters();
      
      LoggerService.i('Loaded ${allBusinesses.length} businesses successfully');
    } catch (e) {
      LoggerService.e('Error loading businesses', error: e);
      AppSnackbar.showError(message: 'Failed to load businesses');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStats() {
    final total = allBusinesses.length;
    final pending = allBusinesses.where((b) => 
        b.verificationStatus == VerificationStatus.pending).length;
    final verified = allBusinesses.where((b) => 
        b.verificationStatus == VerificationStatus.verified).length;
    final rejected = allBusinesses.where((b) => 
        b.verificationStatus == VerificationStatus.rejected).length;
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final newToday = allBusinesses.where((b) => 
        b.createdAt.isAfter(startOfDay)).length;
    
    businessStats.value = BusinessStats(
      totalBusinesses: total,
      pendingVerification: pending,
      verifiedBusinesses: verified,
      rejectedBusinesses: rejected,
      newToday: newToday,
    );
  }

  void _applyFilters() {
    var filteredBusinesses = List<BusinessProfileModel>.from(allBusinesses);

    // Apply search filter
    final searchQuery = searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filteredBusinesses = filteredBusinesses.where((business) {
        return business.businessName.toLowerCase().contains(searchQuery) ||
               business.businessEmail.toLowerCase().contains(searchQuery) ||
               business.businessPhone.toLowerCase().contains(searchQuery) ||
               business.address.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Apply status filter
    if (selectedStatus.value != 'all') {
      filteredBusinesses = filteredBusinesses.where((business) => 
          business.verificationStatus.value == selectedStatus.value).toList();
    }

    // Apply type filter
    if (selectedType.value != 'all') {
      filteredBusinesses = filteredBusinesses.where((business) => 
          business.businessType.value == selectedType.value).toList();
    }

    // Apply date range filter
    if (selectedDateRange.value != 'all') {
      final now = DateTime.now();
      DateTime startDate;
      
      switch (selectedDateRange.value) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(1970);
      }
      
      filteredBusinesses = filteredBusinesses.where((business) => 
          business.createdAt.isAfter(startDate)).toList();
    }

    // Sort by creation date (newest first)
    filteredBusinesses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    businesses.value = filteredBusinesses;
    
    // Clear selection if businesses changed
    selectedBusinesses.removeWhere((id) => !businesses.any((business) => business.id == id));
  }

  // Search and Filter Methods
  void onSearchChanged(String query) {
    _applyFilters();
  }

  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void onTypeFilterChanged(String type) {
    selectedType.value = type;
    _applyFilters();
  }

  void onDateRangeFilterChanged(String dateRange) {
    selectedDateRange.value = dateRange;
    _applyFilters();
  }

  // Selection Methods
  void toggleBusinessSelection(String businessId) {
    if (selectedBusinesses.contains(businessId)) {
      selectedBusinesses.remove(businessId);
    } else {
      selectedBusinesses.add(businessId);
    }
  }

  void toggleSelectAll(bool? selectAll) {
    if (selectAll == true) {
      selectedBusinesses.addAll(businesses.map((business) => business.id));
    } else {
      selectedBusinesses.clear();
    }
  }

  // Business Detail Methods
  Future<void> viewBusinessDetails(String businessId) async {
    try {
      isLoading.value = true;
      
      // Get business details
      final business = await _businessService.getBusinessById(businessId);
      if (business != null) {
        selectedBusiness.value = business;
        
        // Load business history
        final history = await _businessService.getBusinessHistory(businessId);
        businessHistory.value = history;
        
        LoggerService.i('Business details loaded: ${business.businessName}');
      }
    } catch (e) {
      LoggerService.e('Error loading business details', error: e);
      AppSnackbar.showError(message: 'Failed to load business details');
    } finally {
      isLoading.value = false;
    }
  }

  // Business Action Methods
  Future<void> approveBusiness(String businessId, {String? notes}) async {
    try {
      isLoading.value = true;
      
      final success = await _businessService.approveBusiness(
        businessId,
        notes: notes ?? verificationNotesController.text.trim(),
      );

      if (success) {
        LoggerService.i('Business approved: $businessId');
        AppSnackbar.showSuccess(message: 'Business verification approved');
        verificationNotesController.clear();
        
        // Refresh details if viewing this business
        if (selectedBusiness.value?.id == businessId) {
          await viewBusinessDetails(businessId);
        }
      }
    } catch (e) {
      LoggerService.e('Error approving business', error: e);
      AppSnackbar.showError(message: 'Failed to approve business');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectBusiness(String businessId, {String? reason}) async {
    try {
      isLoading.value = true;
      
      final rejectionReason = reason ?? rejectionReasonController.text.trim();
      if (rejectionReason.isEmpty) {
        AppSnackbar.showError(message: 'Rejection reason is required');
        return;
      }
      
      final success = await _businessService.rejectBusiness(
        businessId,
        reason: rejectionReason,
      );

      if (success) {
        LoggerService.i('Business rejected: $businessId');
        AppSnackbar.showSuccess(message: 'Business verification rejected');
        rejectionReasonController.clear();
        
        // Refresh details if viewing this business
        if (selectedBusiness.value?.id == businessId) {
          await viewBusinessDetails(businessId);
        }
      }
    } catch (e) {
      LoggerService.e('Error rejecting business', error: e);
      AppSnackbar.showError(message: 'Failed to reject business');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> suspendBusiness(String businessId, {String? reason}) async {
    try {
      isLoading.value = true;
      
      final suspensionReason = reason ?? suspensionReasonController.text.trim();
      if (suspensionReason.isEmpty) {
        AppSnackbar.showError(message: 'Suspension reason is required');
        return;
      }
      
      final success = await _businessService.suspendBusiness(
        businessId,
        reason: suspensionReason,
      );

      if (success) {
        LoggerService.i('Business suspended: $businessId');
        AppSnackbar.showSuccess(message: 'Business suspended');
        suspensionReasonController.clear();
        
        // Refresh details if viewing this business
        if (selectedBusiness.value?.id == businessId) {
          await viewBusinessDetails(businessId);
        }
      }
    } catch (e) {
      LoggerService.e('Error suspending business', error: e);
      AppSnackbar.showError(message: 'Failed to suspend business');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reactivateBusiness(String businessId) async {
    try {
      isLoading.value = true;
      
      final success = await _businessService.reactivateBusiness(businessId);

      if (success) {
        LoggerService.i('Business reactivated: $businessId');
        AppSnackbar.showSuccess(message: 'Business reactivated');
        
        // Refresh details if viewing this business
        if (selectedBusiness.value?.id == businessId) {
          await viewBusinessDetails(businessId);
        }
      }
    } catch (e) {
      LoggerService.e('Error reactivating business', error: e);
      AppSnackbar.showError(message: 'Failed to reactivate business');
    } finally {
      isLoading.value = false;
    }
  }

  // Bulk Action Methods
  Future<void> bulkApproveBusiness() async {
    if (selectedBusinesses.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      final success = await _businessService.bulkApproveBusiness(selectedBusinesses.toList());

      if (success) {
        LoggerService.i('Bulk approved ${selectedBusinesses.length} businesses');
        AppSnackbar.showSuccess(message: '${selectedBusinesses.length} businesses approved');
        selectedBusinesses.clear();
      }
    } catch (e) {
      LoggerService.e('Error bulk approving businesses', error: e);
      AppSnackbar.showError(message: 'Failed to approve selected businesses');
    } finally {
      isLoading.value = false;
    }
  }

  // Export Methods
  Future<void> exportBusinesses() async {
    try {
      await _exportBusinessesToCSV(businesses);
      
      LoggerService.i('Exported ${businesses.length} businesses to CSV');
      AppSnackbar.showSuccess(message: 'Businesses exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting businesses', error: e);
      AppSnackbar.showError(message: 'Failed to export businesses');
    }
  }

  Future<void> exportSelectedBusinesses() async {
    if (selectedBusinesses.isEmpty) return;
    
    try {
      final selectedBusinessesList = businesses.where((business) => 
          selectedBusinesses.contains(business.id)).toList();
      await _exportBusinessesToCSV(selectedBusinessesList);
      
      LoggerService.i('Exported ${selectedBusinesses.length} selected businesses to CSV');
      AppSnackbar.showSuccess(message: '${selectedBusinesses.length} businesses exported successfully');
    } catch (e) {
      LoggerService.e('Error exporting selected businesses', error: e);
      AppSnackbar.showError(message: 'Failed to export selected businesses');
    }
  }

  Future<void> _exportBusinessesToCSV(List<BusinessProfileModel> businessesToExport) async {
    final csvData = StringBuffer();
    
    // Add header
    csvData.writeln('ID,Business Name,Type,Email,Phone,Address,Verification Status,Rating,Reviews,Created At,Verified At,Is Active');
    
    // Add data rows
    for (final business in businessesToExport) {
      csvData.writeln([
        business.id,
        '"${business.businessName}"',
        business.businessType.displayName,
        business.businessEmail,
        business.businessPhone,
        '"${business.address}"',
        business.verificationStatus.displayName,
        business.formattedRating,
        business.totalReviews,
        business.createdAt.toIso8601String(),
        business.verifiedAt?.toIso8601String() ?? 'Not verified',
        business.isActive ? 'Active' : 'Suspended',
      ].join(','));
    }
    
    // Create and download file
    final bytes = utf8.encode(csvData.toString());
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final filename = 'wanderlust_businesses_$timestamp.csv';
    
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }

  // Utility Methods
  Future<void> refreshBusinesses() async {
    selectedBusinesses.clear();
    await loadBusinesses();
  }

  void clearFilters() {
    searchController.clear();
    selectedStatus.value = 'all';
    selectedType.value = 'all';
    selectedDateRange.value = 'all';
    _applyFilters();
  }

  // Get status color
  Color getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const Color(0xFF10B981); // Green
      case VerificationStatus.pending:
        return const Color(0xFFF59E0B); // Orange
      case VerificationStatus.rejected:
        return const Color(0xFFEF4444); // Red
      case VerificationStatus.expired:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Get type color
  Color getTypeColor(BusinessType type) {
    switch (type) {
      case BusinessType.hotel:
        return const Color(0xFF3B82F6); // Blue
      case BusinessType.tour:
        return const Color(0xFF8B5CF6); // Purple
      case BusinessType.restaurant:
        return const Color(0xFFF59E0B); // Orange
      case BusinessType.service:
        return const Color(0xFF10B981); // Green
    }
  }
}