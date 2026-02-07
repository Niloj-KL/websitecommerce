import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class QuickAddSheet extends StatefulWidget {
  final Product product;

  const QuickAddSheet({
    super.key,
    required this.product,
  });

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _cart = CartService();
  String? selectedSize;
  bool isLoading = false;

  Future<void> _addToCart() async {
    final p = widget.product;

    if (!p.inStock) return;
    if (selectedSize == null) return;

    setState(() => isLoading = true);
    try {
      await _cart.addItem(
        productSlug: p.slug,
        size: selectedSize!,
        qty: 1,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${p.title} ($selectedSize)')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            const Text('Select size', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: p.sizes.map((s) {
                final selected = selectedSize == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (!p.inStock || isLoading)
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
                onPressed: (isLoading || !p.inStock || selectedSize == null) ? null : _addToCart,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(!p.inStock ? 'Out of stock' : 'Add to cart'),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Tip: Cart is linked using X-Cart-Id header (guest cart).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
