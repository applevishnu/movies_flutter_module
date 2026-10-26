import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/trailer.dart';

void main() {
  const tTrailer = Trailer(
    id: '12345',
    key: 'YoHD9XEInc0',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  const tTrailerDuplicate = Trailer(
    id: '12345',
    key: 'YoHD9XEInc0',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  test('should support value equality via Equatable', () {
    expect(tTrailer, equals(tTrailerDuplicate));
  });

  test('should have correct props', () {
    expect(
      tTrailer.props,
      [
        '12345',
        'YoHD9XEInc0',
        'Official Trailer',
        'YouTube',
        'Trailer',
      ],
    );
  });
}
