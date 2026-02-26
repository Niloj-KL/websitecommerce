import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'state/user_state.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return _SessionBootstrap(
      child: MaterialApp.router(
        title: 'Elegant Way',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    );
  }
}

class _SessionBootstrap extends ConsumerStatefulWidget {
  final Widget child;
  const _SessionBootstrap({required this.child});

  @override
  ConsumerState<_SessionBootstrap> createState() => _SessionBootstrapState();
}

class _SessionBootstrapState extends ConsumerState<_SessionBootstrap> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    Future.microtask(() => ref.read(userProvider.notifier).restoreSession());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
