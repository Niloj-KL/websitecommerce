class Collection {
  final String name;
  final String slug;

  const Collection({required this.name, required this.slug});

  factory Collection.fromJson(Map<String, dynamic> j) => Collection(
        name: (j['name'] ?? '') as String,
        slug: (j['slug'] ?? '') as String,
      );
}
