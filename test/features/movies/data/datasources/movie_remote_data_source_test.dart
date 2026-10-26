import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/error/exceptions.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_remote_data_source.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MovieRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = MovieRemoteDataSourceImpl(client: mockDio);
  });

  group('getPopularMovies', () {
    final tMoviesJson = json.decode(fixture('popular_movies.json'));
    const tPage = 1;

    test('should return List<MovieModel> when response code is 200', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: tMoviesJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/movie/popular'),
        ),
      );

      // act
      final result = await dataSource.getPopularMovies(page: tPage);

      // assert
      expect(result.length, 2);
      expect(result[0].title, 'Fight Club');
      expect(result[1].title, 'Inception');
    });

    test('should throw ServerException when response code is not 200', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {'status_message': 'Error'},
          statusCode: 404,
          requestOptions: RequestOptions(path: '/movie/popular'),
        ),
      );

      // act & assert
      expect(
        () => dataSource.getPopularMovies(page: tPage),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when DioException occurs', () async {
      // arrange
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/movie/popular'),
          error: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // act & assert
      expect(
        () => dataSource.getPopularMovies(page: tPage),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getMovieTrailer', () {
    final tTrailersJson = json.decode(fixture('movie_trailers.json'));
    const tMovieId = 550;

    test('should return YouTube Trailer when type == Trailer and site == YouTube',
        () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tTrailersJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
        ),
      );

      // act
      final result = await dataSource.getMovieTrailer(tMovieId);

      // assert
      expect(result.key, 'dG91B3hHyIc');
      expect(result.site, 'YouTube');
      expect(result.type, 'Trailer');
    });

    test('should fall back to Teaser when no Trailer is available', () async {
      // arrange - only teaser is present
      final jsonWithOnlyTeaser = {
        'id': tMovieId,
        'results': [
          {
            'id': 'teaser-1',
            'key': 'teaser_key_456',
            'name': 'Teaser',
            'site': 'YouTube',
            'type': 'Teaser',
          }
        ]
      };

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: jsonWithOnlyTeaser,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
        ),
      );

      // act
      final result = await dataSource.getMovieTrailer(tMovieId);

      // assert
      expect(result.key, 'teaser_key_456');
      expect(result.type, 'Teaser');
    });

    test('should throw ServerException when no suitable trailer or teaser exists',
        () async {
      // arrange
      final jsonWithoutYouTube = {
        'id': tMovieId,
        'results': [
          {
            'id': 'clip-1',
            'key': 'clip_key',
            'name': 'Clip',
            'site': 'Vimeo',
            'type': 'Clip',
          }
        ]
      };

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: jsonWithoutYouTube,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
        ),
      );

      // act & assert
      expect(
        () => dataSource.getMovieTrailer(tMovieId),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException when response code is not 200', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: 'Not found',
          statusCode: 404,
          requestOptions: RequestOptions(path: '/movie/$tMovieId/videos'),
        ),
      );

      // act & assert
      expect(
        () => dataSource.getMovieTrailer(tMovieId),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
