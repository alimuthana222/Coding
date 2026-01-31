import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Professional button widget matching mockup designs
/// 
/// Features:
/// - Primary (filled) and outlined variants
/// - Loading state with spinner
/// - Icon support
/// - Consistent styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 12,
    this.padding,
  });

  /// Primary filled button (default)
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.borderRadius = 12,
    this.padding,
  })  : isOutlined = false,
        backgroundColor = AppColors.primary,
        textColor = Colors.white;

  /// Outlined button variant
  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.borderRadius = 12,
    this.padding,
  })  : isOutlined = true,
        backgroundColor = null,
        textColor = AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppColors.primary;
    final foregroundColor = textColor ?? (isOutlined ? AppColors.textPrimary : Colors.white);

    // Button content
    Widget buttonChild = isLoading
        ? SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    // Outlined variant
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: const BorderSide(color: AppColors.divider, width: 1.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    // Primary filled variant
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: onPressed != null && !isLoading
              ? AppColors.primaryGlow
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: buttonColor.withValues(alpha: 0.6),
          ),
          child: buttonChild,
        ),
      ),
    );
  }
}
