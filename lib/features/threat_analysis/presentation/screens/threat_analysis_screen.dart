import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Threat analysis screen
///
/// Allows users to:
/// - Input system description
/// - Generate threat models
/// - View identified assets and threats
/// - Review attack paths and risk scores
class ThreatAnalysisScreen extends ConsumerWidget {
  const ThreatAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Threat Analysis')),
    body: const Center(child: Text('Threat Analysis Screen - Coming Soon')),
  );
}
