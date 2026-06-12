import 'package:flutter/material.dart';

/// Loading widget that displays a circular progress indicator
///
/// Can optionally display a message below the spinner
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, this.message, this.size = 50})
    : super(key: key);
  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ),
  );
}

/// Loading overlay that covers the entire screen
///
/// Displays a semi-transparent overlay with loading indicator
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  }) : super(key: key);
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      if (isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: LoadingWidget(message: loadingMessage),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
