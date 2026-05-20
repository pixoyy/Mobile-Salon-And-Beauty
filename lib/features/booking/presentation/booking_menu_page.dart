import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/stylist_repository.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';
import 'booking_detail_page.dart';
import 'booking_preview_card.dart';
import 'booking_schedule_page.dart';

class BookingMenuPage extends StatefulWidget {
  const BookingMenuPage({super.key});

  @override
  State<BookingMenuPage> createState() => _BookingMenuPageState();
}

class _BookingMenuPageState extends State<BookingMenuPage> with WidgetsBindingObserver {
  final BookingRepository _repo = BookingRepository();
  final StylistRepository _stylistRepository = StylistRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  bool _isLoading = true;
  List<BookingModel> _items = const <BookingModel>[];
  Map<String, String> _stylistNameById = const <String, String>{};
  Map<String, String> _stylistPhotoById = const <String, String>{};
  Map<String, String> _serviceNameById = const <String, String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBookings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload bookings when app resumes to show newly created bookings
      _loadBookings();
    }
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
          for (final stylist in stylists) stylist.id as String: stylist.name as String,
        };
        _stylistPhotoById = {
          for (final stylist in stylists) stylist.id as String: stylist.photoUrl as String,
        };
        _serviceNameById = {
          for (final service in services) service.id as String: service.name as String,
        };
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _createCard(context),
              const SizedBox(height: 14),
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Buat Booking', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                SizedBox(height: 6),
                Text('Lihat jadwal stylist dan buat booking baru.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingSchedulePage())),
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: _EmptyBookingState(
          onCreateBooking: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingSchedulePage()),
          ),
        ),
      );
    }

    return Column(
      children: _items.map((b) {
        final String stylistName = _stylistNameById[b.stylistId] ?? b.stylistId;
        final String stylistPhotoUrl = _stylistPhotoById[b.stylistId] ?? 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800';
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
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingDetailPage(booking: b))),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _EmptyBookingState extends StatelessWidget {
  const _EmptyBookingState({required this.onCreateBooking});

  final VoidCallback onCreateBooking;

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_outlined, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada history booking',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Setelah booking dibuat, riwayat reservasi akan muncul di sini dan bisa dibuka ke detail booking.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onCreateBooking,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Buat Booking'),
          ),
        ],
      ),
    );
  }
}
