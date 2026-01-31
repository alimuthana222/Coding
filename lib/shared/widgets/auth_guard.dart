import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

// ✅ Helper class محدث
class AuthHelper {
  // استخدم Supabase للتحقق من حالة تسجيل الدخول
  static bool get isLoggedIn => SupabaseConfig.isAuthenticated;
  static String? get currentUserId => SupabaseConfig.currentUserId;
}

// ✅ Function للتحقق من تسجيل الدخول
void requireAuth(BuildContext context, VoidCallback onAuthenticated) {
  if (AuthHelper.isLoggedIn) {
    onAuthenticated();
  } else {
    _showLoginRequiredSheet(context, onAuthenticated);
  }
}

// ✅ Sheet لطلب تسجيل الدخول
void _showLoginRequiredSheet(BuildContext context, VoidCallback onAuthenticated) {
  final colorScheme = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.lock,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'تسجيل الدخول مطلوب',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للوصول إلى هذه الميزة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.login);
              },
              child: const Text('تسجيل الدخول'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                context.push(AppRouter.register);
              },
              child: const Text('إنشاء حساب جديد'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    ),
  );
}