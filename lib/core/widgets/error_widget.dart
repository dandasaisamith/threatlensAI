import 'package:flutter/material.dart';

/// Error display widget
///
/// Shows an error message with optional retry button
class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.errorCode,
  }) : super(key: key);
  final String message;
  final VoidCallback? onRetry;
  final String? errorCode;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (errorCode != null) ...[
          const SizedBox(height: 8),
          Text(
            'Error Code: \$errorCode',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ],
    ),
  );
}

/// Show an error dialog
void showErrorDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? errorCode,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              r'Error Code: $errorCode',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
