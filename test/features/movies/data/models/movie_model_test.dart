import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie_model.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tMovieModel = MovieModel(
    id: 550,
    title: 'Fight Club',
    overview: 'A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.433,
  );

  test('should be a subclass of Movie entity', () async {
    expect(tMovieModel, isA<Movie>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('popular_movies.json'))['results'][0];

      // act
      final result = MovieModel.fromJson(jsonMap);

      // assert
      expect(result, tMovieModel);
    });

    test('should handle integer vote_average by converting to double', () async {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'Overview',
        'poster_path': '/path.jpg',
        'release_date': '2020-01-01',
        'vote_average': 8,
      };

      // act
      final result = MovieModel.fromJson(jsonMap);

      // assert
      expect(result.voteAverage, 8.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = tMovieModel.toJson();

      // assert
      final expectedMap = {
        'id': 550,
        'title': 'Fight Club',
        'overview': 'A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.',
        'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        'release_date': '1999-10-15',
        'vote_average': 8.433,
      };
      expect(result, expectedMap);
    });
  });
}
