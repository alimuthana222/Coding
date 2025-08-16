import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../models/transaction_model.dart';
import '../providers/wallet_provider.dart';

class DepositFundsView extends ConsumerStatefulWidget {
  const DepositFundsView({super.key});

  @override
  ConsumerState<DepositFundsView> createState() => _DepositFundsViewState();
}

class _DepositFundsViewState extends ConsumerState<DepositFundsView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.zainCash;

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);

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
      appBar: const CustomAppBar(title: 'Deposit Funds'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentMethodSelection(),
              SizedBox(height: 24.h),
              _buildAmountInput(),
              SizedBox(height: 16.h),
              _buildReferenceInput(),
              SizedBox(height: 24.h),
              _buildInstructions(),
              SizedBox(height: 32.h),
              LoadingButton(
                onPressed: _handleDeposit,
                isLoading: walletState is WalletLoading,
                text: 'Submit Deposit Request',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),
        _buildPaymentMethodCard(
          PaymentMethod.zainCash,
          'ZainCash',
          'Transfer via ZainCash mobile wallet',
          Icons.phone_android,
        ),
        SizedBox(height: 12.h),
        _buildPaymentMethodCard(
          PaymentMethod.qiCard,
          'Qi Card',
          'Transfer via Qi Card payment system',
          Icons.credit_card,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
      PaymentMethod method,
      String title,
      String description,
      IconData icon,
      ) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppTheme.primaryColor : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return CustomTextField(
      controller: _amountController,
      label: 'Amount (IQD)',
      hintText: 'Enter amount to deposit',
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (amount < 1000) {
          return 'Minimum deposit amount is 1,000 IQD';
        }
        return null;
      },
    );
  }

  Widget _buildReferenceInput() {
    return CustomTextField(
      controller: _referenceController,
      label: 'Transaction Reference',
      hintText: 'Enter transaction ID or reference number',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter transaction reference';
        }
        return null;
      },
    );
  }

  Widget _buildInstructions() {
    String instructions;
    switch (_selectedMethod) {
      case PaymentMethod.zainCash:
        instructions = '''
1. Send money via ZainCash to: 07XX XXX XXXX
2. Copy the transaction ID from ZainCash
3. Enter the transaction ID in the reference field above
4. Submit the deposit request
5. Your deposit will be verified within 24 hours
        ''';
        break;
      case PaymentMethod.qiCard:
        instructions = '''
1. Transfer money via Qi Card to: XXXX XXXX XXXX XXXX
2. Copy the transaction reference number
3. Enter the reference in the field above
4. Submit the deposit request
5. Your deposit will be verified within 24 hours
        ''';
        break;
      default:
        instructions = '';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.accentColor,
                size: 20.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            instructions,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleDeposit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      ref.read(walletNotifierProvider.notifier).depositFunds(
        amount: amount,
        paymentMethod: _selectedMethod,
        reference: _referenceController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}