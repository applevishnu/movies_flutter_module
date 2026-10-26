class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Can be injected via flutter run --dart-define=TMDB_API_KEY=your_key or loaded from .env
  static String apiKey = const String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '',
  );

  static const String popularMoviesEndpoint = '/movie/popular';
  static String movieVideosEndpoint(int movieId) => '/movie/$movieId/videos';
  static String posterUrl(String? posterPath) =>
      posterPath != null && posterPath.isNotEmpty
          ? '$imageBaseUrl$posterPath'
          : '';
}
