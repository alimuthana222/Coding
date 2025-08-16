import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/admin_provider.dart';

// Mock pending request model
class PendingRequestModel {
  final String id;
  final String type; // deposit, service_approval, report, user_verification
  final String title;
  final String description;
  final String? userName;
  final String? userAvatarUrl;
  final double? amount;
  final DateTime createdAt;
  final String priority; // low, medium, high, urgent
  final IconData icon;
  final Color color;

  const PendingRequestModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.userName,
    this.userAvatarUrl,
    this.amount,
    required this.createdAt,
    this.priority = 'medium',
    required this.icon,
    required this.color,
  });
}

// Mock provider for pending requests
final pendingRequestsProvider = FutureProvider<List<PendingRequestModel>>((ref) async {
  // Simulate API call delay
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    PendingRequestModel(
      id: '1',
      type: 'deposit',
      title: 'طلب إيداع',
      description: 'طلب إيداع بقيمة 150 د.ع من أحمد محمد',
      userName: 'أحمد محمد',
      amount: 150.0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      priority: 'high',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.successColor,
    ),
    PendingRequestModel(
      id: '2',
      type: 'service_approval',
      title: 'موافقة على خدمة',
      description: 'خدمة تطوير تطبيقات موبايل تحتاج موافقة',
      userName: 'سارة أحمد',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      priority: 'medium',
      icon: Icons.work_rounded,
      color: AppTheme.primaryColor,
    ),
    PendingRequestModel(
      id: '3',
      type: 'report',
      title: 'بلاغ جديد',
      description: 'بلاغ عن محتوى غير مناسب',
      userName: 'محمد علي',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      priority: 'urgent',
      icon: Icons.report_rounded,
      color: AppTheme.errorColor,
    ),
    PendingRequestModel(
      id: '4',
      type: 'user_verification',
      title: 'طلب توثيق',
      description: 'طلب توثيق حساب مستخدم جديد',
      userName: 'فاطمة حسن',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      priority: 'low',
      icon: Icons.verified_user_rounded,
      color: AppTheme.accentColor,
    ),
  ];
});

class PendingRequestsWidget extends ConsumerWidget {
  const PendingRequestsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الطلبات المعلقة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/admin/pending-requests'),
              child: Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        requestsAsync.when(
          data: (requests) => _buildRequestsList(context, requests, isDark),
          loading: () => _buildLoadingState(isDark),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildRequestsList(BuildContext context, List<PendingRequestModel> requests, bool isDark) {
    if (requests.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    // Sort by priority and date
    final sortedRequests = List<PendingRequestModel>.from(requests)
      ..sort((a, b) {
        final priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
        final aPriority = priorityOrder[a.priority] ?? 2;
        final bPriority = priorityOrder[b.priority] ?? 2;

        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        return b.createdAt.compareTo(a.createdAt);
      });

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedRequests.length > 5 ? 5 : sortedRequests.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        itemBuilder: (context, index) {
          final request = sortedRequests[index];
          return _buildRequestItem(context, request, isDark);
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, PendingRequestModel request, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: request.color.withOpacity(0.1),
            radius: 20.r,
            child: Icon(
              request.icon,
              color: request.color,
              size: 20.w,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: _getPriorityColor(request.priority),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              request.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _buildPriorityChip(context, request.priority, isDark),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              if (request.userName != null) ...[
                Icon(
                  Icons.person_rounded,
                  size: 12.w,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  request.userName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              if (request.amount != null) ...[
                Icon(
                  Icons.attach_money_rounded,
                  size: 12.w,
                  color: AppTheme.successColor,
                ),
                Text(
                  '${request.amount!.toStringAsFixed(0)} د.ع',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Icon(
                Icons.access_time_rounded,
                size: 12.w,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                _getTimeAgo(request.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          size: 16.w,
        ),
        onSelected: (action) => _handleRequestAction(context, request, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'approve',
            child: Row(
              children: [
                Icon(Icons.check_rounded, color: AppTheme.successColor, size: 16.w),
                SizedBox(width: 8.w),
                Text('موافقة'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'reject',
            child: Row(
              children: [
                Icon(Icons.close_rounded, color: AppTheme.errorColor, size: 16.w),
                SizedBox(width: 8.w),
                Text('رفض'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'details',
            child: Row(
              children: [
                Icon(Icons.info_rounded, color: AppTheme.primaryColor, size: 16.w),
                SizedBox(width: 8.w),
                Text('التفاصيل'),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _showRequestDetails(context, request),
    );
  }

  Widget _buildPriorityChip(BuildContext context, String priority, bool isDark) {
    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return AppTheme.warningColor;
      case 'low':
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالي';
      case 'medium':
        return 'متوسط';
      case 'low':
        return 'منخفض';
      default:
        return 'عادي';
    }
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 300.h,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.errorColor,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            'خطأ في تحميل الطلبات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppTheme.successColor,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد طلبات معلقة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جميع الطلبات تمت معالجتها',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  void _handleRequestAction(BuildContext context, PendingRequestModel request, String action) {
    switch (action) {
      case 'approve':
        _showApprovalDialog(context, request);
        break;
      case 'reject':
        _showRejectionDialog(context, request);
        break;
      case 'details':
        _showRequestDetails(context, request);
        break;
    }
  }

  void _showApprovalDialog(BuildContext context, PendingRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('موافقة على الطلب'),
        content: Text('هل أنت متأكد من الموافقة على ${request.title}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveRequest(context, request);
            },
            child: Text('موافقة'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, PendingRequestModel request) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('سبب رفض ${request.title}:'),
            SizedBox(height: 12.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'اكتب سبب الرفض...',
                border: OutlineInputBorder(),
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
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _rejectRequest(context, request, reasonController.text.trim());
              }
            },
            child: Text('رفض'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, PendingRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(request.icon, color: request.color),
            SizedBox(width: 8.w),
            Text('تفاصيل الطلب'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('النوع:', request.title),
            _buildDetailRow('الوصف:', request.description),
            if (request.userName != null)
              _buildDetailRow('المستخدم:', request.userName!),
            if (request.amount != null)
              _buildDetailRow('المبلغ:', '${request.amount!.toStringAsFixed(0)} د.ع'),
            _buildDetailRow('الأولوية:', _getPriorityLabel(request.priority)),
            _buildDetailRow('الوقت:', _getTimeAgo(request.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRequestDetails(context, request);
            },
            child: Text('عرض التفاصيل الكاملة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _approveRequest(BuildContext context, PendingRequestModel request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت الموافقة على ${request.title}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _rejectRequest(BuildContext context, PendingRequestModel request, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم رفض ${request.title}'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _navigateToRequestDetails(BuildContext context, PendingRequestModel request) {
    // Navigate to detailed request page based on type
    String route;
    switch (request.type) {
      case 'deposit':
        route = '/admin/deposit-requests/${request.id}';
        break;
      case 'service_approval':
        route = '/admin/services/${request.id}';
        break;
      case 'report':
        route = '/admin/reports/${request.id}';
        break;
      case 'user_verification':
        route = '/admin/users/${request.id}';
        break;
      default:
        route = '/admin/requests/${request.id}';
    }

    context.push(route);
  }
}