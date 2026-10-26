import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class NativeBridge {
  Future<void> openTrailer({
    required int movieId,
    required String title,
    required String overview,
    required String posterUrl,
    required String trailerKey,
  });

  Future<void> closeModule();
}

class NativeBridgeImpl implements NativeBridge {
  static const MethodChannel _channel =
      MethodChannel('com.example.movies/bridge');

  final MethodChannel channel;

  NativeBridgeImpl({MethodChannel? channel}) : channel = channel ?? _channel;

  @override
  Future<void> openTrailer({
    required int movieId,
    required String title,
    required String overview,
    required String posterUrl,
    required String trailerKey,
  }) async {
    final payload = {
      'movieId': movieId,
      'title': title,
      'overview': overview,
      'posterUrl': posterUrl,
      'trailerKey': trailerKey,
    };

    try {
      await channel.invokeMethod('openTrailer', payload);
      await closeModule();
    } on MissingPluginException {
      // In standalone mode (flutter run), there is no native host listening on the channel.
      debugPrint(
        'ℹ️ [NativeBridge] Standalone mode: openTrailer dispatched with payload: $payload',
      );
    } catch (e) {
      debugPrint('⚠️ [NativeBridge] Error invoking openTrailer: $e');
    }
  }

  @override
  Future<void> closeModule() async {
    try {
      await channel.invokeMethod('closeModule');
    } on MissingPluginException {
      // Standalone mode: fallback to SystemNavigator or no-op
      try {
        await SystemNavigator.pop();
      } catch (_) {}
    } catch (_) {
      try {
        await SystemNavigator.pop();
      } catch (_) {}
    }
  }
}
