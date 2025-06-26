/// Custom exceptions for API operations
abstract class AppException implements Exception {
  final String message;
  final String? details;

  const AppException(this.message, {this.details});

  @override
  String toString() => message;
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.details});
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.details});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.details});
}

/// Telegram-specific exceptions
class TelegramException extends AppException {
  final int? errorCode;

  const TelegramException(super.message, {super.details, this.errorCode});
}

/// Bot configuration exceptions
class BotConfigurationException extends TelegramException {
  const BotConfigurationException(
    super.message, {
    super.details,
    super.errorCode,
  });
}

/// Message sending exceptions
class MessageSendException extends TelegramException {
  const MessageSendException(super.message, {super.details, super.errorCode});
}

/// Chat not found exceptions
class ChatNotFoundException extends TelegramException {
  const ChatNotFoundException(super.message, {super.details, super.errorCode});
}

/// Rate limit exceptions
class RateLimitException extends TelegramException {
  final int? retryAfter;

  const RateLimitException(
    super.message, {
    super.details,
    super.errorCode,
    this.retryAfter,
  });
}

/// Forbidden exceptions (bot blocked by user)
class ForbiddenException extends TelegramException {
  const ForbiddenException(super.message, {super.details, super.errorCode});
}
