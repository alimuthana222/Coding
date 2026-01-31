import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/skills_cubit.dart';
import '../../bloc/skills_state.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SkillsCubit(),
      child: const _SkillsView(),
    );
  }
}

class _SkillsView extends StatefulWidget {
  const _SkillsView();

  @override
  State<_SkillsView> createState() => _SkillsViewState();
}

class _SkillsViewState extends State<_SkillsView> {
  final _scrollController = ScrollController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SkillsCubit>().loadMoreSkills();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SkillsCubit, SkillsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<SkillsCubit>().refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(context.t('skills')),
                    actions: [
                      IconButton(
                        icon: const Icon(Iconsax.search_normal),
                        onPressed: () => _showSearchDialog(context),
                      ),
                    ],
                  ),

                  // Categories
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _CategoryChip(
                              label: context.t('cat_all'),
                              icon: Iconsax.category,
                              isSelected: _selectedCategoryId == null,
                              onTap: () {
                                setState(() => _selectedCategoryId = null);
                                context.read<SkillsCubit>().filterByCategory(null);
                              },
                            );
                          }

                          final category = state.categories[index - 1];
                          return _CategoryChip(
                            label: category.nameAr,
                            icon: Iconsax.code,
                            isSelected: _selectedCategoryId == category.id,
                            onTap: () {
                              setState(() => _selectedCategoryId = category.id);
                              context.read<SkillsCubit>().filterByCategory(category.id);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Loading State
                  if (state.status == SkillsStatus.loading && state.skills.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // Error State
                  else if (state.status == SkillsStatus.error && state.skills.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text(state.errorMessage ?? 'حدث خطأ'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<SkillsCubit>().refresh(),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Empty State
                  else if (state.skills.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.book,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد مهارات',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'كن أول من يضيف مهارة!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Skills Grid
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index >= state.skills.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _SkillCard(skill: state.skills[index]);
                            },
                            childCount: state.hasReachedMax
                                ? state.skills.length
                                : state.skills.length + 1,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                        ),
                      ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
      // ✅ زر الإضافة
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          requireAuth(context, () {
            _showAddSkillSheet(context);
          });
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'أضف مهارة',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(context.t('search')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.t('search_hint'),
              prefixIcon: const Icon(Iconsax.search_normal),
            ),
            onSubmitted: (value) {
              context.read<SkillsCubit>().search(value);
              Navigator.pop(dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.t('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SkillsCubit>().search(controller.text);
                Navigator.pop(dialogContext);
              },
              child: Text(context.t('search')),
            ),
          ],
        );
      },
    );
  }

  // ✅ Sheet لإضافة مهارة جديدة
  void _showAddSkillSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _AddSkillSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ADD SKILL SHEET
// ═══════════════════════════════════════════════════════════════════

class _AddSkillSheet extends StatefulWidget {
  const _AddSkillSheet();

  @override
  State<_AddSkillSheet> createState() => _AddSkillSheetState();
}

class _AddSkillSheetState extends State<_AddSkillSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '1');
  String? _selectedCategoryId;
  bool _isOnline = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t('cancel')),
                ),
                const Spacer(),
                Text(
                  'أضف مهارة جديدة',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveSkill,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(context.t('save')),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant.withOpacity(0.5)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان المهارة',
                    hintText: 'مثال: تعليم البرمجة بلغة Python',
                    prefixIcon: Icon(Iconsax.book),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف المهارة',
                    hintText: 'اكتب وصفاً مفصلاً عن المهارة التي تقدمها...',
                    prefixIcon: Icon(Iconsax.document_text),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Price
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر (بالساعات)',
                    hintText: '1',
                    prefixIcon: const Icon(Iconsax.wallet_3),
                    suffixText: context.t('hours'),
                  ),
                ),
                const SizedBox(height: 16),

                // Online/Onsite
                SwitchListTile(
                  title: const Text('متاح أونلاين'),
                  subtitle: const Text('يمكن تقديم المهارة عن بعد'),
                  value: _isOnline,
                  onChanged: (value) => setState(() => _isOnline = value),
                  secondary: Icon(
                    _isOnline ? Iconsax.video : Iconsax.location,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveSkill() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان المهارة مطلوب')),
      );
      return;
    }

    // TODO: Save skill to backend
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إضافة المهارة بنجاح! ✅'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// CATEGORY CHIP
// ══════════════════════════════════════════════════════���════════════

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: isSelected
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SKILL CARD
// ═══════════════════════════════════════════════════════════════════

class _SkillCard extends StatelessWidget {
  final dynamic skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Navigate to skill details
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top - Icon/Image
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.book,
                    size: 44,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Bottom - Info
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.titleAr ?? 'مهارة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(Iconsax.user, size: 12, color: colorScheme.primary),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            skill.user?.fullName ?? 'مستخدم',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
                        const SizedBox(width: 2),
                        Text(
                          '${skill.rating ?? 0}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${skill.priceHours ?? 1} ${context.t('hours')}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}