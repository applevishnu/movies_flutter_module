import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/usecase/usecase.dart';

void main() {
  test('NoParams should support value equality and empty props', () {
    const noParams1 = NoParams();
    const noParams2 = NoParams();
    expect(noParams1, equals(noParams2));
    expect(noParams1.props, isEmpty);
  });
}
