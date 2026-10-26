import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovies extends MoviesEvent {
  const FetchMovies();
}

class LoadMoreMovies extends MoviesEvent {
  const LoadMoreMovies();
}

class RefreshMovies extends MoviesEvent {
  const RefreshMovies();
}

class MovieSelected extends MoviesEvent {
  final Movie movie;

  const MovieSelected(this.movie);

  @override
  List<Object?> get props => [movie];
}
