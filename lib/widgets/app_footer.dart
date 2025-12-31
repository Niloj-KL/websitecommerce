import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Policies', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Terms of Service • Privacy Policy • Refund Policy'),
          SizedBox(height: 12),
          Text('© YOURBRAND'),
        ],
      ),
    );
  }
}
