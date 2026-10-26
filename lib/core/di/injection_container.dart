import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/movies/data/datasources/movie_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/domain/usecases/get_movie_trailer.dart';
import '../../features/movies/domain/usecases/get_popular_movies.dart';
import '../../features/movies/presentation/bloc/movies_bloc.dart';
import 'package:flutter/services.dart';
import '../network/api_constants.dart';
import '../network/dio_client.dart';
import '../platform/native_bridge.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // If API key was not passed via --dart-define, attempt to read from local .env asset
  if (ApiConstants.apiKey.isEmpty) {
    try {
      final envString = await rootBundle.loadString('.env');
      for (final line in envString.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('TMDB_API_KEY=')) {
          ApiConstants.apiKey = trimmed.substring('TMDB_API_KEY='.length).trim();
          break;
        }
      }
    } catch (_) {
      // In tests or if asset is absent, ignore gracefully
    }
  }
  // 1. Presentation Layer (Bloc)
  sl.registerFactory<MoviesBloc>(
    () => MoviesBloc(
      getPopularMovies: sl<GetPopularMovies>(),
      getMovieTrailer: sl<GetMovieTrailer>(),
      nativeBridge: sl<NativeBridge>(),
    ),
  );

  // 2. Domain Layer (UseCases)
  sl.registerLazySingleton<GetPopularMovies>(
    () => GetPopularMovies(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetMovieTrailer>(
    () => GetMovieTrailer(sl<MovieRepository>()),
  );

  // 3. Data Layer (Repository & Remote DataSource)
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(remoteDataSource: sl<MovieRemoteDataSource>()),
  );
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(client: sl<Dio>()),
  );

  // 4. Core & Platform
  sl.registerLazySingleton<NativeBridge>(
    () => NativeBridgeImpl(),
  );

  // 5. External
  sl.registerLazySingleton<Dio>(
    () => createDioClient(),
  );
}
