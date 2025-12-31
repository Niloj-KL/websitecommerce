import 'package:flutter/material.dart';
import '../../widgets/shop_shell.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Hero Banner Area',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/collections'),
                  child: const Text('View Collections'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
