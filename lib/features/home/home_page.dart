import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/cart_state.dart';
import '../../widgets/shop_shell.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // refresh cart count once app opens (safe way)
    Future.microtask(() => ref.read(cartProvider.notifier).refresh());
  }

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
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.go('/c/tshirts'),
                  child: const Text('Go to T-Shirts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
