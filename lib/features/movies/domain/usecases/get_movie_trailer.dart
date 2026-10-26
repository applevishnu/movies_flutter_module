import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/trailer.dart';
import '../repositories/movie_repository.dart';

class GetMovieTrailer implements UseCase<Trailer, GetMovieTrailerParams> {
  final MovieRepository repository;

  const GetMovieTrailer(this.repository);

  @override
  Future<Either<Failure, Trailer>> call(GetMovieTrailerParams params) async {
    return repository.getMovieTrailer(params.movieId);
  }
}

class GetMovieTrailerParams extends Equatable {
  final int movieId;

  const GetMovieTrailerParams({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}
