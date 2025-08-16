import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final TabBar? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? AppTheme.textPrimaryColor,
        ),
      ),
      backgroundColor: backgroundColor ?? AppTheme.surfaceColor,
      foregroundColor: foregroundColor ?? AppTheme.textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      leading: leading ??
          (automaticallyImplyLeading && context.canPop()
              ? IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20.w,
            ),
            onPressed: () => context.pop(),
          )
              : null),
      actions: actions,
      bottom: bottom,
      shape: Border(
        bottom: BorderSide(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}