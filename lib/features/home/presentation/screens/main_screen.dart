import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/bloc/auth_cubit.dart';
import '../../../services/presentation/screens/services_screen.dart';
import '../../../posts/presentation/screens/posts_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ServicesScreen(),
    const PostsScreen(),
    const EventsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Iconsax.home,
                    activeIcon: Iconsax.home_15,
                    label: context.t('home'),
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Iconsax.book,
                    activeIcon: Iconsax.book5,
                    label: context.t('skills'),
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Iconsax.document,
                    activeIcon: Iconsax.document5,
                    label: context.t('posts'),
                    isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: Iconsax.calendar,
                    activeIcon: Iconsax.calendar5,
                    label: context.t('events'),
                    isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _NavItem(
                    icon: Iconsax.user,
                    activeIcon: Iconsax.user,
                    label: context.t('profile'),
                    isActive: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}