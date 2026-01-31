import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../../auth/bloc/auth_cubit.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ═══════════════════════════════════════════════════════════════════
            // APP BAR
            // ═══════════════════════════════════════════════════════════════════
            SliverAppBar(
              floating: true,
              snap: true,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.book,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.t('app_name'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.notification),
                  onPressed: () {
                    requireAuth(context, () {});
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 16),
                  child: GestureDetector(
                    onTap: () {
                      if (SupabaseConfig.isAuthenticated) {
                        // Navigate to profile
                      } else {
                        context.push(AppRouter.login);
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Iconsax.user,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ═══════════════════════════════════════════════════════════════════
            // GREETING
            // ═══════════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<AuthCubit, AppAuthState>(
                      builder: (context, state) {
                        final name = state.user?.fullName.split(' ').first ?? '';
                        return Text(
                          _getGreeting(name),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),


                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════════
            // WALLET CARD - يفتح صفحة المحفظة
            // ═══════════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _WalletCard(),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════════
            // CATEGORIES
            // ═══════════════════════════════════════════════════════════════════


            // ═══════════════════════════════════════════════════════════════════
            // FEATURED SKILLS
            // ═══════════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _SectionHeader(
                    title: context.t('featured_skills'),
                    onSeeAll: () {},
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _mockSkills.length,
                      itemBuilder: (context, index) {
                        final skill = _mockSkills[index];
                        return _SkillCard(skill: skill);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════════════
            // UPCOMING EVENTS
            // ═══════════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _SectionHeader(
                    title: context.t('upcoming_events'),
                    onSeeAll: () {},
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _mockEvents.length,
                      itemBuilder: (context, index) {
                        final event = _mockEvents[index];
                        return _EventCard(event: event);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    if (name.isNotEmpty) {
      return '$greeting، $name 👋';
    }
    return '$greeting 👋';
  }
}

// ═══════════════════════════════════════════════════════════════════
// WALLET CARD
// ═══════════════════════════════════════════════════════════════════

class _WalletCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AppAuthState>(
      builder: (context, state) {
        final isLoggedIn = state.isAuthenticated;
        final walletHours = state.user?.walletHours ?? 0;

        return GestureDetector(
          onTap: () {
            if (isLoggedIn) {
              // ✅ فتح صفحة المحفظة
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            } else {
              requireAuth(context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WalletScreen()),
                );
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.walletGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              boxShadow: AppColors.primaryGlow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    isLoggedIn ? Iconsax.wallet_3 : Iconsax.lock,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.t('wallet'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          context.t('hours'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLoggedIn ? walletHours.toStringAsFixed(0) : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.arrow_left_2, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'اضغط للتفاصيل',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(context.t('see_all')),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORY CARD
// ═══════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(left: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SKILL CARD
// ═══════════════════════════════════════════════════════════════════

class _SkillCard extends StatelessWidget {
  final Map<String, dynamic> skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: 12),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: (skill['color'] as Color).withOpacity(0.15),
              ),
              child: Center(
                child: Icon(
                  skill['icon'] as IconData,
                  size: 36,
                  color: skill['color'] as Color,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill['teacher'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                      const SizedBox(width: 2),
                      Text(
                        '${skill['rating']}',
                        style: theme.textTheme.labelSmall,
                      ),
                      const Spacer(),
                      Text(
                        skill['price'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// EVENT CARD
// ═══════════════════════════════════════════════════════════════════

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = event['color'] as Color;

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(left: 12),
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
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withOpacity(0.8)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event['day'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    event['month'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['type'] as String,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          event['isOnline'] == true ? Iconsax.video : Iconsax.location,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event['location'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MOCK DATA
// ═══════════════════════════════════════════════════════════════════

final List<Map<String, dynamic>> _categories = [
  {'icon': Iconsax.code, 'label': 'cat_programming', 'color': const Color(0xFF6366F1)},
  {'icon': Iconsax.brush_1, 'label': 'cat_design', 'color': const Color(0xFFEC4899)},
  {'icon': Iconsax.chart, 'label': 'cat_marketing', 'color': const Color(0xFFF59E0B)},
  {'icon': Iconsax.edit, 'label': 'cat_writing', 'color': const Color(0xFF14B8A6)},
  {'icon': Iconsax.video, 'label': 'cat_video', 'color': const Color(0xFFEF4444)},
  {'icon': Iconsax.music, 'label': 'cat_music', 'color': const Color(0xFF8B5CF6)},
  {'icon': Iconsax.teacher, 'label': 'cat_education', 'color': const Color(0xFF0EA5E9)},
];

final List<Map<String, dynamic>> _mockSkills = [
  {
    'title': 'تطوير المواقع',
    'teacher': 'أحمد محمد',
    'rating': 4.9,
    'price': '2 ساعة',
    'icon': Iconsax.code,
    'color': const Color(0xFF6366F1),
  },
  {
    'title': 'تصميم الشعارات',
    'teacher': 'فاطمة علي',
    'rating': 5.0,
    'price': '1 ساعة',
    'icon': Iconsax.brush_1,
    'color': const Color(0xFFEC4899),
  },
  {
    'title': 'مونتاج الفيديو',
    'teacher': 'سارة أحمد',
    'rating': 4.8,
    'price': '3 ساعات',
    'icon': Iconsax.video,
    'color': const Color(0xFFEF4444),
  },
  {
    'title': 'الترجمة',
    'teacher': 'محمد خالد',
    'rating': 4.7,
    'price': '1 ساعة',
    'icon': Iconsax.translate,
    'color': const Color(0xFF14B8A6),
  },
];

final List<Map<String, dynamic>> _mockEvents = [
  {
    'title': 'ورشة تعلم Flutter',
    'type': 'ورشة عمل',
    'day': '15',
    'month': 'فبراير',
    'location': 'أونلاين',
    'isOnline': true,
    'color': AppColors.success,
  },
  {
    'title': 'مطلوب مصمم UI/UX',
    'type': 'وظيفة',
    'day': '20',
    'month': 'فبراير',
    'location': 'بغداد',
    'isOnline': false,
    'color': AppColors.info,
  },
  {
    'title': 'مؤتمر التقنية',
    'type': 'مؤتمر',
    'day': '25',
    'month': 'فبراير',
    'location': 'أربيل',
    'isOnline': false,
    'color': AppColors.primary,
  },
];