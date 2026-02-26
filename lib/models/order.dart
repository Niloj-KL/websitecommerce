class OrderItem {
  final String title;
  final String size;
  final int qty;
  final int priceLkr;

  const OrderItem({
    required this.title,
    required this.size,
    required this.qty,
    required this.priceLkr,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    title: (j['title'] ?? '') as String,
    size: (j['size'] ?? '') as String,
    qty: (j['qty'] ?? 0) as int,
    priceLkr: (j['priceLkr'] ?? 0) as int,
  );
}

class Order {
  final String orderId;
  final String createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  final int totalLkr;
  final List<OrderItem> items;

  const Order({
    required this.orderId,
    required this.createdAt,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.totalLkr,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    orderId: (j['orderId'] ?? '') as String,
    createdAt: (j['createdAt'] ?? '') as String,
    customerName: j['customerName'] as String?,
    customerPhone: j['customerPhone'] as String?,
    deliveryAddress: j['deliveryAddress'] as String?,
    totalLkr: (j['totalLkr'] ?? 0) as int,
    items: (j['items'] as List? ?? [])
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
