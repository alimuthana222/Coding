import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../providers/wallet_provider.dart';
import '../widgets/deposit_dialog.dart';
import '../widgets/withdraw_dialog.dart';
import '../widgets/transfer_dialog.dart';
import '../widgets/transaction_card.dart';
import '../../../generated/l10n.dart';

class WalletView extends ConsumerWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final walletBalanceAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(walletTransactionsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.wallet,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(walletBalanceProvider);
              ref.invalidate(walletTransactionsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletBalanceProvider);
          ref.invalidate(walletTransactionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              walletBalanceAsync.when(
                data: (balance) => Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white70,
                            size: 24.w,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.availableBalance,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.visibility,
                            color: Colors.white70,
                            size: 20.w,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${balance.toStringAsFixed(0)} د.ع',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.green.shade300,
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'نشط',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade300,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'آخر تحديث: الآن',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                loading: () => _buildBalanceCardSkeleton(),
                error: (error, stack) => _buildBalanceCardError(context, error.toString()),
              ),
              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.add,
                      label: l10n.depositFunds,
                      color: AppTheme.successColor,
                      onPressed: () => _showDepositDialog(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.remove,
                      label: l10n.withdrawFunds,
                      color: AppTheme.errorColor,
                      onPressed: () => _showWithdrawDialog(context),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.swap_horiz,
                      label: l10n.transferFunds,
                      color: AppTheme.infoColor,
                      onPressed: () => _showTransferDialog(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Transactions Header
              Row(
                children: [
                  Text(
                    l10n.transactionHistory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to full transaction history
                      // For now, show a dialog with message about full implementation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('عرض جميع المعاملات'),
                          content: Text('سيتم تنفيذ صفحة عرض جميع المعاملات قريباً'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('حسناً'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('عرض الكل'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Transactions List
              transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return _buildEmptyTransactions(context);
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      return TransactionCard(transaction: transactions[index]);
                    },
                  );
                },
                loading: () => _buildTransactionsLoading(),
                error: (error, stack) => _buildTransactionsError(context, error.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppTheme.borderColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildBalanceCardError(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: AppTheme.errorColor, size: 32.w),
          SizedBox(height: 8.h),
          Text(
            'خطأ في تحميل الرصيد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.w,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد معاملات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ بإيداع أموال في محفظتك',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsLoading() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.borderColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsError(BuildContext context, String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: AppTheme.errorColor, size: 32.w),
          SizedBox(height: 8.h),
          Text(
            'خطأ في تحميل المعاملات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DepositDialog(),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WithdrawDialog(),
    );
  }

  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransferDialog(),
    );
  }
}