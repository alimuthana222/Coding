import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionTitle(context, context.t('language')),
          const SizedBox(height: 8),
          _buildLanguageSelector(context),

          const SizedBox(height: 24),

          // Other Settings
          _buildSectionTitle(context, context.t('notifications')),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Iconsax.notification,
            title: context.t('notifications'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle(context, context.t('about')),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Iconsax.document,
            title: context.t('privacy_policy'),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Iconsax.document_text,
            title: context.t('terms_of_service'),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Iconsax.star,
            title: context.t('rate_app'),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Iconsax.share,
            title: context.t('share_app'),
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Iconsax.message_question,
            title: context.t('contact_us'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              // Arabic
              _buildLanguageOption(
                context,
                title: 'العربية',
                subtitle: 'Arabic',
                isSelected: localeProvider.isArabic,
                onTap: () => localeProvider.setArabic(),
              ),
              Divider(height: 1, color: AppColors.divider),
              // English
              _buildLanguageOption(
                context,
                title: 'English',
                subtitle: 'الإنجليزية',
                isSelected: localeProvider.isEnglish,
                onTap: () => localeProvider.setEnglish(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  title == 'العربية' ? 'ع' : 'En',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        trailing: trailing ?? Icon(
          Iconsax.arrow_left_2,
          color: AppColors.textTertiary,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}