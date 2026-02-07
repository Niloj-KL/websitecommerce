import 'package:dio/dio.dart';
import 'api_config.dart';
import 'cart_id.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cartId = await CartIdStore.getOrCreate();
        options.headers['X-Cart-Id'] = cartId;
        handler.next(options);
      },
    ),
  );
