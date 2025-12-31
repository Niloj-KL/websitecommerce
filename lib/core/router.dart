import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/collections/collections_page.dart';
import '../features/products/product_detail_page.dart';
import '../features/products/product_list_page.dart';
import '../features/cart/cart_page.dart';
import '../features/account/account_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/collections', builder: (c, s) => const CollectionsPage()),
      GoRoute(
        path: '/c/:slug',
        builder: (c, s) => ProductListPage(slug: s.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/p/:slug',
        builder: (c, s) => ProductDetailPage(slug: s.pathParameters['slug']!),
      ),
      GoRoute(path: '/cart', builder: (c, s) => const CartPage()),
      GoRoute(path: '/account', builder: (c, s) => const AccountPage()),
    ],
  );
});
