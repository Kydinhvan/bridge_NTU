import 'package:flutter/material.dart';

class Responsive {
  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double cardWidth(BuildContext context) {
    if (isPhone(context)) return double.infinity;
    if (isTablet(context)) return 520;
    return 480;
  }

  // Centered kiosk/desktop layout wrapper
  static Widget centeredCard(BuildContext context, Widget child) {
    if (isPhone(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardWidth(context)),
        child: child,
      ),
    );
  }
}
