import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/error/failures.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/trailer.dart';
import 'package:movies_flutter_module/features/movies/domain/usecases/get_movie_trailer.dart';
import 'package:movies_flutter_module/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_event.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_state.dart';

class MockGetPopularMovies extends Mock implements GetPopularMovies {}

class MockGetMovieTrailer extends Mock implements GetMovieTrailer {}

class MockNativeBridge extends Mock implements NativeBridge {}

void main() {
  late MoviesBloc bloc;
  late MockGetPopularMovies mockGetPopularMovies;
  late MockGetMovieTrailer mockGetMovieTrailer;
  late MockNativeBridge mockNativeBridge;

  setUp(() {
    mockGetPopularMovies = MockGetPopularMovies();
    mockGetMovieTrailer = MockGetMovieTrailer();
    mockNativeBridge = MockNativeBridge();

    bloc = MoviesBloc(
      getPopularMovies: mockGetPopularMovies,
      getMovieTrailer: mockGetMovieTrailer,
      nativeBridge: mockNativeBridge,
    );
  });

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'Overview...',
    posterPath: '/path.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
  );
  final tMoviesList = [tMovie];

  const tTrailer = Trailer(
    id: '123',
    key: 'dG91B3hHyIc',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  test('initial state should be MoviesInitial', () {
    expect(bloc.state, const MoviesInitial());
  });

  group('FetchMovies', () {
    blocTest<MoviesBloc, MoviesState>(
      'emits [MoviesLoading, MoviesLoaded] when fetching movies is successful',
      build: () {
        when(() => mockGetPopularMovies(const GetPopularMoviesParams(page: 1)))
            .thenAnswer((_) async => Right(tMoviesList));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        const MoviesLoading(),
        MoviesLoaded(movies: tMoviesList, hasReachedMax: false),
      ],
      verify: (_) {
        verify(() =>
                mockGetPopularMovies(const GetPopularMoviesParams(page: 1)))
            .called(1);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits [MoviesLoading, MoviesError] when fetching movies fails',
      build: () {
        when(() => mockGetPopularMovies(const GetPopularMoviesParams(page: 1)))
            .thenAnswer((_) async => const Left(ServerFailure('API Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        const MoviesLoading(),
        const MoviesError('API Error'),
      ],
    );
  });

  group('RefreshMovies', () {
    blocTest<MoviesBloc, MoviesState>(
      'fetches page 1 and emits [MoviesLoading, MoviesLoaded]',
      build: () {
        when(() => mockGetPopularMovies(const GetPopularMoviesParams(page: 1)))
            .thenAnswer((_) async => Right(tMoviesList));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshMovies()),
      expect: () => [
        const MoviesLoading(),
        MoviesLoaded(movies: tMoviesList, hasReachedMax: false),
      ],
    );
  });

  group('MovieSelected', () {
    blocTest<MoviesBloc, MoviesState>(
      'calls trailer use case and invokes nativeBridge.openTrailer on success',
      build: () {
        when(() => mockGetMovieTrailer(
                GetMovieTrailerParams(movieId: tMovie.id)))
            .thenAnswer((_) async => const Right(tTrailer));
        when(() => mockNativeBridge.openTrailer(
              movieId: any(named: 'movieId'),
              title: any(named: 'title'),
              overview: any(named: 'overview'),
              posterUrl: any(named: 'posterUrl'),
              trailerKey: any(named: 'trailerKey'),
            )).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const MovieSelected(tMovie)),
      verify: (_) {
        verify(() => mockGetMovieTrailer(
                GetMovieTrailerParams(movieId: tMovie.id)))
            .called(1);
        verify(() => mockNativeBridge.openTrailer(
              movieId: tMovie.id,
              title: tMovie.title,
              overview: tMovie.overview,
              posterUrl: any(named: 'posterUrl'),
              trailerKey: tTrailer.key,
            )).called(1);
      },
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits MoviesError when trailer use case fails',
      build: () {
        when(() => mockGetMovieTrailer(
                GetMovieTrailerParams(movieId: tMovie.id)))
            .thenAnswer((_) async => const Left(ServerFailure('No trailer')));
        return bloc;
      },
      act: (bloc) => bloc.add(const MovieSelected(tMovie)),
      expect: () => [
        const MoviesError('No trailer'),
      ],
    );
  });
}
