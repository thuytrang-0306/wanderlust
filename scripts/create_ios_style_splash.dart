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

  print('Original logo size: ${originalImage.width}x${originalImage.height}');

  // iOS style: Smaller logo, more padding
  // Use 40% of screen width (like iOS does)
  final iosCanvasSize = 768; // Larger canvas
  final iosLogoSize = (iosCanvasSize * 0.35).round(); // Only 35% of canvas = 269px
  
  // Create iOS-style canvas
  final iosImage = img.Image(
    width: iosCanvasSize,
    height: iosCanvasSize,
    numChannels: 4,
  );
  
  // Fill with transparent
  img.fill(iosImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Resize logo to smaller size (269px from 312px)
  final resizedLogo = img.copyResize(
    originalImage,
    width: iosLogoSize,
    height: iosLogoSize,
    interpolation: img.Interpolation.cubic, // Best quality
  );
  
  // Center logo in canvas
  final xOffset = (iosCanvasSize - resizedLogo.width) ~/ 2;
  final yOffset = (iosCanvasSize - resizedLogo.height) ~/ 2;
  
  img.compositeImage(
    iosImage,
    resizedLogo,
    dstX: xOffset,
    dstY: yOffset,
  );
  
  // Save iOS-style splash
  final iosFile = File('assets/images/splash_logo_ios_style.png');
  iosFile.writeAsBytesSync(img.encodePng(iosImage, level: 1));
  
  print('✅ Created splash_logo_ios_style.png');
  print('   Canvas: ${iosCanvasSize}x${iosCanvasSize}px');
  print('   Logo size: ${resizedLogo.width}x${resizedLogo.height}px (35% of canvas)');
  print('   Visual: Small and crisp like iOS');
  
  // Also create medium version (between iOS and current)
  final mediumCanvasSize = 640;
  final mediumLogoSize = (mediumCanvasSize * 0.4).round(); // 40% = 256px
  
  final mediumImage = img.Image(
    width: mediumCanvasSize,
    height: mediumCanvasSize,
    numChannels: 4,
  );
  
  img.fill(mediumImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  final mediumResized = img.copyResize(
    originalImage,
    width: mediumLogoSize,
    height: mediumLogoSize,
    interpolation: img.Interpolation.cubic,
  );
  
  final mediumXOffset = (mediumCanvasSize - mediumResized.width) ~/ 2;
  final mediumYOffset = (mediumCanvasSize - mediumResized.height) ~/ 2;
  
  img.compositeImage(
    mediumImage,
    mediumResized,
    dstX: mediumXOffset,
    dstY: mediumYOffset,
  );
  
  final mediumFile = File('assets/images/splash_logo_medium.png');
  mediumFile.writeAsBytesSync(img.encodePng(mediumImage, level: 1));
  
  print('✅ Created splash_logo_medium.png');
  print('   Canvas: ${mediumCanvasSize}x${mediumCanvasSize}px');
  print('   Logo size: ${mediumResized.width}x${mediumResized.height}px (40% of canvas)');
}