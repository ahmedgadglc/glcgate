import 'package:flutter/material.dart';
import '../widgets/fly_to_cart_animation.dart';

/// Service to handle fly-to-cart animations
class FlyToCartService {
  /// Trigger a fly-to-cart animation
  /// 
  /// [context] - BuildContext to access overlay
  /// [sourceKey] - GlobalKey of the source widget (product image)
  /// [targetKey] - GlobalKey of the target widget (cart icon)
  /// [imageUrl] - URL of the product image to animate
  /// [onComplete] - Optional callback when animation completes
  static void flyToCart({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    String? imageUrl,
    VoidCallback? onComplete,
  }) {
    // Get source position
    final sourceRenderBox = sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (sourceRenderBox == null) {
      debugPrint('FlyToCart: Source widget not found');
      return;
    }

    final sourcePosition = sourceRenderBox.localToGlobal(Offset.zero);
    final sourceSize = sourceRenderBox.size;
    final sourceCenter = Offset(
      sourcePosition.dx + sourceSize.width / 2,
      sourcePosition.dy + sourceSize.height / 2,
    );

    // Get target position
    final targetRenderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) {
      debugPrint('FlyToCart: Target widget not found');
      return;
    }

    final targetPosition = targetRenderBox.localToGlobal(Offset.zero);
    final targetSize = targetRenderBox.size;
    final targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Show animation in overlay
    try {
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => FlyToCartAnimation(
          startPosition: sourceCenter,
          endPosition: targetCenter,
          imageUrl: imageUrl,
          onComplete: () {
            overlayEntry.remove();
            onComplete?.call();
          },
        ),
      );

      overlay.insert(overlayEntry);
    } catch (e) {
      debugPrint('FlyToCart: Failed to show animation - $e');
    }
  }

  /// Trigger animation using RenderBox positions directly
  /// Useful when you already have the positions calculated
  static void flyToCartWithPositions({
    required BuildContext context,
    required Offset startPosition,
    required Offset endPosition,
    String? imageUrl,
    VoidCallback? onComplete,
  }) {
    try {
      final overlay = Overlay.of(context);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => FlyToCartAnimation(
          startPosition: startPosition,
          endPosition: endPosition,
          imageUrl: imageUrl,
          onComplete: () {
            overlayEntry.remove();
            onComplete?.call();
          },
        ),
      );

      overlay.insert(overlayEntry);
    } catch (e) {
      debugPrint('FlyToCart: Failed to show animation - $e');
    }
  }
}

