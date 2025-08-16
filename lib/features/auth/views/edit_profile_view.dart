import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_button.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import '../../../generated/l10n.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final currentUserAsync = ref.read(currentUserProvider);
    currentUserAsync.when(
      data: (user) {
        if (user != null) {
          _fullNameController.text = user.fullName ?? '';
          _universityController.text = user.university ?? '';
          _majorController.text = user.major ?? '';
          _bioController.text = user.bio ?? '';
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        fullName: _fullNameController.text.trim(),
        university: _universityController.text.trim(),
        major: _majorController.text.trim(),
        bio: _bioController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final profileState = ref.watch(profileNotifierProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    ref.listen(profileNotifierProvider, (previous, next) {
      if (next is ProfileSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // تحديث بيانات المستخدم
        ref.invalidate(currentUserProvider);
        context.pop();
      } else if (next is ProfileError) {
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
        title: 'تعديل الملف الشخصي',
        actions: [
          TextButton(
            onPressed: profileState is ProfileLoading ? null : _handleSave,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: profileState is ProfileLoading
                    ? AppTheme.textSecondaryColor
                    : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) => SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture Section
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60.r,
                      backgroundColor: AppTheme.primaryColor,
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? Text(
                        user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: تغيير الصورة الشخصية
                          _showImagePickerDialog();
                        },
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),

                // Form Fields
                CustomTextField(
                  controller: _fullNameController,
                  label: l10n.fullName,
                  hintText: 'أدخل اسمك الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: _universityController,
                  label: l10n.university,
                  hintText: 'أدخل جامعتك (اختياري)',
                  prefixIcon: Icons.school_outlined,
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: _majorController,
                  label: l10n.major,
                  hintText: 'أدخل تخصصك (اختياري)',
                  prefixIcon: Icons.book_outlined,
                ),
                SizedBox(height: 16.h),

                CustomTextField(
                  controller: _bioController,
                  label: 'السيرة الذاتية',
                  hintText: 'اكتب نبذة عن نفسك وخبراتك',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  maxLength: 500,
                ),
                SizedBox(height: 32.h),

                // Save Button
                LoadingButton(
                  onPressed: _handleSave,
                  isLoading: profileState is ProfileLoading,
                  text: l10n.save,
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64.w, color: AppTheme.errorColor),
              SizedBox(height: 16.h),
              Text(
                'خطأ في تحميل البيانات',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تغيير الصورة الشخصية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.camera_alt,
                        title: 'الكاميرا',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: التقاط صورة من الكاميرا
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildImageOption(
                        icon: Icons.photo_library,
                        title: 'المعرض',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: اختيار صورة من المعرض
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}