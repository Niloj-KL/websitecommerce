import 'package:flutter/material.dart';
import '../../widgets/shop_shell.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ShopShell(
        child: Center(child: Text('Account Page')),
      ),
    );
  }
}
