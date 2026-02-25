import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import 'quick_add_sheet.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEDED)),
          boxShadow: hovered
              ? [
                  const BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x14000000),
                  )
                ]
              : null,
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/p/${p.slug}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFF5F5F5),
                        child: p.imageUrls.isEmpty
                            ? const Center(child: Icon(Icons.image_outlined, size: 44))
                            : Image.network(
                                p.imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, index, stackTrace) => const Center(
                                  child: Icon(Icons.image_not_supported_outlined, size: 44),
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _Badge(
                          text: p.compareAtPriceLkr != null ? 'SALE' : (p.inStock ? 'NEW' : 'OUT'),
                        ),
                      ),
                      if (hovered)
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  showDragHandle: true,
                                  isScrollControlled: true,
                                  builder: (_) => QuickAddSheet(product: p),
                                );
                              },
                              child: const Text('Quick add'),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Rs. ${_formatInt(p.priceLkr)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (p.compareAtPriceLkr != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Rs. ${_formatInt(p.compareAtPriceLkr!)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Pay in 3 installments (demo)',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
