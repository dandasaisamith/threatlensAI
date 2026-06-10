import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI chat screen for threat analysis conversation
/// 
/// Allows users to:
/// - Ask questions about their threat analysis
/// - Get AI-powered recommendations
/// - Refine threat models through conversation
class AiChatScreen extends ConsumerWidget {
  final String analysisId;

  const AiChatScreen({
    Key? key,
    required this.analysisId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: Center(
        child: Text('AI Chat Screen - Coming Soon\nAnalysis ID: \$analysisId'),
      ),
    );
  }
}
