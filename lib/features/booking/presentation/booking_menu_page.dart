import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/stylist_repository.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';
import 'booking_detail_page.dart';
import 'booking_preview_card.dart';
// import 'booking_schedule_page.dart';

class BookingMenuPage extends StatefulWidget {
  const BookingMenuPage({super.key});

  @override
  State<BookingMenuPage> createState() => _BookingMenuPageState();
}

class _BookingMenuPageState extends State<BookingMenuPage>
    with WidgetsBindingObserver {
  // final BookingRepository _repo = BookingRepository();
  // final StylistRepository _stylistRepository = StylistRepository();
  // final ServiceRepository _serviceRepository = ServiceRepository();
  // bool _isLoading = true;
  // List<BookingModel> _items = const <BookingModel>[];
  // Map<String, String> _stylistNameById = const <String, String>{};
  // Map<String, String> _stylistPhotoById = const <String, String>{};
  // Map<String, String> _serviceNameById = const <String, String>{};

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  //   _loadBookings();
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // Reload bookings when app resumes to show newly created bookings
  //     _loadBookings();
  //   }
  // }

  // Future<void> _loadBookings() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     final results = await Future.wait<dynamic>([
  //       _repo.getAllBookings(),
  //       _stylistRepository.getAllStylists(),
  //       _serviceRepository.getAllServices(),
  //     ]);
  //     if (!mounted) return;

  //     final items = results[0] as List<BookingModel>;
  //     final stylists = results[1] as List<dynamic>;
  //     final services = results[2] as List<dynamic>;

  //     setState(() {
  //       _items = items;
  //       _stylistNameById = {
  //         for (final stylist in stylists) stylist.id as String: stylist.name as String,
  //       };
  //       _stylistPhotoById = {
  //         for (final stylist in stylists) stylist.id as String: stylist.photoUrl as String,
  //       };
  //       _serviceNameById = {
  //         for (final service in services) service.id as String: service.name as String,
  //       };
  //       _isLoading = false;
  //     });
  //   } catch (_) {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);
  //   }
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Booking')),
  //     body: SafeArea(
  //       child: RefreshIndicator(
  //         onRefresh: _loadBookings,
  //         child: ListView(
  //           padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
  //           children: [
  //             _createCard(context),
  //             const SizedBox(height: 14),
  //             _isLoading
  //                 ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
  //                 : _buildList(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _createCard(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColors.surface,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: AppColors.border),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: const [
  //               Text('Buat Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
  //               SizedBox(height: 6),
  //               Text('Lihat jadwal stylist dan buat booking baru.'),
  //             ],
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingSchedulePage())),
  //           child: const Text('Buat'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildList() {
  //   if (_items.isEmpty) {
  //     return Padding(
  //       padding: const EdgeInsets.only(top: 4),
  //       child: _EmptyBookingState(
  //         onCreateBooking: () => Navigator.of(context).push(
  //           MaterialPageRoute(builder: (_) => const BookingSchedulePage()),
  //         ),
  //       ),
  //     );
  //   }

  //   return Column(
  //     children: _items.map((b) {
  //       final String stylistName = _stylistNameById[b.stylistId] ?? b.stylistId;
  //       final String stylistPhotoUrl = _stylistPhotoById[b.stylistId] ?? 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800';
  //       final List<String> serviceNames = b.serviceIds
  //           .map((id) => _serviceNameById[id] ?? id)
  //           .toList(growable: false);

  //       return Padding(
  //         padding: const EdgeInsets.only(bottom: 12),
  //         child: BookingPreviewCard(
  //           booking: b,
  //           stylistName: stylistName,
  //           stylistPhotoUrl: stylistPhotoUrl,
  //           serviceNames: serviceNames,
  //           onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailPage(booking: b))),
  //         ),
  //       );
  //     }).toList(growable: false),
  //   );
  // }
  final BookingRepository _repo = BookingRepository();
  final StylistRepository _stylistRepository = StylistRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();

  bool _isLoading = true;
  List<BookingModel> _items = const <BookingModel>[];
  List<BookingModel> _filtered = const <BookingModel>[];

  BookingStatus? _filterStatus;

  Map<String, String> _stylistNameById = const <String, String>{};
  Map<String, String> _stylistPhotoById = const <String, String>{};
  Map<String, String> _serviceNameById = const <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<dynamic>([
        _repo.getAllBookings(),
        _stylistRepository.getAllStylists(),
        _serviceRepository.getAllServices(),
      ]);

      if (!mounted) return;

      final items = results[0] as List<BookingModel>;
      final stylists = results[1] as List<dynamic>;
      final services = results[2] as List<dynamic>;

      setState(() {
        _items = items;
        _stylistNameById = {
          for (final stylist in stylists)
            stylist.id as String: stylist.name as String,
        };
        _stylistPhotoById = {
          for (final stylist in stylists)
            stylist.id as String: stylist.photoUrl as String,
        };
        _serviceNameById = {
          for (final service in services)
            service.id as String: service.name as String,
        };
        _isLoading = false;
      });

      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filterStatus == null) {
        _filtered = List<BookingModel>.from(_items);
      } else {
        _filtered = _items
            .where((b) => b.status == _filterStatus)
            .toList(growable: false);
      }
    });
  }

  void _setFilter(BookingStatus? status) {
    _filterStatus = status;
    _applyFilter();
  }

  Future<void> _openBookingDetail(BookingModel booking) async {
    final BookingModel? updated = await Navigator.of(context)
        .push<BookingModel>(
          MaterialPageRoute(
            builder: (_) => BookingDetailPage(booking: booking),
          ),
        );

    if (!mounted || updated == null) {
      return;
    }

    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildFilters(),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final List<Widget> chips = <Widget>[
      ChoiceChip(
        label: const Text('Semua'),
        selected: _filterStatus == null,
        onSelected: (_) => _setFilter(null),
      ),
      ChoiceChip(
        label: const Text('Upcoming'),
        selected: _filterStatus == BookingStatus.upcoming,
        onSelected: (_) => _setFilter(BookingStatus.upcoming),
      ),
      ChoiceChip(
        label: const Text('On Going'),
        selected: _filterStatus == BookingStatus.onGoing,
        onSelected: (_) => _setFilter(BookingStatus.onGoing),
      ),
      ChoiceChip(
        label: const Text('Completed'),
        selected: _filterStatus == BookingStatus.completed,
        onSelected: (_) => _setFilter(BookingStatus.completed),
      ),
      ChoiceChip(
        label: const Text('Cancelled'),
        selected: _filterStatus == BookingStatus.cancelled,
        onSelected: (_) => _setFilter(BookingStatus.cancelled),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (int index = 0; index < chips.length; index++) ...[
            chips[index],
            if (index != chips.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _EmptyState(
          status: _filterStatus,
          onRefresh: _loadBookings,
        ),
      );
    }

    return Column(
      children: _filtered
          .map((b) {
            final String stylistName =
                _stylistNameById[b.stylistId] ?? b.stylistId;
            final String stylistPhotoUrl =
                _stylistPhotoById[b.stylistId] ??
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800';
            final List<String> serviceNames = b.serviceIds
                .map((id) => _serviceNameById[id] ?? id)
                .toList(growable: false);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BookingPreviewCard(
                booking: b,
                stylistName: stylistName,
                stylistPhotoUrl: stylistPhotoUrl,
                serviceNames: serviceNames,
                onTap: () => _openBookingDetail(b),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

// class _EmptyBookingState extends StatelessWidget {
//   const _EmptyBookingState({required this.onCreateBooking});

//   final VoidCallback onCreateBooking;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withValues(alpha: 0.10),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.calendar_month_outlined,
//               size: 36,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Belum ada history booking',
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Setelah booking dibuat, riwayat reservasi akan muncul di sini dan bisa dibuka ke detail booking.',
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: onCreateBooking,
//             icon: const Icon(Icons.add_circle_outline),
//             label: const Text('Buat Booking'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status, required this.onRefresh});

  final BookingStatus? status;

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final _EmptyStateContent content = _resolveContent(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: content.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(content.icon, size: 36, color: content.iconColor),
          ),
          const SizedBox(height: 14),
          Text(
            content.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            content.message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
          // const SizedBox(height: 16),
          // OutlinedButton.icon(
          //   onPressed: () => onRefresh(),
          //   icon: const Icon(Icons.refresh),
          //   label: const Text('Muat Ulang'),
          // ),
        ],
      ),
    );
  }

  _EmptyStateContent _resolveContent(BookingStatus? status) {
    switch (status) {
      case BookingStatus.upcoming:
        return const _EmptyStateContent(
          icon: Icons.event_available_outlined,
          iconColor: AppColors.primary,
          iconBackground: Color(0x1A8B3A62),
          title: 'Belum ada booking upcoming',
          message:
              'Booking yang sudah dibuat dan menunggu jadwal akan tampil di sini.',
        );
      case BookingStatus.onGoing:
        return const _EmptyStateContent(
          icon: Icons.schedule_outlined,
          iconColor: Color(0xFF1F7A3D),
          iconBackground: Color(0x1AE3F3E8),
          title: 'Belum ada booking yang sedang berjalan',
          message:
              'Saat ada booking yang sedang diproses, daftar ini akan terisi otomatis.',
        );
      case BookingStatus.completed:
        return const _EmptyStateContent(
          icon: Icons.verified_outlined,
          iconColor: Color(0xFF2952A3),
          iconBackground: Color(0x1AE7EEFF),
          title: 'Belum ada booking completed',
          message:
              'Booking yang sudah selesai akan muncul di tab completed.',
        );
      case BookingStatus.cancelled:
        return const _EmptyStateContent(
          icon: Icons.cancel_outlined,
          iconColor: Color(0xFF9B314D),
          iconBackground: Color(0x1AF5E4E7),
          title: 'Belum ada booking cancelled',
          message:
              'Booking yang dibatalkan akan muncul di sini sebagai arsip.',
        );
      case null:
        return const _EmptyStateContent(
          icon: Icons.history,
          iconColor: AppColors.primary,
          iconBackground: Color(0x1A8B3A62),
          title: 'Belum ada riwayat booking',
          message:
              'Setelah booking dibuat, riwayat reservasi akan muncul di sini.',
        );
    }
  }
}

class _EmptyStateContent {
  const _EmptyStateContent({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
}
