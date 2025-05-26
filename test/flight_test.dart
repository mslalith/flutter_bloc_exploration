import 'package:flutter_bloc_exploration/core/flight/flight.dart';
import 'package:flutter_bloc_exploration/core/flight/retry_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flight', () {
    late int fetchCount;
    late Flight<int> flight;

    setUp(() {
      fetchCount = 0;
      flight = Flight<int>(
        fetcher: () => Future.value(++fetchCount),
      );
    });

    test('fetch() should call fetcher and cache the value', () async {
      final result1 = await flight.fetch();
      expect(result1, 1);
      expect(fetchCount, 1);

      final result2 = await flight.get();
      expect(result2, 1);
      expect(fetchCount, 1);
    });

    test('fetch() should not trigger multiple calls in parallel', () async {
      final future1 = flight.fetch();
      final future2 = flight.fetch();
      final future3 = flight.get();

      final results = await Future.wait([future1, future2, future3]);
      expect(results[0], 1);
      expect(results[1], 1);
      expect(results[2], 1);
      expect(fetchCount, 1);
    });

    test('get() should return null when no value is cached and no fetch is ongoing', () async {
      final result1 = await flight.get();

      expect(result1, null);
    });
  });

  group('Flight (with TTL)', () {
    late int fetchCount;
    late Flight<int> flight;
    final ttl = Duration(milliseconds: 300);

    setUp(() {
      fetchCount = 0;
      flight = Flight<int>(
        ttl: ttl,
        fetcher: () async {
          await Future.delayed(ttl ~/ 2);
          return Future.value(++fetchCount);
        },
      );
    });

     test('fetch() reuses cache if TTL not expired', () async {
      final result1 = await flight.fetch();
      await Future.delayed(ttl - Duration(milliseconds: 50));

      final result2 = await flight.fetch();
      expect(result2, result1);

      expect(fetchCount, 1);
    });

    test('fetch() triggers new fetch after TTL expiry', () async {
      final result1 = await flight.fetch();
      await Future.delayed(ttl + Duration(milliseconds: 50));

      final result2 = await flight.fetch();

      expect(result1, 1);
      expect(result2, 2);
      expect(fetchCount, 2);
    });

    test('get() returns cache if TTL not expired', () async {
      final result1 = await flight.fetch();
      await Future.delayed(ttl - Duration(milliseconds: 50));

      final result2 = await flight.get();

      expect(result1, 1);
      expect(result2, 1);
    });

    test('get() should return null if TTL expired and no fetch running', () async {
      final result1 = await flight.fetch();
      await Future.delayed(ttl + Duration(milliseconds: 50));

      final result2 = await flight.get();

      expect(result1, 1);
      expect(result2, null);
    });


    test('get() awaits if fetch is running even if TTL expired', () async {
      final result1 = await flight.fetch();
      await Future.delayed(ttl - Duration(milliseconds: 50));

      final result2 = await flight.get();

      expect(result1, 1);
      expect(result2, 1);
    });
  });

  group('Flight (with RetryStrategy)', () {

    test('NoRetryStrategy does not retry and fails immediately', () async {
      int fetchCount = 0;
      final flight = Flight<String>(
        fetcher: () async {
          fetchCount++;
          throw Exception('Fail');
        },
        retryStrategy: NoRetryStrategy(),
      );

      await expectLater(flight.fetch(), throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Fail'))));
      expect(fetchCount, 1);
    });

    test('FixedDelayRetryStrategy retries specified number of times with fixed delay', () async {
      int fetchCount = 0;
      final flight = Flight<String>(
        fetcher: () async {
          fetchCount++;
          throw Exception('Fail');
        },
        retryStrategy: FixedDelayRetryStrategy(
          maxAttempts: 3,
          delay: Duration(milliseconds: 10),
        ),
      );

      await expectLater(flight.fetch(), throwsA(isA<Exception>()));
      expect(fetchCount, 3);
    });

    test('ExponentialBackoffRetryStrategy retries with exponential delays up to maxAttempts', () async {
      int fetchCount = 0;
      final flight = Flight<String>(
        fetcher: () async {
          fetchCount++;
          throw Exception('Fail');
        },
        retryStrategy: ExponentialBackoffRetryStrategy(
          maxAttempts: 4,
          baseDelay: Duration(milliseconds: 5),
        ),
      );

      await expectLater(flight.fetch(), throwsA(isA<Exception>()));
      expect(fetchCount, 4);
    });

    test('FixedDelayRetryStrategy succeeds on final attempt', () async {
      int fetchCount = 0;
      final flight = Flight<String>(
        fetcher: () async {
          fetchCount++;
          if (fetchCount < 3) {
            throw Exception('Try again');
          }
          return 'Success!';
        },
        retryStrategy: FixedDelayRetryStrategy(
          maxAttempts: 3,
          delay: Duration(milliseconds: 5),
        ),
      );

      final result = await flight.fetch();
      expect(result, 'Success!');
      expect(fetchCount, 3);
    });
  });
}
