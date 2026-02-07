import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_service.dart';

class CartState {
  final int itemCount;
  const CartState({required this.itemCount});

  CartState copyWith({int? itemCount}) => CartState(itemCount: itemCount ?? this.itemCount);
}

class CartNotifier extends StateNotifier<CartState> {
  final CartService _service;
  CartNotifier(this._service) : super(const CartState(itemCount: 0));

  Future<void> refresh() async {
    final json = await _service.getCart();
    final items = (json['items'] as List? ?? []);
    final count = items.fold<int>(0, (sum, it) => sum + (it['qty'] as int? ?? 0));
    state = state.copyWith(itemCount: count);
  }

  // Call this after adding to cart
  Future<void> addItem({
    required String productSlug,
    required String size,
    int qty = 1,
  }) async {
    await _service.addItem(productSlug: productSlug, size: size, qty: qty);
    await refresh();
  }

  Future<void> removeItem(String itemId) async {
    await _service.removeItem(itemId);
    await refresh();
  }

  Future<void> updateQty({required String itemId, required int qty}) async {
    await _service.updateQty(itemId: itemId, qty: qty);
    await refresh();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(CartService());
});
