import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/error/failures.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/domain/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/domain/usecases/get_popular_movies.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetPopularMovies usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetPopularMovies(mockMovieRepository);
  });

  const tMovie = Movie(
    id: 1,
    title: 'Inception',
    overview: 'A thief who steals corporate secrets...',
    posterPath: '/path/to/poster.jpg',
    releaseDate: '2010-07-16',
    voteAverage: 8.8,
  );
  final tMoviesList = [tMovie];
  const tPage = 1;

  test('should get popular movies list from the repository on success', () async {
    // arrange
    when(() => mockMovieRepository.getPopularMovies(page: tPage))
        .thenAnswer((_) async => Right(tMoviesList));

    // act
    final result = await usecase(const GetPopularMoviesParams(page: tPage));

    // assert
    expect(result, Right(tMoviesList));
    verify(() => mockMovieRepository.getPopularMovies(page: tPage)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return Failure when repository call fails', () async {
    // arrange
    const tFailure = ServerFailure('Server failure');
    when(() => mockMovieRepository.getPopularMovies(page: tPage))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const GetPopularMoviesParams(page: tPage));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.getPopularMovies(page: tPage)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('GetPopularMoviesParams should support value equality', () {
    const params1 = GetPopularMoviesParams(page: 1);
    const params2 = GetPopularMoviesParams(page: 1);
    expect(params1, equals(params2));
    expect(params1.props, [1]);
  });
}

