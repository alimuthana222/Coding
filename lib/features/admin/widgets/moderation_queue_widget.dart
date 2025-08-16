import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/moderator_provider.dart';
import '../models/report_model.dart';

class ModerationQueueWidget extends ConsumerWidget {
  const ModerationQueueWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReportsAsync = ref.watch(pendingReportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'طابور الإشراف',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/moderator/reports'),
              child: Text('عرض الكل'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        pendingReportsAsync.when(
          data: (reports) => _buildReportsList(context, reports, isDark),
          loading: () => _buildLoadingState(isDark),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildReportsList(BuildContext context, List<ReportModel> reports, bool isDark) {
    if (reports.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    final limitedReports = reports.take(5).toList();

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
        itemCount: limitedReports.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        itemBuilder: (context, index) {
          final report = limitedReports[index];
          return _buildReportItem(context, report, isDark);
        },
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, ReportModel report, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        backgroundColor: _getReportColor(report.reason).withOpacity(0.1),
        child: Icon(
          _getReportIcon(report.reason),
          color: _getReportColor(report.reason),
          size: 20.w,
        ),
      ),
      title: Text(
        report.reasonDisplayName,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${report.contentTypeDisplayName} من ${report.reportedUserName ?? 'مستخدم'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: 2.h),
          Text(
            report.timeAgo,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: _getReportColor(report.reason).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          report.statusDisplayName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _getReportColor(report.reason),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      onTap: () => _showReportDetails(context, report),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      height: 200.h,
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
            'خطأ في تحميل البلاغات',
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
            'لا توجد بلاغات معلقة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'جميع البلاغات تم مراجعتها',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getReportColor(String reason) {
    switch (reason) {
      case 'spam':
        return AppTheme.warningColor;
      case 'harassment':
      case 'violence':
      case 'hate_speech':
        return AppTheme.errorColor;
      case 'inappropriate_content':
        return AppTheme.accentColor;
      case 'fake_profile':
      case 'scam':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getReportIcon(String reason) {
    switch (reason) {
      case 'spam':
        return Icons.report_gmailerrorred_rounded;
      case 'harassment':
        return Icons.person_off_rounded;
      case 'inappropriate_content':
        return Icons.block_rounded;
      case 'fake_profile':
        return Icons.account_circle_outlined;
      case 'violence':
        return Icons.dangerous_rounded;
      case 'hate_speech':
        return Icons.speaker_notes_off_rounded;
      case 'scam':
        return Icons.warning_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل البلاغ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('السبب:', report.reasonDisplayName),
                      _buildDetailRow('النوع:', report.contentTypeDisplayName),
                      _buildDetailRow('المبلغ:', report.reporterName ?? 'غير معروف'),
                      _buildDetailRow('المبلغ عليه:', report.reportedUserName ?? 'غير معروف'),
                      _buildDetailRow('الوقت:', report.timeAgo),
                      if (report.description != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          'الوصف:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          report.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // هنا يمكن إضافة منطق حل البلاغ
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                      child: Text('حل البلاغ'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // هنا يمكن إضافة منطق رفض البلاغ
                      },
                      child: Text('رفض'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
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
}