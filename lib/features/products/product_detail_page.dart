import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../state/cart_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shop_shell.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final service = ProductService();
  String? selectedSize;
  bool adding = false;

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  Future<Map<String, dynamic>> _loadAll() async {
    final productJson = await service.getProduct(widget.slug);
    final collection = (productJson['collection'] ?? '').toString();
    final relatedJson = collection.isEmpty
        ? <dynamic>[]
        : await service.listProducts(collection: collection);

    return {
      "product": productJson,
      "related": relatedJson,
    };
  }

  Future<void> _addToCart(Product p) async {
    if (!p.inStock) return;
    if (selectedSize == null) return;

    setState(() => adding = true);
    try {
      await ref.read(cartProvider.notifier).addItem(
            productSlug: p.slug,
            size: selectedSize!,
            qty: 1,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${p.title} ($selectedSize)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('API error: ${snap.error}'));
            }

            final product = Product.fromJson(snap.data!['product'] as Map<String, dynamic>);
            final related = (snap.data!['related'] as List)
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .where((p) => p.slug != product.slug)
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final cols = _columnsForWidth(constraints.maxWidth);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),

                    // Image area (carousel next step)
                    Container(
                      height: 380,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDEDED)),
                      ),
                      alignment: Alignment.center,
                      child: product.imageUrls.isEmpty
                          ? const Icon(Icons.image_outlined, size: 60)
                          : Image.network(product.imageUrls.first, fit: BoxFit.cover),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Text(
                          'Rs. ${_formatInt(product.priceLkr)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        if (product.compareAtPriceLkr != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            'Rs. ${_formatInt(product.compareAtPriceLkr!)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Text('Size', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: product.sizes.map((s) {
                        final isSelected = selectedSize == s;
                        // for now, if product out of stock, disable all sizes
                        return ChoiceChip(
                          label: Text(s),
                          selected: isSelected,
                          onSelected: (!product.inStock || adding)
                              ? null
                              : (_) => setState(() => selectedSize = s),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: (!product.inStock || selectedSize == null || adding)
                            ? null
                            : () => _addToCart(product),
                        child: adding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(!product.inStock ? 'Out of stock' : 'Add to cart'),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text('Description', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      (snap.data!['product']['description'] ?? 'No description').toString(),
                      style: const TextStyle(color: Colors.black87),
                    ),

                    const SizedBox(height: 24),

                    if (related.isNotEmpty) ...[
                      const Text(
                        'Related products',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: related.length > 8 ? 8 : related.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, i) => ProductCard(product: related[i]),
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

  static String _formatInt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
