import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/core/constants/app_colors.dart';
import 'package:task_day/services/send_telegram_service.dart';

class TelegramSettingsScreen extends StatefulWidget {
  const TelegramSettingsScreen({super.key});

  @override
  State<TelegramSettingsScreen> createState() => _TelegramSettingsScreenState();
}

class _TelegramSettingsScreenState extends State<TelegramSettingsScreen> {
  final _botTokenController = TextEditingController();
  final _chatIdController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _botInfo;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);

    try {
      await SendTelegramService.initialize();

      if (SendTelegramService.isConfigured) {
        _botInfo = await SendTelegramService.getBotInfo();
      }
    } catch (e) {
      _showSnackBar('خطأ في تهيئة الخدمة: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCredentials() async {
    if (_botTokenController.text.isEmpty || _chatIdController.text.isEmpty) {
      _showSnackBar('يرجى ملء جميع الحقول', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await SendTelegramService.updateCredentials(
        botToken: _botTokenController.text.trim(),
        chatId: _chatIdController.text.trim(),
      );

      if (success) {
        _botInfo = await SendTelegramService.getBotInfo();
        _showSnackBar('تم حفظ الإعدادات بنجاح!', Colors.green);
        _clearFields();
      } else {
        _showSnackBar('فشل في الاتصال. تحقق من البيانات', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);

    try {
      final success = await SendTelegramService.testConnection();

      if (success) {
        _showSnackBar('الاتصال يعمل بشكل صحيح!', Colors.green);
      } else {
        _showSnackBar('فشل في الاتصال', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTestMessage() async {
    setState(() => _isLoading = true);

    try {
      final success = await SendTelegramService.sendQuickNotification(
        'اختبار الخدمة',
        'هذه رسالة اختبار للتأكد من عمل خدمة التيليجرام.',
      );

      if (success) {
        _showSnackBar('تم إرسال رسالة الاختبار!', Colors.green);
      } else {
        _showSnackBar('فشل في إرسال الرسالة', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendDailySummary() async {
    setState(() => _isLoading = true);

    try {
      final success = await SendTelegramService.sendDailySummary();

      if (success) {
        _showSnackBar('تم إرسال الملخص اليومي!', Colors.green);
      } else {
        _showSnackBar('فشل في إرسال الملخص', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendWeeklyReport() async {
    setState(() => _isLoading = true);

    try {
      final success = await SendTelegramService.sendWeeklyReport();

      if (success) {
        _showSnackBar('تم إرسال التقرير الأسبوعي!', Colors.green);
      } else {
        _showSnackBar('فشل في إرسال التقرير', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearFields() {
    _botTokenController.clear();
    _chatIdController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'إعدادات التيليجرام',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الحالة الحالية
                    if (SendTelegramService.isConfigured) ...[
                      _buildStatusCard(),
                      SizedBox(height: 24.h),
                    ],

                    // معلومات إعداد البوت
                    _buildSetupGuideCard(),

                    SizedBox(height: 24.h),

                    // نموذج التحديث
                    _buildUpdateForm(),

                    SizedBox(height: 24.h),

                    // أزرار الاختبار والإرسال
                    if (SendTelegramService.isConfigured) ...[
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.2),
            Colors.green.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'الخدمة مفعلة',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          if (_botInfo != null) ...[
            SizedBox(height: 12.h),
            Text(
              'اسم البوت: ${_botInfo!['first_name'] ?? 'غير محدد'}',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
              ),
            ),
            Text(
              'معرف البوت: @${_botInfo!['username'] ?? 'غير محدد'}',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSetupGuideCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'دليل الإعداد',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '1. اذهب إلى @BotFather في التيليجرام\n'
            '2. اكتب /newbot واتبع التعليمات\n'
            '3. احصل على Bot Token\n'
            '4. ابدأ محادثة مع البوت\n'
            '5. اكتب /start\n'
            '6. احصل على Chat ID من @userinfobot',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحديث بيانات التيليجرام',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 16.h),

        // حقل Bot Token
        Text(
          'Bot Token',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _botTokenController,
          style: GoogleFonts.poppins(color: Colors.white),
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'أدخل Bot Token الجديد...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.visibility,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                // Toggle password visibility
              },
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // حقل Chat ID
        Text(
          'Chat ID',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _chatIdController,
          style: GoogleFonts.poppins(color: Colors.white),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'أدخل Chat ID...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // زر التحديث
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _updateCredentials,
            icon: Icon(Icons.save, color: AppColors.primaryColor),
            label: Text(
              'تحديث الإعدادات',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: AppColors.primaryColor,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات التيليجرام',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 16.h),

        // زر اختبار الاتصال
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _testConnection,
            icon: Icon(Icons.wifi_find, color: Colors.white),
            label: Text(
              'اختبار الاتصال',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // زر إرسال رسالة اختبار
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _sendTestMessage,
            icon: Icon(Icons.send, color: Colors.white),
            label: Text(
              'إرسال رسالة اختبار',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // زر إرسال الملخص اليومي
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _sendDailySummary,
            icon: Icon(Icons.summarize, color: Colors.orange),
            label: Text(
              'إرسال الملخص اليومي',
              style: GoogleFonts.poppins(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orange),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // زر إرسال التقرير الأسبوعي
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _sendWeeklyReport,
            icon: Icon(Icons.calendar_view_week, color: Colors.green),
            label: Text(
              'إرسال التقرير الأسبوعي',
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.green),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
