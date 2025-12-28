import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/listing_model.dart';
import 'package:wanderlust/data/services/listing_service.dart';
import 'package:wanderlust/data/services/accommodation_service.dart';
import 'package:wanderlust/data/models/accommodation_model.dart';

class FavoritesController extends BaseController {
  final ListingService _listingService = Get.find<ListingService>();
  final AccommodationService _accommodationService = Get.find<AccommodationService>();

  // Observables
  final favorites = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'all'.obs; // all, room, tour, food, service

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Load all favorites
  Future<void> loadFavorites() async {
    try {
      setLoading();

      final listingFavorites = await _listingService.getUserFavorites();
      final accommodationFavorites = await _accommodationService.getUserFavorites();

      final allFavorites = <Map<String, dynamic>>[];

      // Add listing favorites
      for (final listing in listingFavorites) {
        allFavorites.add({
          'id': listing.id,
          'type': 'listing',
          'listingType': listing.type.value,
          'title': listing.title,
          'description': listing.description,
          'image': listing.images.isNotEmpty ? listing.images.first : '',
          'price': listing.hasDiscount ? listing.discountPrice! : listing.price,
          'originalPrice': listing.price,
          'rating': listing.rating,
          'reviews': listing.reviews,
          'location': '${listing.details['city'] ?? ''}, ${listing.details['province'] ?? ''}',
          'businessName': listing.businessName,
          'hasDiscount': listing.hasDiscount,
        });
      }

      // Add accommodation favorites
      for (final acc in accommodationFavorites) {
        allFavorites.add({
          'id': acc.id,
          'type': 'accommodation',
          'listingType': 'room',
          'title': acc.name,
          'description': acc.description,
          'image': acc.images.isNotEmpty ? acc.images.first : '',
          'price': acc.pricePerNight,
          'originalPrice': acc.originalPrice,
          'rating': acc.rating,
          'reviews': acc.totalReviews,
          'location': acc.fullAddress,
          'businessName': acc.hostName,
          'hasDiscount': acc.originalPrice > acc.pricePerNight,
        });
      }

      favorites.value = allFavorites;
      setSuccess();

      LoggerService.i('Loaded ${favorites.length} favorites');
    } catch (e) {
      LoggerService.e('Error loading favorites', error: e);
      setError('Không thể tải danh sách yêu thích');
    }
  }

  /// Filter favorites by type
  List<Map<String, dynamic>> get filteredFavorites {
    if (selectedFilter.value == 'all') {
      return favorites;
    }
    return favorites.where((fav) => fav['listingType'] == selectedFilter.value).toList();
  }

  /// Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// Remove favorite
  Future<void> removeFavorite(Map<String, dynamic> item) async {
    try {
      final itemType = item['type'] as String;
      final itemId = item['id'] as String;

      if (itemType == 'listing') {
        await _listingService.toggleFavorite(itemId);
      } else {
        await _accommodationService.toggleFavorite(itemId);
      }

      // Remove from list
      favorites.removeWhere((fav) => fav['id'] == itemId);

      LoggerService.i('Removed favorite: $itemId');
    } catch (e) {
      LoggerService.e('Error removing favorite', error: e);
    }
  }

  /// Navigate to detail
  void navigateToDetail(Map<String, dynamic> item) {
    final itemType = item['type'] as String;
    final itemId = item['id'] as String;

    if (itemType == 'listing') {
      Get.toNamed(
        '/accommodation-detail',
        arguments: {'listingId': itemId},
      );
    } else {
      Get.toNamed(
        '/accommodation-detail',
        arguments: {'accommodationId': itemId},
      );
    }
  }

  /// Get filter count
  int getFilterCount(String filter) {
    if (filter == 'all') return favorites.length;
    return favorites.where((fav) => fav['listingType'] == filter).length;
  }
}
