import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/user_friendly_messages.dart';
import '../models/product.dart';
import '../state/cart_state.dart';

class QuickAddSheet extends ConsumerStatefulWidget {
  final Product product;

  const QuickAddSheet({super.key, required this.product});

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  String? selectedSize;
  int selectedQty = 1;
  bool isLoading = false;

  Future<void> _addToCart() async {
    final p = widget.product;
    if (!p.inStock) return;
    if (selectedSize == null) return;

    setState(() => isLoading = true);
    try {
      await ref
          .read(cartProvider.notifier)
          .addItem(productSlug: p.slug, size: selectedSize!, qty: selectedQty);

      if (!mounted) return;
      Navigator.pop(context);
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

            const Text(
              'Select size',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
            const Text(
              'Quantity',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: (isLoading || selectedQty <= 1)
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
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$selectedQty',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: isLoading
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
                onPressed: (isLoading || !p.inStock || selectedSize == null)
                    ? null
                    : _addToCart,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(!p.inStock ? 'Out of stock' : 'Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
