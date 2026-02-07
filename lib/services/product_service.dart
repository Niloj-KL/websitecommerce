import '../core/http_client.dart';

class ProductService {
  Future<List<dynamic>> listProducts({String? collection}) async {
    final res = await dio.get(
      '/products',
      queryParameters: {if (collection != null) 'collection': collection},
    );
    return (res.data as List);
  }
}
