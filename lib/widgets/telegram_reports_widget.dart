import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_day/services/send_telegram_service.dart';

class TelegramReportsWidget extends StatefulWidget {
  const TelegramReportsWidget({super.key});

  @override
  State<TelegramReportsWidget> createState() => _TelegramReportsWidgetState();
}

class _TelegramReportsWidgetState extends State<TelegramReportsWidget>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _hasValidSettings = false;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkTelegramSettings();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  void _startPulse() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulse() {
    _pulseController.stop();
    _pulseController.reset();
  }

  Future<void> _checkTelegramSettings() async {
    final hasSettings = await TelegramService.hasValidSettings();
    if (mounted) {
      setState(() => _hasValidSettings = hasSettings);
    }
  }

  Future<void> _sendDailyReport() async {
    _startPulse();
    setState(() => _isLoading = true);

    try {
      final success = await TelegramService.sendDailySummary();
      if (mounted) {
        _showResultDialog(
          success: success,
          title: 'الملخص اليومي',
          message:
              success
                  ? 'تم إرسال الملخص اليومي بنجاح! 📊'
                  : 'فشل في إرسال الملخص اليومي',
        );
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(success: false, title: 'خطأ', message: 'حدث خطأ: $e');
      }
    } finally {
      _stopPulse();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendWeeklyReport() async {
    _startPulse();
    setState(() => _isLoading = true);

    try {
      final success = await TelegramService.sendWeeklySummary();
      if (mounted) {
        _showResultDialog(
          success: success,
          title: 'الملخص الأسبوعي',
          message:
              success
                  ? 'تم إرسال الملخص الأسبوعي بنجاح! 📈'
                  : 'فشل في إرسال الملخص الأسبوعي',
        );
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(success: false, title: 'خطأ', message: 'حدث خطأ: $e');
      }
    } finally {
      _stopPulse();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendQuickSummary() async {
    _startPulse();
    setState(() => _isLoading = true);

    try {
      final success = await TelegramService.sendQuickSummary();
      if (mounted) {
        _showResultDialog(
          success: success,
          title: 'الملخص السريع',
          message:
              success
                  ? 'تم إرسال الملخص السريع بنجاح! ⚡'
                  : 'فشل في إرسال الملخص السريع',
        );
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(success: false, title: 'خطأ', message: 'حدث خطأ: $e');
      }
    } finally {
      _stopPulse();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            backgroundColor: const Color(0xFF2E3447),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color:
                        success
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    success ? Icons.check_circle : Icons.error_outline,
                    color: success ? Colors.green : Colors.red,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF0088CC).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'موافق',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF0088CC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _navigateToSettings() {
    context.push('/telegram-settings').then((_) {
      // إعادة فحص الإعدادات عند العودة من الشاشة
      _checkTelegramSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2E3447).withOpacity(0.9),
              const Color(0xFF242938).withOpacity(0.8),
              const Color(0xFF1A1D2E).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFF0088CC).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0088CC).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0088CC).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.telegram,
                        color: const Color(0xFF0088CC),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تقارير Telegram',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'إرسال ملخصات الإنجاز',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _navigateToSettings,
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white60,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // حالة الإعدادات
                if (!_hasValidSettings) ...[
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'يرجى إعداد Telegram أولاً',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToSettings,
                          child: Text(
                            'إعداد',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // أزرار الإرسال
                if (_hasValidSettings) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportButton(
                          icon: Icons.today,
                          title: 'يومي',
                          subtitle: 'اليوم',
                          color: const Color(0xFF4CAF50),
                          onPressed: _isLoading ? null : _sendDailyReport,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildReportButton(
                          icon: Icons.date_range,
                          title: 'أسبوعي',
                          subtitle: 'الأسبوع',
                          color: const Color(0xFF2196F3),
                          onPressed: _isLoading ? null : _sendWeeklyReport,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: _buildReportButton(
                      icon: Icons.flash_on,
                      title: 'ملخص سريع',
                      subtitle: 'إحصائيات فورية',
                      color: const Color(0xFFFF9800),
                      onPressed: _isLoading ? null : _sendQuickSummary,
                      isWide: true,
                    ),
                  ),
                ],

                // حالة التحميل
                if (_isLoading) ...[
                  SizedBox(height: 16.h),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF0088CC),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'جاري الإرسال...',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onPressed,
    bool isWide = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child:
              isWide
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 20.sp),
                      SizedBox(width: 8.w),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 24.sp),
                      SizedBox(height: 8.h),
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
