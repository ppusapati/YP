import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// A horizontally scrollable photo gallery with full-screen preview.
class PhotoGallery extends StatelessWidget {
  const PhotoGallery({
    super.key,
    required this.photos,
    this.height = 200,
    this.onRemove,
  });

  /// List of photo URLs or local file paths.
  final List<String> photos;

  /// Height of the gallery thumbnails.
  final double height;

  /// If provided, shows a remove button on each photo.
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No photos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _PhotoThumbnail(
            photoPath: photos[index],
            height: height,
            onTap: () => _openFullScreen(context, index),
            onRemove: onRemove != null ? () => onRemove!(index) : null,
          );
        },
      ),
    );
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _FullScreenGallery(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.photoPath,
    required this.height,
    required this.onTap,
    this.onRemove,
  });

  final String photoPath;
  final double height;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: height * 0.75,
              height: height,
              child: _buildImage(),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (photoPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: photoPath,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    }
    return Image.file(File(photoPath), fit: BoxFit.cover);
  }
}

class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({
    required this.photos,
    required this.initialIndex,
  });

  final List<String> photos;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${initialIndex + 1} / ${photos.length}'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: photos.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          final photo = photos[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: photo.startsWith('http')
                ? CachedNetworkImageProvider(photo) as ImageProvider
                : FileImage(File(photo)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
