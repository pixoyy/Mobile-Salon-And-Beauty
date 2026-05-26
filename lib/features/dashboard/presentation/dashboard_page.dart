import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/dummy_discounts.dart';
import '../../../core/theme/app_colors.dart';

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

/// ======================================================
/// DISCOUNT SLIDER
/// ======================================================
class _DiscountSlider extends StatefulWidget {
  const _DiscountSlider();

  @override
  State<_DiscountSlider> createState() => _DiscountSliderState();
}

class _DiscountSliderState extends State<_DiscountSlider> {
  late PageController _controller;
  Timer? _autoSlideTimer;

  double _currentPage = 0;

  final List discounts = DummyDiscounts.data;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 1);

    _controller.addListener(() {
      if (!_controller.hasClients) return;

      setState(() {
        _currentPage = _controller.page ?? 0;
      });
    });

    autoSlide();
  }

  void autoSlide() async {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }

      int nextPage = (_controller.page ?? 0).round() + 1;

      if (nextPage >= discounts.length) {
        nextPage = 0;
      }

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double _getScale(int index) {
    double scale = 1 - ((_currentPage - index).abs() * 0.08);

    return scale.clamp(0.92, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 240,

          child: PageView.builder(
            controller: _controller,
            itemCount: discounts.length,

            itemBuilder: (context, index) {
              final d = discounts[index];

              final scale = _getScale(index);

              return Transform.scale(
                scale: scale,

                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),

                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7D3C5A),
                        Color(0xFF9B5B76),
                        Color(0xFFB67891),
                      ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9B5B76).withOpacity(0.25),

                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),

                  child: Stack(
                    children: [
                      /// BG CIRCLE
                      Positioned(
                        right: -20,
                        top: -10,
                        child: Container(
                          height: 180,
                          width: 180,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),

                      Positioned(
                        right: 30,
                        bottom: -40,
                        child: Container(
                          height: 140,
                          width: 140,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(22),

                        child: Row(
                          children: [
                            /// LEFT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.14),

                                      borderRadius: BorderRadius.circular(30),
                                    ),

                                    child: const Text(
                                      'Special Promo',

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontSize: 12,

                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    d.title,

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 24,

                                      height: 1.2,

                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Disc. ',

                                              style: TextStyle(
                                                color: Colors.white70,

                                                fontSize: 18,

                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),

                                            TextSpan(
                                              text: '${d.percent}%',

                                              style: const TextStyle(
                                                color: Colors.white,

                                                fontSize: 42,

                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// =========================
                                      /// MINIMUM SPEND
                                      /// =========================
                                      if (d.minSpend > 0) ...[
                                        const SizedBox(height: 6),

                                        Text(
                                          'Min. spend Rp ${_formatPrice(d.minSpend)}',

                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.85,
                                            ),

                                            fontSize: 10,

                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'Berlaku hingga '
                                    '${d.endDate.day} '
                                    '${_monthName(d.endDate.month)} '
                                    '${d.endDate.year}',

                                    style: const TextStyle(
                                      color: Colors.white70,

                                      fontSize: 13,

                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        /// INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: List.generate(discounts.length, (index) {
            final isActive = index == _currentPage.round();

            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),

              margin: const EdgeInsets.symmetric(horizontal: 4),

              width: isActive ? 22 : 8,
              height: 8,

              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade300,

                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month];
  }

  String _formatPrice(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
  }
}

/// ======================================================
/// DASHBOARD VIEW
/// ======================================================
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),

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
                    height: 48,
                    width: 48,

                    decoration: BoxDecoration(
                      color: AppColors.surface,

                      borderRadius: BorderRadius.circular(16),

                      border: Border.all(color: AppColors.border),
                    ),

                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// PROMO
              const _DiscountSlider(),

              const SizedBox(height: 26),

              /// QUICK ACTION
              Text(
                'Menu Cepat',

                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              _QuickActionGrid(actions: snapshot?.quickActions ?? const []),

              const SizedBox(height: 26),

              /// BOOKING
              Text(
                'Booking Terdekat',

                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              _BookingCard(snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }
}

/// ======================================================
/// QUICK GRID
/// ======================================================
class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.actions});

  final List<dynamic> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox();
    }

    final icons = [
      Icons.content_cut_rounded,
      Icons.spa_rounded,
      Icons.face_retouching_natural_rounded,
      Icons.calendar_month_rounded,
    ];

    return GridView.builder(
      itemCount: actions.length,

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),

      itemBuilder: (context, index) {
        final action = actions[index];

        return Column(
          children: [
            Container(
              height: 72,
              width: 72,

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius: BorderRadius.circular(22),

                border: Border.all(color: AppColors.border),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),

                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Icon(
                icons[index % icons.length],

                color: AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              action.title ?? '',

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}

/// ======================================================
/// BOOKING CARD
/// ======================================================
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.snapshot});

  final dynamic snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),

            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,

            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),

              borderRadius: BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.calendar_month_rounded,

              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Jadwal Booking',

                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 6),

                Text(
                  snapshot?.nextBooking?.dateLabel ?? '-',

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Colors.black45),
        ],
      ),
    );
  }
}
