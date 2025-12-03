import 'package:cached_network_image/cached_network_image.dart';
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
      return const Icon(
        Icons.image,
        color: Colors.grey,
        size: 50,
      );
    }

    return Center(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.contain,
        placeholder: (context, url) => Skeletonizer(
          containersColor: Colors.white,
          enabled: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.network(
              imageUrl!,
              width: width,
              height: height,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.image,
          color: Colors.grey,
          size: 50,
        ),
      ),
    );
  }
}
