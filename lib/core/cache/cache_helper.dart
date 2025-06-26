import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  /// تهيئة الكاش
  static Future<void> init() async {
    try {
      _sharedPreferences = await SharedPreferences.getInstance();
      log('✅ Cache Helper initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize Cache Helper: $e');
      rethrow;
    }
  }

  /// حفظ البيانات
  static Future<bool> saveData({
    required String key,
    required dynamic value,
  }) async {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized, initializing now...');
      await init();
    }

    try {
      if (value is int) {
        return await _sharedPreferences!.setInt(key, value);
      } else if (value is double) {
        return await _sharedPreferences!.setDouble(key, value);
      } else if (value is bool) {
        return await _sharedPreferences!.setBool(key, value);
      } else if (value is String) {
        return await _sharedPreferences!.setString(key, value);
      } else if (value is List<String>) {
        return await _sharedPreferences!.setStringList(key, value);
      } else {
        log('❌ Unsupported data type for key: $key');
        return false;
      }
    } catch (e) {
      log('❌ Error saving data for key: $key, error: $e');
      return false;
    }
  }

  /// جلب البيانات
  static dynamic getData({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.get(key);
    } catch (e) {
      log('❌ Error getting data for key: $key, error: $e');
      return null;
    }
  }

  /// جلب النص
  static String? getString({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.getString(key);
    } catch (e) {
      log('❌ Error getting string for key: $key, error: $e');
      return null;
    }
  }

  /// جلب الرقم الصحيح
  static int? getInt({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.getInt(key);
    } catch (e) {
      log('❌ Error getting int for key: $key, error: $e');
      return null;
    }
  }

  /// جلب الرقم العشري
  static double? getDouble({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.getDouble(key);
    } catch (e) {
      log('❌ Error getting double for key: $key, error: $e');
      return null;
    }
  }

  /// جلب القيمة المنطقية
  static bool? getBool({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.getBool(key);
    } catch (e) {
      log('❌ Error getting bool for key: $key, error: $e');
      return null;
    }
  }

  /// جلب قائمة النصوص
  static List<String>? getStringList({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return null;
    }

    try {
      return _sharedPreferences!.getStringList(key);
    } catch (e) {
      log('❌ Error getting string list for key: $key, error: $e');
      return null;
    }
  }

  /// حذف البيانات
  static Future<bool> removeData({required String key}) async {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return false;
    }

    try {
      return await _sharedPreferences!.remove(key);
    } catch (e) {
      log('❌ Error removing data for key: $key, error: $e');
      return false;
    }
  }

  /// مسح جميع البيانات
  static Future<bool> clearData() async {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return false;
    }

    try {
      return await _sharedPreferences!.clear();
    } catch (e) {
      log('❌ Error clearing all data: $e');
      return false;
    }
  }

  /// التحقق من وجود المفتاح
  static bool containsKey({required String key}) {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return false;
    }

    try {
      return _sharedPreferences!.containsKey(key);
    } catch (e) {
      log('❌ Error checking key: $key, error: $e');
      return false;
    }
  }

  /// جلب جميع المفاتيح
  static Set<String> getAllKeys() {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return <String>{};
    }

    try {
      return _sharedPreferences!.getKeys();
    } catch (e) {
      log('❌ Error getting all keys: $e');
      return <String>{};
    }
  }

  /// إعادة تحميل البيانات
  static Future<void> reload() async {
    if (_sharedPreferences == null) {
      log('⚠️ Cache Helper not initialized');
      return;
    }

    try {
      await _sharedPreferences!.reload();
      log('✅ Cache Helper reloaded successfully');
    } catch (e) {
      log('❌ Error reloading cache: $e');
    }
  }

  /// التحقق من حالة التهيئة
  static bool get isInitialized => _sharedPreferences != null;
}
