import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/brand_text_styles.dart';
import '../../state/user_state.dart';
import '../../widgets/shop_shell.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSignUp = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(userProvider.notifier);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    String? error;
    if (_isSignUp) {
      error = await notifier.signup(
        fullName: _nameController.text.trim(),
        email: email,
        password: password,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    } else {
      error = await notifier.login(email: email, password: password);
    }
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isSignUp ? 'Account created successfully.' : 'Logged in successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final profile = userState.profile;

    return Scaffold(
      body: ShopShell(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'My Account',
              style: formalHeadingStyle(size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your profile and order preferences.',
              style: inlineAccentStyle(),
            ),
            const SizedBox(height: 14),
            if (profile == null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Create your account' : 'Login to your account',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    if (_isSignUp) ...[
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'At least 8 chars with letters and numbers',
                      ),
                    ),
                    if (_isSignUp) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Phone (10 digits)'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _addressController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: userState.loading ? null : _submit,
                        child: Text(userState.loading
                            ? 'Please wait...'
                            : (_isSignUp ? 'Sign Up' : 'Login')),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: userState.loading
                          ? null
                          : () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Login'
                            : 'New here? Create account',
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text('Name: ${profile.fullName}'),
                    Text('Email: ${profile.email}'),
                    Text('Phone: ${profile.phone}'),
                    const SizedBox(height: 6),
                    Text('Address: ${profile.address}'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: userState.loading
                            ? null
                            : () => ref.read(userProvider.notifier).logout(),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
