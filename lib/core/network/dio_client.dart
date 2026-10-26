import 'dart:io';
import 'package:dio/dio.dart';
import 'api_constants.dart';

Dio createDioClient({String? apiKey}) {
  final effectiveApiKey = apiKey ?? ApiConstants.apiKey;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (effectiveApiKey.isNotEmpty) {
          final queryParams =
              Map<String, dynamic>.from(options.queryParameters);
          if (!queryParams.containsKey('api_key')) {
            queryParams['api_key'] = effectiveApiKey;
          }
          options.queryParameters = queryParams;
          if (effectiveApiKey.length > 50) {
            options.headers['Authorization'] = 'Bearer $effectiveApiKey';
          }
        }
        return handler.next(options);
      },
      onError: (err, handler) async {
        // Automatically retry up to 3 times if connection was reset or experienced a socket glitch
        var retryCount =
            (err.requestOptions.extra['retry_count'] as int?) ?? 0;
        final isSocketError = err.error is SocketException ||
            err.type == DioExceptionType.connectionError ||
            (err.message != null &&
                err.message!.toLowerCase().contains('connection reset'));

        while (retryCount < 3 && isSocketError) {
          retryCount++;
          err.requestOptions.extra['retry_count'] = retryCount;
          await Future.delayed(Duration(milliseconds: 600 * retryCount));
          try {
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            if (retryCount >= 3) {
              return handler.next(e is DioException ? e : err);
            }
          }
        }
        return handler.next(err);
      },
    ),
  );

  return dio;
}
