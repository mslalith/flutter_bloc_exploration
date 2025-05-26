abstract class RetryStrategy {
  Future<bool> shouldRetry(int attempt, Exception exception);
}

class NoRetryStrategy implements RetryStrategy {

  const NoRetryStrategy();

  @override
  Future<bool> shouldRetry(int attempt, Exception exception) async => false;
}

class FixedDelayRetryStrategy implements RetryStrategy {
  final int maxAttempts;
  final Duration delay;

  const FixedDelayRetryStrategy({
    required this.maxAttempts,
    required this.delay,
  });

  @override
  Future<bool> shouldRetry(int attempt, Exception exception) async {
    if (attempt >= maxAttempts) return false;

    await Future.delayed(delay);
    return true;
  }
}

class ExponentialBackoffRetryStrategy implements RetryStrategy {
  final int maxAttempts;
  final Duration baseDelay;

  const ExponentialBackoffRetryStrategy({
    required this.maxAttempts,
    required this.baseDelay,
  });

  @override
  Future<bool> shouldRetry(int attempt, Object error) async {
    if (attempt >= maxAttempts) return false;

    final delay = baseDelay * (1 << (attempt - 1));
    await Future.delayed(delay);
    return true;
  }
}

