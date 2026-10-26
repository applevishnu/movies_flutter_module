import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/di/injection_container.dart' as di;
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/domain/repositories/movie_repository.dart';
import 'package:movies_flutter_module/main.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockMovieRepository;

  setUp(() async {
    await di.sl.reset();
    mockMovieRepository = MockMovieRepository();
    when(() => mockMovieRepository.getPopularMovies(page: any(named: 'page')))
        .thenAnswer((_) async => const Right(<Movie>[]));

    await di.init();
    di.sl.unregister<MovieRepository>();
    di.sl.registerLazySingleton<MovieRepository>(() => mockMovieRepository);
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('MoviesApp smoke test renders MoviesPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MoviesApp());
    await tester.pump();
    expect(find.byType(MoviesApp), findsOneWidget);
  });
}
