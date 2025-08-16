import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../generated/l10n.dart';
import '../models/service_model.dart';
import '../providers/services_provider.dart';

class CreateServiceView extends ConsumerStatefulWidget {
  final String type; // إضافة المعامل المطلوب

  const CreateServiceView({
    super.key,
    required this.type, // جعله مطلوب
  });

  @override
  ConsumerState<CreateServiceView> createState() => _CreateServiceViewState();
}

class _CreateServiceViewState extends ConsumerState<CreateServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'برمجة وتطوير';

  final List<String> _categories = [
    'برمجة وتطوير',
    'تصميم جرافيك',
    'كتابة وترجمة',
    'تسويق رقمي',
    'تعليم ودروس',
    'استشارات',
    'أخرى',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final servicesState = ref.watch(servicesNotifierProvider);
    final isOffer = widget.type == 'offer';

    ref.listen(servicesNotifierProvider, (previous, next) {
      if (next is ServicesSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      } else if (next is ServicesError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: isOffer ? 'تقديم خدمة' : 'طلب خدمة',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isOffer
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isOffer
                        ? AppTheme.successColor.withOpacity(0.3)
                        : AppTheme.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOffer ? Icons.work_outline : Icons.search,
                      color: isOffer ? AppTheme.successColor : AppTheme.infoColor,
                      size: 24.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOffer ? 'تقديم خدمة جديدة' : 'طلب خدمة جديدة',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOffer ? AppTheme.successColor : AppTheme.infoColor,
                            ),
                          ),
                          Text(
                            isOffer
                                ? 'شارك مهاراتك مع المجتمع'
                                : 'احصل على المساعدة التي تحتاجها',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              CustomTextField(
                controller: _titleController,
                label: isOffer ? 'عنوان الخدمة' : 'عنوان الطلب',
                hintText: isOffer
                    ? 'مثال: تطوير تطبيق موبايل'
                    : 'مثال: مطلوب مصمم شعار',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال العنوان';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Category
              Text(
                'الفئة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: isOffer ? 'وصف الخدمة' : 'وصف الطلب',
                hintText: isOffer
                    ? 'اشرح ما تقدمه بالتفصيل...'
                    : 'اشرح ما تحتاجه بالتفصيل...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال الوصف';
                  }
                  if (value.trim().length < 50) {
                    return 'الوصف قصير جداً (50 حرف على الأقل)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Price
              CustomTextField(
                controller: _priceController,
                label: isOffer ? 'سعر الخدمة (د.ع)' : 'الميزانية المتوقعة (د.ع)',
                hintText: 'أدخل المبلغ',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.h),

              // Submit Button
              LoadingButton(
                onPressed: _handleSubmit,
                isLoading: servicesState is ServicesLoading,
                text: isOffer ? 'نشر الخدمة' : 'نشر الطلب',
                backgroundColor: isOffer ? AppTheme.successColor : AppTheme.infoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      
      ref.read(servicesNotifierProvider.notifier).createService(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        hourlyRate: price,
        tags: [], // Can be extended to include tags
      );
    }
  }
}