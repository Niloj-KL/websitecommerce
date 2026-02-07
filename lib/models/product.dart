class Product {
  final String id;
  final String slug;
  final String title;
  final int priceLkr;
  final int? compareAtPriceLkr;
  final List<String> imageUrls;
  final List<String> sizes;
  final bool inStock;

  const Product({
    required this.id,
    required this.slug,
    required this.title,
    required this.priceLkr,
    this.compareAtPriceLkr,
    required this.imageUrls,
    required this.sizes,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> j) {
    return Product(
      id: (j['id'] ?? '') as String,
      slug: (j['slug'] ?? '') as String,
      title: (j['title'] ?? '') as String,
      priceLkr: (j['priceLkr'] ?? 0) as int,
      compareAtPriceLkr: j['compareAtPriceLkr'] as int?,
      imageUrls: (j['imageUrls'] as List? ?? []).cast<String>(),
      sizes: (j['sizes'] as List? ?? []).cast<String>(),
      inStock: (j['inStock'] ?? true) as bool,
    );
  }
}
