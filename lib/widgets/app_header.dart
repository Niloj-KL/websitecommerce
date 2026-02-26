import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand_text_styles.dart';
import '../state/cart_state.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartProvider).itemCount;
    final isCompact = MediaQuery.of(context).size.width < 940;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
        color: Colors.white.withValues(alpha: 0.96),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: Text(
              'Elegant Way',
              style: brandRoundedStyle(
                size: 22,
                weight: FontWeight.w700,
                color: const Color(0xFF1F1A12),
                letterSpacing: 1.2,
              ),
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(width: 24),
            _NavItem(title: 'HOME', onTap: () => context.go('/')),
            _NavItem(
              title: 'COLLECTIONS',
              onTap: () => context.go('/collections'),
            ),
          ],

          const Spacer(),

          // Search
          if (!isCompact)
            const SizedBox(width: 280, child: _HeaderSearchBox())
          else
            IconButton(
              onPressed: () => _showCompactSearch(context),
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
          const SizedBox(width: 8),
          if (!isCompact)
            const VerticalDivider(width: 18, indent: 20, endIndent: 20),

          IconButton(
            onPressed: () => context.go('/account'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Account',
          ),

          // Cart icon with badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.go('/cart'),
                icon: const Icon(Icons.shopping_bag_outlined),
                tooltip: 'Cart',
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      cartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static void _showCompactSearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Search products'),
          content: TextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) {
              final q = controller.text.trim();
              if (q.isEmpty) return;
              Navigator.of(dialogContext).pop();
              context.go('/search?q=${Uri.encodeComponent(q)}');
            },
            decoration: const InputDecoration(hintText: 'Type product name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final q = controller.text.trim();
                if (q.isEmpty) return;
                Navigator.of(dialogContext).pop();
                context.go('/search?q=${Uri.encodeComponent(q)}');
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HeaderSearchBox extends StatefulWidget {
  const _HeaderSearchBox();

  @override
  State<_HeaderSearchBox> createState() => _HeaderSearchBoxState();
}

class _HeaderSearchBoxState extends State<_HeaderSearchBox> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goSearch() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    context.go('/search?q=${Uri.encodeComponent(q)}');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: (_) => _goSearch(),
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: IconButton(
          onPressed: _goSearch,
          icon: const Icon(Icons.arrow_forward),
          tooltip: 'Search',
        ),
        isDense: true,
      ),
    );
  }
}
