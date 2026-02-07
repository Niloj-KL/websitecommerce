import '../core/http_client.dart';

class ProductService {
  Future<List<dynamic>> listProducts({String? collection}) async {
    final res = await dio.get(
      '/products',
      queryParameters: {if (collection != null) 'collection': collection},
    );
    return (res.data as List);
  }

  Future<List<dynamic>> searchProducts({required String q}) async {
    final res = await dio.get(
      '/products',
      queryParameters: {'q': q},
    );
    return (res.data as List);
  }

  Future<Map<String, dynamic>> getProduct(String slug) async {
    final res = await dio.get('/products/$slug');
    return (res.data as Map<String, dynamic>);
  }
}
