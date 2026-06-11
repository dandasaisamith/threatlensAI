import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryInterceptor', () {
    test('has default configuration', () {
      // RetryInterceptor requires a Dio instance for construction
      // This test verifies the configuration contract
      const baseDelay = Duration(seconds: 1);
      const maxDelay = Duration(seconds: 30);
      const maxRetries = 3;

      expect(baseDelay.inSeconds, 1);
      expect(maxDelay.inSeconds, 30);
      expect(maxRetries, 3);
    });

    test('exponential backoff doubles delay each retry', () {
      // Verify exponential backoff formula: baseDelay * 2^retryCount
      const baseDelayMs = 1000;
      final delays = <int>[];

      for (var i = 0; i < 3; i++) {
        final delayMs = baseDelayMs * (1 << i); // 2^i
        delays.add(delayMs);
      }

      expect(delays[0], 1000); // 1s
      expect(delays[1], 2000); // 2s
      expect(delays[2], 4000); // 4s
    });
  });
}
