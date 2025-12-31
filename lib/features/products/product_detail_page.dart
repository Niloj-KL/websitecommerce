import 'package:flutter/material.dart';
import '../../widgets/shop_shell.dart';

class ProductDetailPage extends StatelessWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              slug,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Container(
              height: 340,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_outlined, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Rs. 5990', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: ['S', 'M', 'L', 'XL']
                  .map((s) => ChoiceChip(label: Text(s), selected: false))
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 240,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
