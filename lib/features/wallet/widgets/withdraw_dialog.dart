import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_button.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_model.dart';

class WithdrawDialog extends ConsumerStatefulWidget {
  const WithdrawDialog({super.key});

  @override
  ConsumerState<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends ConsumerState<WithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.zainCash;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _handleWithdraw() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      await ref.read(walletNotifierProvider.notifier).withdrawFunds(
        amount: amount,
        paymentMethod: _selectedMethod,
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(), walletNumber: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
    final walletBalanceAsync = ref.watch(walletBalanceProvider);

    ref.listen(walletNotifierProvider, (previous, next) {
      if (next is WalletSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.successColor,
          ),
        );
        ref.invalidate(walletTransactionsProvider);
      } else if (next is WalletError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: AppTheme.errorColor,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'سحب أموال',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Balance Info
              walletBalanceAsync.when(
                data: (balance) => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.infoColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'الرصيد المتاح: ${balance.toStringAsFixed(0)} د.ع',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              SizedBox(height: 16.h),

              // Amount Input
              Text(
                'المبلغ (د.ع)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  hintText: 'أدخل المبلغ',
                  prefixIcon: const Icon(Icons.remove),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  if (amount < 1000) {
                    return 'الحد الأدنى للسحب 1000 د.ع';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Payment Method
              Text(
                'طريقة الاستلام',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...PaymentMethod.values.map((method) {
                return RadioListTile<PaymentMethod>(
                  value: method,
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
                  title: Row(
                    children: [
                      Icon(_getPaymentMethodIcon(method)),
                      SizedBox(width: 8.w),
                      Text(_getPaymentMethodName(method)),
                    ],
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
              SizedBox(height: 16.h),

              // Reference
              Text(
                'رقم الحساب/المحفظة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _referenceController,
                decoration: InputDecoration(
                  hintText: 'رقم حسابك أو محفظتك',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الحساب';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Warning
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                ),
                child: Text(
                  'ملاحظة: طلبات السحب تحتاج موافقة إدارية وقد تستغرق 24-48 ساعة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: LoadingButton(
                      onPressed: _handleWithdraw,
                      isLoading: walletState is WalletLoading,
                      text: 'سحب',
                      backgroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.zainCash:
        return Icons.phone_android;
      case PaymentMethod.qiCard:
        return Icons.credit_card;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.zainCash:
        return 'زين كاش';
      case PaymentMethod.qiCard:
        return 'كي كارد';
      case PaymentMethod.wallet:
        return 'المحفظة الإلكترونية';
    }
  }
}