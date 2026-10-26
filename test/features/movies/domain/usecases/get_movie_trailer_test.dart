import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movies_flutter_module/core/error/failures.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/trailer.dart';
import 'package:movies_flutter_module/features/movies/domain/repositories/movie_repository.dart';
import 'package:movies_flutter_module/features/movies/domain/usecases/get_movie_trailer.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetMovieTrailer usecase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    usecase = GetMovieTrailer(mockMovieRepository);
  });

  const tMovieId = 550;
  const tTrailer = Trailer(
    id: 'trailer-123',
    key: 'dG91B3hHyIc',
    name: 'Fight Club Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  test('should get trailer for movie from repository on success', () async {
    // arrange
    when(() => mockMovieRepository.getMovieTrailer(tMovieId))
        .thenAnswer((_) async => const Right(tTrailer));

    // act
    final result = await usecase(const GetMovieTrailerParams(movieId: tMovieId));

    // assert
    expect(result, const Right(tTrailer));
    verify(() => mockMovieRepository.getMovieTrailer(tMovieId)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('should return Failure when repository fails to retrieve trailer', () async {
    // arrange
    const tFailure = ServerFailure('Trailer not found');
    when(() => mockMovieRepository.getMovieTrailer(tMovieId))
        .thenAnswer((_) async => const Left(tFailure));

    // act
    final result = await usecase(const GetMovieTrailerParams(movieId: tMovieId));

    // assert
    expect(result, const Left(tFailure));
    verify(() => mockMovieRepository.getMovieTrailer(tMovieId)).called(1);
    verifyNoMoreInteractions(mockMovieRepository);
  });

  test('GetMovieTrailerParams should support value equality', () {
    const params1 = GetMovieTrailerParams(movieId: 550);
    const params2 = GetMovieTrailerParams(movieId: 550);
    expect(params1, equals(params2));
    expect(params1.props, [550]);
  });
}

