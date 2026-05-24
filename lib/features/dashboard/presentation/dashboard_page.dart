import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/models/discount.dart';

import '../bloc/dashboard_cubit.dart';
import '../data/dashboard_repository.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardCubit(const DashboardRepository())..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DiscountSlider extends StatefulWidget {
  const _DiscountSlider();

  @override
  State<_DiscountSlider> createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<_DiscountSlider> {
  late PageController _controller;
  double _currentPage = 0;

  final List<Discount> discounts = [
    Discount(
      code: "GLAMORA2",
      title: "GLAMOROUS",
      percent: 20,
      maxAmount: 50000,
      minSpend: 100000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 6, 1),
    ),
    Discount(
      code: "JULY20",
      title: "ROSE N JULIET",
      percent: 30,
      maxAmount: 50000,
      minSpend: 250000,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    Discount(
      code: "AUG15",
      title: "AUGUST MUST GOOD",
      percent: 15,
      maxAmount: 30000,
      minSpend: 80000,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
    ),
    Discount(
      code: "SEP10",
      title: "SLAYTEMBER",
      percent: 10,
      maxAmount: 20000,
      minSpend: 70000,
      startDate: DateTime(2026, 9, 1),
      endDate: DateTime(2026, 9, 30),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 0.75);

    _controller.addListener(() {
      if (!_controller.hasClients) return;

      setState(() {
        _currentPage = _controller.page ?? 0;
      });
    });

    autoSlide();
  }

  void autoSlide() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));

      if (!_controller.hasClients) continue;

      int nextPage = (_controller.page ?? 0).round() + 1;

      if (nextPage >= discounts.length) {
        nextPage = 0;
      }

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getScale(int index) {
    double scale = 1 - ((_currentPage - index).abs() * 0.2);
    return scale.clamp(0.8, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: discounts.length,
            itemBuilder: (context, index) {
              final d = discounts[index];
              final scale = _getScale(index);

              return Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B4D6B), Color(0xFFB96B85)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        d.title,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${d.percent}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Exp: ${d.endDate.toString().split(' ')[0]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        /// DOT INDICATOR (SAFE)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(discounts.length, (index) {
            final isActive = index == _currentPage.round();

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.pink : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// =======================
/// DASHBOARD VIEW
/// =======================
class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final snapshot = state.snapshot;

        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot?.customer.greeting ?? 'Halo,',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot?.customer.name ?? 'Siska Amanda',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const _DiscountSlider(),

              const SizedBox(height: 20),

              Text('Menu Cepat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _QuickActionGrid(actions: snapshot?.quickActions ?? const []),

              const SizedBox(height: 20),

              Text(
                'Booking Terdekat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _BookingCard(snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }
}

/// QUICK GRID
class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});
  final List<dynamic> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox();

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(child: Text(action.title ?? '')),
        );
      },
    );
  }
}

/// BOOKING CARD
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.snapshot});
  final dynamic snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(snapshot?.nextBooking?.dateLabel ?? '-'),
    );
  }
}
