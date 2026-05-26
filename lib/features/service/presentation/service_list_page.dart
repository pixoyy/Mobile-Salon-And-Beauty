import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../booking/presentation/booking_schedule_page.dart';
import '../../booking/presentation/booking_menu_page.dart';
import '../bloc/service_cubit.dart';
import '../data/service_model.dart';
import '../data/service_repository.dart';
import 'service_detail_page.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceListCubit(context.read<ServiceRepository>())..loadServices(),
      child: const _ServiceListView(),
    );
  }
}

class _ServiceListView extends StatefulWidget {
  const _ServiceListView();

  @override
  State<_ServiceListView> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<_ServiceListView> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedServiceIds = <String>[];
  List<String> _allCategories = [];
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleServiceSelection(ServiceModel service) {
    setState(() {
      if (_selectedServiceIds.contains(service.id)) {
        _selectedServiceIds.remove(service.id);
      } else {
        _selectedServiceIds.add(service.id);
      }
    });
  }

  List<ServiceModel> _selectedServices(ServiceListCubit cubit) {
    final Map<String, ServiceModel> servicesById = {
      for (final service in cubit.allServices) service.id: service,
    };

    return _selectedServiceIds
        .map((id) => servicesById[id])
        .whereType<ServiceModel>()
        .toList(growable: false);
  }

  void _goToBooking(BuildContext context) {
    if (_selectedServiceIds.isEmpty) return;

    () async {
      final BookingModel? created = await Navigator.of(context).push<BookingModel?>(
        MaterialPageRoute<BookingModel?>(
          builder: (_) => BookingSchedulePage(
            prefillServiceIds: _selectedServiceIds.toList(growable: false),
          ),
        ),
      );

      if (!mounted) return;

      if (created != null) {
        // After successful booking, navigate user to the Booking menu to see their booking.
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingMenuPage()));
      }
    }();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final services = await context.read<ServiceRepository>().getAllServices();
        final categories = services.map((s) => s.category).toSet().toList()..sort();
        setState(() {
          _allCategories = ['Semua'] + categories;
          _selectedCategory = 'Semua';
        });
      } catch (_) {
        // ignore errors here; categories will be empty and chips hidden
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceListCubit, ServiceListState>(
      listener: (context, state) {
        if (state.status == ServiceStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Gagal memuat layanan.')),
          );
        }
      },
      builder: (context, state) {
        final ServiceListCubit serviceCubit = context.read<ServiceListCubit>();
        final List<ServiceModel> selectedServices = _selectedServices(serviceCubit);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Layanan Salon'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      context.read<ServiceListCubit>().searchServices(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari layanan...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ServiceListCubit>().searchServices('');
                              },
                            ),
                    ),
                    onSubmitted: (_) => context.read<ServiceListCubit>().searchServices(_searchController.text),
                  ),
                ),
                if (_allCategories.isNotEmpty)
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final category = _allCategories[index];
                        final isSelected = _selectedCategory != null && _selectedCategory == category;

                        return FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (_) {
                            // Toggle selection: if selecting 'Semua' or deselecting, restore 'Semua'
                            if (category == 'Semua') {
                              setState(() {
                                _selectedCategory = 'Semua';
                              });
                              context.read<ServiceListCubit>().setActiveCategory(null);
                              return;
                            }

                            if (_selectedCategory == category) {
                              setState(() {
                                _selectedCategory = 'Semua';
                              });
                              context.read<ServiceListCubit>().setActiveCategory(null);
                            } else {
                              setState(() {
                                _selectedCategory = category;
                              });
                              context.read<ServiceListCubit>().setActiveCategory(category);
                            }
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _allCategories.length,
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: switch (state.status) {
                    ServiceStatus.loading || ServiceStatus.initial => _buildLoadingSkeleton(),
                    ServiceStatus.failure => _ErrorState(
                        onRetry: () => context.read<ServiceListCubit>().loadServices(),
                      ),
                    ServiceStatus.success => state.services.isEmpty
                        ? _EmptyState(query: state.query)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: state.services.length + 1,
                            separatorBuilder: (_, index) => index == state.services.length - 1
                                ? const SizedBox(height: 16)
                                : const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (index == state.services.length) {
                                return const SizedBox(height: 8);
                              }

                              final service = state.services[index];
                              return _ServiceCard(
                                service: service,
                                isSelected: _selectedServiceIds.contains(service.id),
                                onToggleSelection: () => _toggleServiceSelection(service),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailPage(serviceId: service.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final Animation<Offset> offsetAnimation = Tween<Offset>(
                begin: const Offset(0, 0.18),
                end: Offset.zero,
              ).animate(animation);

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            child: selectedServices.isEmpty
                ? const SizedBox.shrink(key: ValueKey<String>('empty-cart'))
                : SafeArea(
                    key: const ValueKey<String>('filled-cart'),
                    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _ServiceCartSummary(
                      services: selectedServices,
                      onRemoveService: (serviceId) {
                        setState(() {
                          _selectedServiceIds.remove(serviceId);
                        });
                      },
                      onContinue: () => _goToBooking(context),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 130, height: 14, color: AppColors.background),
                    const SizedBox(height: 8),
                    Container(width: 90, height: 12, color: AppColors.background),
                    const SizedBox(height: 10),
                    Container(width: 170, height: 12, color: AppColors.background),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onTap,
  });

  final ServiceModel service;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final VoidCallback onTap;

  String get _priceLabel {
    final price = service.price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < price.length; i++) {
      final reverseIndex = price.length - i;
      buffer.write(price[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _serviceIcon(service.category),
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.mutedText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (service.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Populer',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.schedule_rounded,
                          label: '${service.durationMinutes} menit',
                        ),
                        const SizedBox(width: 8),
                        _InfoPill(
                          icon: Icons.sell_outlined,
                          label: _priceLabel,
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: onToggleSelection,
                          tooltip: isSelected ? 'Hapus dari cart' : 'Tambah ke cart',
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: Icon(
                              isSelected ? Icons.remove_rounded : Icons.add_rounded,
                              key: ValueKey<bool>(isSelected),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Di cart',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCartSummary extends StatelessWidget {
  const _ServiceCartSummary({
    required this.services,
    required this.onRemoveService,
    required this.onContinue,
  });

  final List<ServiceModel> services;
  final ValueChanged<String> onRemoveService;
  final VoidCallback onContinue;

  int get _totalPrice => services.fold<int>(0, (sum, service) => sum + service.price);

  int get _totalDuration => services.fold<int>(0, (sum, service) => sum + service.durationMinutes);

  String _formatPrice(int price) {
    final String raw = price.toString();
    final StringBuffer buffer = StringBuffer();
    for (var index = 0; index < raw.length; index++) {
      final int reverseIndex = raw.length - index;
      buffer.write(raw[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onContinue,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart layanan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${services.length} layanan • ${_totalDuration} menit',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatPrice(_totalPrice),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services
                    .map(
                      (service) => InputChip(
                        onPressed: onContinue,
                        onDeleted: () => onRemoveService(service.id),
                        deleteIconColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                        label: Text(
                          service.name,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Lanjut ke Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _serviceIcon(String category) {
  switch (category.toLowerCase()) {
    case 'haircut':
      return Icons.content_cut_rounded;
    case 'coloring':
      return Icons.palette_outlined;
    case 'treatment':
      return Icons.spa_outlined;
    case 'styling':
      return Icons.auto_awesome_outlined;
    default:
      return Icons.room_service_outlined;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.mutedText),
            const SizedBox(height: 10),
            Text(
              'Layanan tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata kunci lain untuk "$query".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 46, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Terjadi kendala saat memuat layanan',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}