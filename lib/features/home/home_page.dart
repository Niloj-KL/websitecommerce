import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand_text_styles.dart';
import '../../state/cart_state.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/scroll_reveal.dart';
import '../../widgets/shop_shell.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // refresh cart count once app opens (safe way)
    Future.microtask(() => ref.read(cartProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ScrollReveal(
              child: _HeroBanner(
                onShopNow: () => context.go('/collections'),
                onExploreKurtis: () => context.go('/c/kurtis'),
              ),
            ),
            const SizedBox(height: 22),
            const ScrollReveal(
              delayMs: 60,
              child: _SectionTitle(
                title: 'Shop by Category',
                subtitle: 'Explore our curated essentials and statement styles.',
              ),
            ),
            const SizedBox(height: 12),
            ScrollReveal(
              delayMs: 100,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _CategoryChip(
                    label: 'Kurtis',
                    onTap: () => context.go('/c/kurtis'),
                  ),
                  _CategoryChip(
                    label: 'T-Shirts',
                    onTap: () => context.go('/c/tshirts'),
                  ),
                  _CategoryChip(
                    label: 'Shirts',
                    onTap: () => context.go('/c/shirts'),
                  ),
                  _CategoryChip(
                    label: 'Dress',
                    onTap: () => context.go('/c/dress'),
                  ),
                  _CategoryChip(
                    label: 'All Collections',
                    onTap: () => context.go('/products/all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ScrollReveal(
              delayMs: 140,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F4EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6D6C5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Islandwide delivery. Easy exchanges. Secure checkout.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const ScrollReveal(
              delayMs: 170,
              child: _SectionTitle(
                title: 'New Arrivals',
                subtitle: 'Freshly added picks selected for this week.',
              ),
            ),
            const SizedBox(height: 10),
            ScrollReveal(
              delayMs: 220,
              child: FutureBuilder<List<dynamic>>(
                future: _productService.listHomepageProducts(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snap.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Unable to load products right now.'),
                    );
                  }
                  final products = (snap.data ?? [])
                      .map((e) => Product.fromJson(e as Map<String, dynamic>))
                      .toList();
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No products available yet.'),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 280,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.70,
                    ),
                    itemBuilder: (context, i) =>
                        ProductCard(product: products[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onShopNow;
  final VoidCallback onExploreKurtis;

  const _HeroBanner({required this.onShopNow, required this.onExploreKurtis});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        return Container(
          constraints: const BoxConstraints(minHeight: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF2C2C2C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _HeroTextBlock(),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: onShopNow,
                          child: const Text('Shop Now'),
                        ),
                        OutlinedButton(
                          onPressed: onExploreKurtis,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          child: const Text('Explore Kurtis'),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _HeroTextBlock(),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            children: [
                              ElevatedButton(
                                onPressed: onShopNow,
                                child: const Text('Shop Now'),
                              ),
                              OutlinedButton(
                                onPressed: onExploreKurtis,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white54),
                                ),
                                child: const Text('Explore Kurtis'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.checkroom, size: 120, color: Colors.white24),
                  ],
                ),
        );
      },
    );
  }
}

class _HeroTextBlock extends StatelessWidget {
  const _HeroTextBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elegant Way',
          style: brandRoundedStyle(
            size: 15,
            weight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'New Season\nCollection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Modern everyday fashion with premium comfort.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: formalHeadingStyle(size: 24, weight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: inlineAccentStyle()),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
