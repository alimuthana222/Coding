import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../bloc/auth_cubit.dart';
import '../../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على شروط الخدمة'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      await context.read<AuthCubit>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthCubit, AppAuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          // ✅ إظهار رسالة تأكيد الإيميل
          _showEmailConfirmationDialog(context);
        } else if (state.status == AppAuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'حدث خطأ'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_3),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    context.t('create_account'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'انضم إلينا وابدأ بتبادل المهارات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  AppTextField(
                    controller: _nameController,
                    label: context.t('full_name'),
                    hint: 'أحمد محمد',
                    prefixIcon: Iconsax.user,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t('name_required');
                      }
                      if (value.length < 3) {
                        return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  AppTextField(
                    controller: _emailController,
                    label: context.t('email'),
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Iconsax.sms,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t('email_required');
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return context.t('email_invalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    label: context.t('password'),
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    prefixIcon: Iconsax.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.t('password_required');
                      }
                      if (value.length < 6) {
                        return context.t('password_too_short');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: context.t('confirm_password'),
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Iconsax.lock,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'تأكيد كلمة المرور مطلوب';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _agreeToTerms = !_agreeToTerms);
                          },
                          child: Text.rich(
                            TextSpan(
                              text: 'أوافق على ',
                              children: [
                                TextSpan(
                                  text: 'شروط الخدمة',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' و '),
                                TextSpan(
                                  text: 'سياسة الخصوصية',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button - ✅ بدون مؤقت
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onRegister,
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(context.t('create_account')),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.t('have_account'),
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(context.t('login')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Dialog لتأكيد الإيميل
  void _showEmailConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.sms_tracking,
            size: 48,
            color: AppColors.success,
          ),
        ),
        title: const Text('تم إنشاء الحساب بنجاح! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تم إرسال رابط التفعيل إلى بريدك الإلكتروني',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _emailController.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'يرجى فتح بريدك الإلكتروني والضغط على رابط التفعيل لتتمكن من تسجيل الدخول',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.go(AppRouter.login);
              },
              child: const Text('حسناً، سأتحقق من بريدي'),
            ),
          ),
        ],
      ),
    );
  }
}