import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/service_model.dart';
import '../../../../shared/widgets/auth_guard.dart';
import '../../bloc/services_cubit.dart';
import '../../bloc/services_state.dart';
import '../widgets/create_service_sheet.dart';
import '../widgets/service_card.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServicesCubit(),
      child: const _ServicesView(),
    );
  }
}

class _ServicesView extends StatefulWidget {
  const _ServicesView();

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ServicesCubit>().loadMore();
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
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(context.t('skills')),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.filter),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة...',
                        prefixIcon: const Icon(Iconsax.search_normal),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Iconsax.close_circle),
                          onPressed: () {
                            _searchController.clear();
                            context.read<ServicesCubit>().search('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (value) {
                        context.read<ServicesCubit>().search(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    tabs: const [
                      Tab(text: 'الكل'),
                      Tab(text: 'عروض الخدمات'),
                      Tab(text: 'طلبات الخدمات'),
                    ],
                    onTap: (index) {
                      ServiceType? type;
                      if (index == 1) type = ServiceType.offering;
                      if (index == 2) type = ServiceType.requesting;
                      context.read<ServicesCubit>().filterByType(type);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
        body: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ServicesList(services: state.services, state: state),
                _ServicesList(services: state.offerings, state: state),
                _ServicesList(services: state.requests, state: state),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          requireAuth(context, () {
            _showCreateServiceSheet(context);
          });
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'أضف خدمة',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ServicesCubit>(),
        child: const _FilterSheet(),
      ),
    );
  }

  void _showCreateServiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ServicesCubit>(),
        child: const CreateServiceSheet(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SERVICES LIST
// ═══════════════════════════════════════════════════════════════════

class _ServicesList extends StatelessWidget {
  final List<ServiceModel> services;
  final ServicesState state;

  const _ServicesList({
    required this.services,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.status == ServicesStatus.loading && services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ServicesStatus.error && services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'حدث خطأ'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ServicesCubit>().refresh(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.book,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد خدمات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من يضيف خدمة!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ServicesCubit>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= services.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return ServiceCard(service: services[index]);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FILTER SHEET
// ═══════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'تصفية الخدمات',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Pricing Type
              Text('نوع التسعير', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  _FilterChip(
                    label: 'الكل',
                    isSelected: state.selectedPricing == null,
                    onTap: () {
                      context.read<ServicesCubit>().filterByPricing(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'بنك الساعات',
                    icon: Iconsax.clock,
                    color: AppColors.secondary,
                    isSelected: state.selectedPricing == PricingType.hours,
                    onTap: () {
                      context.read<ServicesCubit>().filterByPricing(PricingType.hours);
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'مدفوع',
                    icon: Iconsax.money,
                    color: AppColors.success,
                    isSelected: state.selectedPricing == PricingType.money,
                    onTap: () {
                      context.read<ServicesCubit>().filterByPricing(PricingType.money);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Categories
              Text('التصنيف', style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'الكل',
                    isSelected: state.selectedCategoryId == null,
                    onTap: () {
                      context.read<ServicesCubit>().filterByCategory(null);
                    },
                  ),
                  ...state.categories.map((cat) => _FilterChip(
                    label: cat.nameAr,
                    isSelected: state.selectedCategoryId == cat.id,
                    onTap: () {
                      context.read<ServicesCubit>().filterByCategory(cat.id);
                    },
                  )),
                ],
              ),
              const SizedBox(height: 24),

              // Clear Filters
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ServicesCubit>().clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('مسح الفلاتر'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipColor = color ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}