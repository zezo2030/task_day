import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_day/models/daily_routine_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

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
      'بداية المهام',
      description: 'تذكيرات بداية المهام اليومية',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // قناة تذكيرات نهاية المهام
    const AndroidNotificationChannel endChannel = AndroidNotificationChannel(
      'routine_end_reminders',
      'انتهاء المهام',
      description: 'تذكيرات انتهاء المهام اليومية',
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

  static void _onNotificationTap(NotificationResponse response) {
    log('Notification tapped: ${response.payload}');
    // يمكن إضافة منطق التنقل هنا حسب الحاجة
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
          'قرب بداية المهمة 🕐',
          'ستبدأ مهمة "${routine.name}" خلال 10 دقائق في ${_formatTimeOfDay(routine.startTime)}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_start_reminders',
              'بداية المهام',
              channelDescription: 'تذكيرات بداية المهام اليومية',
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

        log('تم جدولة إشعار بداية المهمة بنجاح - ID: $notificationId');
      } else {
        log('وقت التذكير في الماضي، لم يتم جدولة الإشعار');
      }
    } catch (e) {
      log('خطأ في جدولة إشعار بداية المهمة: $e');
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

      log('جدولة إشعار نهاية المهمة: ${routine.name}');
      log('وقت النهاية: $endDateTime');
      log('وقت التذكير: $reminderTime');

      // تأكد أن وقت التذكير في المستقبل
      if (reminderTime.isAfter(DateTime.now())) {
        final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

        await _notifications.zonedSchedule(
          notificationId,
          'قرب انتهاء المهمة ⏰',
          'ستنتهي مهمة "${routine.name}" خلال 10 دقائق في ${_formatTimeOfDay(routine.endTime)}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'routine_end_reminders',
              'انتهاء المهام',
              channelDescription: 'تذكيرات انتهاء المهام اليومية',
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

        log('تم جدولة إشعار نهاية المهمة بنجاح - ID: $notificationId');
      } else {
        log('وقت التذكير في الماضي، لم يتم جدولة الإشعار');
      }
    } catch (e) {
      log('خطأ في جدولة إشعار نهاية المهمة: $e');
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
        'اختبار الإشعارات 🔔',
        'الإشعارات تعمل بشكل صحيح!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'اختبار',
            channelDescription: 'قناة اختبار الإشعارات',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      log('تم إظهار إشعار الاختبار بنجاح');
    } catch (e) {
      log('خطأ في إظهار إشعار الاختبار: $e');
    }
  }

  /// فحص الإشعارات المجدولة وطباعة تفاصيلها
  static Future<void> debugScheduledNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      log('عدد الإشعارات المجدولة: ${pending.length}');

      for (final notification in pending) {
        log('إشعار مجدول:');
        log('  - ID: ${notification.id}');
        log('  - العنوان: ${notification.title}');
        log('  - الوصف: ${notification.body}');
        log('  - Payload: ${notification.payload}');
        log('---');
      }
    } catch (e) {
      log('خطأ في فحص الإشعارات المجدولة: $e');
    }
  }

  /// جدولة إشعار اختبار في المستقبل القريب
  static Future<void> scheduleTestNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(minutes: 1));
      final scheduledDate = tz.TZDateTime.from(testTime, tz.local);

      await _notifications.zonedSchedule(
        9999,
        'إشعار اختبار مجدول ⏰',
        'هذا إشعار تم جدولته للاختبار في ${_formatTimeOfDay(TimeOfDay.fromDateTime(testTime))}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'اختبار',
            channelDescription: 'قناة اختبار الإشعارات',
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

      log('تم جدولة إشعار الاختبار في: $testTime');
    } catch (e) {
      log('خطأ في جدولة إشعار الاختبار: $e');
    }
  }
}
