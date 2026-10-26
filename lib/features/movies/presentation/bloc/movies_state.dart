import 'package:equatable/equatable.dart';
import '../../domain/entities/movie.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final bool hasReachedMax;

  const MoviesLoaded({
    required this.movies,
    this.hasReachedMax = false,
  });

  MoviesLoaded copyWith({
    List<Movie>? movies,
    bool? hasReachedMax,
  }) {
    return MoviesLoaded(
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [movies, hasReachedMax];
}

class MoviesError extends MoviesState {
  final String message;

  const MoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
