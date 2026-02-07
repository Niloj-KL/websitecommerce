import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shop_shell.dart';

class ProductListPage extends StatelessWidget {
  final String slug;
  const ProductListPage({super.key, required this.slug});

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final products = List.generate(16, (i) {
      return Product(
        id: 'p$i',
        slug: 'product-$i',
        title: 'Cotton Tee - Model ${i + 1}',
        priceLkr: 4990 + (i * 150),
        compareAtPriceLkr: i % 5 == 0 ? (5990 + i * 150) : null,
        imageUrls: const [],
        sizes: const ['S', 'M', 'L', 'XL'],
        inStock: i % 9 != 0,
      );
    });

    return Scaffold(
      body: ShopShell(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cols = _columnsForWidth(constraints.maxWidth);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text(
                      slug.toUpperCase(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    DropdownButton<String>(
                      value: 'new',
                      items: const [
                        DropdownMenuItem(value: 'new', child: Text('Newest')),
                        DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                        DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                      ],
                      onChanged: (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, i) => ProductCard(product: products[i]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
