import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/platform/native_bridge.dart';
import '../../domain/usecases/get_movie_trailer.dart';
import '../../domain/usecases/get_popular_movies.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetPopularMovies getPopularMovies;
  final GetMovieTrailer getMovieTrailer;
  final NativeBridge nativeBridge;

  int _currentPage = 1;
  bool _isLoadingMore = false;

  MoviesBloc({
    required this.getPopularMovies,
    required this.getMovieTrailer,
    required this.nativeBridge,
  }) : super(const MoviesInitial()) {
    on<FetchMovies>(_onFetchMovies);
    on<RefreshMovies>(_onRefreshMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<MovieSelected>(_onMovieSelected);
  }

  Future<void> _onFetchMovies(
    FetchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    _currentPage = 1;
    emit(const MoviesLoading());

    final failureOrMovies = await getPopularMovies(
      GetPopularMoviesParams(page: _currentPage),
    );

    failureOrMovies.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(movies: movies, hasReachedMax: false)),
    );
  }

  Future<void> _onRefreshMovies(
    RefreshMovies event,
    Emitter<MoviesState> emit,
  ) async {
    _currentPage = 1;
    emit(const MoviesLoading());

    final failureOrMovies = await getPopularMovies(
      GetPopularMoviesParams(page: _currentPage),
    );

    failureOrMovies.fold(
      (failure) => emit(MoviesError(failure.message)),
      (movies) => emit(MoviesLoaded(movies: movies, hasReachedMax: false)),
    );
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MoviesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesLoaded ||
        currentState.hasReachedMax ||
        _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    final nextPage = _currentPage + 1;

    final failureOrMovies = await getPopularMovies(
      GetPopularMoviesParams(page: nextPage),
    );

    failureOrMovies.fold(
      (failure) {
        _isLoadingMore = false;
        // Keep existing loaded list but preserve state
      },
      (newMovies) {
        _isLoadingMore = false;
        if (newMovies.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          _currentPage = nextPage;
          emit(
            currentState.copyWith(
              movies: [...currentState.movies, ...newMovies],
              hasReachedMax: false,
            ),
          );
        }
      },
    );
  }

  Future<void> _onMovieSelected(
    MovieSelected event,
    Emitter<MoviesState> emit,
  ) async {
    final movie = event.movie;
    final failureOrTrailer = await getMovieTrailer(
      GetMovieTrailerParams(movieId: movie.id),
    );

    await failureOrTrailer.fold(
      (failure) async {
        emit(MoviesError(failure.message));
      },
      (trailer) async {
        final posterUrl = ApiConstants.posterUrl(movie.posterPath);
        await nativeBridge.openTrailer(
          movieId: movie.id,
          title: movie.title,
          overview: movie.overview,
          posterUrl: posterUrl,
          trailerKey: trailer.key,
        );
      },
    );
  }
}
