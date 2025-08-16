import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class S {
  S();

  static S? _current;
  static S get current {
    assert(_current != null,
    'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;
      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
    'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of(context, S);
  }

  // App Info
  String get appName => 'سوق المهارات';
  String get appSlogan => 'منصة تبادل المهارات والخدمات';

  // Auth
  String get welcome => 'مرحباً بك';
  String get signIn => 'تسجيل الدخول';
  String get signUp => 'إنشاء حساب';
  String get signOut => 'تسجيل الخروج';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get confirmPassword => 'تأكيد كلمة المرور';
  String get fullName => 'الاسم الكامل';
  String get university => 'الجامعة';
  String get major => 'التخصص';
  String get forgotPassword => 'نسيت كلمة المرور؟';
  String get createAccount => 'إنشاء حساب جديد';
  String get alreadyHaveAccount => 'لديك حساب؟';
  String get dontHaveAccount => 'ليس لديك حساب؟';
  String get acceptTerms => 'أوافق على الشروط والأحكام';
  String get profile => 'الملف الشخصي';

  // Navigation
  String get home => 'الرئيسية';
  String get services => 'الخدمات';
  String get wallet => 'المحفظة';
  String get timeBank => 'بنك الوقت';
  String get community => 'المجتمع';
  String get events => 'الفعاليات';
  String get messages => 'الرسائل';
  String get bookings => 'الحجوزات';
  String get admin => 'الإدارة';

  // Services
  String get createService => 'إنشاء خدمة';
  String get serviceRequest => 'طلب خدمة';
  String get serviceOffer => 'تقديم خدمة';
  String get serviceTitle => 'عنوان الخدمة';
  String get serviceDescription => 'وصف الخدمة';
  String get servicePrice => 'سعر الخدمة';
  String get serviceCategory => 'فئة الخدمة';
  String get serviceSkills => 'المهارات المطلوبة';
  String get publishService => 'نشر الخدمة';

  // Wallet
  String get availableBalance => 'الرصيد المتاح';
  String get depositFunds => 'إيداع أموال';
  String get withdrawFunds => 'سحب أموال';
  String get transferFunds => 'تحويل أموال';
  String get transactionHistory => 'تاريخ المعاملات';
  String get noTransactions => 'لا توجد معاملات';

  // General
  String get rating => 'التقييم';
  String get reviews => 'التقييمات';
  String get timeHours => 'الساعات';
  String get loading => 'جاري التحميل...';
  String get error => 'خطأ';
  String get success => 'نجح';
  String get cancel => 'إلغاء';
  String get save => 'حفظ';
  String get edit => 'تعديل';
  String get delete => 'حذف';
  String get search => 'البحث';
  String get filter => 'تصفية';
  String get sort => 'ترتيب';
  String get refresh => 'تحديث';
  String get viewAll => 'عرض الكل';

  // Community
  String get createPost => 'إنشاء منشور';
  String get whatsOnMind => 'ما الذي يجول في خاطرك؟';
  String get post => 'نشر';

  // Messages
  String get newMessage => 'رسالة جديدة';
  String get sendMessage => 'إرسال رسالة';
  String get noMessages => 'لا توجد رسائل';

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    return [
      delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  static List<Locale> get supportedLocales {
    return [
      Locale('ar'),
      Locale('en'),
    ];
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

Future<bool> initializeMessages(String localeName) async {
  return true;
}