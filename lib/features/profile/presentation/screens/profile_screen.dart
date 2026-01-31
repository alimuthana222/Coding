import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/bloc/auth_cubit.dart';
import '../../../auth/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (context, state) {
        if (!state.isAuthenticated || state.user == null) {
          return _buildLoginRequired(context);
        }

        final user = state.user!;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ═══════════════════════════════════════════════════════════════════
                  // PROFILE HEADER
                  // ═══════════════════════════════════════════════════════════════════
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.primaryContainer,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                user.initials,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Iconsax.camera,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.username != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '@${user.username}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (user.bio != null)
                          Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════════════
                  // STATS ROW
                  // ═══════════════════════════════════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: context.t('wallet'),
                          value: '${user.walletHours}',
                          icon: Iconsax.wallet_3,
                          color: AppColors.primary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colorScheme.outlineVariant,
                        ),
                        _StatItem(
                          label: 'المهارات',
                          value: '${user.skills.length}',
                          icon: Iconsax.book,
                          color: AppColors.secondary,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: colorScheme.outlineVariant,
                        ),
                        _StatItem(
                          label: 'التقييم',
                          value: '4.9',
                          icon: Iconsax.star,
                          color: AppColors.star,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════════════
                  // MENU ITEMS
                  // ═══════════════════════════════════════════════════════════════════
                  _MenuItem(
                    icon: Iconsax.user_edit,
                    title: 'تعديل الملف الشخصي',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: صفحة تعديل الملف الشخصي')),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Iconsax.book_saved,
                    title: 'مهاراتي',
                    onTap: () {
                      // Switch to skills tab (index 1)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('انتقل إلى تبويب المهارات من القائمة السفلية')),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Iconsax.heart,
                    title: 'المفضلة',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: صفحة المفضلة')),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Iconsax.calendar,
                    title: 'حجوزاتي',
                    onTap: () => context.push('/bookings'),
                  ),
                  _MenuItem(
                    icon: Iconsax.wallet_2,
                    title: 'المحفظة',
                    onTap: () => context.push('/wallet'),
                  ),
                  _MenuItem(
                    icon: Iconsax.notification,
                    title: 'الإشعارات',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: صفحة الإشعارات')),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Iconsax.setting_2,
                    title: 'الإعدادات',
                    onTap: () => context.push('/settings'),
                  ),
                  _MenuItem(
                    icon: Iconsax.info_circle,
                    title: 'عن التطبيق',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: صفحة عن التطبيق')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════════════════════
                  // LOGOUT BUTTON
                  // ═══════════════════════════════════════════════════════════════════
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Iconsax.logout, color: AppColors.error),
                      label: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.user,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'مرحباً بك!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سجل دخولك للوصول إلى ملفك الشخصي',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRouter.login),
                  child: Text(context.t('login')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRouter.register),
                  child: Text(context.t('create_account')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STAT ITEM
// ═══════════════════════════════════════════════════════════════════

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MENU ITEM
// ═══════════════════════════════════════════════════════════════════

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(
            icon,
            color: iconColor ?? colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(title),
        trailing: Icon(
          Iconsax.arrow_left_2,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}