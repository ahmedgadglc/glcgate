import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // Configurable breakpoints
  static const double mobileBreakpoint = 850;
  static const double tabletBreakpoint = 1100;

  // Enhanced type checking methods
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  // Utility methods
  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint;

  static bool isMobileOrTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  // Get current screen type as enum
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) return ScreenType.desktop;
    if (width >= mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  // Get responsive value based on screen size
  static T valueWhen<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) return desktop;
    if (width >= mobileBreakpoint && tablet != null) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Enum for better type safety
enum ScreenType {
  mobile,
  tablet,
  desktop;

  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
  bool get isDesktop => this == ScreenType.desktop;
}

