# Navigation System Documentation 📱

## نظام التنقل المحسن في TaskDay

تم تطوير نظام تنقل متقدم وموحد للتطبيق باستخدام `go_router` مع أفضل الممارسات.

## 🏗️ الهيكل

```
lib/core/router/
├── app_route.dart           # إعداد الراوتر الرئيسي
├── navigation_helper.dart   # مساعد التنقل المركزي
└── README.md               # هذا الملف

lib/core/extensions/
└── navigation_extensions.dart  # Extensions للتنقل السهل
```

## 🚀 المميزات

### ✅ ما تم إصلاحه:
- استبدال جميع `Navigator.push` بـ `context.push`
- استبدال جميع `Navigator.pop` بـ `context.pop` الذكي
- إضافة معالجة للأخطاء والصفحات المفقودة
- دعم التنقل مع البيانات (extra parameters)
- تحسين الأداء والذاكرة

### 🔧 الأدوات المتوفرة:

#### 1. NavigationHelper Class
```dart
// التنقل الأساسي
NavigationHelper.goHome(context);
NavigationHelper.goToTasks(context);
NavigationHelper.goToHabits(context);

// التنقل مع البيانات
NavigationHelper.goToTaskDetails(context, task);
NavigationHelper.goToHabitDetails(context, habit);

// التنقل الذكي للخلف
NavigationHelper.goBack(context, fallbackRoute: '/tasks');
```

#### 2. Navigation Extensions
```dart
// استخدام أسهل مع BuildContext
context.goHome();
context.goToTasks();
context.pushTaskDetails(task);
context.smartPop(fallbackRoute: '/habits');
```

## 📚 طرق الاستخدام

### التنقل العادي
```dart
// الطريقة القديمة ❌
Navigator.push(context, MaterialPageRoute(
  builder: (context) => TaskDetailsScreen(task: task)
));

// الطريقة الجديدة ✅
context.pushTaskDetails(task);
// أو
NavigationHelper.goToTaskDetails(context, task);
```

### التنقل للخلف الذكي
```dart
// الطريقة القديمة ❌
Navigator.pop(context);

// الطريقة الجديدة ✅
context.smartPop(); // يتحقق من إمكانية الرجوع
// أو مع fallback
context.smartPop(fallbackRoute: '/home');
```

### التنقل بين التبويبات
```dart
// التبديل للتبويب الثاني (Habits)
context.switchToTab(1);
// أو
NavigationHelper.goToHomeWithTab(context, 1);
```

## 🛣️ المسارات المتوفرة

| المسار | الوصف | معاملات |
|--------|--------|---------|
| `/` | الصفحة الرئيسية | `?tab=0,1,2,3` |
| `/tasks` | صفحة المهام | - |
| `/habits` | صفحة العادات | - |
| `/status` | صفحة الإحصائيات | - |
| `/create-task` | إنشاء مهمة جديدة | - |
| `/create-habit` | إنشاء عادة جديدة | - |
| `/task-details/:taskId` | تفاصيل المهمة | `extra: TaskModel` |
| `/habit-details/:habitId` | تفاصيل العادة | `extra: HabitModel` |

## 🎯 أفضل الممارسات

### 1. استخدم Smart Navigation
```dart
// بدلاً من التحقق اليدوي
if (Navigator.canPop(context)) {
  Navigator.pop(context);
} else {
  Navigator.pushReplacement(context, ...);
}

// استخدم الطريقة الذكية
context.smartPop(fallbackRoute: '/home');
```

### 2. مرر البيانات بشكل صحيح
```dart
// للتفاصيل السريعة (مع البيانات)
context.pushTaskDetails(task);

// للتنقل العادي (بدون بيانات)
context.go('/tasks');
```

### 3. التعامل مع الأخطاء
النظام يتعامل تلقائياً مع:
- صفحات الأخطاء المخصصة
- البيانات المفقودة
- المسارات غير الموجودة

## 🔄 الترحيل من النظام القديم

### خطوات التحديث:
1. استبدال `Navigator.push` بـ `context.push`
2. استبدال `Navigator.pop` بـ `context.smartPop`
3. استخدام `NavigationHelper` للمنطق المعقد
4. إضافة `import` للـ extensions

### مثال على الترحيل:
```dart
// القديم ❌
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TaskDetailsScreen(task: task),
  ),
);

// الجديد ✅
context.pushTaskDetails(task);
```

## 🐛 معالجة الأخطاء

النظام يتضمن:
- صفحة أخطاء مخصصة وجميلة
- صفحة "غير موجود" للمحتوى المفقود
- Log للأخطاء في وضع التطوير
- استعادة تلقائية للحالة

## 📱 التجربة

- تنقل سلس وسريع
- عدم فقدان البيانات
- دعم الرجوع للخلف
- ذاكرة محسنة
- UX متسق

---

**ملاحظة:** جميع أنماط التنقل القديمة تم تحديثها واستبدالها بالنظام الجديد المحسن. 🚀 