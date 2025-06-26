class EndPoint {
  // Base URL for the main API (if needed)
  static const String baseUrl = 'https://api.example.com/';

  // Telegram API endpoints
  static const String telegramBaseUrl = 'https://api.telegram.org/bot';
  static const String sendMessage = 'sendMessage';
  static const String getMe = 'getMe';
  static const String getUpdates = 'getUpdates';

  static String getUserDataEndPoint(String id) {
    return 'user/get-user/$id';
  }

  static String getTelegramBotUrl(String botToken) {
    return '$telegramBaseUrl$botToken/';
  }
}

class ApiKey {
  // General API keys
  static const String status = 'status';
  static const String errorMessage = 'ErrorMessage';
  static const String message = 'message';
  static const String token = 'token';
  static const String email = 'email';
  static const String password = 'password';
  static const String id = 'id';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String profilePic = 'profilePic';
  static const String confirmPassword = 'confirmPassword';
  static const String location = 'location';

  // Telegram API keys
  static const String chatId = 'chat_id';
  static const String text = 'text';
  static const String parseMode = 'parse_mode';
  static const String ok = 'ok';
  static const String result = 'result';
  static const String description = 'description';
}

class TelegramKeys {
  // استخدم متغيرات البيئة أو التشفير لحماية هذه البيانات
  static const String _encryptedBotToken =
      '7601188335:AAEjPR7RZK916wnFDydsiD_9fM5_ZsANRVs';
  static const String _encryptedChatId = '2107413564'; // استخرج الرقم من الرابط

  // في بيئة الإنتاج، يجب تشفير هذه القيم أو استخدام متغيرات البيئة
  static String get botToken => _encryptedBotToken;
  static String get chatId => _encryptedChatId;

  // للحصول على chat ID من الرابط @https://t.me/zoz20390
  // يمكن استخدام getUpdates API أو userinfobot
}
