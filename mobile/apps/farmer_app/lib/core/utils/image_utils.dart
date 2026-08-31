import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';

/// Utilities for image compression and resizing.
abstract final class ImageUtils {
  /// Compresses and resizes an image file to fit within [maxDimension].
  ///
  /// Returns the path to the compressed image file.
  static Future<String> compressImage(
    String sourcePath, {
    int maxDimension = AppConfig.maxImageDimension,
    int quality = AppConfig.imageQuality,
  }) async {
    final sourceFile = File(sourcePath);
    final bytes = await sourceFile.readAsBytes();
    final compressed = compressImageBytes(
      bytes,
      maxDimension: maxDimension,
      quality: quality,
    );

    if (compressed == null) return sourcePath;

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/compressed_$timestamp.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(compressed);

    return outputPath;
  }

  /// Compresses image bytes and returns the result, or null if decoding fails.
  static Uint8List? compressImageBytes(
    Uint8List bytes, {
    int maxDimension = AppConfig.maxImageDimension,
    int quality = AppConfig.imageQuality,
  }) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    img.Image resized;
    if (image.width > maxDimension || image.height > maxDimension) {
      if (image.width >= image.height) {
        resized = img.copyResize(image, width: maxDimension);
      } else {
        resized = img.copyResize(image, height: maxDimension);
      }
    } else {
      resized = image;
    }

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  /// Creates a thumbnail from an image file.
  static Future<String> createThumbnail(
    String sourcePath, {
    int size = 256,
  }) async {
    final sourceFile = File(sourcePath);
    final bytes = await sourceFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return sourcePath;

    final thumbnail = img.copyResizeCropSquare(image, size: size);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/thumb_$timestamp.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 80));

    return outputPath;
  }

  /// Calculates the file size in a human-readable format.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Estimates compression savings.
  static double compressionRatio(int originalSize, int compressedSize) {
    if (originalSize == 0) return 0;
    return 1.0 - (compressedSize / originalSize);
  }
}
