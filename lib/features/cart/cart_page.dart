import 'package:flutter/material.dart';
import '../../widgets/shop_shell.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ShopShell(
        child: Center(child: Text('Cart Page')),
      ),
    );
  }
}
