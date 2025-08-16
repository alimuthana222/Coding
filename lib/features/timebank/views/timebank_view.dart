import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/time_transaction_model.dart';
import '../providers/timebank_provider.dart';

class TimeBankView extends ConsumerWidget {
  const TimeBankView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeBalance = ref.watch(timeBalanceProvider);
    final timeTransactions = ref.watch(timeTransactionsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Time Bank'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(timeBalanceProvider);
          ref.invalidate(timeTransactionsProvider);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: timeBalance.when(
                  data: (balance) => _buildTimeBalanceCard(context, balance),
                  loading: () => _buildBalanceCardSkeleton(),
                  error: (error, stack) => _buildErrorCard(context, error.toString()),
                ),
              ),
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _buildQuickActions(context),
              ),
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _buildTimeTransactions(context, timeTransactions),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBalanceCard(BuildContext context, int balance) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 28.w,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '$balance',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Hours',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Exchange your time for skills or receive time by providing services',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      width: double.infinity,
      height: 160.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20.r),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
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
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load time balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Transfer Time',
                Icons.send,
                AppTheme.primaryColor,
                    () => _showTransferDialog(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                context,
                'Exchange Skills',
                Icons.swap_horiz,
                AppTheme.accentColor,
                    () => _showSkillExchangeDialog(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Earn Time',
                Icons.add_circle,
                AppTheme.successColor,
                    () => _showEarnTimeDialog(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                context,
                'Time History',
                Icons.history,
                AppTheme.warningColor,
                    () => _showTimeHistory(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTransactions(BuildContext context, AsyncValue<List<TimeTransactionModel>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Time Activity',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16.h),
        transactions.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.take(10).length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildTransactionItem(context, transactions[index]);
              },
            );
          },
          loading: () => _buildTransactionSkeleton(),
          error: (error, stack) => Center(
            child: Text('Error loading transactions: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, TimeTransactionModel transaction) {
    IconData icon;
    Color color;
    String sign;

    switch (transaction.type) {
      case TimeTransactionType.earned:
        icon = Icons.add_circle;
        color = AppTheme.successColor;
        sign = '+';
        break;
      case TimeTransactionType.spent:
        icon = Icons.remove_circle;
        color = AppTheme.errorColor;
        sign = '-';
        break;
      case TimeTransactionType.transferred:
        icon = Icons.send;
        color = AppTheme.warningColor;
        sign = '-';
        break;
      case TimeTransactionType.received:
        icon = Icons.call_received;
        color = AppTheme.accentColor;
        sign = '+';
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$sign${transaction.hours} hrs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(48.w),
      child: Column(
        children: [
          Icon(
            Icons.access_time,
            size: 64.w,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No time transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start exchanging skills to see your time activity',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSkeleton() {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showTransferDialog(BuildContext context) {
    // TODO: Implement transfer time dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Time'),
        content: const Text('Transfer time feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSkillExchangeDialog(BuildContext context) {
    // TODO: Implement skill exchange dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exchange Skills'),
        content: const Text('Skill exchange feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEarnTimeDialog(BuildContext context) {
    // TODO: Implement earn time dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earn Time'),
        content: const Text('Earn time feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimeHistory(BuildContext context) {
    // TODO: Navigate to detailed time history
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time History'),
        content: const Text('Detailed time history coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}