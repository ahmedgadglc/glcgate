import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? itemMainDescription;
  final double width;
  final double height;

  const ProductImageCard({
    super.key,
    required this.imageUrl,
    required this.itemMainDescription,
    this.width = 150,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final bool isValidUrl =
        imageUrl != null &&
        imageUrl!.isNotEmpty &&
        Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

    if (!isValidUrl) {
      return const Icon(Icons.image, color: Colors.grey, size: 50);
    }

    // Calculate optimal cache dimensions for web performance
    // Use device pixel ratio for crisp images without overloading
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = kIsWeb
        ? (width * devicePixelRatio).round().clamp(100, 400)
        : (width * devicePixelRatio).round();
    final cacheHeight = kIsWeb
        ? (height * devicePixelRatio).round().clamp(100, 400)
        : (height * devicePixelRatio).round();

    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.contain,
        // Optimize memory cache for web
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        // Faster fade for better perceived performance
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Prevent unnecessary reloads
        useOldImageOnUrlChange: true,
        // Progressive loading indicator - handles both initial and loading states
        progressIndicatorBuilder: (context, url, progress) {
          // Show skeleton during initial load (when progress value is null or 0)
          if (progress.progress == null || progress.progress == 0) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Skeletonizer(
                enabled: true,
                containersColor: Colors.white,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }
          // Show progress indicator when download progress is available
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: progress.progress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.image, color: Colors.grey, size: 50),
        ),
      ),
    );
  }
}
