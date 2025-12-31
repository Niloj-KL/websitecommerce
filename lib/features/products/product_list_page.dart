import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shop_shell.dart';

class ProductListPage extends StatelessWidget {
  final String slug;
  const ProductListPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final products = List.generate(
      12,
      (i) => ('Product ${i + 1}', 'product-${i + 1}', 4990 + i * 250),
    );

    return Scaffold(
      body: ShopShell(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              slug.toUpperCase(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final (name, pSlug, price) = products[i];
                return InkWell(
                  onTap: () => context.go('/p/$pSlug'),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEDEDED)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_outlined, size: 40),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('Rs. $price'),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Quick add'),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
