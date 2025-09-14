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

  // For splash screen, we want the logo to be smaller on screen
  // Create a version with more padding so it appears smaller
  
  // Option 1: Create splash logo with extra padding (appears smaller)
  final splashPadding = 1.5; // 150% padding for smaller appearance
  final splashSize = (originalImage.width * (1 + splashPadding)).round();
  
  final splashImage = img.Image(
    width: splashSize,
    height: splashSize,
    numChannels: 4,
  );
  
  // Fill with transparent
  img.fill(splashImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Center the logo with extra padding
  final xOffset = (splashSize - originalImage.width) ~/ 2;
  final yOffset = (splashSize - originalImage.height) ~/ 2;
  
  img.compositeImage(
    splashImage,
    originalImage,
    dstX: xOffset,
    dstY: yOffset,
  );
  
  // Save splash version
  final splashFile = File('assets/images/splash_logo.png');
  splashFile.writeAsBytesSync(img.encodePng(splashImage));
  
  print('✅ Created splash_logo.png');
  print('   Original: ${originalImage.width}x${originalImage.height}');
  print('   Splash: ${splashSize}x${splashSize}');
  print('   Visual size: ~${(100 / (1 + splashPadding)).round()}% of screen width');
  
  // Option 2: Also create a fixed-size version for consistent display
  final fixedSize = 200; // Fixed 200x200 for splash
  final fixedImage = img.Image(
    width: fixedSize,
    height: fixedSize,
    numChannels: 4,
  );
  
  img.fill(fixedImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Resize logo to fit within 140x140 (leaving padding)
  final logoMaxSize = 140;
  final scale = logoMaxSize / originalImage.width;
  final resizedLogo = img.copyResize(
    originalImage,
    width: (originalImage.width * scale).round(),
    height: (originalImage.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );
  
  // Center in 200x200
  final fixedXOffset = (fixedSize - resizedLogo.width) ~/ 2;
  final fixedYOffset = (fixedSize - resizedLogo.height) ~/ 2;
  
  img.compositeImage(
    fixedImage,
    resizedLogo,
    dstX: fixedXOffset,
    dstY: fixedYOffset,
  );
  
  final fixedFile = File('assets/images/splash_logo_fixed.png');
  fixedFile.writeAsBytesSync(img.encodePng(fixedImage));
  
  print('✅ Created splash_logo_fixed.png (200x200 with logo at 140px)');
}