import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main dashboard screen
///
/// Displays:
/// - Recent threat analyses
/// - Risk statistics
/// - Quick access to features
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('ThreatLens AI Dashboard')),
    body: const Center(child: Text('Dashboard Screen - Coming Soon')),
  );
}
