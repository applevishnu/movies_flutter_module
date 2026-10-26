import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/movie.dart';
import '../entities/trailer.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<Failure, Trailer>> getMovieTrailer(int movieId);
}
