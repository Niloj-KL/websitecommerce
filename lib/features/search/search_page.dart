import 'package:flutter/material.dart';
import '../../core/brand_text_styles.dart';
import '../../core/user_friendly_messages.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shop_shell.dart';

class SearchPage extends StatefulWidget {
  final String q;
  const SearchPage({super.key, required this.q});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final service = ProductService();

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.q.trim();

    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<List<dynamic>>(
          future: service.searchProducts(q: query),
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

            return LayoutBuilder(
              builder: (context, constraints) {
                final cols = _columnsForWidth(constraints.maxWidth);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF7F4F0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search: "$query"',
                              style: formalHeadingStyle(size: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (products.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Center(child: Text('No results found')),
                      )
                    else
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
                        itemBuilder: (context, i) =>
                            ProductCard(product: products[i]),
                      ),
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
