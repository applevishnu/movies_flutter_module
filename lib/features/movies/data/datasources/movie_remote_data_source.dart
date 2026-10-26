import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/movie_model.dart';
import '../models/trailer_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<TrailerModel> getMovieTrailer(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio client;

  MovieRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await client.get(
        ApiConstants.popularMoviesEndpoint,
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = (data is Map && data.containsKey('results'))
            ? data['results'] as List
            : <dynamic>[];

        return results
            .map((movieJson) =>
                MovieModel.fromJson(movieJson as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          'Failed to load popular movies. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred while fetching movies',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TrailerModel> getMovieTrailer(int movieId) async {
    try {
      final response = await client.get(
        ApiConstants.movieVideosEndpoint(movieId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = (data is Map && data.containsKey('results'))
            ? data['results'] as List
            : <dynamic>[];

        final trailerModels = results
            .map((videoJson) =>
                TrailerModel.fromJson(videoJson as Map<String, dynamic>))
            .toList();

        // 1. Look for type == "Trailer" and site == "YouTube"
        final trailers = trailerModels.where(
          (v) =>
              v.site.toLowerCase() == 'youtube' &&
              v.type.toLowerCase() == 'trailer' &&
              v.key.isNotEmpty,
        );

        if (trailers.isNotEmpty) {
          return trailers.first;
        }

        // 2. Fallback: look for type == "Teaser" and site == "YouTube"
        final teasers = trailerModels.where(
          (v) =>
              v.site.toLowerCase() == 'youtube' &&
              v.type.toLowerCase() == 'teaser' &&
              v.key.isNotEmpty,
        );

        if (teasers.isNotEmpty) {
          return teasers.first;
        }

        throw const ServerException('No YouTube trailer found for this movie');
      } else {
        throw ServerException(
          'Failed to load trailer. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred while fetching trailer',
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
