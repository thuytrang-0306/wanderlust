import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

/// Geocoding service using OpenStreetMap Nominatim API (Free, no API key needed)
class GeocodingService extends GetxService {
  static GeocodingService get to => Get.find();

  final Dio _dio = Dio();
  final String _baseUrl = 'https://nominatim.openstreetmap.org';

  // User agent required by Nominatim
  final String _userAgent = 'WanderlustApp/1.0.0';

  @override
  void onInit() {
    super.onInit();
    _dio.options.headers['User-Agent'] = _userAgent;
  }

  /// Forward geocoding: Address → Coordinates
  /// Returns: {lat: double, lng: double, displayName: String} or null
  Future<Map<String, dynamic>?> geocode(String address) async {
    if (address.isEmpty) return null;

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
        final result = response.data[0];
        return {
          'lat': double.parse(result['lat']),
          'lng': double.parse(result['lon']),
          'displayName': result['display_name'],
          'address': result['address'],
        };
      }

      LoggerService.w('No geocoding results for: $address');
      return null;
    } catch (e) {
      LoggerService.e('Geocoding error', error: e);
      return null;
    }
  }

  /// Reverse geocoding: Coordinates → Address
  /// Returns: {displayName: String, address: Map} or null
  Future<Map<String, dynamic>?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reverse',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lng.toString(),
          'format': 'json',
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return {
          'displayName': data['display_name'],
          'address': data['address'],
          'road': data['address']?['road'] ?? '',
          'suburb': data['address']?['suburb'] ?? '',
          'city': data['address']?['city'] ?? data['address']?['town'] ?? data['address']?['village'] ?? '',
          'state': data['address']?['state'] ?? '',
          'country': data['address']?['country'] ?? '',
        };
      }

      LoggerService.w('No reverse geocoding results for: $lat, $lng');
      return null;
    } catch (e) {
      LoggerService.e('Reverse geocoding error', error: e);
      return null;
    }
  }

  /// Search places by query
  /// Returns list of results with coordinates
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 10,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((item) {
          return {
            'lat': double.parse(item['lat']),
            'lng': double.parse(item['lon']),
            'displayName': item['display_name'],
            'type': item['type'],
            'class': item['class'],
            'address': item['address'],
          };
        }).toList();
      }

      return [];
    } catch (e) {
      LoggerService.e('Place search error', error: e);
      return [];
    }
  }

  /// Format address components to readable string
  String formatAddress(Map<String, dynamic> addressComponents) {
    final parts = <String>[];

    if (addressComponents['road']?.isNotEmpty == true) {
      parts.add(addressComponents['road']);
    }
    if (addressComponents['suburb']?.isNotEmpty == true) {
      parts.add(addressComponents['suburb']);
    }
    if (addressComponents['city']?.isNotEmpty == true) {
      parts.add(addressComponents['city']);
    }
    if (addressComponents['state']?.isNotEmpty == true) {
      parts.add(addressComponents['state']);
    }

    return parts.join(', ');
  }
}
