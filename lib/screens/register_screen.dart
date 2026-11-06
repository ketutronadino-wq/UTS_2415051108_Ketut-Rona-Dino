import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    switch (result) {
      case RegisterResult.signedIn:
        messenger.showSnackBar(const SnackBar(content: Text('Registrasi berhasil!'), backgroundColor: Colors.green));
        navigator.popUntil((route) => route.isFirst);
      case RegisterResult.needsConfirmation:
        messenger.showSnackBar(const SnackBar(content: Text('Registrasi berhasil. Cek email Anda.'), backgroundColor: Colors.green));
        navigator.pop();
      case RegisterResult.failed:
        messenger.showSnackBar(SnackBar(content: Text(auth.error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController, enabled: !isLoading,
                    decoration: const InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                    validator: (value) => Validators.notEmpty(value, 'Nama'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController, enabled: !isLoading, keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController, enabled: !isLoading, obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: Validators.newPassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController, enabled: !isLoading, obscureText: _obscurePassword,
                    decoration: const InputDecoration(labelText: 'Konfirmasi Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                    validator: (value) => Validators.confirmPassword(value, _passwordController.text),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(text: 'Register', icon: Icons.person_add, isLoading: isLoading, onPressed: _submit),
                  const SizedBox(height: 8),
                  TextButton(onPressed: isLoading ? null : () => Navigator.pop(context), child: const Text('Sudah punya akun? Login')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}