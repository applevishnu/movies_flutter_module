import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/features/movies/data/models/trailer_model.dart';
import 'package:movies_flutter_module/features/movies/domain/entities/trailer.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tTrailerModel = TrailerModel(
    id: '533ec654c3a36854480003eb',
    key: 'dG91B3hHyIc',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  test('should be a subclass of Trailer entity', () async {
    expect(tTrailerModel, isA<Trailer>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('movie_trailers.json'))['results'][2];

      // act
      final result = TrailerModel.fromJson(jsonMap);

      // assert
      expect(result, tTrailerModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = tTrailerModel.toJson();

      // assert
      final expectedMap = {
        'id': '533ec654c3a36854480003eb',
        'key': 'dG91B3hHyIc',
        'name': 'Official Trailer',
        'site': 'YouTube',
        'type': 'Trailer',
      };
      expect(result, expectedMap);
    });
  });
}
