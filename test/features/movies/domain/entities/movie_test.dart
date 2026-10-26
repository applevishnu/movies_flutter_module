import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';

void main() {
  const tMovie = Movie(
    id: 1,
    title: 'Inception',
    overview: 'A thief who steals corporate secrets through the use of dream-sharing technology.',
    posterPath: '/path/to/poster.jpg',
    releaseDate: '2010-07-16',
    voteAverage: 8.8,
  );

  const tMovieDuplicate = Movie(
    id: 1,
    title: 'Inception',
    overview: 'A thief who steals corporate secrets through the use of dream-sharing technology.',
    posterPath: '/path/to/poster.jpg',
    releaseDate: '2010-07-16',
    voteAverage: 8.8,
  );

  test('should support value equality via Equatable', () {
    expect(tMovie, equals(tMovieDuplicate));
  });

  test('should have correct props', () {
    expect(
      tMovie.props,
      [
        1,
        'Inception',
        'A thief who steals corporate secrets through the use of dream-sharing technology.',
        '/path/to/poster.jpg',
        '2010-07-16',
        8.8,
      ],
    );
  });
}
