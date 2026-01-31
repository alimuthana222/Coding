import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['ar']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': _arabicStrings,
    'en': _englishStrings,
  };

  // ═══════════════════════════════════════════════════════════════════
  // ARABIC STRINGS
  // ═══════════════════════════════════════════════════════════════════

  static const Map<String, String> _arabicStrings = {
    // App
    'app_name': 'مهارات',
    'app_slogan': 'تبادل المهارات، استثمر وقتك',

    // Onboarding
    'onboarding1_title': 'تعلّم مهارات جديدة',
    'onboarding1_desc': 'اكتشف مهارات متنوعة من أشخاص حقيقيين في مجتمعك',
    'onboarding2_title': 'شارك خبراتك',
    'onboarding2_desc': 'علّم الآخرين ما تتقنه واكسب ساعات لتعلم ما تريد',
    'onboarding3_title': 'بنك الوقت',
    'onboarding3_desc': 'ساعة تعليم = ساعة تعلّم. نظام عادل للجميع',

    // Auth
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'confirm_password': 'تأكيد كلمة المرور',
    'full_name': 'الاسم الكامل',
    'phone': 'رقم الهاتف',
    'forgot_password': 'نسيت كلمة المرور؟',
    'no_account': 'ليس لديك حساب؟',
    'have_account': 'لديك حساب بالفعل؟',
    'welcome_back': 'مرحباً بعودتك',
    'create_account': 'إنشاء حساب جديد',
    'or_continue_with': 'أو المتابعة باستخدام',
    'google': 'Google',
    'login_to_continue': 'سجّل دخولك للمتابعة',
    'login_required_desc': 'تحتاج تسجيل الدخول لاستخدام هذه الميزة.\nسجّل الآن واستمتع بتبادل المهارات!',
    'later': 'لاحقاً',
    'welcome_guest': 'أهلاً بك في مهارات!',
    'guest_features': 'سجّل دخولك للوصول إلى:\n• ملفك الشخصي\n• محادثاتك\n• حجوزاتك\n• محفظتك',

    // Validation
    'email_required': 'البريد الإلكتروني مطلوب',
    'email_invalid': 'البريد الإلكتروني غير صحيح',
    'password_required': 'كلمة المرور مطلوبة',
    'password_too_short': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'name_required': 'الاسم مطلوب',

    // Navigation
    'home': 'الرئيسية',
    'skills': 'المهارات',
    'messages': 'الرسائل',
    'profile': 'الملف',
    'posts': 'المنشورات',
    'events': 'الفعاليات',

    // Home
    'greeting': 'أهلاً،',
    'search_hint': 'ابحث عن مهارة...',
    'wallet': 'المحفظة',
    'hours': 'ساعات',
    'featured_skills': 'مهارات مميزة',
    'see_all': 'عرض الكل',
    'per_hour': 'للساعة',
    'guest_user': 'زائر',
    'username': 'اسم المستخدم',

    // General
    'next': 'التالي',
    'skip': 'تخطي',
    'start': 'ابدأ',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'done': 'تم',
    'settings': 'الإعدادات',

    // Settings & Theme
    'appearance': 'المظهر',
    'system_theme': 'حسب النظام',
    'follow_system': 'اتبع إعدادات الجهاز',
    'light_mode': 'الوضع الفاتح',
    'light_theme_desc': 'مظهر فاتح ومريح للعين',
    'dark_mode': 'الوضع الداكن',
    'dark_theme_desc': 'مريح للعين ليلاً',

    // Language
    'language': 'اللغ��',
    'arabic': 'العربية',
    'english': 'English',

    // Other Settings
    'notifications': 'الإشعارات',
    'privacy_policy': 'سياسة الخصوصية',
    'terms_of_service': 'شروط الخدمة',
    'rate_app': 'قيّم التطبيق',
    'share_app': 'شارك التطبيق',
    'contact_us': 'تواصل معنا',
    'about': 'عن التطبيق',
    'version': 'الإصدار',

    // Login Required
    'login_required_for': 'سجّل دخولك لعرض',
    'feature_requires_login': 'هذه الميزة تتطلب تسجيل الدخول',

    // Skills Page
    'skills_page': 'صفحة المهارات',
    'available_for_all': 'متاحة للجميع',
    'book_now': 'احجز الآن',
    'skill_details': 'تفاصيل المهارة',

    // Messages
    'messages_page': 'صفحة الرسائل',
    'no_messages': 'لا توجد رسائل',

    // Profile
    'profile_page': 'الملف الشخصي',
    'edit_profile': 'تعديل الملف',

    // Misc
    'google_login_soon': 'سيتم إضافة تسجيل الدخول بجوجل قريباً',

    // ═══════════════════════════════════════════════════════════════════
    // SKILLS DATA - Arabic
    // ═══════════════════════════════════════════════════════════════════

    // Skill Categories - Fiverr Style
    'cat_all': 'الكل',
    'cat_programming': 'البرمجة والتقنية',
    'cat_design': 'التصميم',
    'cat_marketing': 'التسويق الرقمي',
    'cat_writing': 'الكتابة والترجمة',
    'cat_video': 'الفيديو والأنيميشن',
    'cat_music': 'الموسيقى والصوتيات',
    'cat_business': 'الأعمال',
    'cat_data': 'البيانات',
    'cat_photography': 'التصوير',
    'cat_ai': 'الذكاء الاصطناعي',
    'cat_lifestyle': 'أسلوب الحياة',
    'cat_education': 'التعليم والتدريب',

// Updated Skills
    'skill_web_dev': 'تطوير المواقع',
    'skill_mobile_dev': 'تطوير التطبيقات',
    'skill_logo_design': 'تصميم الشعارات',
    'skill_ui_ux': 'تصميم UI/UX',
    'skill_social_media': 'تصميم السوشيال ميديا',
    'skill_video_editing': 'مونتاج الفيديو',
    'skill_animation': 'الأنيميشن',
    'skill_voice_over': 'التعليق الصوتي',
    'skill_translation': 'الترجمة',
    'skill_content_writing': 'كتابة المحتوى',
    'skill_seo': 'تحسين محركات البحث ',
    'skill_ads': 'الإعلانات المدفوعة',
    'skill_data_entry': 'إدخال البيانات',
    'skill_data_analysis': 'تحليل البيانات',
    'skill_photo_editing': 'تعديل الصور',
    'skill_ai_services': 'خدمات الذكاء الاصطناعي',
    'skill_online_tutoring': 'الدروس الخصوصية',
    'skill_consulting': 'الاستشارات',



    // Prices/Duration
    'price_one_hour': 'ساعة واحدة',
    'price_two_hours': 'ساعتان',
    'price_three_hours': 'ثلاث ساعات',
    'hour': 'ساعة',
    'hours_unit': 'ساعات',



// Posts Section
    'posts_page': 'المنشورات',
    'create_post': 'إنشاء منشور',
    'whats_on_your_mind': 'بماذا تفكر؟',
    'post': 'نشر',
    'like': 'إعجاب',
    'comment': 'تعليق',
    'share': 'مشاركة',
    'comments': 'تعليقات',
    'likes': 'إعجابات',
    'write_comment': 'اكتب تعليقاً...',
    'just_now': 'الآن',
    'minutes_ago': 'دقائق',
    'hours_ago': 'ساعات',
    'days_ago': 'أيام',
    'no_posts': 'لا توجد منشورات',
    'be_first_post': 'كن أول من ينشر!',

// Events Section
    'events_page': 'الفعاليات',
    'create_event': 'إنشاء فعالية',
    'all_events': 'جميع الفعاليات',
    'upcoming_events': 'الفعاليات القادمة',
    'past_events': 'الفعاليات السابقة',
    'my_events': 'فعالياتي',

// Event Types
    'event_type': 'نوع الفعالية',
    'job': 'وظيفة',
    'workshop': 'ورشة عمل',
    'conference': 'مؤتمر',
    'meetup': 'لقاء',
    'webinar': 'ندوة إلكترونية',
    'training': 'تدريب',
    'other': 'أخرى',

// Event Details
    'event_title': 'عنوان الفعالية',
    'event_description': 'وصف الفعالية',
    'event_date': 'تاريخ الفعالية',
    'event_time': 'وقت الفعالية',
    'event_location': 'موقع الفعالية',
    'event_online': 'أونلاين',
    'event_onsite': 'حضوري',
    'registered': 'مسجل',
    'interested': 'مهتم',
    'attendees': 'المشاركون',
    'free': 'مجاني',
    'paid': 'مدفوع',
    'limited_seats': 'مقاعد محدودة',
    'seats_available': 'مقعد متاح',
    'registration_closed': 'التسجيل مغلق',
    'event_ended': 'انتهت الفعالية',
    'starting_soon': 'تبدأ قريباً',
    'happening_now': 'جارية الآن',

// Job specific
    'job_title': 'المسمى الوظيفي',
    'company': 'الشركة',
    'job_type': 'نوع الوظيفة',
    'full_time': 'دوام كامل',
    'part_time': 'دوام جزئي',
    'remote': 'عن بعد',
    'hybrid': 'هجين',
    'salary': 'الراتب',
    'apply_now': 'قدم الآن',
    'requirements': 'المتطلبات',
    'benefits': 'المزايا',

// Filters
    'filter_by': 'تصفية حسب',
    'sort_by': 'ترتيب حسب',
    'newest': 'الأحدث',
    'oldest': 'الأقدم',
    'most_popular': 'الأكثر شعبية',
    'nearest': 'الأقرب',

    'send': 'إرسال',
    'password_reset_sent': 'تم إرسال رابط إعادة تعيين كلمة المرور',
    'password_reset_failed': 'فشل إرسال الرابط',
    'agree_terms_required': 'يجب الموافقة على شروط الخدمة',
    'join_us': 'انضم إلينا وابدأ بتبادل المهارات',
    'name_too_short': 'الاسم يجب أن يكون 3 أحرف على الأقل',
    'confirm_password_required': 'تأكيد كلمة المرور مطلوب',
    'passwords_not_match': 'كلمة المرور غير متطابقة',
    'i_agree_to': 'أوافق على ',
    'and': ' و ',

  };

  // ═══════════════════════════════════════════════════════════════════
  // ENGLISH STRINGS
  // ═══════════════════════════════════════════════════════════════════

  static const Map<String, String> _englishStrings = {
    // App
    'app_name': 'Maharat',
    'app_slogan': 'Exchange Skills, Invest Your Time',

    // Onboarding
    'onboarding1_title': 'Learn New Skills',
    'onboarding1_desc': 'Discover diverse skills from real people in your community',
    'onboarding2_title': 'Share Your Expertise',
    'onboarding2_desc': 'Teach others what you know and earn hours to learn what you want',
    'onboarding3_title': 'Time Bank',
    'onboarding3_desc': '1 hour teaching = 1 hour learning. A fair system for everyone',

    // Auth
    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'full_name': 'Full Name',
    'phone': 'Phone Number',
    'forgot_password': 'Forgot Password?',
    'no_account': "Don't have an account?",
    'have_account': 'Already have an account?',
    'welcome_back': 'Welcome Back',
    'create_account': 'Create New Account',
    'or_continue_with': 'Or continue with',
    'google': 'Google',
    'login_to_continue': 'Login to Continue',
    'login_required_desc': 'You need to login to use this feature.\nJoin now and start exchanging skills!',
    'later': 'Later',
    'welcome_guest': 'Welcome to Maharat!',
    'guest_features': 'Login to access:\n• Your profile\n• Your chats\n• Your bookings\n• Your wallet',

    // Validation
    'email_required': 'Email is required',
    'email_invalid': 'Invalid email address',
    'password_required': 'Password is required',
    'password_too_short': 'Password must be at least 6 characters',
    'name_required': 'Name is required',

    // Navigation
    'home': 'Home',
    'skills': 'Skills',
    'messages': 'Messages',
    'profile': 'Profile',
    'posts': 'Posts',
    'events': 'Events',

    // Home
    'greeting': 'Hello,',
    'search_hint': 'Search for a skill...',
    'wallet': 'Wallet',
    'hours': 'hours',
    'featured_skills': 'Featured Skills',
    'see_all': 'See All',
    'per_hour': 'per hour',
    'guest_user': 'Guest',
    'username': 'Username',

    // General
    'next': 'Next',
    'skip': 'Skip',
    'start': 'Start',
    'cancel': 'Cancel',
    'save': 'Save',
    'done': 'Done',
    'settings': 'Settings',

    // Settings & Theme
    'appearance': 'Appearance',
    'system_theme': 'System',
    'follow_system': 'Follow device settings',
    'light_mode': 'Light Mode',
    'light_theme_desc': 'Bright and easy on the eyes',
    'dark_mode': 'Dark Mode',
    'dark_theme_desc': 'Easy on the eyes at night',

    // Language
    'language': 'Language',
    'arabic': 'العربية',
    'english': 'English',

    // Other Settings
    'notifications': 'Notifications',
    'privacy_policy': 'Privacy Policy',
    'terms_of_service': 'Terms of Service',
    'rate_app': 'Rate App',
    'share_app': 'Share App',
    'contact_us': 'Contact Us',
    'about': 'About',
    'version': 'Version',

    // Login Required
    'login_required_for': 'Login to view',
    'feature_requires_login': 'This feature requires login',

    // Skills Page
    'skills_page': 'Skills Page',
    'available_for_all': 'Available for everyone',
    'book_now': 'Book Now',
    'skill_details': 'Skill Details',

    // Messages
    'messages_page': 'Messages Page',
    'no_messages': 'No messages',

    // Profile
    'profile_page': 'Profile Page',
    'edit_profile': 'Edit Profile',

    // Misc
    'google_login_soon': 'Google login coming soon',

    // ═══════════════════════════════════════════════════════════════════
    // SKILLS DATA - English
    // ═══════════════════════════════════════════════════════════════════

    // Skill Categories
    'cat_all': 'All',
    'cat_programming': 'Programming & Tech',
    'cat_design': 'Graphics & Design',
    'cat_marketing': 'Digital Marketing',
    'cat_writing': 'Writing & Translation',
    'cat_video': 'Video & Animation',
    'cat_music': 'Music & Audio',
    'cat_business': 'Business',
    'cat_data': 'Data',
    'cat_photography': 'Photography',
    'cat_ai': 'AI Services',
    'cat_education': 'Education & Training',

// Skills
    'skill_web_dev': 'Web Development',
    'skill_mobile_dev': 'Mobile Development',
    'skill_logo_design': 'Logo Design',
    'skill_ui_ux': 'UI/UX Design',
    'skill_social_media': 'Social Media Design',
    'skill_video_editing': 'Video Editing',
    'skill_animation': 'Animation',
    'skill_voice_over': 'Voice Over',
    'skill_translation': 'Translation',
    'skill_content_writing': 'Content Writing',
    'skill_seo': 'SEO',
    'skill_ads': 'Paid Advertising',
    'skill_data_entry': 'Data Entry',
    'skill_data_analysis': 'Data Analysis',
    'skill_photo_editing': 'Photo Editing',
    'skill_ai_services': 'AI Services',
    'skill_online_tutoring': 'Online Tutoring',
    'skill_consulting': 'Consulting',



    // Prices/Duration
    'price_one_hour': '1 hour',
    'price_two_hours': '2 hours',
    'price_three_hours': '3 hours',
    'hour': 'hour',
    'hours_unit': 'hours',



// Posts Section
    'posts_page': 'Posts',
    'create_post': 'Create Post',
    'whats_on_your_mind': "What's on your mind?",
    'post': 'Post',
    'like': 'Like',
    'comment': 'Comment',
    'share': 'Share',
    'comments': 'comments',
    'likes': 'likes',
    'write_comment': 'Write a comment...',
    'just_now': 'Just now',
    'minutes_ago': 'minutes ago',
    'hours_ago': 'hours ago',
    'days_ago': 'days ago',
    'no_posts': 'No posts yet',
    'be_first_post': 'Be the first to post!',

// Events Section
    'events_page': 'Events',
    'create_event': 'Create Event',
    'all_events': 'All Events',
    'upcoming_events': 'Upcoming Events',
    'past_events': 'Past Events',
    'my_events': 'My Events',

// Event Types
    'event_type': 'Event Type',
    'job': 'Job',
    'workshop': 'Workshop',
    'conference': 'Conference',
    'meetup': 'Meetup',
    'webinar': 'Webinar',
    'training': 'Training',
    'other': 'Other',

// Event Details
    'event_title': 'Event Title',
    'event_description': 'Event Description',
    'event_date': 'Event Date',
    'event_time': 'Event Time',
    'event_location': 'Event Location',
    'event_online': 'Online',
    'event_onsite': 'On-site',
    'registered': 'Registered',
    'interested': 'Interested',
    'attendees': 'Attendees',
    'free': 'Free',
    'paid': 'Paid',
    'limited_seats': 'Limited Seats',
    'seats_available': 'seats available',
    'registration_closed': 'Registration Closed',
    'event_ended': 'Event Ended',
    'starting_soon': 'Starting Soon',
    'happening_now': 'Happening Now',

// Job specific
    'job_title': 'Job Title',
    'company': 'Company',
    'job_type': 'Job Type',
    'full_time': 'Full Time',
    'part_time': 'Part Time',
    'remote': 'Remote',
    'hybrid': 'Hybrid',
    'salary': 'Salary',
    'apply_now': 'Apply Now',
    'requirements': 'Requirements',
    'benefits': 'Benefits',

// Filters
    'filter_by': 'Filter by',
    'sort_by': 'Sort by',
    'newest': 'Newest',
    'oldest': 'Oldest',
    'most_popular': 'Most Popular',
    'nearest': 'Nearest',

    'send': 'Send',
    'password_reset_sent': 'Password reset link has been sent',
    'password_reset_failed': 'Failed to send reset link',
    'agree_terms_required': 'You must agree to the terms of service',
    'join_us': 'Join us and start exchanging skills',
    'name_too_short': 'Name must be at least 3 characters',
    'confirm_password_required': 'Confirm password is required',
    'passwords_not_match': 'Passwords do not match',
    'i_agree_to': 'I agree to ',
    'and': ' and ',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;
  String t(String key) => AppLocalizations.of(this)?.get(key) ?? key;
}