import 'package:dio/dio.dart';
import 'api_config.dart';
import 'cart_id.dart';
import 'user_session.dart';

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
        final userToken = await UserSessionStore.getToken();
        if (userToken != null && userToken.isNotEmpty) {
          options.headers['X-User-Token'] = userToken;
        }
        handler.next(options);
      },
    ),
  );
