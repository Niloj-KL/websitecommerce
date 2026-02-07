class CartItem {
  final String itemId;
  final String productSlug;
  final String title;
  final int priceLkr;
  final String? imageUrl;
  final String size;
  final int qty;

  const CartItem({
    required this.itemId,
    required this.productSlug,
    required this.title,
    required this.priceLkr,
    required this.imageUrl,
    required this.size,
    required this.qty,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        itemId: j['itemId'],
        productSlug: j['productSlug'],
        title: j['title'],
        priceLkr: j['priceLkr'],
        imageUrl: j['imageUrl'],
        size: j['size'],
        qty: j['qty'],
      );
}

class Cart {
  final List<CartItem> items;
  final int subtotalLkr;
  final int totalLkr;

  const Cart({required this.items, required this.subtotalLkr, required this.totalLkr});

  factory Cart.fromJson(Map<String, dynamic> j) => Cart(
        items: (j['items'] as List).map((e) => CartItem.fromJson(e)).toList(),
        subtotalLkr: j['subtotalLkr'],
        totalLkr: j['totalLkr'],
      );
}
