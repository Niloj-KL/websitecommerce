import 'package:flutter/material.dart';

import '../../core/brand_text_styles.dart';
import '../../core/user_friendly_messages.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shop_shell.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final service = ProductService();
  static const int _pageSize = 12;
  int _currentPage = 0;

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<List<dynamic>>(
          future: service.listProducts(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return const Center(child: Text(kMaintenanceMessage));
            }

            final products = (snap.data ?? [])
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .toList();
            final totalPages = products.isEmpty
                ? 1
                : ((products.length + _pageSize - 1) ~/ _pageSize);
            final safePage = _currentPage.clamp(0, totalPages - 1);
            final start = safePage * _pageSize;
            final end = (start + _pageSize) > products.length
                ? products.length
                : (start + _pageSize);
            final pageItems = products.sublist(start, end);

            return LayoutBuilder(
              builder: (context, constraints) {
                final cols = _columnsForWidth(constraints.maxWidth);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF7F4F0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Products',
                            style: formalHeadingStyle(size: 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${products.length} items • Page ${safePage + 1} of $totalPages',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Browse every product from all collections.',
                            style: inlineAccentStyle(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (products.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEDEDED)),
                        ),
                        child: const Center(
                          child: Text('No products available yet.'),
                        ),
                      )
                    else ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pageItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, i) =>
                            ProductCard(product: pageItems[i]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: safePage > 0
                                ? () => setState(
                                    () => _currentPage = safePage - 1,
                                  )
                                : null,
                            child: const Text('Previous'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${safePage + 1} / $totalPages',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: safePage < totalPages - 1
                                ? () => setState(
                                    () => _currentPage = safePage + 1,
                                  )
                                : null,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
