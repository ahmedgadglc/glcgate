import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductImageCard extends StatelessWidget {
  final String? imageUrl;
  final String? productDescription;
  final double width;
  final double height;

  const ProductImageCard({
    super.key,
    required this.imageUrl,
    required this.productDescription,
    this.width = 150,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    // final bool isValidUrl =
    //     imageUrl != null &&
    //     imageUrl!.isNotEmpty &&
    //     Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

    // if (!isValidUrl) {
    //   return const Icon(Icons.image, color: Colors.grey, size: 50);
    // }

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
        memCacheWidth: cacheWidth,
        memCacheHeight: cacheHeight,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        useOldImageOnUrlChange: true,
        progressIndicatorBuilder: (context, url, progress) {
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
