import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderlust/core/constants/app_colors.dart';

/// Smart image widget that handles both network URLs and base64 data
/// Automatically detects and displays the right format
class AppImage extends StatelessWidget {
  final String imageData;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  /// Avatar constructor with optimized settings
  factory AppImage.avatar({required String imageData, double size = 40}) {
    return AppImage(
      imageData: imageData,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// Post image constructor
  factory AppImage.post({required String imageData, double? width, double? height}) {
    return AppImage(imageData: imageData, width: width, height: height, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    if (imageData.isEmpty) {
      return _buildErrorWidget();
    }

    Widget imageWidget;

    // Check if it's base64 data URL
    if (imageData.startsWith('data:image')) {
      // Don't log base64 strings to avoid flooding logs
      imageWidget = _buildBase64Image();
    }
    // Check if it's raw base64 (without data URL prefix)
    else if (_isBase64(imageData)) {
      imageWidget = _buildBase64Image(isRawBase64: true);
    }
    // Otherwise treat as network URL
    else {
      imageWidget = _buildNetworkImage();
    }

    // Apply border radius if specified
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildBase64Image({bool isRawBase64 = false}) {
    try {
      late Uint8List bytes;

      if (isRawBase64) {
        bytes = base64Decode(imageData);
      } else {
        // Extract base64 string from data URL
        final base64String = imageData.split(',').last;
        bytes = base64Decode(base64String);
      }

      return Image.memory(
        bytes,
        key: ValueKey(imageData),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true, // ← Smooth transition when rebuilt
        errorBuilder: (context, error, stackTrace) {
          // Debug: log error to understand issue
          debugPrint('AppImage Error: $error');
          return _buildErrorWidget();
        },
      );
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      key: ValueKey(imageData),
      imageUrl: imageData,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('CachedNetworkImage Error: $error');
        return errorWidget ?? _buildErrorWidget();
      },
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral100,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.neutral100,
      child: Icon(
        Icons.image_not_supported,
        color: AppColors.neutral400,
        size: width != null && width! < 50 ? 20 : 30,
      ),
    );
  }

  bool _isBase64(String str) {
    if (str.isEmpty) return false;

    // Basic check for base64 pattern
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');

    // Must be divisible by 4
    if (str.length % 4 != 0) return false;

    return base64Regex.hasMatch(str);
  }
}

/// Extension for easy usage
extension ImageExtension on String {
  Widget toImage({double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return AppImage(imageData: this, width: width, height: height, fit: fit);
  }

  Widget toAvatar({double size = 40}) {
    return AppImage.avatar(imageData: this, size: size);
  }
}
