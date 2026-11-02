import 'package:flutter/material.dart';

import 'app_navigation_bar.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: const AppNavigationBar(),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  );
}
