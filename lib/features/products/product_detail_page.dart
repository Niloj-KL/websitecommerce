import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/shop_shell.dart';

class ProductDetailPage extends StatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final service = ProductService();
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<Map<String, dynamic>>(
          future: service.getProduct(widget.slug),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('API error: ${snap.error}'));
            }

            final product = Product.fromJson(snap.data!);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  product.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),

                // Image area (later: carousel)
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
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSelected,
                      onSelected: product.inStock ? (_) => setState(() => selectedSize = s) : null,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!product.inStock || selectedSize == null)
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${product.title} ($selectedSize)')),
                            );
                          },
                    child: Text(!product.inStock ? 'Out of stock' : 'Ad
