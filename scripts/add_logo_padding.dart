import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Read original logo
  final originalFile = File('assets/images/logo.png');
  if (!originalFile.existsSync()) {
    print('Error: logo.png not found in assets/images/');
    return;
  }

  final originalBytes = originalFile.readAsBytesSync();
  final originalImage = img.decodeImage(originalBytes);
  
  if (originalImage == null) {
    print('Error: Could not decode image');
    return;
  }

  // Calculate new size with padding (add 40% padding)
  final originalSize = originalImage.width > originalImage.height 
      ? originalImage.width 
      : originalImage.height;
  
  // Create new square canvas with padding
  final paddingPercent = 0.4; // 40% padding (20% each side)
  final newSize = (originalSize * (1 + paddingPercent)).round();
  
  // Create new image with transparent background
  final paddedImage = img.Image(
    width: newSize,
    height: newSize,
    numChannels: 4, // RGBA
  );
  
  // Fill with transparent
  img.fill(paddedImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Calculate position to center the logo
  final xOffset = (newSize - originalImage.width) ~/ 2;
  final yOffset = (newSize - originalImage.height) ~/ 2;
  
  // Composite original image onto padded canvas
  img.compositeImage(
    paddedImage,
    originalImage,
    dstX: xOffset,
    dstY: yOffset,
  );
  
  // Save padded version for app icon
  final iconFile = File('assets/images/app_icon.png');
  iconFile.writeAsBytesSync(img.encodePng(paddedImage));
  
  print('✅ Created app_icon.png with padding');
  print('   Original size: ${originalImage.width}x${originalImage.height}');
  print('   New size: ${newSize}x${newSize}');
  print('   Padding: ${(paddingPercent * 100).round()}%');
  
  // Also create a version specifically for Android adaptive icon
  // with more padding for better display
  final adaptivePadding = 0.66; // 66% padding for Android adaptive
  final adaptiveSize = (originalSize * (1 + adaptivePadding)).round();
  
  final adaptiveImage = img.Image(
    width: adaptiveSize,
    height: adaptiveSize,
    numChannels: 4,
  );
  
  img.fill(adaptiveImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  final adaptiveXOffset = (adaptiveSize - originalImage.width) ~/ 2;
  final adaptiveYOffset = (adaptiveSize - originalImage.height) ~/ 2;
  
  img.compositeImage(
    adaptiveImage,
    originalImage,
    dstX: adaptiveXOffset,
    dstY: adaptiveYOffset,
  );
  
  final adaptiveFile = File('assets/images/app_icon_adaptive.png');
  adaptiveFile.writeAsBytesSync(img.encodePng(adaptiveImage));
  
  print('✅ Created app_icon_adaptive.png for Android');
  print('   Size: ${adaptiveSize}x${adaptiveSize}');
  print('   Padding: ${(adaptivePadding * 100).round()}%');
}