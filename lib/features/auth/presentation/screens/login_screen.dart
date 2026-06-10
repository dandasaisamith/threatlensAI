import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen for user authentication
/// 
/// Handles user sign-in and account creation
class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ThreatLens AI'),
      ),
      body: const Center(
        child: Text('Login Screen - Coming Soon'),
      ),
    );
  }
}
