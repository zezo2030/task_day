# 📅 TaskDay - تطبيق إدارة المهام والعادات

<div align="center">
  <img src="assets/images/images.png" alt="TaskDay App" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
  
  **تطبيق شامل لإدارة المهام والعادات اليومية مع نظام إحصائيات متقدم**
</div>

## 🌟 المميزات الرئيسية

### 📋 إدارة المهام
- ✅ إنشاء وتعديل المهام مع تواريخ البداية والنهاية
- 🎯 تصنيف المهام حسب الأولوية (منخفضة، متوسطة، عالية)
- 📝 إضافة مهام فرعية لتنظيم أفضل
- 🔍 فلترة المهام (اليوم، الأسبوع، الشهر، نطاق مخصص)
- ⏰ تتبع حالة الإنجاز للمهام والمهام الفرعية
- 📊 إحصائيات مفصلة عن الأداء

### 🎯 إدارة العادات
- 🔄 عادات قابلة للقياس (مع قيم هدف محددة)
- ✔️ عادات غير قابلة للقياس (مكتملة/غير مكتملة)
- 🎨 تخصيص الألوان والأيقونات للعادات
- 📈 تتبع السلاسل (Streaks) للعادات
- 📅 سجل كامل لتواريخ الإنجاز
- 🔄 إعادة تعيين يومية تلقائية

### 🕐 الروتين اليومي
- ⏰ إنشاء روتين يومي بأوقات محددة
- 🔔 إشعارات للتذكير بالأنشطة
- 📊 تتبع معدل الإنجاز اليومي
- 🔄 إعادة تعيين تلقائية للروتين المتكرر

### 📊 نظام الإحصائيات المتقدم
- 📈 إحصائيات يومية وأسبوعية وشهرية
- 🎯 معدلات الإنجاز المفصلة
- 📊 نقاط الإنتاجية
- 📈 تتبع التقدم مع الرسوم البيانية
- 🏆 أطول السلاسل للعادات

### 📅 المراجعة الأسبوعية
- 📋 تحليل الأداء الأسبوعي
- 💡 اقتراحات للتحسين
- 📊 مقارنة الأداء عبر الأيام
- 🎯 تحديد أفضل وأسوأ الأيام

### 🤖 تكامل تيليجرام
- 📱 إرسال تقارير يومية عبر تيليجرام
- 🔔 إشعارات فورية للإنجازات
- ⚙️ إعدادات قابلة للتخصيص

## 📸 لقطات الشاشة

<div align="center">
  <img src="assets/images/create_task.png" alt="إنشاء مهمة" width="300"/>
  <img src="assets/images/task_details.png" alt="تفاصيل المهمة" width="300"/>
</div>

## 🛠️ التقنيات المستخدمة

### 🎯 Frontend
- **Flutter**: إطار العمل الرئيسي
- **Dart**: لغة البرمجة
- **BLoC/Cubit**: إدارة الحالة
- **go_router**: نظام التنقل
- **Google Fonts**: الخطوط

### 💾 تخزين البيانات
- **Hive**: قاعدة بيانات محلية سريعة
- **Shared Preferences**: الإعدادات
- **JSON Serialization**: تحويل البيانات

### 🔔 الإشعارات والتكامل
- **Flutter Local Notifications**: الإشعارات المحلية
- **Telegram Bot API**: تكامل تيليجرام
- **HTTP**: الاتصال بالخوادم

### 🎨 UI/UX
- **Material Design**: تصميم متسق
- **Custom Animations**: رسوم متحركة مخصصة
- **Dark Theme**: الواجهة الداكنة
- **Responsive Design**: تصميم متجاوب

## 🚀 كيفية التثبيت

### المتطلبات
- Flutter SDK (3.0.0 أو أحدث)
- Dart SDK (3.0.0 أو أحدث)
- Android Studio أو VS Code

### خطوات التثبيت

1. **استنسخ المستودع**
```bash
git clone https://github.com/yourusername/task_day.git
cd task_day
```

2. **تثبيت التبعيات**
```bash
flutter pub get
```

3. **تشغيل build_runner لإنشاء الملفات**
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

4. **تشغيل التطبيق**
```bash
flutter run
```

## 📱 كيفية الاستخدام

### إنشاء مهمة جديدة
1. اضغط على أيقونة "+" في الشاشة الرئيسية
2. اختر "إنشاء مهمة"
3. أدخل عنوان المهمة والوصف
4. حدد تاريخ البداية والنهاية
5. اختر مستوى الأولوية
6. أضف مهام فرعية إذا لزم الأمر

