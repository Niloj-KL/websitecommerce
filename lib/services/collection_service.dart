import '../core/http_client.dart';

class CollectionService {
  Future<List<dynamic>> listCollections() async {
    final res = await dio.get('/collections');
    return (res.data as List);
  }
}
