import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/deposit_request_provider.dart';
import '../models/deposit_request_model.dart';

class DepositRequestsViewImproved extends ConsumerStatefulWidget {
  const DepositRequestsViewImproved({super.key});

  @override
  ConsumerState<DepositRequestsViewImproved> createState() => _DepositRequestsViewImprovedState();
}

class _DepositRequestsViewImprovedState extends ConsumerState<DepositRequestsViewImproved>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(depositRequestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الإيداع'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context, isDark),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(depositRequestsProvider),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(text: 'معلقة'),
            Tab(text: 'مقبولة'),
            Tab(text: 'مرفوضة'),
          ],
        ),
      ),
      body: requestsAsync.when(
        data: (requests) => _buildRequestsTabView(context, requests, isDark),
        loading: () => _buildRequestsLoading(isDark),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildRequestsTabView(BuildContext context, List<DepositRequestModel> requests, bool isDark) {
    final pendingRequests = requests.where((r) => r.status == 'pending').toList();
    final approvedRequests = requests.where((r) => r.status == 'approved').toList();
    final rejectedRequests = requests.where((r) => r.status == 'rejected').toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _buildRequestsList(context, pendingRequests, isDark, showActions: true),
        _buildRequestsList(context, approvedRequests, isDark, showActions: false),
        _buildRequestsList(context, rejectedRequests, isDark, showActions: false),
      ],
    );
  }

  Widget _buildRequestsList(BuildContext context, List<DepositRequestModel> requests, bool isDark, {required bool showActions}) {
    if (requests.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request, isDark, showActions: showActions);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, DepositRequestModel request, bool isDark, {required bool showActions}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Header
          _buildRequestHeader(context, request, isDark),
          
          // Request Details
          _buildRequestDetails(context, request, isDark),
          
          // Receipt Image
          if (request.receiptImageUrl != null)
            _buildReceiptImage(context, request, isDark),
          
          // Actions (for pending requests only)
          if (showActions && request.status == 'pending')
            _buildRequestActions(context, request, isDark),
        ],
      ),
    );
  }

  Widget _buildRequestHeader(BuildContext context, DepositRequestModel request, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getStatusColor(request.status).withOpacity(0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.primaryColor,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.userName ?? 'مستخدم غير معروف',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.userEmail ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(context, request.status, isDark),
        ],
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context, DepositRequestModel request, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المبلغ المطلوب:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${request.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Payment Method
          _buildDetailRow(
            context,
            'طريقة الدفع:',
            _getPaymentMethodName(request.paymentMethod),
            isDark,
          ),
          
          SizedBox(height: 8.h),
          
          // Request Date
          _buildDetailRow(
            context,
            'تاريخ الطلب:',
            _formatDate(request.createdAt),
            isDark,
          ),
          
          // Notes
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'ملاحظات:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                request.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          
          // Admin Notes (for processed requests)
          if (request.adminNotes != null && request.adminNotes!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'ملاحظات الإدارة:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.warningColor,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
              ),
              child: Text(
                request.adminNotes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.warningColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptImage(BuildContext context, DepositRequestModel request, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إيصال الدفع:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => _showReceiptFullScreen(context, request.receiptImageUrl!),
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  request.receiptImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 48.w,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'خطأ في تحميل الصورة',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestActions(BuildContext context, DepositRequestModel request, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _approveRequest(request),
              icon: Icon(Icons.check_rounded),
              label: Text('قبول'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rejectRequest(request),
              icon: Icon(Icons.close_rounded),
              label: Text('رفض'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status, bool isDark) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRequestsLoading(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          height: 200.h,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64.w,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لا توجد طلبات إيداع في هذه الفئة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64.w,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => ref.refresh(depositRequestsProvider),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'mobile_payment':
        return 'دفع عبر الهاتف';
      case 'credit_card':
        return 'بطاقة ائتمان';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showReceiptFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 0.8.sh,
            maxWidth: 0.9.sw,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, bool isDark) {
    // Implement filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية الطلبات'),
        content: Text('ميزة التصفية ستكون متاحة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _approveRequest(DepositRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('قبول طلب الإيداع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من قبول طلب الإيداع؟'),
            SizedBox(height: 12.h),
            Text('المبلغ: \$${request.amount.toStringAsFixed(2)}'),
            Text('المستخدم: ${request.userName}'),
            SizedBox(height: 12.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أضف ملاحظات للمستخدم...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processApproval(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: Text('قبول'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(DepositRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('رفض طلب الإيداع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رفض طلب الإيداع؟'),
            SizedBox(height: 12.h),
            Text('المبلغ: \$${request.amount.toStringAsFixed(2)}'),
            Text('المستخدم: ${request.userName}'),
            SizedBox(height: 12.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'سبب الرفض (مطلوب)',
                hintText: 'اكتب سبب رفض الطلب...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processRejection(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _processApproval(DepositRequestModel request) {
    // Implement approval logic
    ref.read(depositRequestsProvider.notifier).approveRequest(request.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم قبول طلب الإيداع بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _processRejection(DepositRequestModel request) {
    // Implement rejection logic
    ref.read(depositRequestsProvider.notifier).rejectRequest(request.id, reason: '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض طلب الإيداع'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }
}

