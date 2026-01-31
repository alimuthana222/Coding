import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/service_model.dart';
import '../../../../core/models/wallet_model.dart';
import '../../bloc/services_cubit.dart';
import '../../bloc/services_state.dart';

class CreateServiceSheet extends StatefulWidget {
  const CreateServiceSheet({super.key});

  @override
  State<CreateServiceSheet> createState() => _CreateServiceSheetState();
}

class _CreateServiceSheetState extends State<CreateServiceSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  ServiceType _serviceType = ServiceType.offering;
  PricingType _pricingType = PricingType.hours;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('عنوان الخدمة مطلوب');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('وصف الخدمة مطلوب');
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showError('أدخل سعر صحيح');
      return;
    }

    final success = await context.read<ServicesCubit>().createService(
      serviceType: _serviceType,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      pricingType: _pricingType,
      priceHours: _pricingType == PricingType.hours ? price : null,
      priceMoney: _pricingType == PricingType.money ? price : null,
      categoryId: _selectedCategoryId,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الخدمة بنجاح! ✅'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'إضافة خدمة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ═══════════════════════════════════════════════════════════════════
                      // SERVICE TYPE
                      // ═══════════════════════════════════════════════════════════════════
                      Text('نوع الخدمة', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _TypeCard(
                              icon: Iconsax.export_3,
                              title: 'أعرض خدمة',
                              subtitle: 'أقدر أساعدك في...',
                              color: AppColors.success,
                              isSelected: _serviceType == ServiceType.offering,
                              onTap: () => setState(() => _serviceType = ServiceType.offering),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _TypeCard(
                              icon: Iconsax.import_1,
                              title: 'أطلب خدمة',
                              subtitle: 'أحتاج مساعدة في...',
                              color: AppColors.info,
                              isSelected: _serviceType == ServiceType.requesting,
                              onTap: () => setState(() => _serviceType = ServiceType.requesting),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════════════════════
                      // TITLE
                      // ═══════════════════════════════════════════════════════════════════
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الخدمة',
                          hintText: 'مثال: تصميم شعار احترافي',
                          prefixIcon: Icon(Iconsax.edit),
                        ),
                        maxLength: 100,
                      ),
                      const SizedBox(height: 16),

                      // ═══════════════════════════════════════════════════════════════════
                      // DESCRIPTION
                      // ═══════════════════════════════════════════════════════════════════
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'وصف الخدمة',
                          hintText: 'اكتب وصفاً مفصلاً عن الخدمة...',
                          prefixIcon: Icon(Iconsax.document_text),
                          alignLabelWithHint: true,
                        ),
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),

                      // ═══════════════════════════════════════════════════════════════════
                      // CATEGORY
                      // ═══════════════════════════════════════════════════════════════════
                      Text('التصنيف', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategoryId = isSelected ? null : cat.id;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                cat.nameAr,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // ═══════════════════════════════════════════════════════════════════
                      // PRICING TYPE
                      // ═══════════════════════════════════════════════════════════════════
                      Text('طريقة التسعير', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _PricingCard(
                              icon: Iconsax.clock,
                              title: 'بنك الساعات',
                              subtitle: 'تبادل بالساعات',
                              color: AppColors.secondary,
                              isSelected: _pricingType == PricingType.hours,
                              onTap: () => setState(() => _pricingType = PricingType.hours),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PricingCard(
                              icon: Iconsax.money,
                              title: 'مدفوع',
                              subtitle: 'بالدينار العراقي',
                              color: AppColors.success,
                              isSelected: _pricingType == PricingType.money,
                              onTap: () => setState(() => _pricingType = PricingType.money),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ═══════════════════════════════════════════════════════════════════
                      // PRICE
                      // ═══════════════════════════════════════════════════════════════════
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: _pricingType == PricingType.hours
                              ? 'السعر (بالساعات)'
                              : 'السعر (بالدينار)',
                          hintText: _pricingType == PricingType.hours ? '1' : '5000',
                          prefixIcon: Icon(
                            _pricingType == PricingType.hours
                                ? Iconsax.clock
                                : Iconsax.money,
                          ),
                          suffixText: _pricingType == PricingType.hours ? 'ساعة' : 'د.ع',
                        ),
                      ),

                      // Info
                      if (_pricingType == PricingType.hours) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.info_circle, color: AppColors.info, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'سيتم خصم الساعات من العميل عند إتمام الخدمة وإضافتها لرصيدك',
                                  style: TextStyle(
                                    color: AppColors.info,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),

                      // ═══════════════════════════════════════════════════════════════════
                      // SUBMIT BUTTON
                      // ═══════════════════════════════════════════════════════════════════
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isCreating ? null : _submit,
                          child: state.isCreating
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text('نشر الخدمة'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PricingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? color : colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}