import 'dart:io';

import 'package:flutter/material.dart';

/// Resolves the three forms a diagnosis photo arrives in.
///
/// `Diagnosis.imagePath` is a local file path when the photo was just taken,
/// an `http(s)` URL when it came back from the service, and a `data:` URI when
/// it went out through `uploadImage` — which encodes the bytes inline because
/// PlantDiagnosisService embeds images in the request rather than taking an
/// upload first.
///
/// The result screen used `Image.file` for all three, so a submitted diagnosis
/// showed the broken-image placeholder for its own photo.
ImageProvider? analysedImageProvider(String path) {
  if (path.isEmpty) return null;

  if (path.startsWith('data:')) {
    try {
      final data = UriData.parse(path);
      return MemoryImage(data.contentAsBytes());
    } on FormatException {
      // A malformed data URI is not something a retry fixes; fall through to
      // the caller's placeholder rather than throwing during build.
      return null;
    }
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }

  return FileImage(File(path));
}

/// The diagnosis photo, or a placeholder when there is nothing to show.
class AnalysedImage extends StatelessWidget {
  const AnalysedImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final provider = analysedImageProvider(imagePath);
    if (provider == null) return const _ImagePlaceholder();

    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
