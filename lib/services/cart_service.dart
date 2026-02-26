import '../core/http_client.dart';

class CartService {
  Future<Map<String, dynamic>> getCart() async {
    final res = await dio.get('/cart');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addItem({
    required String productSlug,
    required String size,
    int qty = 1,
  }) async {
    final res = await dio.post(
      '/cart/items',
      data: {'productSlug': productSlug, 'size': size, 'qty': qty},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateQty({
    required String itemId,
    required int qty,
  }) async {
    final res = await dio.patch('/cart/items/$itemId', data: {'qty': qty});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> removeItem(String itemId) async {
    final res = await dio.delete('/cart/items/$itemId');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkout({
    required bool useProfileContact,
    String? customerPhone,
    String? deliveryAddress,
  }) async {
    final res = await dio.post(
      '/checkout',
      data: {
        'useProfileContact': useProfileContact,
        'customerPhone': customerPhone,
        'deliveryAddress': deliveryAddress,
      },
    );
    return res.data as Map<String, dynamic>;
  }
}