### إنشاء عادة جديدة
1. اضغط على أيقونة "+" في الشاشة الرئيسية
2. اختر "إنشاء عادة"
3. أدخل اسم العادة والوصف
4. اختر الأيقونة واللون
5. حدد نوع العادة (قابلة للقياس أو غير قابلة للقياس)
6. حدد القيمة المستهدفة للعادات القابلة للقياس

### تتبع الإحصائيات
- انتقل إلى تبويب "الإحصائيات"
- اعرض الإحصائيات اليومية والأسبوعية
- تتبع معدلات الإنجاز والتقدم
- راجع أطول السلاسل للعادات

## 🏗️ هيكل المشروع

```
lib/
├── controller/          # إدارة الحالة (BLoC/Cubit)
│   ├── habit_cubit/
│   ├── task_cubit/
│   ├── status_cubit/
│   ├── daily_routine_cubit/
│   └── weekly_review_cubit/
├── core/               # الملفات الأساسية
│   ├── constants/      # الثوابت
│   ├── extensions/     # التوسعات
│   ├── router/         # نظام التنقل
│   ├── themes/         # الثيمات
│   └── utils/          # الأدوات المساعدة
├── models/             # نماذج البيانات
│   ├── habit_model.dart
│   ├── task_model.dart
│   ├── daily_routine_model.dart
│   ├── weekly_review_model.dart
│   └── daily_stats_model.dart
├── services/           # الخدمات
│   ├── hive_service.dart
│   ├── notification_service.dart
│   ├── send_telegram_service.dart
│   ├── quick_stats_service.dart
│   ├── stored_stats_service.dart
│   └── weekly_review_service.dart
├── view/               # الشاشات
│   ├── home_screen.dart
│   ├── tasks_screen.dart
│   ├── habits_screen.dart
│   ├── status_screen.dart
│   ├── create_task_screen.dart
│   ├── create_habit_screen.dart
│   ├── edit_task_screen.dart
│   ├── edit_habit_screen.dart
│   ├── task_details_screen.dart
│   ├── habit_details_screen.dart
│   ├── daily_routine_view.dart
│   ├── weekly_review_screen.dart
│   └── telegram_settings_screen.dart
├── widgets/            # الودجات المخصصة
│   ├── habit_card.dart
│   ├── measurable_habit_card.dart
│   ├── non_measurable_habit_card.dart
│   ├── habit_streak_calendar.dart
│   └── telegram_reports_widget.dart
└── main.dart           # نقطة الدخول
```

## 🔧 المميزات المتقدمة

### نظام الإحصائيات الهجين
- **حسابات فورية**: للبيانات البسيطة
- **حسابات مخزنة**: للبيانات المعقدة
- **تحديث ذكي**: يحسب البيانات عند الحاجة فقط
- **تنظيف تلقائي**: يحذف البيانات القديمة

### إعادة التعيين اليومي
- **تلقائي**: يعيد تعيين العادات يومياً
- **ذكي**: يحافظ على سجل الإنجاز
- **مرن**: يدعم الروتين المتكرر وغير المتكرر

### نظام التنقل المتقدم
- **go_router**: تنقل حديث ومرن
- **Deep Linking**: دعم الروابط العميقة
- **State Management**: إدارة حالة التنقل
- **Error Handling**: معالجة أخطاء التنقل

## 🤝 المساهمة

نرحب بمساهماتكم! يرجى اتباع هذه الخطوات:

1. Fork المشروع
2. إنشاء branch جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push إلى البranch (`git push origin feature/amazing-feature`)
5. فتح Pull Request

## 📝 To-Do List

- [ ] إضافة مزامنة السحابة
- [ ] دعم التذكيرات الذكية
- [ ] تكامل مع تطبيقات أخرى
- [ ] إضافة المزيد من أنواع الإحصائيات
- [ ] دعم التصدير والاستيراد
- [ ] إضافة نظام المكافآت

## 🐛 الإبلاغ عن الأخطاء

إذا وجدت خطأ، يرجى إنشاء issue جديد مع:
- وصف مفصل للخطأ
- خطوات إعادة الإنتاج
- لقطات شاشة إن أمكن
- معلومات الجهاز والنظام

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## 👨‍💻 المطور

**[اسم المطور]**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 شكر وتقدير

- فريق Flutter للإطار الرائع
- مجتمع Dart للدعم المستمر
- جميع المساهمين في هذا المشروع

---

<div align="center">
  <p>صنع بـ ❤️ باستخدام Flutter</p>
  <p>⭐ إذا أعجبك المشروع، لا تنس وضع نجمة!</p>
</div>
