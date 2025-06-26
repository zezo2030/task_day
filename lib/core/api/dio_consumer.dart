import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:task_day/core/api/api_consumer.dart';
import 'package:task_day/core/api/api_interceptors.dart';
import 'package:task_day/core/api/end_point.dart';

/// Dio implementation of ApiConsumer
class DioConsumer implements ApiConsumer {
  late final Dio _dio;

  DioConsumer() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EndPoint.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor());

    // Add log interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (obj) => log('Dio: $obj'),
      ),
    );
  }

  /// Create Dio instance for Telegram API
  factory DioConsumer.telegram(String botToken) {
    final consumer = DioConsumer();
    consumer._dio.options.baseUrl = '${EndPoint.telegramBaseUrl}$botToken/';

    // Replace API interceptor with Telegram interceptor
    consumer._dio.interceptors.clear();
    consumer._dio.interceptors.add(TelegramInterceptor());
    consumer._dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => log('Telegram API: $obj'),
      ),
    );

    return consumer;
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update base URL (useful for switching between different APIs)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Get current Dio instance (for advanced usage)
  Dio get dio => _dio;
}
