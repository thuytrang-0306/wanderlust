import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:wanderlust/data/models/location_point.dart';

class AppMap extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final double initialZoom;
  final List<LocationPoint>? markers;
  final List<List<LocationPoint>>? routes;
  final bool interactive;
  final Function(LatLng)? onTap;
  final Function(LocationPoint)? onMarkerTap;
  final bool showUserLocation;
  final double? height;
  final BorderRadius? borderRadius;
  final MapController? controller;
  final LocationPoint? selectedLocation;

  const AppMap({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialZoom = 13.0,
    this.markers,
    this.routes,
    this.interactive = true,
    this.onTap,
    this.onMarkerTap,
    this.showUserLocation = false,
    this.height,
    this.borderRadius,
    this.controller,
    this.selectedLocation,
  });

  // Factory constructor for location selection
  factory AppMap.locationPicker({
    required Function(LatLng) onLocationSelected,
    LocationPoint? initialLocation,
    double? height,
  }) {
    return AppMap(
      initialLatitude: initialLocation?.latitude ?? 10.762622,
      initialLongitude: initialLocation?.longitude ?? 106.660172,
      initialZoom: 15.0,
      interactive: true,
      onTap: onLocationSelected,
      height: height,
      selectedLocation: initialLocation,
      markers: initialLocation != null ? [initialLocation] : null,
    );
  }

  // Factory constructor for route display
  factory AppMap.routeDisplay({
    required List<LocationPoint> waypoints,
    double? height,
    BorderRadius? borderRadius,
  }) {
    if (waypoints.isEmpty) {
      return AppMap(
        height: height,
        borderRadius: borderRadius,
        interactive: false,
      );
    }

    // Calculate center point
    double avgLat = waypoints.map((p) => p.latitude).reduce((a, b) => a + b) / waypoints.length;
    double avgLng = waypoints.map((p) => p.longitude).reduce((a, b) => a + b) / waypoints.length;

    return AppMap(
      initialLatitude: avgLat,
      initialLongitude: avgLng,
      initialZoom: 12.0,
      markers: waypoints,
      routes: [waypoints],
      interactive: false,
      height: height,
      borderRadius: borderRadius,
    );
  }

  // Factory constructor for single location display
  factory AppMap.singleLocation({
    required LocationPoint location,
    double? height,
    BorderRadius? borderRadius,
    double zoom = 15.0,
  }) {
    return AppMap(
      initialLatitude: location.latitude,
      initialLongitude: location.longitude,
      initialZoom: zoom,
      markers: [location],
      interactive: false,
      height: height,
      borderRadius: borderRadius,
    );
  }

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late MapController _mapController;
  LocationPoint? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = widget.controller ?? MapController();
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final defaultLat = widget.initialLatitude ?? 10.762622; // Ho Chi Minh City
    final defaultLng = widget.initialLongitude ?? 106.660172;

    Widget mapWidget = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(defaultLat, defaultLng),
        initialZoom: widget.initialZoom,
        interactionOptions: InteractionOptions(
          enableMultiFingerGestureRace: true,
          flags: widget.interactive
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
        onTap: widget.interactive && widget.onTap != null
            ? (tapPosition, latLng) {
                setState(() {
                  _selectedLocation = LocationPoint(
                    id: 'selected',
                    name: 'Selected Location',
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                  );
                });
                widget.onTap!(latLng);
              }
            : null,
      ),
      children: [
        // Tile Layer - Using CartoDB Light with error handling
        TileLayer(
          urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.wanderlust.app',
          maxZoom: 19,
          errorTileCallback: (tile, error, stackTrace) {
            // Log error but don't crash the app
            LoggerService.e('Map tile error', error: error);
          },
        ),

        // Draw routes if provided
        if (widget.routes != null && widget.routes!.isNotEmpty)
          PolylineLayer(
            polylines: widget.routes!.map((route) {
              return Polyline(
                points: route
                    .map((p) => LatLng(p.latitude, p.longitude))
                    .toList(),
                color: AppColors.primary.withValues(alpha: 0.8),
                strokeWidth: 4.0,
              );
            }).toList(),
          ),

        // Marker Layer
        MarkerLayer(
          markers: _buildMarkers(),
        ),

        // Selected location marker
        if (_selectedLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
                width: 50.w,
                height: 50.w,
                child: Icon(
                  Icons.location_on,
                  color: AppColors.error,
                  size: 40.sp,
                ),
              ),
            ],
          ),
      ],
    );

    // Apply height and border radius if provided
    if (widget.height != null || widget.borderRadius != null) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: mapWidget,
        ),
      );
    }

    return mapWidget;
  }

  List<Marker> _buildMarkers() {
    if (widget.markers == null || widget.markers!.isEmpty) {
      return [];
    }

    return widget.markers!.map((location) {
      // Calculate dynamic height based on whether name is shown
      final bool showName = location.name.isNotEmpty;
      final double markerHeight = showName ? 70.w : 50.w;
      
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: showName ? 80.w : 50.w,
        height: markerHeight,
        child: GestureDetector(
          onTap: () {
            if (widget.onMarkerTap != null) {
              widget.onMarkerTap!(location);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getIconForType(location.type),
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              if (showName)
                Positioned(
                  bottom: -20.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'attraction':
        return Icons.attractions;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_bus;
      case 'airport':
        return Icons.flight;
      default:
        return Icons.place;
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.controller == null && _mapController.hashCode != widget.controller.hashCode) {
      _mapController.dispose();
    }
    super.dispose();
  }
}

// Loading placeholder widget
class AppMapLoading extends StatelessWidget {
  final double? height;
  final BorderRadius? borderRadius;

  const AppMapLoading({
    super.key,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading map...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}