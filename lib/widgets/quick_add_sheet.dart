import 'package:flutter/material.dart';
import '../models/product.dart';

class QuickAddSheet extends StatefulWidget {
  final Product product;
  final void Function(String size) onAdd;

  const QuickAddSheet({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  String? selectedSize;

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
                  onSelected: (_) => setState(() => selectedSize = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (!p.inStock || selectedSize == null)
                    ? null
                    : () {
                        widget.onAdd(selectedSize!);
                        Navigator.pop(context);
                      },
                child: Text(!p.inStock ? 'Out of stock' : 'Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
