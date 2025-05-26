import 'dart:async';

import 'package:flutter_bloc_exploration/core/flight/retry_strategy.dart';

class Flight<T> {
  final Future<T> Function() _fetcher;
  final Duration? _ttl;
  final RetryStrategy _retryStrategy;

  Flight({
    required Future<T> Function() fetcher,
    Duration? ttl,
    RetryStrategy retryStrategy = const NoRetryStrategy(),
  }) : _fetcher = fetcher,
      _ttl = ttl,
      _retryStrategy = retryStrategy;

  T? _cache;
  Completer<T>? _completer;
  DateTime? _lastFetch;

  int _invokationCount = 0;
  int get invokationCount => _invokationCount;
  
  Future<T?> fetch({
    bool force = false,
  }) async {
    if (_completer != null) {
      _cache = await _completer?.future;
      return _cache;
    }

    if (!force && _cache != null && !_isExpired()) return _cache;

    final completer = Completer<T>();
    _completer = completer;

    await _startFlight(completer);

    // this is to propagate the error caught from the future
    await completer.future;

    return _cache;
  }

  Future<T?> get() async {
    if (_completer != null) {
      _cache = await _completer?.future;
    }

    if (_cache != null && !_isExpired()) return _cache;

    return null;
  }

  void invalidateCache() {
    _cache = null;
    _lastFetch = null;
  }

  Future<void> _startFlight(Completer<T> completer) {
    return _retryFlight(completer, 0);
  }

  Future<void> _retryFlight(Completer<T> completer, int attempt) async {
    try {
      _invokationCount++;
      _cache = await _fetcher();
      _lastFetch = DateTime.now();
      completer.complete(_cache);
    } on Exception catch (exception) {
      final retry = await _retryStrategy.shouldRetry(attempt + 1, exception);
      if (retry) {
        await _retryFlight(completer, attempt + 1);
      } else {
        completer.completeError(exception);
      }
    } finally {
      if (completer.isCompleted) {
        _completer = null;
      }
    }
  }

  bool _isExpired() {
    if (_ttl == null) return false;
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > _ttl;
  }
}
