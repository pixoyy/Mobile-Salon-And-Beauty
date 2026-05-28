import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/core/utils/profile_image.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_detail_page.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_preview_card.dart';
import 'package:salon_and_beauty/features/stylist/data/dummy_stylists.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_model.dart';
import 'package:salon_and_beauty/features/stylist/presentation/stylist_detail_page.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';

import '../../../core/data/discount_repository.dart';
import '../../../core/data/dummy_discounts.dart';
import '../../../core/models/discount.dart';
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

  List<Discount> _discounts = List<Discount>.from(DummyDiscounts.data);

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

    _loadDiscounts();
    autoSlide();
  }

  Future<void> _loadDiscounts() async {
    final loaded = await DiscountRepository().getAllDiscounts();
    if (!mounted || loaded.isEmpty) {
      return;
    }

    setState(() {
      _discounts = List<Discount>.from(loaded);
    });
  }

  void autoSlide() async {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }

      int nextPage = (_controller.page ?? 0).round() + 1;

      if (nextPage >= _discounts.length) {
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
            itemCount: _discounts.length,

            itemBuilder: (context, index) {
              final d = _discounts[index];

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

          children: List.generate(_discounts.length, (index) {
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
        final customerName = AuthSession.activeUser.name.isNotEmpty
            ? AuthSession.activeUser.name
            : (snapshot?.customer.name ?? 'Customer');
        final greeting = snapshot?.customer.greeting ?? 'Halo,';
        final profileImage = profileImageProvider(AuthSession.activeUser.imageUrl);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F3EF),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 80,
            titleSpacing: 20,
            title: Row(
              children: [
                /// PROFILE
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB67891), Color(0xFF7D3C5A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: profileImage != null
                        ? Image(
                            image: profileImage,
                            fit: BoxFit.cover,
                            width: 52,
                            height: 52,
                          )
                        : Center(
                            child: Text(
                              customerName.isNotEmpty
                                  ? customerName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 16)),
                        ],
                      ),

                      const SizedBox(height: 2),

                      Text(
                        customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.0,
                          letterSpacing: 0.2,
                          fontFamily: 'Montserrat',
                          fontFamilyFallback: ['sans-serif'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                // Container(
                //   padding: const EdgeInsets.all(18),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [Color(0xFFFFFFFF), Color(0xFFFDF7F3)],
                //     ),
                //     borderRadius: BorderRadius.circular(28),
                //     border: Border.all(color: AppColors.border),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.04),
                //         blurRadius: 18,
                //         offset: const Offset(0, 8),
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     children: [
                //       Container(
                //         width: 56,
                //         height: 56,
                //         decoration: BoxDecoration(
                //           color: AppColors.primary.withOpacity(0.1),
                //           borderRadius: BorderRadius.circular(18),
                //         ),
                //         child: const Icon(
                //           Icons.spa_rounded,
                //           color: AppColors.primary,
                //           size: 30,
                //         ),
                //       ),
                //       const SizedBox(width: 14),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Selamat datang di Glamora',
                //               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //                 fontWeight: FontWeight.w800,
                //               ),
                //             ),
                //             const SizedBox(height: 4),
                //             Text(
                //               'Pantau promo, stylist, dan booking terbaru dari dashboard ini.',
                //               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //                 color: AppColors.mutedText,
                //                 height: 1.35,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // const SizedBox(height: 22),

                /// PROMO
                const _DiscountSlider(),

                const SizedBox(height: 26),

                /// QUICK ACTION
                Text(
                  'Recommend Stylist',

                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 14),

                _StylistList(stylists: DummyStylists.data),

                const SizedBox(height: 26),

                /// BOOKING
                Text(
                  'Booking Terdekat',

                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 14),

                const _NearestBookingSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ======================================================
/// QUICK STYLIST CAROUSEL
/// ======================================================
class _StylistList extends StatefulWidget {
  const _StylistList({required this.stylists});

  final List<StylistModel> stylists;

  @override
  State<_StylistList> createState() => _StylistListState();
}

class _StylistListState extends State<_StylistList> {
  late final PageController _controller;
  Timer? _autoSlideTimer;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 0.88);
    _controller.addListener(() {
      if (!_controller.hasClients) return;

      setState(() {
        _currentPage = _controller.page ?? 0;
      });
    });

    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients || widget.stylists.isEmpty) {
        return;
      }

      var nextPage = (_controller.page ?? 0).round() + 1;
      if (nextPage >= widget.stylists.length) {
        nextPage = 0;
      }

      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
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
    final scale = 1 - ((_currentPage - index).abs() * 0.06);
    return scale.clamp(0.94, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stylists.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: widget.stylists.length,
        itemBuilder: (context, index) {
          final stylist = widget.stylists[index];

          return Transform.scale(
            scale: _getScale(index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StylistSlideCard(stylist: stylist),
            ),
          );
        },
      ),
    );
  }
}

class _StylistSlideCard extends StatelessWidget {
  const _StylistSlideCard({required this.stylist});

  final StylistModel stylist;

  @override
  Widget build(BuildContext context) {
    final rating = stylist.rating;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StylistDetailPage(stylistId: stylist.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFDF7F3), Color(0xFFFFFFFF)],
            ),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    stylist.photoUrl,
                    width: 82,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stylist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        stylist.specialization,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 17,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${stylist.reviewCount} ulasan)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================================================
/// BOOKING TERDEKAT
/// ======================================================
class _NearestBookingSection extends StatefulWidget {
  const _NearestBookingSection();

  @override
  State<_NearestBookingSection> createState() => _NearestBookingSectionState();
}

class _NearestBookingSectionState extends State<_NearestBookingSection> {
  final BookingRepository _bookingRepository = BookingRepository();
  final StylistRepository _stylistRepository = StylistRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();

  late Future<_NearestBookingCardData?> _bookingFuture;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _loadNearestBooking();
  }

  Future<void> _refreshBooking() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _bookingFuture = _loadNearestBooking();
    });
  }

  Future<_NearestBookingCardData?> _loadNearestBooking() async {
    try {
      final results = await Future.wait<dynamic>([
        _bookingRepository.getAllBookings(),
        _stylistRepository.getAllStylists(),
        _serviceRepository.getAllServices(),
      ]);

      final List<BookingModel> bookings = results[0] as List<BookingModel>;
      final List<dynamic> stylists = results[1] as List<dynamic>;
      final List<dynamic> services = results[2] as List<dynamic>;

      final BookingModel? nearestBooking = _selectNearestBooking(bookings);
      if (nearestBooking == null) {
        return null;
      }

      final Map<String, dynamic> stylistById = {
        for (final stylist in stylists) stylist.id as String: stylist,
      };
      final Map<String, String> serviceNameById = {
        for (final service in services)
          service.id as String: service.name as String,
      };

      final dynamic stylist = stylistById[nearestBooking.stylistId];
      final List<String> serviceNames = nearestBooking.serviceIds
          .map((id) => serviceNameById[id] ?? id)
          .toList(growable: false);

      return _NearestBookingCardData(
        booking: nearestBooking,
        stylistName: stylist?.name as String? ?? nearestBooking.stylistId,
        stylistPhotoUrl:
            stylist?.photoUrl as String? ??
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
        serviceNames: serviceNames,
      );
    } catch (_) {
      return null;
    }
  }

  BookingModel? _selectNearestBooking(List<BookingModel> bookings) {
    final DateTime now = DateTime.now();
    final List<BookingModel> candidates = bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.onGoing ||
              booking.bookingDateTime.isAfter(now),
        )
        .toList(growable: false);

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((a, b) => a.bookingDateTime.compareTo(b.bookingDateTime));
    return candidates.first;
  }

  Future<void> _openBookingDetail(_NearestBookingCardData data) async {
    final BookingModel? updated = await Navigator.of(context)
        .push<BookingModel>(
          MaterialPageRoute<BookingModel>(
            builder: (_) => BookingDetailPage(booking: data.booking),
          ),
        );

    if (!mounted) {
      return;
    }

    if (updated != null) {
      await _refreshBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_NearestBookingCardData?>(
      future: _bookingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 112,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final _NearestBookingCardData? data = snapshot.data;
        if (data == null) {
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
                        'Booking Terdekat',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada jadwal booking yang akan datang',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return BookingPreviewCard(
          booking: data.booking,
          stylistName: data.stylistName,
          stylistPhotoUrl: data.stylistPhotoUrl,
          serviceNames: data.serviceNames,
          onTap: () => _openBookingDetail(data),
        );
      },
    );
  }
}

class _NearestBookingCardData {
  const _NearestBookingCardData({
    required this.booking,
    required this.stylistName,
    required this.stylistPhotoUrl,
    required this.serviceNames,
  });

  final BookingModel booking;
  final String stylistName;
  final String stylistPhotoUrl;
  final List<String> serviceNames;
}
