import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/error/failures.dart';

void main() {
  test('ServerFailure should support value equality and default message', () {
    const failure1 = ServerFailure();
    const failure2 = ServerFailure('Server failure occurred');
    expect(failure1, equals(failure2));
    expect(failure1.props, ['Server failure occurred']);
  });

  test('NetworkFailure should support value equality and default message', () {
    const failure1 = NetworkFailure();
    const failure2 = NetworkFailure('No internet connection');
    expect(failure1, equals(failure2));
    expect(failure1.props, ['No internet connection']);
  });

  test('CacheFailure should support value equality and default message', () {
    const failure1 = CacheFailure();
    const failure2 = CacheFailure('Cache failure occurred');
    expect(failure1, equals(failure2));
    expect(failure1.props, ['Cache failure occurred']);
  });
}
