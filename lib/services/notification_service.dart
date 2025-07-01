import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:task_day/services/send_telegram_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Asia/Riyadh'),
    ); // أو المنطقة المناسبة لك

    // Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the notification
    final bool? initialized = await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    log('Notification service initialized: $initialized');

    await _requestPermissions();
    await _createNotificationChannels();
  }

  static Future<void> _requestPermissions() async {
    // طلب أذونات الإشعارات
    await Permission.notification.request();

    // للأندرويد 13+ طلب إذن POST_NOTIFICATIONS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // للأندرويد 12+ طلب إذن SCHEDULE_EXACT_ALARM
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }

    log('Notification permissions requested');
  }

  static Future<void> _createNotificationChannels() async {
    // قناة تذكيرات بداية المهام
    const AndroidNotificationChannel startChannel = AndroidNotificationChannel(
      'routine_start_reminders',
      'Start of Tasks',
      description: 'Reminders for start of daily tasks',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // قناة تذكيرات نهاية المهام
    const AndroidNotificationChannel endChannel = AndroidNotificationChannel(
      'routine_end_reminders',
      'End of Tasks',
      description: 'Reminders for end of daily tasks',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // قناة الاختبار
    const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
      'test_channel',
      'اختبار',
      description: 'قناة اختبار الإشعارات',
      importance: Importance.high,
    );

    // إنشاء القنوات
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(startChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(endChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(testChannel);

    log('Notification channels created');
  }

  static void _onNotificationTap(NotificationResponse response) async {
    log('Notification tapped: ${response.payload}');
    if (response.payload == 'daily_report') {
      log('Sending daily report to Telegram...');
      final success = await TelegramService.sendDailySummary();
      if (success) {
        log('✅ Daily report sent to Telegram successfully');
      } else {
        log('❌ Failed to send daily report to Telegram');
      }
    }
    // Additional navigation logic can be added here if needed
  }

  /// جدولة إشعار بداية المهمة (قبل 10 دقائق)
  static Future<void> scheduleRoutineStartReminder(
    DailyRoutineModel routine,
  ) async {
    try {
      final startDateTime = _combineDateTime(
        routine.dateTime,
        routine.startTime,
      );
      final reminderTime = startDateTime.subtract(const Duration(minutes: 10));
      final notificationId = '${routine.id}_start'.hashCode;

      log('جدولة إشعار بداية المهمة: ${routine.name}');
      log('وقت البداية: $startDateTime');
      log('وقت التذكير: $reminderTime');
      log('الوقت الحالي: ${DateTime.now()}');

      // تأكد أن وقت التذكير في المستقبل
      if (reminderTime.isAfter(DateTime.now())) {
        final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

        await _notifications.zonedSchedule(
          notificationId,
          'Start of Task 🕐',
          'Task "${routine.name}" will start in 10 minutes at ${_formatTimeOfDay(routine.startTime)}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_start_reminders',
              'Start of Tasks',
              channelDescription: 'Reminders for start of daily tasks',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFF6366F1),
              enableVibration: true,
              playSound: true,
              autoCancel: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: 1,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'routine_start_${routine.id}',
        );

        log('Scheduled start reminder for task - ID: $notificationId');
      } else {
        log('Reminder time is in the past, notification not scheduled');
      }
    } catch (e) {
      log('Error scheduling start reminder: $e');
    }
  }

  /// جدولة إشعار نهاية المهمة (قبل 10 دقائق من النهاية)
  static Future<void> scheduleRoutineEndReminder(
    DailyRoutineModel routine,
  ) async {
    try {
      final endDateTime = _combineDateTime(routine.dateTime, routine.endTime);
      final reminderTime = endDateTime.subtract(const Duration(minutes: 10));
      final notificationId = '${routine.id}_end'.hashCode;

      log('Scheduling end reminder for task: ${routine.name}');
      log('End time: $endDateTime');
      log('Reminder time: $reminderTime');

      // تأكد أن وقت التذكير في المستقبل
      if (reminderTime.isAfter(DateTime.now())) {
        final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

        await _notifications.zonedSchedule(
          notificationId,
          'End of Task ⏰',
          'Task "${routine.name}" will end in 10 minutes at ${_formatTimeOfDay(routine.endTime)}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_end_reminders',
              'End of Tasks',
              channelDescription: 'Reminders for end of daily tasks',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              color: Color(0xFFF59E0B),
              enableVibration: true,
              playSound: true,
              autoCancel: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: 1,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'routine_end_${routine.id}',
        );

        log('Scheduled end reminder for task - ID: $notificationId');
      } else {
        log('Reminder time is in the past, notification not scheduled');
      }
    } catch (e) {
      log('Error scheduling end reminder: $e');
    }
  }

  /// جدولة جميع إشعارات الروتين (البداية والنهاية)
  static Future<void> scheduleDailyRoutineReminders(
    DailyRoutineModel routine,
  ) async {
    await scheduleRoutineStartReminder(routine);
    await scheduleRoutineEndReminder(routine);
  }

  /// إلغاء إشعارات روتين محدد
  static Future<void> cancelRoutineNotifications(String routineId) async {
    await _notifications.cancel('${routineId}_start'.hashCode);
    await _notifications.cancel('${routineId}_end'.hashCode);
  }

  /// إلغاء جميع الإشعارات
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// عرض قائمة الإشعارات المجدولة
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// دمج التاريخ مع الوقت
  static DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// تنسيق TimeOfDay للعرض
  static String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// إظهار إشعار فوري للاختبار
  static Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        999,
        'Test Notifications 🔔',
        'Notifications are working correctly!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test',
            channelDescription: 'Test notification channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      log('Test notification shown successfully');
    } catch (e) {
      log('Error showing test notification: $e');
    }
  }

  /// فحص الإشعارات المجدولة وطباعة تفاصيلها
  static Future<void> debugScheduledNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      log('Number of scheduled notifications: ${pending.length}');

      for (final notification in pending) {
        log('Scheduled notification:');
        log('  - ID: ${notification.id}');
        log('  - Title: ${notification.title}');
        log('  - Description: ${notification.body}');
        log('  - Payload: ${notification.payload}');
        log('---');
      }
    } catch (e) {
      log('Error checking scheduled notifications: $e');
    }
  }

  /// جدولة إشعار اختبار في المستقبل القريب
  static Future<void> scheduleTestNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(minutes: 1));
      final scheduledDate = tz.TZDateTime.from(testTime, tz.local);

      await _notifications.zonedSchedule(
        9999,
        'Scheduled Test Notification ⏰',
        'This is a scheduled notification for testing at ${_formatTimeOfDay(TimeOfDay.fromDateTime(testTime))}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test',
            channelDescription: 'Test notification channel',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'test_scheduled',
      );

      log('Scheduled test notification at: $testTime');
    } catch (e) {
      log('Error scheduling test notification: $e');
    }
  }

  /// جدولة إشعار التقرير اليومي في نهاية اليوم
  static Future<void> scheduleDailyReportNotification({
    int hour = 23,
    int minute = 0,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      // إذا كان الوقت قد مضى اليوم، جدوله للغد
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      await _notifications.zonedSchedule(
        10001, // Unique ID for daily report notification
        'Your Daily Report is Ready! 📊',
        'Tap to send your daily report to Telegram',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_report_channel',
            'Daily Report',
            channelDescription:
                'Notification reminder to send daily report to Telegram',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFF0088CC),
            enableVibration: true,
            playSound: true,
            autoCancel: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'daily_report',
        matchDateTimeComponents: DateTimeComponents.time, // يومياً
      );
      log('Daily report notification scheduled at $hour:$minute');
    } catch (e) {
      log('Error scheduling daily report notification: $e');
    }
  }
}
