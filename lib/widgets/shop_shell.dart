import 'package:flutter/material.dart';
import 'top_announcement_bar.dart';
import 'app_header.dart';
import 'app_footer.dart';

class ShopShell extends StatelessWidget {
  final Widget child;
  const ShopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFEFA), Color(0xFFF9F2E3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFF1DFC1).withValues(alpha: 0.42),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -80,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EAD6).withValues(alpha: 0.34),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Column(
          children: [
            const TopAnnouncementBar(),
            const AppHeader(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: child,
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ],
    );
  }
}
