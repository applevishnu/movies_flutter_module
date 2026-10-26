import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/movie.dart';
import 'package:movies_flutter_module/features/movies/presentation/widgets/movie_card.dart';

void main() {
  const tMovie = Movie(
    id: 550,
    title: 'Fight Club',
    overview: 'An insomniac office worker and a devil-may-care soap maker form an underground fight club.',
    posterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
    releaseDate: '1999-10-15',
    voteAverage: 8.4,
  );

  testWidgets('renders movie title, description, and triggers onTap callback',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieCard(
            movie: tMovie,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify title and overview are displayed
    expect(find.text('Fight Club'), findsOneWidget);
    expect(
      find.text(
        'An insomniac office worker and a devil-may-care soap maker form an underground fight club.',
      ),
      findsOneWidget,
    );

    // Tap the card
    await tester.tap(find.byType(MovieCard));
    await tester.pump();

    // Verify tap callback was invoked
    expect(tapped, isTrue);
  });
}
