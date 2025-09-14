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

  // For HD splash: Use 512x512 canvas (high quality)
  // Logo will be 60% of canvas size = ~307px (close to original 312px)
  final canvasSize = 512;
  final logoTargetSize = (canvasSize * 0.6).round(); // 307px
  
  // Create HD canvas
  final hdImage = img.Image(
    width: canvasSize,
    height: canvasSize,
    numChannels: 4,
  );
  
  // Fill with transparent
  img.fill(hdImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Since original is 312px and target is 307px, almost no resize needed
  // This preserves quality
  final scale = logoTargetSize / originalImage.width.toDouble();
  
  img.Image resizedLogo;
  if (scale < 0.95 || scale > 1.05) {
    // Only resize if difference is significant
    resizedLogo = img.copyResize(
      originalImage,
      width: logoTargetSize,
      height: logoTargetSize,
      interpolation: img.Interpolation.cubic, // Best quality
    );
  } else {
    // Use original size to maintain quality
    resizedLogo = originalImage;
  }
  
  // Center logo in canvas
  final xOffset = (canvasSize - resizedLogo.width) ~/ 2;
  final yOffset = (canvasSize - resizedLogo.height) ~/ 2;
  
  img.compositeImage(
    hdImage,
    resizedLogo,
    dstX: xOffset,
    dstY: yOffset,
  );
  
  // Save HD splash logo
  final hdFile = File('assets/images/splash_logo_hd.png');
  hdFile.writeAsBytesSync(img.encodePng(hdImage, level: 1)); // Low compression for quality
  
  print('✅ Created splash_logo_hd.png');
  print('   Canvas: ${canvasSize}x${canvasSize}px');
  print('   Logo size: ${resizedLogo.width}x${resizedLogo.height}px');
  print('   Logo percentage: ${(logoTargetSize * 100 / canvasSize).round()}% of canvas');
  print('   Quality: HD (no upscaling, minimal resize)');
  
  // Also create an even larger version for tablets/high DPI
  final xlCanvasSize = 768;
  final xlLogoSize = (xlCanvasSize * 0.5).round(); // 50% = 384px
  
  final xlImage = img.Image(
    width: xlCanvasSize,
    height: xlCanvasSize,
    numChannels: 4,
  );
  
  img.fill(xlImage, color: img.ColorRgba8(255, 255, 255, 0));
  
  // Resize logo for XL (slight upscale from 312 to 384)
  final xlLogo = img.copyResize(
    originalImage,
    width: xlLogoSize,
    height: xlLogoSize,
    interpolation: img.Interpolation.cubic,
  );
  
  final xlXOffset = (xlCanvasSize - xlLogo.width) ~/ 2;
  final xlYOffset = (xlCanvasSize - xlLogo.height) ~/ 2;
  
  img.compositeImage(
    xlImage,
    xlLogo,
    dstX: xlXOffset,
    dstY: xlYOffset,
  );
  
  final xlFile = File('assets/images/splash_logo_xl.png');
  xlFile.writeAsBytesSync(img.encodePng(xlImage, level: 1));
  
  print('✅ Created splash_logo_xl.png for tablets');
  print('   Canvas: ${xlCanvasSize}x${xlCanvasSize}px');
  print('   Logo size: ${xlLogo.width}x${xlLogo.height}px');
}