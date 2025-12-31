import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDEDED))),
        color: Colors.white,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: const Text(
              'YOURBRAND',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 24),

          // Menu links (simple)
          _NavItem(title: 'HOME', onTap: () => context.go('/')),
          _NavItem(title: 'COLLECTIONS', onTap: () => context.go('/collections')),

          const Spacer(),

          // Search
          SizedBox(
            width: 260,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          IconButton(
            onPressed: () => context.go('/account'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Account',
          ),
          IconButton(
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Cart',
          ),
        ],
      ),
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
