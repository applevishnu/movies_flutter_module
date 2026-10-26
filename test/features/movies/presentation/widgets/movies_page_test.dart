import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_event.dart';
import 'package:movies_flutter_module/features/movies/presentation/bloc/movies_state.dart';
import 'package:movies_flutter_module/features/movies/presentation/pages/movies_page.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_card.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_error_widget.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_loading_widget.dart';

class MockMoviesBloc extends MockBloc<MoviesEvent, MoviesState>
    implements MoviesBloc {}

void main() {
  late MockMoviesBloc mockMoviesBloc;

  setUp(() {
    mockMoviesBloc = MockMoviesBloc();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<MoviesBloc>.value(
        value: mockMoviesBloc,
        child: child,
      ),
    );
  }

  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'Overview...',
    posterPath: '/path.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
  );

  testWidgets('renders MovieLoadingWidget when state is MoviesLoading',
      (WidgetTester tester) async {
    when(() => mockMoviesBloc.state).thenReturn(const MoviesLoading());

    await tester.pumpWidget(buildTestableWidget(const MoviesPageView()));

    expect(find.byType(MovieLoadingWidget), findsOneWidget);
  });

  testWidgets('renders MovieErrorWidget when state is MoviesError',
      (WidgetTester tester) async {
    when(() => mockMoviesBloc.state)
        .thenReturn(const MoviesError('Failed to load'));

    await tester.pumpWidget(buildTestableWidget(const MoviesPageView()));

    expect(find.byType(MovieErrorWidget), findsOneWidget);
    expect(find.text('Failed to load'), findsOneWidget);
  });

  testWidgets('renders movie list when state is MoviesLoaded',
      (WidgetTester tester) async {
    when(() => mockMoviesBloc.state).thenReturn(
      const MoviesLoaded(movies: [tMovie]),
    );

    await tester.pumpWidget(buildTestableWidget(const MoviesPageView()));

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('Fight Club'), findsOneWidget);
  });

  testWidgets('dispatches MovieSelected when a card is tapped',
      (WidgetTester tester) async {
    when(() => mockMoviesBloc.state).thenReturn(
      const MoviesLoaded(movies: [tMovie]),
    );

    await tester.pumpWidget(buildTestableWidget(const MoviesPageView()));

    await tester.tap(find.byType(MovieCard));
    await tester.pump();

    verify(() => mockMoviesBloc.add(const MovieSelected(tMovie))).called(1);
  });
}
