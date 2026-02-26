import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand_text_styles.dart';
import '../../core/user_friendly_messages.dart';
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
  int selectedQty = 1;
  bool adding = false;
  final PageController _imagePageController = PageController();
  int _activeImageIndex = 0;

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

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

    return {"product": productJson, "related": relatedJson};
  }

  Future<void> _addToCart(Product p) async {
    if (!p.inStock) return;
    if (selectedSize == null) return;

    setState(() => adding = true);
    try {
      await ref
          .read(cartProvider.notifier)
          .addItem(productSlug: p.slug, size: selectedSize!, qty: selectedQty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${p.title} ($selectedSize) x$selectedQty'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(kActionFailedMessage)));
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
              return const Center(child: Text(kMaintenanceMessage));
            }

            final product = Product.fromJson(
              snap.data!['product'] as Map<String, dynamic>,
            );
            if (product.imageUrls.isNotEmpty && _activeImageIndex >= product.imageUrls.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _imagePageController.jumpToPage(0);
                setState(() => _activeImageIndex = 0);
              });
            }
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 980;
                        final detailsCard = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: formalHeadingStyle(size: 30),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Rs. ${_formatInt(product.priceLkr)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
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
                              const Text(
                                'Select Size',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: product.sizes.map((s) {
                                  final isSelected = selectedSize == s;
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
                              const Text(
                                'Quantity',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        (!product.inStock || adding || selectedQty <= 1)
                                        ? null
                                        : () => setState(() => selectedQty -= 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                      ),
                                    ),
                                    child: Text(
                                      '$selectedQty',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (!product.inStock || adding)
                                        ? null
                                        : () => setState(() => selectedQty += 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  onPressed: (!product.inStock ||
                                          selectedSize == null ||
                                          adding)
                                      ? null
                                      : () => _addToCart(product),
                                  child: adding
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          !product.inStock
                                              ? 'Out of stock'
                                              : 'Add to cart',
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );

                        final imageCard = Container(
                          height: 420,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEDEDED)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: product.imageUrls.isEmpty
                              ? const Center(child: Icon(Icons.image_outlined, size: 60))
                              : Stack(
                                  children: [
                                    PageView.builder(
                                      controller: _imagePageController,
                                      itemCount: product.imageUrls.length,
                                      onPageChanged: (i) =>
                                          setState(() => _activeImageIndex = i),
                                      itemBuilder: (context, i) {
                                        return Container(
                                          color: const Color(0xFFF8F8F8),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.all(12),
                                          child: Image.network(
                                            product.imageUrls[i],
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.image_not_supported_outlined,
                                                      size: 60,
                                                    ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (product.imageUrls.length > 1)
                                      Positioned(
                                        right: 12,
                                        top: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.62),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '${_activeImageIndex.clamp(0, product.imageUrls.length - 1) + 1}/${product.imageUrls.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (product.imageUrls.length > 1)
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 10,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            product.imageUrls.length,
                                            (i) => Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 3),
                                              width: i == _activeImageIndex ? 18 : 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                color: i == _activeImageIndex
                                                    ? Colors.black87
                                                    : Colors.black26,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: imageCard),
                              const SizedBox(width: 16),
                              Expanded(flex: 4, child: detailsCard),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            imageCard,
                            const SizedBox(height: 16),
                            detailsCard,
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),

                    Text(
                      'Description',
                      style: formalHeadingStyle(size: 24, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (snap.data!['product']['description'] ??
                              'No details available')
                          .toString(),
                      style: const TextStyle(color: Colors.black87),
                    ),

                    const SizedBox(height: 24),

                    if (related.isNotEmpty) ...[
                      Text(
                        'Related products',
                        style: formalHeadingStyle(size: 24, weight: FontWeight.w600),
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
                        itemBuilder: (context, i) =>
                            ProductCard(product: related[i]),
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
