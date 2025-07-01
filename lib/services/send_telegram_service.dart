import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_day/models/habit_model.dart';
import 'package:task_day/models/task_model.dart';
import 'package:task_day/models/weekly_review_model.dart';
import 'package:task_day/services/hive_service.dart';
import 'package:task_day/services/quick_stats_service.dart';
import 'package:task_day/services/weekly_review_service.dart';

class TelegramService {
  static const String _telegramBoxName = 'telegram_settings';
  static const String _botTokenKey = 'bot_token';
  static const String _chatIdKey = 'chat_id';

  static late Dio _dio;

  /// تهيئة الخدمة
  static Future<void> init() async {
    await _ensureLocaleInitialized();
    await _initializeDio();
  }

  /// ضمان تهيئة locale العربية
  static Future<void> _ensureLocaleInitialized() async {
    try {
      await initializeDateFormatting('ar');
      log('✅ تم تهيئة locale العربية بنجاح');
    } catch (e) {
      log('❌ خطأ في تهيئة locale العربية: $e');
    }
  }

  /// تهيئة Dio مع الإعدادات الحالية
  static Future<void> _initializeDio() async {
    final settings = await _getTelegramSettings();
    final botToken = settings['botToken'] ?? '';

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.telegram.org/bot$botToken',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// حفظ إعدادات Telegram
  static Future<bool> saveTelegramSettings({
    required String botToken,
    required String chatId,
  }) async {
    try {
      final box = await Hive.openBox(_telegramBoxName);
      await box.put(_botTokenKey, botToken);
      await box.put(_chatIdKey, chatId);

      // إعادة تهيئة Dio مع الإعدادات الجديدة
      await _initializeDio();

      log('✅ تم حفظ إعدادات Telegram بنجاح');
      return true;
    } catch (e) {
      log('❌ خطأ في حفظ إعدادات Telegram: $e');
      return false;
    }
  }

  /// استرداد إعدادات Telegram
  static Future<Map<String, String?>> _getTelegramSettings() async {
    try {
      final box = await Hive.openBox(_telegramBoxName);
      return {'botToken': box.get(_botTokenKey), 'chatId': box.get(_chatIdKey)};
    } catch (e) {
      log('❌ خطأ في استرداد إعدادات Telegram: $e');
      return {'botToken': null, 'chatId': null};
    }
  }

  /// التحقق من وجود الإعدادات
  static Future<bool> hasValidSettings() async {
    final settings = await _getTelegramSettings();
    final botToken = settings['botToken'];
    final chatId = settings['chatId'];

    return botToken != null &&
        chatId != null &&
        botToken.isNotEmpty &&
        chatId.isNotEmpty;
  }

  /// الحصول على الإعدادات (public)
  static Future<Map<String, String?>> getTelegramSettings() async {
    return await _getTelegramSettings();
  }

  /// إرسال رسالة إلى Telegram
  static Future<bool> _sendMessage(String text) async {
    try {
      // التحقق من وجود الإعدادات
      if (!await hasValidSettings()) {
        log('❌ إعدادات Telegram غير مكتملة');
        return false;
      }

      final settings = await _getTelegramSettings();
      final chatId = settings['chatId']!;

      final response = await _dio.post(
        '/sendMessage',
        data: {
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
          'disable_web_page_preview': true,
        },
      );

      if (response.statusCode == 200) {
        log('✅ تم إرسال الرسالة بنجاح إلى Telegram');
        return true;
      } else {
        log('❌ فشل في إرسال الرسالة: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      log('❌ خطأ Dio في إرسال الرسالة: ${e.message}');
      return false;
    } catch (e) {
      log('❌ خطأ عام في إرسال الرسالة: $e');
      return false;
    }
  }

  /// إرسال الملخص اليومي
  static Future<bool> sendDailySummary({DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dailySummary = await _generateDailySummary(targetDate);
      return await _sendMessage(dailySummary);
    } catch (e) {
      log('❌ خطأ في إرسال الملخص اليومي: $e');
      return false;
    }
  }

  /// إرسال الملخص الأسبوعي
  static Future<bool> sendWeeklySummary({DateTime? weekStart}) async {
    try {
      final targetWeekStart = weekStart ?? _getWeekStart(DateTime.now());
      final weeklySummary = await _generateWeeklySummary(targetWeekStart);
      return await _sendMessage(weeklySummary);
    } catch (e) {
      log('❌ خطأ في إرسال الملخص الأسبوعي: $e');
      return false;
    }
  }

  /// إنشاء الملخص اليومي
  static Future<String> _generateDailySummary(DateTime date) async {
    await _ensureLocaleInitialized();
    final formatter = DateFormat('dd/MM/yyyy', 'ar');
    final dayName = _getArabicDayName(date.weekday);

    // جلب البيانات
    final tasks = await HiveService.getAllTasks();
    final habits = await HiveService.getAllHabits();

    // حساب الإحصائيات
    final completedTasks = QuickStatsService.getTodayCompletedTasks(
      tasks,
      referenceDate: date,
    );
    final totalTasks = QuickStatsService.getTodayTotalTasks(
      tasks,
      referenceDate: date,
    );
    final tasksRate = QuickStatsService.getTodayTasksCompletionRate(
      tasks,
      referenceDate: date,
    );

    final completedHabits = QuickStatsService.getTodayCompletedHabits(
      habits,
      referenceDate: date,
    );
    final habitsRate = QuickStatsService.getTodayHabitsCompletionRate(
      habits,
      referenceDate: date,
    );

    final longestStreak = QuickStatsService.getCurrentLongestStreak(
      habits,
      referenceDate: date,
    );

    // حساب نقاط الإنتاجية
    final productivityScore = _calculateProductivityScore(
      tasksRate,
      habitsRate,
    );

    // بناء الملخص
    final summary = StringBuffer();
    summary.writeln('📊 <b>الملخص اليومي</b>');
    summary.writeln('📅 $dayName، ${formatter.format(date)}');
    summary.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    summary.writeln('');

    // قسم المهام
    summary.writeln('📋 <b>المهام:</b>');
    summary.writeln('✅ مكتملة: <b>$completedTasks</b> من <b>$totalTasks</b>');
    summary.writeln(
      '📊 معدل الإنجاز: <b>${(tasksRate * 100).toStringAsFixed(1)}%</b>',
    );

    if (totalTasks > 0) {
      final tasksProgress = _createProgressBar(tasksRate);
      summary.writeln(tasksProgress);
    }
    summary.writeln('');

    // قسم العادات
    summary.writeln('🔄 <b>العادات:</b>');
    summary.writeln(
      '✅ مكتملة: <b>$completedHabits</b> من <b>${habits.length}</b>',
    );
    summary.writeln(
      '📊 معدل الإنجاز: <b>${(habitsRate * 100).toStringAsFixed(1)}%</b>',
    );

    if (habits.isNotEmpty) {
      final habitsProgress = _createProgressBar(habitsRate);
      summary.writeln(habitsProgress);
    }
    summary.writeln('');

    // الإحصائيات الإضافية
    summary.writeln('🔥 <b>أطول سلسلة:</b> $longestStreak يوم');
    summary.writeln(
      '⭐ <b>نقاط الإنتاجية:</b> ${productivityScore.toStringAsFixed(0)}/100',
    );
    summary.writeln('');

    // تقييم الأداء
    summary.writeln('🎯 <b>تقييم الأداء:</b>');
    summary.writeln(_getPerformanceMessage(productivityScore));

    // أهم العادات المكتملة
    final topHabits = await _getTodayCompletedHabits(habits, date);
    if (topHabits.isNotEmpty) {
      summary.writeln('');
      summary.writeln('🏆 <b>عادات مكتملة اليوم:</b>');
      for (final habit in topHabits.take(3)) {
        summary.writeln('• ${habit.title}');
      }
    }

    return summary.toString();
  }

  /// إنشاء الملخص الأسبوعي
  static Future<String> _generateWeeklySummary(DateTime weekStart) async {
    await _ensureLocaleInitialized();
    final weekEnd = weekStart.add(const Duration(days: 6));
    final formatter = DateFormat('dd/MM', 'ar');

    // إنشاء المراجعة الأسبوعية
    final weeklyReview = await WeeklyReviewService.generateWeeklyReview(
      weekStart,
    );

    // جلب البيانات الإضافية
    final tasks = await HiveService.getAllTasks();
    final habits = await HiveService.getAllHabits();

    // حساب الإحصائيات الأسبوعية
    final weekStats = await _calculateWeeklyStatistics(
      tasks,
      habits,
      weekStart,
      weekEnd,
    );

    // بناء الملخص
    final summary = StringBuffer();
    summary.writeln('📈 <b>الملخص الأسبوعي</b>');
    summary.writeln(
      '📅 ${formatter.format(weekStart)} - ${formatter.format(weekEnd)}',
    );
    summary.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    summary.writeln('');

    // الإحصائيات العامة
    summary.writeln('📊 <b>إحصائيات عامة:</b>');
    summary.writeln(
      '📋 الروتين اليومي: <b>${weeklyReview.completedRoutines}</b>/<b>${weeklyReview.totalRoutines}</b>',
    );
    summary.writeln(
      '📈 معدل الإنجاز العام: <b>${weeklyReview.completionRate.toStringAsFixed(1)}%</b>',
    );
    summary.writeln('🔥 مجموع السلاسل: <b>${weeklyReview.totalStreaks}</b>');
    summary.writeln('');

    // إحصائيات المهام
    summary.writeln('📋 <b>المهام الأسبوعية:</b>');
    summary.writeln(
      '✅ مكتملة: <b>${weekStats['completedTasks']}</b>/<b>${weekStats['totalTasks']}</b>',
    );
    summary.writeln(
      '📊 معدل إنجاز المهام: <b>${(weekStats['tasksRate'] * 100).toStringAsFixed(1)}%</b>',
    );
    final tasksProgress = _createProgressBar(weekStats['tasksRate']);
    summary.writeln(tasksProgress);
    summary.writeln('');

    // إحصائيات العادات
    summary.writeln('🔄 <b>العادات الأسبوعية:</b>');
    summary.writeln(
      '✅ مكتملة: <b>${weekStats['completedHabits']}</b>/<b>${weekStats['totalHabits']}</b>',
    );
    summary.writeln(
      '📊 معدل إنجاز العادات: <b>${(weekStats['habitsRate'] * 100).toStringAsFixed(1)}%</b>',
    );
    final habitsProgress = _createProgressBar(weekStats['habitsRate']);
    summary.writeln(habitsProgress);
    summary.writeln('');

    // تحليل الأيام
    summary.writeln('📅 <b>تحليل الأيام:</b>');
    summary.writeln(
      '🏆 أفضل يوم: <b>${_getArabicDayName(_getDayOfWeek(weeklyReview.bestDay))}</b>',
    );
    summary.writeln(
      '⚠️ يحتاج تحسين: <b>${_getArabicDayName(_getDayOfWeek(weeklyReview.worstDay))}</b>',
    );
    summary.writeln('');

    // الأداء اليومي التفصيلي
    summary.writeln('📊 <b>الأداء اليومي:</b>');
    final sortedDays =
        weeklyReview.dailyCompletions.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    for (final day in sortedDays) {
      final arabicDay = _getArabicDayName(_getDayOfWeek(day.key));
      final completions = day.value;
      final emoji = _getDayEmoji(completions);
      summary.writeln('$emoji $arabicDay: $completions مهمة');
    }
    summary.writeln('');

    // أفضل العادات
    if (weeklyReview.topPerformingRoutines.isNotEmpty) {
      summary.writeln('🏅 <b>أفضل العادات:</b>');
      for (final routine in weeklyReview.topPerformingRoutines.take(3)) {
        final rate = weeklyReview.routineCompletionRates[routine] ?? 0.0;
        summary.writeln('• $routine (<b>${rate.toStringAsFixed(1)}%</b>)');
      }
      summary.writeln('');
    }

    // عادات تحتاج تطوير
    if (weeklyReview.needsImprovementRoutines.isNotEmpty) {
      summary.writeln('⚡ <b>عادات تحتاج تطوير:</b>');
      for (final routine in weeklyReview.needsImprovementRoutines.take(3)) {
        final rate = weeklyReview.routineCompletionRates[routine] ?? 0.0;
        summary.writeln('• $routine (<b>${rate.toStringAsFixed(1)}%</b>)');
      }
      summary.writeln('');
    }

    // نصائح للأسبوع القادم
    summary.writeln('💡 <b>نصائح للأسبوع القادم:</b>');
    summary.writeln(_getWeeklyAdvice(weeklyReview));

    return summary.toString();
  }

  /// حساب نقاط الإنتاجية
  static double _calculateProductivityScore(
    double tasksRate,
    double habitsRate,
  ) {
    // وزن المهام 60% والعادات 40%
    return (tasksRate * 0.6 + habitsRate * 0.4) * 100;
  }

  /// إنشاء شريط التقدم
  static String _createProgressBar(double rate) {
    final completed = (rate * 10).round();
    final remaining = 10 - completed;
    final percentage = (rate * 100).toStringAsFixed(0);

    return '[${'█' * completed}${'░' * remaining}] $percentage%';
  }

  /// الحصول على رسالة تقييم الأداء
  static String _getPerformanceMessage(double score) {
    if (score >= 90)
      return '🔥 <b>أداء رائع!</b> استمر على هذا المستوى المتميز';
    if (score >= 75) return '👍 <b>أداء جيد جداً</b> مع بعض التحسينات البسيطة';
    if (score >= 60) return '👌 <b>أداء جيد</b> يمكن تطويره أكثر';
    if (score >= 40) return '⚠️ <b>أداء متوسط</b> يحتاج تركيز أكبر';
    return '🔴 <b>يحتاج تحسين</b> لا تستسلم، الغد فرصة جديدة!';
  }

  /// الحصول على العادات المكتملة اليوم
  static Future<List<HabitModel>> _getTodayCompletedHabits(
    List<HabitModel> habits,
    DateTime date,
  ) async {
    return habits.where((habit) {
      return habit.completedDates.any((completedDate) {
        return completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day;
      });
    }).toList();
  }

  /// حساب الإحصائيات الأسبوعية
  static Future<Map<String, dynamic>> _calculateWeeklyStatistics(
    List<TaskModel> tasks,
    List<HabitModel> habits,
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    int totalTasks = 0;
    int completedTasks = 0;
    int totalHabits = 0;
    int completedHabits = 0;

    // حساب إحصائيات كل يوم في الأسبوع
    for (int i = 0; i < 7; i++) {
      final currentDate = weekStart.add(Duration(days: i));

      final dayTotalTasks = QuickStatsService.getTodayTotalTasks(
        tasks,
        referenceDate: currentDate,
      );
      final dayCompletedTasks = QuickStatsService.getTodayCompletedTasks(
        tasks,
        referenceDate: currentDate,
      );
      final dayCompletedHabits = QuickStatsService.getTodayCompletedHabits(
        habits,
        referenceDate: currentDate,
      );

      totalTasks += dayTotalTasks;
      completedTasks += dayCompletedTasks;
      totalHabits += habits.length;
      completedHabits += dayCompletedHabits;
    }

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'tasksRate': totalTasks > 0 ? completedTasks / totalTasks : 0.0,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'habitsRate': totalHabits > 0 ? completedHabits / totalHabits : 0.0,
    };
  }

  /// الحصول على نصائح الأسبوع القادم
  static String _getWeeklyAdvice(WeeklyReviewModel review) {
    final advice = StringBuffer();

    if (review.completionRate >= 80) {
      advice.writeln(
        '• <b>أداؤك ممتاز!</b> حاول إضافة تحدي جديد للأسبوع القادم',
      );
    } else if (review.completionRate >= 60) {
      advice.writeln(
        '• ركز على تحسين أداء يوم <b>${_getArabicDayName(_getDayOfWeek(review.worstDay))}</b>',
      );
    } else {
      advice.writeln('• ابدأ بعادات أقل وزد تدريجياً للوصول لهدفك');
    }

    if (review.needsImprovementRoutines.isNotEmpty) {
      advice.writeln(
        '• اعطِ اهتماماً خاصاً لعادة: <b>${review.needsImprovementRoutines.first}</b>',
      );
    }

    advice.writeln(
      '• حافظ على روتينك الممتاز في يوم <b>${_getArabicDayName(_getDayOfWeek(review.bestDay))}</b>',
    );

    return advice.toString();
  }

  /// الحصول على emoji للأيام حسب الأداء
  static String _getDayEmoji(int completions) {
    if (completions >= 5) return '🔥';
    if (completions >= 3) return '💪';
    if (completions >= 1) return '👍';
    return '😔';
  }

  /// تحويل اسم اليوم إلى العربية
  static String _getArabicDayName(int weekday) {
    const arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return arabicDays[weekday - 1];
  }

  /// الحصول على رقم اليوم من اسم اليوم بالإنجليزية
  static int _getDayOfWeek(String dayName) {
    const dayMap = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    return dayMap[dayName] ?? 1;
  }

  /// الحصول على بداية الأسبوع
  static DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// اختبار الاتصال مع البوت
  static Future<bool> testConnection() async {
    try {
      await _ensureLocaleInitialized();
      final timestamp = DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());
      final testMessage =
          '🤖 <b>اختبار الاتصال</b>\n📅 $timestamp\n✅ البوت يعمل بشكل طبيعي!';
      return await _sendMessage(testMessage);
    } catch (e) {
      log('❌ خطأ في اختبار الاتصال: $e');
      return false;
    }
  }

  /// إرسال رسالة مخصصة
  static Future<bool> sendCustomMessage(String message) async {
    return await _sendMessage(message);
  }

  /// إرسال ملخص سريع
  static Future<bool> sendQuickSummary() async {
    try {
      await _ensureLocaleInitialized();
      final now = DateTime.now();
      final tasks = await HiveService.getAllTasks();
      final habits = await HiveService.getAllHabits();

      final completedTasks = QuickStatsService.getTodayCompletedTasks(tasks);
      final totalTasks = QuickStatsService.getTodayTotalTasks(tasks);
      final completedHabits = QuickStatsService.getTodayCompletedHabits(habits);

      final message = '''
⚡ <b>ملخص سريع</b>
📅 ${DateFormat('HH:mm - dd/MM/yyyy').format(now)}

📋 المهام: $completedTasks/$totalTasks
🔄 العادات: $completedHabits/${habits.length}

🚀 استمر في التقدم!
''';

      return await _sendMessage(message);
    } catch (e) {
      log('❌ خطأ في إرسال الملخص السريع: $e');
      return false;
    }
  }
}
