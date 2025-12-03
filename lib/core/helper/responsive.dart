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

  // Get current screen type as enum
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) return ScreenType.desktop;
    if (width >= mobileBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }

  // Get responsive value based on screen size
  //
  // Usage examples:
  //
  // 1. Responsive padding:
  //    padding: EdgeInsets.all(
  //      Responsive.valueWhen(
  //        context: context,
  //        mobile: 8.0,
  //        tablet: 16.0,
  //        desktop: 24.0,
  //      ),
  //    ),
  //
  // 2. Responsive font size:
  //    fontSize: Responsive.valueWhen(
  //      context: context,
  //      mobile: 14.0,
  //      tablet: 16.0,
  //      desktop: 18.0,
  //    ),
  //
  // 3. Responsive number of columns:
  //    crossAxisCount: Responsive.valueWhen(
  //      context: context,
  //      mobile: 2,
  //      tablet: 3,
  //      desktop: 4,
  //    ),
  //
  // 4. Responsive without tablet (falls back to mobile):
  //    spacing: Responsive.valueWhen(
  //      context: context,
  //      mobile: 8.0,
  //      desktop: 16.0,
  //    ),
  //
  // 5. Responsive EdgeInsets:
  //    margin: Responsive.valueWhen(
  //      context: context,
  //      mobile: EdgeInsets.all(8),
  //      tablet: EdgeInsets.all(16),
  //      desktop: EdgeInsets.all(24),
  //    ),
  //
  // 6. Responsive string/text:
  //    title: Responsive.valueWhen(
  //      context: context,
  //      mobile: 'Short',
  //      tablet: 'Medium Title',
  //      desktop: 'Full Title Text',
  //    ),
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
