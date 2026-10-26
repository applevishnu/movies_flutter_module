import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_flutter_module/core/platform/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NativeBridgeImpl bridge;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    const MethodChannel channel = MethodChannel('com.example.movies/bridge');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });

    bridge = NativeBridgeImpl(channel: channel);
  });

  test('openTrailer invokes openTrailer and closeModule methods with correct payload',
      () async {
    // act
    await bridge.openTrailer(
      movieId: 550,
      title: 'Fight Club',
      overview: 'Overview...',
      posterUrl: 'https://image.tmdb.org/t/p/w500/path.jpg',
      trailerKey: 'dG91B3hHyIc',
    );

    // assert
    expect(log.length, 2);
    expect(log[0].method, 'openTrailer');
    expect(log[0].arguments, {
      'movieId': 550,
      'title': 'Fight Club',
      'overview': 'Overview...',
      'posterUrl': 'https://image.tmdb.org/t/p/w500/path.jpg',
      'trailerKey': 'dG91B3hHyIc',
    });
    expect(log[1].method, 'closeModule');
  });
}
