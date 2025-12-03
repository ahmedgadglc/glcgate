import 'package:flutter/material.dart';
import 'package:glcgate/core/helper/responsive.dart';

extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  ScreenType get screenType => Responsive.getScreenType(this);
}
