import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../generated/l10n.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      labelKey: 'home',
      route: '/',
      color: AppTheme.accentColor, // Use theme accent color
    ),
    NavItem(
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
      labelKey: 'search',
      route: '/services',
      color: AppTheme.textSecondaryColor,
    ),
    NavItem(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      labelKey: 'wallet',
      route: '/wallet',
      color: AppTheme.textSecondaryColor,
    ),
    NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      labelKey: 'profile',
      route: '/profile',
      color: AppTheme.textSecondaryColor,
    ),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(_navItems[index].route);
    }
  }

  String _getCurrentRoute() {
    return GoRouterState.of(context).matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final currentRoute = _getCurrentRoute();

    // تحديث الفهرس بناءً على المسار الحالي
    for (int i = 0; i < _navItems.length; i++) {
      if (currentRoute.startsWith(_navItems[i].route)) {
        _selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.icon,
                            color: isSelected
                                ? item.color
                                : AppTheme.textSecondaryColor.withOpacity(0.6),
                            size: 26.w,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _getLabel(l10n, item.labelKey),
                            style: TextStyle(
                              color: isSelected
                                  ? item.color
                                  : AppTheme.textSecondaryColor.withOpacity(0.6),
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _getLabel(S l10n, String labelKey) {
    switch (labelKey) {
      case 'home':
        return 'الرئيسية';
      case 'search':
        return 'البحث';
      case 'wallet':
        return 'المحفظة';
      case 'profile':
        return 'الملف الشخصي';
      default:
        return labelKey;
    }
  }
}

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String labelKey;
  final String route;
  final Color color;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    required this.route,
    required this.color,
  });
}