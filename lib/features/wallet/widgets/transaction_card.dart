import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = _isIncomingTransaction();
    final color = _getTransactionColor();
    final icon = _getTransactionIcon();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 48.w,
            height: 48.h,
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
          SizedBox(width: 12.w),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.typeDisplayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${isIncoming ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} د.ع',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.description ?? _getDefaultDescription(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        transaction.statusDisplayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('dd/MM/yyyy - HH:mm').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isIncomingTransaction() {
    return transaction.type == TransactionType.deposit ||
        transaction.type == TransactionType.transferReceived ||
        transaction.type == TransactionType.refund;
  }

  Color _getTransactionColor() {
    if (_isIncomingTransaction()) {
      return AppTheme.successColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.deposit:
        return Icons.add_circle_outline;
      case TransactionType.withdrawal:
        return Icons.remove_circle_outline;
      case TransactionType.transferSent:
        return Icons.arrow_upward;
      case TransactionType.transferReceived:
        return Icons.arrow_downward;
      case TransactionType.payment:
        return Icons.payment;
      case TransactionType.refund:
        return Icons.refresh;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return AppTheme.warningColor;
      case TransactionStatus.completed:
        return AppTheme.successColor;
      case TransactionStatus.failed:
        return AppTheme.errorColor;
      case TransactionStatus.cancelled:
        return AppTheme.textSecondaryColor;
    }
  }

  String _getDefaultDescription() {
    switch (transaction.type) {
      case TransactionType.deposit:
        return 'إيداع أموال في المحفظة';
      case TransactionType.withdrawal:
        return 'سحب أموال من المحفظة';
      case TransactionType.transferSent:
        return 'تحويل إلى ${transaction.toUserName ?? 'مستخدم آخر'}';
      case TransactionType.transferReceived:
        return 'تحويل من ${transaction.fromUserName ?? 'مستخدم آخر'}';
      case TransactionType.payment:
        return 'دفع مقابل خدمة';
      case TransactionType.refund:
        return 'استرداد مبلغ';
    }
  }
}