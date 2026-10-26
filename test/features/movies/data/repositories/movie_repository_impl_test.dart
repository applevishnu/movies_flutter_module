import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/error/exceptions.dart';
import 'package:movies_flutter_module/core/error/failures.dart';
import 'package:movies_flutter_module/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movies_flutter_module/features/movies/data/models/movie_model.dart';
import 'package:movies_flutter_module/features/movies/data/models/trailer_model.dart';
import 'package:movies_flutter_module/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/trailer.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    repository = MovieRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getPopularMovies', () {
    const tMovieModel = MovieModel(
      id: 550,
      title: 'Fight Club',
      overview: 'Overview text',
      posterPath: '/path.jpg',
      releaseDate: '1999-10-15',
      voteAverage: 8.4,
    );
    final List<MovieModel> tMovieModels = [tMovieModel];
    final List<Movie> tMovies = tMovieModels;
    const tPage = 1;

    test('should return remote data when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: tPage))
          .thenAnswer((_) async => tMovieModels);

      // act
      final result = await repository.getPopularMovies(page: tPage);

      // assert
      verify(() => mockRemoteDataSource.getPopularMovies(page: tPage)).called(1);
      expect(result, equals(Right(tMovies)));
    });

    test('should return ServerFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getPopularMovies(page: tPage))
          .thenThrow(const ServerException('Server error'));

      // act
      final result = await repository.getPopularMovies(page: tPage);

      // assert
      verify(() => mockRemoteDataSource.getPopularMovies(page: tPage)).called(1);
      expect(result, equals(const Left(ServerFailure('Server error'))));
    });
  });

  group('getMovieTrailer', () {
    const tMovieId = 550;
    const tTrailerModel = TrailerModel(
      id: '123',
      key: 'trailer_key',
      name: 'Trailer',
      site: 'YouTube',
      type: 'Trailer',
    );
    const Trailer tTrailer = tTrailerModel;

    test('should return trailer when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getMovieTrailer(tMovieId))
          .thenAnswer((_) async => tTrailerModel);

      // act
      final result = await repository.getMovieTrailer(tMovieId);

      // assert
      verify(() => mockRemoteDataSource.getMovieTrailer(tMovieId)).called(1);
      expect(result, equals(const Right(tTrailer)));
    });

    test('should return ServerFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getMovieTrailer(tMovieId))
          .thenThrow(const ServerException('Trailer not found'));

      // act
      final result = await repository.getMovieTrailer(tMovieId);

      // assert
      verify(() => mockRemoteDataSource.getMovieTrailer(tMovieId)).called(1);
      expect(result, equals(const Left(ServerFailure('Trailer not found'))));
    });
  });
}
