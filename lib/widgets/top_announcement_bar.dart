import 'package:flutter/material.dart';

class TopAnnouncementBar extends StatelessWidget {
  const TopAnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F10), Color(0xFF2A2A2C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Free delivery islandwide on orders above Rs. 8,000',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          letterSpacing: 0.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
