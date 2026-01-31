import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/wallet_model.dart';
import '../../bloc/wallet_cubit.dart';
import '../../bloc/wallet_state.dart';

class WithdrawalSheet extends StatefulWidget {
  const WithdrawalSheet({super.key});

  @override
  State<WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends State<WithdrawalSheet> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.zainCash;

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغ صحيح')),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل رقم الهاتف')),
      );
      return;
    }

    final success = await context.read<WalletCubit>().requestWithdrawal(
      amount: amount,
      method: _selectedMethod,
      withdrawalPhone: _phoneController.text,
      withdrawalAccount: _accountController.text.isNotEmpty
          ? _accountController.text
          : null,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final balance = state.walletData?.balance ?? 0;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                  'سحب رصيد',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Balance
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Iconsax.wallet_3, color: AppColors.primary),
                            const SizedBox(width: 12),
                            const Text('الرصيد المتاح:'),
                            const Spacer(),
                            Text(
                              '${balance.toStringAsFixed(0)} د.ع',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method
                      Text('طريقة السحب', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MethodCard(
                              icon: '📱',
                              name: 'زين كاش',
                              isSelected: _selectedMethod == PaymentMethod.zainCash,
                              onTap: () => setState(() => _selectedMethod = PaymentMethod.zainCash),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MethodCard(
                              icon: '💳',
                              name: 'كي كارد',
                              isSelected: _selectedMethod == PaymentMethod.qiCard,
                              onTap: () => setState(() => _selectedMethod = PaymentMethod.qiCard),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Amount
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'المبلغ (د.ع)',
                          hintText: '10000',
                          prefixIcon: Icon(Iconsax.money),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: _selectedMethod == PaymentMethod.zainCash
                              ? 'رقم زين كاش'
                              : 'رقم الهاتف',
                          hintText: '07xxxxxxxxx',
                          prefixIcon: const Icon(Iconsax.call),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_selectedMethod == PaymentMethod.qiCard)
                        TextField(
                          controller: _accountController,
                          decoration: const InputDecoration(
                            labelText: 'رقم البطاقة',
                            hintText: '6280 XXXX XXXX XXXX',
                            prefixIcon: Icon(Iconsax.card),
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Note - ✅ تم التصحيح
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.warning, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'سيتم تحويل المبلغ خلال 24-48 ساعة بعد الموافقة',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state.isProcessing ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
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
                              : const Text('إرسال طلب السحب'),
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

class _MethodCard extends StatelessWidget {
  final String icon;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
          ],
        ),
      ),
    );
  }
}

