import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand_text_styles.dart';
import '../../core/user_friendly_messages.dart';
import '../../models/cart.dart';
import '../../services/cart_service.dart';
import '../../state/cart_state.dart';
import '../../state/user_state.dart';
import '../../widgets/shop_shell.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final service = CartService();
  late Future<Cart> future;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _checkingOut = false;
  bool _useProfileContact = true;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<Cart> _load() async {
    final json = await service.getCart();
    return Cart.fromJson(json);
  }

  Future<void> _refreshAll() async {
    setState(() => future = _load());
    await ref.read(cartProvider.notifier).refresh(); // update badge count
  }

  Future<void> _checkout() async {
    final userState = ref.read(userProvider);
    final profile = userState.profile;
    if (profile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before checkout.')),
      );
      context.go('/account');
      return;
    }

    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final phoneRegex = RegExp(r'^\d{10}$');

    if (!_useProfileContact && (phone.isEmpty || address.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number and address are required.'),
        ),
      );
      return;
    }
    if (!_useProfileContact && !phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be exactly 10 digits.'),
        ),
      );
      return;
    }

    setState(() => _checkingOut = true);
    try {
      final res = await service.checkout(
        useProfileContact: _useProfileContact,
        customerPhone: _useProfileContact ? null : phone,
        deliveryAddress: _useProfileContact ? null : address,
      );
      final order = res['order'] as Map<String, dynamic>;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed: ${order['orderId']}')),
      );
      await _refreshAll();
      _phoneController.clear();
      _addressController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(kMaintenanceMessage)));
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
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
              return const Center(child: Text(kMaintenanceMessage));
            }

            final cart = snap.data!;
            final userState = ref.watch(userProvider);
            final profile = userState.profile;
            if (cart.items.isEmpty) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  child: const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Your Cart',
                  style: formalHeadingStyle(size: 28),
                ),
                const SizedBox(height: 12),

                ...cart.items.map(
                  (it) => _CartRow(
                    item: it,
                    onMinus: () async {
                      final newQty = it.qty - 1;
                      if (newQty < 1) return;
                      await ref
                          .read(cartProvider.notifier)
                          .updateQty(itemId: it.itemId, qty: newQty);
                      await _refreshAll();
                    },
                    onPlus: () async {
                      await ref
                          .read(cartProvider.notifier)
                          .updateQty(itemId: it.itemId, qty: it.qty + 1);
                      await _refreshAll();
                    },
                    onRemove: () async {
                      await ref
                          .read(cartProvider.notifier)
                          .removeItem(it.itemId);
                      await _refreshAll();
                    },
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEDEDED)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text('Rs. ${cart.subtotalLkr}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const Spacer(),
                          Text(
                            'Rs. ${cart.totalLkr}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (profile == null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF0D0D0)),
                          ),
                          child: const Text(
                            'Please create an account and login before placing an order.',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      else ...[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Use my saved phone and address',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${profile.phone} • ${profile.address}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: _useProfileContact,
                          onChanged: (v) => setState(() => _useProfileContact = v),
                        ),
                        if (!_useProfileContact) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'New phone (10 digits) *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _addressController,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'New delivery address *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (profile == null || _checkingOut) ? null : _checkout,
                          child: Text(
                            _checkingOut ? 'Processing...' : 'Checkout',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
        color: Colors.white,
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
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('Size: ${item.size} • Rs. ${item.priceLkr}'),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(
                onPressed: onMinus,
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: 'Decrease quantity',
              ),
              Text(
                '${item.qty}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: onPlus,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Increase quantity',
              ),
            ],
          ),

          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
