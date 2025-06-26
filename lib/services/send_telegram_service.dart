import 'dart:developer';
import 'package:task_day/core/api/api_consumer.dart';
import 'package:task_day/core/api/dio_consumer.dart';
import 'package:task_day/core/api/end_point.dart';
import 'package:task_day/core/cache/cache_helper.dart';
import 'package:task_day/core/errors/exceptions.dart';
import 'package:task_day/models/daily_stats_model.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/quick_stats_service.dart';
import 'package:task_day/services/stored_stats_service.dart';

/// خدمة إرسال الملخص اليومي إلى التيليجرام مع الأمان المحسن
class SendTelegramService {
  static ApiConsumer? _apiConsumer;
  static String? _botToken;
  static String? _chatId;
  static bool _isInitialized = false;

  /// تهيئة الخدمة
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تحميل الإعدادات المحفوظة أولاً
      await _loadStoredCredentials();

      // إنشاء consumer مخصص للتيليجرام مع البوت توكن
      if (_botToken != null) {
        _apiConsumer = DioConsumer.telegram(_botToken!);
      }

      _isInitialized = true;
      log('✅ Telegram service initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize Telegram service: $e');
      rethrow;
    }
  }

  /// تحميل البيانات المحفوظة من CacheHelper
  static Future<void> _loadStoredCredentials() async {
    try {
      // تأكد من تهيئة CacheHelper
      if (!CacheHelper.isInitialized) {
        await CacheHelper.init();
      }

      // جرب تحميل البيانات المحفوظة أولاً
      _botToken = CacheHelper.getString(key: 'telegram_bot_token');
      _chatId = CacheHelper.getString(key: 'telegram_chat_id');

      // إذا لم توجد، استخدم البيانات الافتراضية (مع ضمان الأمان)
      if (_botToken == null || _chatId == null) {
        _botToken = TelegramKeys.botToken;
        _chatId = TelegramKeys.chatId;

        // احفظ البيانات الافتراضية
        await _saveCredentials(_botToken!, _chatId!);
      }

      log('📱 Telegram credentials loaded');
    } catch (e) {
      log('⚠️ Error loading credentials, using defaults: $e');
      _botToken = TelegramKeys.botToken;
      _chatId = TelegramKeys.chatId;
    }
  }

  /// حفظ بيانات الاعتماد
  static Future<void> _saveCredentials(String botToken, String chatId) async {
    try {
      await CacheHelper.saveData(key: 'telegram_bot_token', value: botToken);
      await CacheHelper.saveData(key: 'telegram_chat_id', value: chatId);
    } catch (e) {
      log('⚠️ Failed to save credentials: $e');
    }
  }

  /// تحديث بيانات الاعتماد
  static Future<bool> updateCredentials({
    required String botToken,
    required String chatId,
  }) async {
    try {
      // اختبار صحة البيانات أولاً
      final tempToken = _botToken;
      final tempChatId = _chatId;

      _botToken = botToken;
      _chatId = chatId;

      // إعادة إنشاء ApiConsumer مع البوت توكن الجديد
      _apiConsumer = DioConsumer.telegram(_botToken!);

      final isValid = await testConnection();

      if (isValid) {
        await _saveCredentials(botToken, chatId);
        log('✅ Credentials updated successfully');
        return true;
      } else {
        // استرجاع البيانات القديمة في حالة الفشل
        _botToken = tempToken;
        _chatId = tempChatId;
        if (_botToken != null) {
          _apiConsumer = DioConsumer.telegram(_botToken!);
        } else {
          _apiConsumer = null;
        }
        log('❌ Invalid credentials, reverting to previous ones');
        return false;
      }
    } catch (e) {
      log('❌ Error updating credentials: $e');
      return false;
    }
  }

  /// التأكد من وجود وتجهيز _apiConsumer
  static Future<bool> _ensureApiConsumer() async {
    if (_apiConsumer == null && _botToken != null) {
      try {
        _apiConsumer = DioConsumer.telegram(_botToken!);
        return true;
      } catch (e) {
        log('❌ Error creating API consumer: $e');
        return false;
      }
    }
    return _apiConsumer != null;
  }

  /// التحقق من صحة الإعدادات
  static bool get isConfigured =>
      _isInitialized &&
      _botToken != null &&
      _botToken!.isNotEmpty &&
      _chatId != null &&
      _chatId!.isNotEmpty;

  /// اختبار الاتصال
  static Future<bool> testConnection() async {
    if (!isConfigured) {
      log('⚠️ Service not configured');
      return false;
    }

    if (!await _ensureApiConsumer()) {
      log('⚠️ API consumer not available');
      return false;
    }

    try {
      final response = await _apiConsumer!.get(EndPoint.getMe);

      final isOk = response[ApiKey.ok] as bool? ?? false;
      if (isOk) {
        log('✅ Telegram connection test successful');
        return true;
      } else {
        log('❌ Telegram connection test failed');
        return false;
      }
    } on TelegramException catch (e) {
      log('❌ Telegram error during connection test: $e');
      return false;
    } catch (e) {
      log('❌ Unexpected error during connection test: $e');
      return false;
    }
  }

  /// إرسال الملخص اليومي
  static Future<bool> sendDailySummary() async {
    if (!isConfigured) {
      log('⚠️ Service not configured for daily summary');
      return false;
    }

    try {
      // تحديث الإحصائيات اليومية
      await StoredStatsService.updateDailyStatsIfNeeded();

      // جلب البيانات
      final tasks = await HiveService.getAllTasks();
      final habits = await HiveService.getAllHabits();
      final quickStats = QuickStatsService.calculateQuickStats(tasks, habits);
      final dailyStats = StoredStatsService.getDailyStats(DateTime.now());

      // إنشاء رسالة الملخص
      final message = _buildDailySummaryMessage(
        tasks: tasks,
        habits: habits,
        quickStats: quickStats,
        dailyStats: dailyStats,
      );

      // إرسال الرسالة
      return await _sendMessage(message);
    } catch (e) {
      log('❌ Error sending daily summary: $e');
      return false;
    }
  }

  /// إرسال رسالة مخصصة
  static Future<bool> sendCustomMessage(String message) async {
    if (!isConfigured) {
      log('⚠️ Service not configured for custom message');
      return false;
    }

    return await _sendMessage(message);
  }

  /// إرسال إشعار سريع
  static Future<bool> sendQuickNotification(
    String title,
    String message,
  ) async {
    if (!isConfigured) {
      log('⚠️ Service not configured for quick notification');
      return false;
    }

    final formattedMessage = '''
🚨 <b>$title</b>

$message

⏰ ${DateTime.now().toString().substring(11, 16)}
''';

    return await _sendMessage(formattedMessage);
  }

  /// إرسال رسالة إلى التيليجرام
  static Future<bool> _sendMessage(String message) async {
    if (!await _ensureApiConsumer()) {
      log('⚠️ API consumer not available for sending message');
      return false;
    }

    try {
      final response = await _apiConsumer!.post(
        EndPoint.sendMessage,
        data: {
          ApiKey.chatId: _chatId!,
          ApiKey.text: message,
          ApiKey.parseMode: 'HTML',
        },
      );

      final isOk = response[ApiKey.ok] as bool? ?? false;
      if (isOk) {
        log('✅ Message sent successfully to Telegram');
        return true;
      } else {
        log('❌ Failed to send message to Telegram');
        return false;
      }
    } on TelegramException catch (e) {
      log('❌ Telegram error sending message: $e');
      return false;
    } catch (e) {
      log('❌ Unexpected error sending message: $e');
      return false;
    }
  }

  /// بناء رسالة الملخص اليومي
  static String _buildDailySummaryMessage({
    required List<TaskModel> tasks,
    required List<HabitModel> habits,
    required QuickStatsData quickStats,
    DailyStatsModel? dailyStats,
  }) {
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    // حساب المهام المكتملة اليوم
    final todayTasks =
        tasks.where((task) {
          final taskStart = DateTime(
            task.startDate.year,
            task.startDate.month,
            task.startDate.day,
          );
          final taskEnd = DateTime(
            task.endDate.year,
            task.endDate.month,
            task.endDate.day,
          );
          final today = DateTime(now.year, now.month, now.day);

          return (taskStart.isBefore(today.add(const Duration(days: 1))) &&
              taskEnd.isAfter(today.subtract(const Duration(days: 1))));
        }).toList();

    final completedTasks = todayTasks.where((task) => task.isDone).toList();
    final pendingTasks = todayTasks.where((task) => !task.isDone).toList();

    // حساب العادات المكتملة اليوم
    final completedHabits =
        habits.where((habit) {
          return habit.completedDates.any((completedDate) {
            final completedDay = DateTime(
              completedDate.year,
              completedDate.month,
              completedDate.day,
            );
            final today = DateTime(now.year, now.month, now.day);
            return completedDay.isAtSameMomentAs(today);
          });
        }).toList();

    final pendingHabits =
        habits.where((habit) {
          return !habit.completedDates.any((completedDate) {
            final completedDay = DateTime(
              completedDate.year,
              completedDate.month,
              completedDate.day,
            );
            final today = DateTime(now.year, now.month, now.day);
            return completedDay.isAtSameMomentAs(today);
          });
        }).toList();

    // بناء الرسالة
    final buffer = StringBuffer();

    // العنوان
    buffer.writeln('📊 <b>الملخص اليومي - $formattedDate</b>');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    // إحصائيات المهام
    buffer.writeln('📋 <b>المهام:</b>');
    buffer.writeln(
      '   ✅ مكتملة: ${completedTasks.length}/${todayTasks.length}',
    );
    if (todayTasks.isNotEmpty) {
      final completionRate =
          (completedTasks.length / todayTasks.length * 100).round();
      buffer.writeln('   📈 معدل الإنجاز: $completionRate%');
    }
    buffer.writeln();

    // إحصائيات العادات
    buffer.writeln('🔄 <b>العادات:</b>');
    buffer.writeln('   ✅ مكتملة: ${completedHabits.length}/${habits.length}');
    if (habits.isNotEmpty) {
      final completionRate =
          (completedHabits.length / habits.length * 100).round();
      buffer.writeln('   📈 معدل الإنجاز: $completionRate%');
    }
    buffer.writeln();

    // نقاط الإنتاجية
    if (dailyStats != null) {
      buffer.writeln('🎯 <b>نقاط الإنتاجية:</b>');
      buffer.writeln(
        '   ⭐ النقاط اليومية: ${dailyStats.productivityScore.round()}',
      );
      buffer.writeln('   🔥 أطول سلسلة: ${dailyStats.longestStreak} يوم');
      buffer.writeln();
    }

    // المهام المكتملة
    if (completedTasks.isNotEmpty) {
      buffer.writeln('✅ <b>المهام المكتملة:</b>');
      for (final task in completedTasks.take(5)) {
        buffer.writeln('   • ${task.title}');
      }
      if (completedTasks.length > 5) {
        buffer.writeln('   ... و ${completedTasks.length - 5} مهام أخرى');
      }
      buffer.writeln();
    }

    // المهام المعلقة
    if (pendingTasks.isNotEmpty) {
      buffer.writeln('⏳ <b>المهام المعلقة:</b>');
      for (final task in pendingTasks.take(3)) {
        buffer.writeln('   • ${task.title}');
      }
      if (pendingTasks.length > 3) {
        buffer.writeln('   ... و ${pendingTasks.length - 3} مهام أخرى');
      }
      buffer.writeln();
    }

    // العادات المكتملة
    if (completedHabits.isNotEmpty) {
      buffer.writeln('✅ <b>العادات المكتملة:</b>');
      for (final habit in completedHabits.take(3)) {
        final streak =
            quickStats.habitsWithStreaks
                .where((h) => h.id == habit.id)
                .firstOrNull
                ?.currentStreak ??
            0;
        buffer.writeln('   • ${habit.title} (سلسلة: $streak يوم)');
      }
      if (completedHabits.length > 3) {
        buffer.writeln('   ... و ${completedHabits.length - 3} عادات أخرى');
      }
      buffer.writeln();
    }

    // العادات المعلقة
    if (pendingHabits.isNotEmpty) {
      buffer.writeln('⏳ <b>العادات المعلقة:</b>');
      for (final habit in pendingHabits.take(3)) {
        buffer.writeln('   • ${habit.title}');
      }
      if (pendingHabits.length > 3) {
        buffer.writeln('   ... و ${pendingHabits.length - 3} عادات أخرى');
      }
      buffer.writeln();
    }

    // رسالة تشجيعية
    final totalCompleted = completedTasks.length + completedHabits.length;
    final totalItems = todayTasks.length + habits.length;

    if (totalItems > 0) {
      final overallRate = (totalCompleted / totalItems * 100).round();
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln();

      if (overallRate >= 80) {
        buffer.writeln('🎉 <b>أداء ممتاز اليوم!</b>');
        buffer.writeln('استمر في هذا المستوى الرائع! 💪');
      } else if (overallRate >= 60) {
        buffer.writeln('👍 <b>أداء جيد اليوم!</b>');
        buffer.writeln('يمكنك تحسين الأداء أكثر غداً! 📈');
      } else if (overallRate >= 40) {
        buffer.writeln('📈 <b>أداء مقبول اليوم!</b>');
        buffer.writeln('حاول إنجاز المزيد غداً! 🎯');
      } else {
        buffer.writeln('💪 <b>لا تستسلم!</b>');
        buffer.writeln('غداً يوم جديد وفرصة جديدة! 🌅');
      }
    }

    return buffer.toString();
  }

  /// إرسال تقرير أسبوعي
  static Future<bool> sendWeeklyReport() async {
    if (!isConfigured) {
      log('⚠️ Service not configured for weekly report');
      return false;
    }

    try {
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));

      final weeklyProgress = await StoredStatsService.calculateWeeklyProgress();

      final message = '''
📊 <b>التقرير الأسبوعي</b>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 <b>إحصائيات الأسبوع:</b>
   📊 التقدم العام: ${(weeklyProgress * 100).round()}%
   📅 من: ${startOfWeek.day}/${startOfWeek.month}/${startOfWeek.year}
   📅 إلى: ${now.day}/${now.month}/${now.year}

💡 <b>ملاحظات:</b>
   ${weeklyProgress >= 0.8
          ? '🎉 أسبوع ممتاز! استمر في هذا المستوى'
          : weeklyProgress >= 0.6
          ? '👍 أسبوع جيد! يمكنك التحسين أكثر'
          : weeklyProgress >= 0.4
          ? '📈 أسبوع مقبول! ركز على التحسين'
          : '💪 لا تستسلم! الأسبوع القادم أفضل'}
''';

      return await _sendMessage(message);
    } catch (e) {
      log('❌ Error sending weekly report: $e');
      return false;
    }
  }

  /// الحصول على معلومات البوت
  static Future<Map<String, dynamic>?> getBotInfo() async {
    if (!isConfigured) return null;

    if (!await _ensureApiConsumer()) {
      log('⚠️ API consumer not available for getting bot info');
      return null;
    }

    try {
      final response = await _apiConsumer!.get(EndPoint.getMe);

      final isOk = response[ApiKey.ok] as bool? ?? false;
      if (isOk) {
        return response[ApiKey.result] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      log('❌ Error getting bot info: $e');
      return null;
    }
  }

  /// تنظيف الموارد
  static void dispose() {
    _isInitialized = false;
    _botToken = null;
    _chatId = null;
  }
}
