import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/wallet_model.dart';
import '../../bloc/wallet_cubit.dart';
import '../../bloc/wallet_state.dart';

class BuyHoursSheet extends StatefulWidget {
  const BuyHoursSheet({super.key});

  @override
  State<BuyHoursSheet> createState() => _BuyHoursSheetState();
}

class _BuyHoursSheetState extends State<BuyHoursSheet> {
  double _selectedHours = 1;

  double get _totalCost => _selectedHours * WalletConstants.hourPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final balance = state.walletData?.balance ?? 0;
        final currentHours = state.walletData?.timeBankHours ?? 0;
        final maxHours = (balance / WalletConstants.hourPrice).floor().toDouble();
        final canAfford = _totalCost <= balance;

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'شراء ساعات',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Info Cards
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Iconsax.wallet_3,
                              label: 'رصيد المحفظة',
                              value: '${balance.toStringAsFixed(0)} د.ع',
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Iconsax.clock,
                              label: 'ساعاتك الحالية',
                              value: '${currentHours.toStringAsFixed(1)} ساعة',
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Price Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.info_circle, color: AppColors.info),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'سعر الساعة: ${WalletConstants.hourPrice.toStringAsFixed(0)} د.ع',
                                style: const TextStyle(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Hours Selector
                      Text(
                        'اختر عدد الساعات',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),

                      // Quick Select Buttons
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [1, 2, 5, 10, 20].map((hours) {
                          final isSelected = _selectedHours == hours.toDouble();
                          final canSelect = hours <= maxHours;

                          return GestureDetector(
                            onTap: canSelect
                                ? () => setState(() => _selectedHours = hours.toDouble())
                                : null,
                            child: Container(
                              width: 70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.secondary
                                    : canSelect
                                    ? colorScheme.surface
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondary
                                      : colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '$hours',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : canSelect
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    'ساعة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.white70
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Custom Slider
                      if (maxHours > 0) ...[
                        Row(
                          children: [
                            const Text('1'),
                            Expanded(
                              child: Slider(
                                value: _selectedHours.clamp(1, maxHours > 0 ? maxHours : 1),
                                min: 1,
                                max: maxHours > 0 ? maxHours : 1,
                                divisions: maxHours > 1 ? (maxHours - 1).toInt() : 1,
                                activeColor: AppColors.secondary,
                                onChanged: maxHours > 0
                                    ? (value) => setState(() => _selectedHours = value.roundToDouble())
                                    : null,
                              ),
                            ),
                            Text('${maxHours.toInt()}'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Summary
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('عدد الساعات:'),
                                Text(
                                  '${_selectedHours.toStringAsFixed(0)} ساعة',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('المبلغ المطلوب:'),
                                Text(
                                  '${_totalCost.toStringAsFixed(0)} د.ع',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: canAfford ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            if (!canAfford) ...[
                              const SizedBox(height: 8),
                              Text(
                                'الرصيد غير كافي!',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buy Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: canAfford && !state.isProcessing
                              ? () async {
                            final success = await context
                                .read<WalletCubit>()
                                .buyHours(_selectedHours);
                            if (success && mounted) {
                              Navigator.pop(context);
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                          ),
                          child: state.isProcessing
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text('شراء ${_selectedHours.toStringAsFixed(0)} ساعة'),
                        ),
                      ),
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}