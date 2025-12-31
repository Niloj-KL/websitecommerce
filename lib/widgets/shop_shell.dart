import 'package:flutter/material.dart';
import 'top_announcement_bar.dart';
import 'app_header.dart';
import 'app_footer.dart';

class ShopShell extends StatelessWidget {
  final Widget child;
  const ShopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TopAnnouncementBar(),
        const AppHeader(),
        Expanded(child: child),
        const AppFooter(),
      ],
    );
  }
}
