import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/auth_exception.dart';
import '../camera/camera_capture_page.dart';
import 'provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  String? _capturedImagePath;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_emailController.text, _passwordController.text);
      if (!mounted) return;
      // final nav = Navigator.of(context);
      // if (nav.canPop()) {
      //   nav.pop(true); 
      // } else {
      //   nav.pushReplacementNamed('/home');
      // }

      Navigator.pushReplacementNamed(context, '/home');

    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openCameraAndCapture() async {
    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(),
      ),
    );

    if (!mounted || imagePath == null) return;

    setState(() {
      _capturedImagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset(AppConstants.logoAssetPath),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enabled: !auth.isBusy,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return 'Please enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed: auth.isBusy
                      ? null
                      : () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                ),
              ),
              obscureText: _obscurePassword,
              enabled: !auth.isBusy,
              validator: (value) {
                final v = value ?? '';
                if (v.isEmpty) return 'Please enter your password';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: auth.isBusy ? null : _submit,
              child: auth.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: auth.isBusy ? null : _openCameraAndCapture,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Open Camera'),
            ),
            if (_capturedImagePath != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_capturedImagePath!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
