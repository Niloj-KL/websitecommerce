import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cart.dart';
import '../../services/cart_service.dart';
import '../../state/cart_state.dart';
import '../../widgets/shop_shell.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final service = CartService();
  late Future<Cart> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<Cart> _load() async {
    final json = await service.getCart();
    return Cart.fromJson(json);
  }

  Future<void> _refreshAll() async {
    setState(() => future = _load());
    await ref.read(cartProvider.notifier).refresh(); // update badge count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShopShell(
        child: FutureBuilder<Cart>(
          future: future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Cart API error: ${snap.error}'));
            }

            final cart = snap.data!;
            if (cart.items.isEmpty) {
              return const Center(child: Text('Your cart is empty'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),

                ...cart.items.map(
                  (it) => _CartRow(
                    item: it,
                    onMinus: () async {
                      final newQty = it.qty - 1;
                      if (newQty < 1) return;
                      await ref.read(cartProvider.notifier).updateQty(itemId: it.itemId, qty: newQty);
                      await _refreshAll();
                    },
                    onPlus: () async {
                      await ref.read(cartProvider.notifier).updateQty(itemId: it.itemId, qty: it.qty + 1);
                      await _refreshAll();
                    },
                    onRemove: () async {
                      await ref.read(cartProvider.notifier).removeItem(it.itemId);
                      await _refreshAll();
                    },
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('Rs. ${cart.subtotalLkr}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('Rs. ${cart.totalLkr}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Next: Checkout')),
                      );
                    },
                    child: const Text('Checkout'),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  const _CartRow({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDEDED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Size: ${item.size} • Rs. ${item.priceLkr}'),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
              Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.w800)),
              IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
            ],
          ),

          IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }
}
