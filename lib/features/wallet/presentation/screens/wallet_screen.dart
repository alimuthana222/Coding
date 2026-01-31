import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/wallet_model.dart';
import '../../bloc/wallet_cubit.dart';
import '../../bloc/wallet_state.dart';
import '../widgets/deposit_sheet.dart';
import '../widgets/withdrawal_sheet.dart';
import '../widgets/buy_hours_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<WalletCubit>().clearMessages();
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<WalletCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('المحفظة'),
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_right_3),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: state.status == WalletStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: () => context.read<WalletCubit>().refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ═══════════════════════════════════════════════════════════════════
                  // WALLET BALANCE CARD
                  // ═══════════════════════════════════════════════════════════════════
                  _WalletBalanceCard(
                    balance: state.walletData?.balance ?? 0,
                    onDeposit: () => _showDepositSheet(context),
                    onWithdraw: () => _showWithdrawalSheet(context),
                  ),
                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════════════════════
                  // TIME BANK CARD
                  // ═══════════════════════════════════════════════════════════════════
                  _TimeBankCard(
                    hours: state.walletData?.timeBankHours ?? 0,
                    onBuyHours: () => _showBuyHoursSheet(context),
                  ),
                  const SizedBox(height: 24),

                  // ═══════════════════════════════════════════════════════════════════
                  // TRANSACTIONS TABS
                  // ═══════════════════════════════════════════════════════════════════
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      tabs: const [
                        Tab(text: 'معاملات المحفظة'),
                        Tab(text: 'معاملات الساعات'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ═══════════════════════════════════════════════════════════════════
                  // TRANSACTIONS LIST
                  // ═══════════════════════════════════════════════════════════════════
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _WalletTransactionsList(
                          transactions: state.walletTransactions,
                        ),
                        _TimeBankTransactionsList(
                          transactions: state.timeBankTransactions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDepositSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: const DepositSheet(),
      ),
    );
  }

  void _showWithdrawalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: const WithdrawalSheet(),
      ),
    );
  }

  void _showBuyHoursSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<WalletCubit>(),
        child: const BuyHoursSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WALLET BALANCE CARD
// ═══════════════════════════════════════════════════════════════════

class _WalletBalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  const _WalletBalanceCard({
    required this.balance,
    required this.onDeposit,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppColors.primaryGlow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.wallet_3, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'رصيد المحفظة',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                balance.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'د.ع',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Iconsax.add,
                  label: 'إيداع',
                  onTap: onDeposit,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Iconsax.export_1,
                  label: 'سحب',
                  onTap: onWithdraw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TIME BANK CARD
// ═══════════════════════════════════════════════════════════════════

class _TimeBankCard extends StatelessWidget {
  final double hours;
  final VoidCallback onBuyHours;

  const _TimeBankCard({
    required this.hours,
    required this.onBuyHours,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.clock, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بنك الساعات',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      hours.toStringAsFixed(1),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ساعة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onBuyHours,
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('شراء'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WALLET TRANSACTIONS LIST
// ═══════════════════════════════════════════════════════════════════

class _WalletTransactionsList extends StatelessWidget {
  final List<WalletTransactionModel> transactions;

  const _WalletTransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.receipt,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionItem(
          icon: _getIcon(transaction.type),
          iconColor: transaction.isIncoming ? AppColors.success : AppColors.error,
          title: transaction.typeLabel,
          subtitle: transaction.descriptionAr ?? '',
          amount: '${transaction.isIncoming ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} د.ع',
          amountColor: transaction.isIncoming ? AppColors.success : AppColors.error,
          status: transaction.statusLabel,
          statusColor: _getStatusColor(transaction.status),
          date: _formatDate(transaction.createdAt),
        );
      },
    );
  }

  IconData _getIcon(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.deposit: return Iconsax.add_circle;
      case WalletTransactionType.withdrawal: return Iconsax.export_1;
      case WalletTransactionType.servicePayment: return Iconsax.shopping_cart;
      case WalletTransactionType.serviceEarning: return Iconsax.money_recive;
      case WalletTransactionType.buyHours: return Iconsax.clock;
      case WalletTransactionType.refund: return Iconsax.refresh;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending: return AppColors.warning;
      case TransactionStatus.completed: return AppColors.success;
      case TransactionStatus.rejected: return AppColors.error;
      case TransactionStatus.cancelled: return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// TIME BANK TRANSACTIONS LIST
// ═══════════════════════════════════════════════════════════════════

class _TimeBankTransactionsList extends StatelessWidget {
  final List<TimeBankTransactionModel> transactions;

  const _TimeBankTransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.clock,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد معاملات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionItem(
          icon: _getIcon(transaction.type),
          iconColor: transaction.isIncoming ? AppColors.success : AppColors.secondary,
          title: transaction.typeLabel,
          subtitle: transaction.descriptionAr ?? '',
          amount: '${transaction.isIncoming ? '+' : '-'}${transaction.hours.toStringAsFixed(1)} ساعة',
          amountColor: transaction.isIncoming ? AppColors.success : AppColors.secondary,
          date: _formatDate(transaction.createdAt),
        );
      },
    );
  }

  IconData _getIcon(TimeBankTransactionType type) {
    switch (type) {
      case TimeBankTransactionType.initial: return Iconsax.gift;
      case TimeBankTransactionType.purchased: return Iconsax.shopping_bag;
      case TimeBankTransactionType.earned: return Iconsax.medal_star;
      case TimeBankTransactionType.spent: return Iconsax.timer;
      case TimeBankTransactionType.refund: return Iconsax.refresh;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// TRANSACTION ITEM
// ═══════════════════════════════════════════════════════════════════

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final String? status;
  final Color? statusColor;
  final String date;

  const _TransactionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    this.status,
    this.statusColor,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status!,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: theme.textTheme.titleSmall?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}