class Product {
  final String id;
  final String slug;
  final String title;
  final int priceLkr;
  final int? compareAtPriceLkr; // optional discount comparison price
  final List<String> imageUrls;
  final List<String> sizes; // e.g. ["S","M","L","XL"]
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
}
