import '../core/http_client.dart';
import 'package:dio/dio.dart';

class ProductService {
  Future<List<dynamic>> listProducts({String? collection}) async {
    final res = await dio.get(
      '/products',
      queryParameters: {if (collection != null) 'collection': collection},
    );
    return (res.data as List);
  }

  Future<List<dynamic>> listHomepageProducts() async {
    final res = await dio.get('/homepage-products');
    return (res.data as List);
  }

  Future<List<dynamic>> searchProducts({required String q}) async {
    final res = await dio.get('/products', queryParameters: {'q': q});
    return (res.data as List);
  }

  Future<Map<String, dynamic>> getProduct(String slug) async {
    final res = await dio.get('/products/$slug');
    return (res.data as Map<String, dynamic>);
  }

  Future<String> adminLogin({
    required String username,
    required String password,
  }) async {
    final res = await dio.post(
      '/admin/login',
      data: {'username': username, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    return (data['token'] ?? '') as String;
  }

  Future<void> adminLogout({required String adminToken}) async {
    await dio.post(
      '/admin/logout',
      options: Options(headers: {'X-Admin-Token': adminToken}),
    );
  }

  Future<List<dynamic>> adminListProducts({required String adminToken}) async {
    final res = await dio.get(
      '/admin/products',
      options: Options(headers: {'X-Admin-Token': adminToken}),
    );
    return (res.data as List);
  }

  Future<Map<String, dynamic>> adminUpdateProduct({
    required String adminToken,
    required String slug,
    String? title,
    int? priceLkr,
    int? compareAtPriceLkr,
    List<String>? imageUrls,
  }) async {
    final payload = <String, dynamic>{};
    if (title != null && title.trim().isNotEmpty) {
      payload['title'] = title.trim();
    }
    if (priceLkr != null) payload['priceLkr'] = priceLkr;
    if (compareAtPriceLkr != null) {
      payload['compareAtPriceLkr'] = compareAtPriceLkr;
    }
    if (imageUrls != null) payload['imageUrls'] = imageUrls;

    final res = await dio.patch(
      '/admin/products/$slug',
      data: payload,
      options: Options(headers: {'X-Admin-Token': adminToken}),
    );
    return (res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> adminUploadImage({
    required String adminToken,
    required String productSlug,
    required String fileName,
    required List<int> fileBytes,
    int? priceLkr,
    int? compareAtPriceLkr,
  }) async {
    final formData = FormData.fromMap({
      'productSlug': productSlug,
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      if (priceLkr != null) 'priceLkr': priceLkr,
      if (compareAtPriceLkr != null) 'compareAtPriceLkr': compareAtPriceLkr,
    });

    final res = await dio.post(
      '/admin/upload-image',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'X-Admin-Token': adminToken},
      ),
    );
    return (res.data as Map<String, dynamic>);
  }

  Future<List<dynamic>> adminListOrders({required String adminToken}) async {
    final res = await dio.get(
      '/admin/orders',
      options: Options(headers: {'X-Admin-Token': adminToken}),
    );
    return (res.data as List);
  }
}
