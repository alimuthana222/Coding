import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../providers/wallet_provider.dart';

class TransferFundsView extends ConsumerStatefulWidget {
  const TransferFundsView({super.key});

  @override
  ConsumerState<TransferFundsView> createState() => _TransferFundsViewState();
}

class _TransferFundsViewState extends ConsumerState<TransferFundsView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
    final walletBalance = ref.watch(walletBalanceProvider);

    ref.listen(walletNotifierProvider, (previous, next) {
      if (next is WalletSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      } else if (next is WalletError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'تحويل أموال'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              walletBalance.when(
                data: (balance) => _buildBalanceInfo(context, balance),
                loading: () => _buildBalanceInfoSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني للمستلم',
                hintText: 'أدخل البريد الإلكتروني للمستلم',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني للمستلم';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _amountController,
                label: 'المبلغ (د.ع)',
                hintText: 'أدخل المبلغ المراد تحويله',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  if (amount < 100) {
                    return 'الحد الأدنى للتحويل 100 د.ع';
                  }
                  // Check against available balance
                  final currentBalance = walletBalance.value ?? 0.0;
                  if (amount > currentBalance) {
                    return 'المبلغ أكبر من الرصيد المتاح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _descriptionController,
                label: 'الوصف (اختياري)',
                hintText: 'أدخل وصف التحويل',
                prefixIcon: Icons.note,
                maxLines: 2,
              ),
              SizedBox(height: 32.h),
              LoadingButton(
                onPressed: _handleTransfer,
                isLoading: walletState is WalletLoading,
                text: 'تحويل الأموال',
                backgroundColor: AppTheme.infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context, double balance) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: AppTheme.accentColor,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرصيد المتاح',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor,
                  ),
                ),
                Text(
                  '${balance.toStringAsFixed(0)} د.ع',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfoSkeleton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.borderColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTransfer() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final email = _emailController.text.trim();
      final description = _descriptionController.text.trim();

      // Use email as the identifier - the service will handle looking up the user
      await ref.read(walletNotifierProvider.notifier).transferFunds(
        toUserId: email, // The service will resolve email to user ID
        amount: amount,
        description: description.isEmpty ? null : description,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}