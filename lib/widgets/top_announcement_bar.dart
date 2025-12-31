import 'package:flutter/material.dart';

class TopAnnouncementBar extends StatelessWidget {
  const TopAnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: double.infinity,
      color: Colors.black,
      alignment: Alignment.center,
      child: const Text(
        'Enjoy FREE DELIVERY islandwide on orders above Rs. 15,000',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
