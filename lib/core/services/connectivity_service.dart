import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity status.
///
/// Uses [connectivity_plus] to detect network changes.
/// Useful for offline-first architecture and retry logic.
class ConnectivityService {
  ConnectivityService() {
    _connectivity = Connectivity();
  }

  late final Connectivity _connectivity;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  /// Stream of connectivity changes (true = connected).
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Current connectivity status.
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring.
  Future<void> initialize() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    _connectionController.add(_isConnected);

    // Listen for changes
    _connectivity.onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
      _connectionController.add(_isConnected);
    });
  }

  /// Dispose resources.
  void dispose() {
    _connectionController.close();
  }
}
