import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shop_shell.dart';

class CollectionsPage extends StatelessWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = const [
      ('All Products', 'all'),
      ('Dress', 'dress'),
      ('Kurtis', 'kurtis'),
      ('T Shirts', 'tshirts'),
      ('Sale', 'sale'),
    ];

    return Scaffold(
      body: ShopShell(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.1,
          ),
          itemCount: collections.length,
          itemBuilder: (context, i) {
            final (name, slug) = collections[i];
            return InkWell(
              onTap: () => context.go('/c/$slug'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
