import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:task_day/core/errors/exceptions.dart';

/// Custom interceptor for API logging and error handling
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('🚀 API Request: ${options.method} ${options.uri}');
    log('📝 Headers: ${options.headers}');
    if (options.data != null) {
      log('📦 Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    log('📥 Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('❌ API Error: ${err.message}');
    log('🔍 Error Type: ${err.type}');
    log('🔍 Error Response: ${err.response?.data}');

    // Convert DioException to custom exceptions
    final exception = _handleDioError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Convert DioException to custom app exceptions
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'انتهت مهلة الاتصال. تحقق من اتصال الإنترنت.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.connectionError:
        return const NetworkException(
          'خطأ في الاتصال. تحقق من اتصال الإنترنت.',
        );

      case DioExceptionType.cancel:
        return const NetworkException('تم إلغاء العملية.');

      case DioExceptionType.unknown:
      default:
        return NetworkException('حدث خطأ غير متوقع: ${error.message}');
    }
  }

  /// Handle HTTP response errors
  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case 400:
        return ServerException(
          'طلب غير صحيح',
          details: responseData?.toString(),
        );

      case 401:
        return const AuthException('غير مخول للوصول');

      case 403:
        return const AuthException('ممنوع الوصول');

      case 404:
        return const ServerException('المورد غير موجود');

      case 408:
        return const NetworkException('انتهت مهلة الطلب');

      case 429:
        // استخراج retry-after من response headers إذا متوفر
        final retryAfter = error.response?.headers['retry-after']?.first;
        return RateLimitException(
          'تم تجاوز حد الطلبات',
          retryAfter: retryAfter != null ? int.tryParse(retryAfter) : null,
        );

      case 500:
        return const ServerException('خطأ في الخادم');

      case 502:
        return const ServerException('خطأ في البوابة');

      case 503:
        return const ServerException('الخدمة غير متاحة');

      default:
        return ServerException(
          'خطأ في الخادم: $statusCode',
          details: responseData?.toString(),
        );
    }
  }
}

/// Telegram-specific interceptor for handling Telegram API errors
class TelegramInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Telegram API always returns 200, check 'ok' field
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final isOk = data['ok'] as bool? ?? false;

      if (!isOk) {
        final errorCode = data['error_code'] as int?;
        final description = data['description'] as String? ?? 'Unknown error';

        final exception = _handleTelegramError(errorCode, description);
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: exception,
            type: DioExceptionType.badResponse,
            response: response,
          ),
        );
        return;
      }
    }

    super.onResponse(response, handler);
  }

  /// Handle Telegram-specific errors
  TelegramException _handleTelegramError(int? errorCode, String description) {
    switch (errorCode) {
      case 400:
        if (description.contains('chat not found')) {
          return ChatNotFoundException(
            'المحادثة غير موجودة',
            details: description,
            errorCode: errorCode,
          );
        }
        return TelegramException(
          'طلب غير صحيح',
          details: description,
          errorCode: errorCode,
        );

      case 401:
        return BotConfigurationException(
          'رمز البوت غير صحيح',
          details: description,
          errorCode: errorCode,
        );

      case 403:
        return ForbiddenException(
          'البوت محظور من قبل المستخدم',
          details: description,
          errorCode: errorCode,
        );

      case 429:
        // استخراج retry_after من الرسالة
        final retryMatch = RegExp(r'retry after (\d+)').firstMatch(description);
        final retryAfter =
            retryMatch != null ? int.tryParse(retryMatch.group(1) ?? '') : null;

        return RateLimitException(
          'تم تجاوز حد الطلبات',
          details: description,
          errorCode: errorCode,
          retryAfter: retryAfter,
        );

      default:
        return TelegramException(description, errorCode: errorCode);
    }
  }
}
