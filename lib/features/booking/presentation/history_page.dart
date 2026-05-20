import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/stylist_repository.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';
import 'booking_detail_page.dart';
import 'booking_preview_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
        _filtered = _items.where((b) => b.status == _filterStatus).toList(growable: false);
      }
    });
  }

  void _setFilter(BookingStatus? status) {
    _filterStatus = status;
    _applyFilter();
  }

  Future<void> _openBookingDetail(BookingModel booking) async {
    final BookingModel? updated = await Navigator.of(context).push<BookingModel>(
      MaterialPageRoute(builder: (_) => BookingDetailPage(booking: booking)),
    );

    if (!mounted || updated == null) {
      return;
    }

    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBookings,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildFilters(),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : _buildList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Semua'),
          selected: _filterStatus == null,
          onSelected: (_) => _setFilter(null),
        ),
        ChoiceChip(
          label: const Text('Pending'),
          selected: _filterStatus == BookingStatus.pending,
          onSelected: (_) => _setFilter(BookingStatus.pending),
        ),
        ChoiceChip(
          label: const Text('Confirmed'),
          selected: _filterStatus == BookingStatus.confirmed,
          onSelected: (_) => _setFilter(BookingStatus.confirmed),
        ),
        ChoiceChip(
          label: const Text('Completed'),
          selected: _filterStatus == BookingStatus.completed,
          onSelected: (_) => _setFilter(BookingStatus.completed),
        ),
        ChoiceChip(
          label: const Text('Dibatalkan'),
          selected: _filterStatus == BookingStatus.cancelled,
          onSelected: (_) => _setFilter(BookingStatus.cancelled),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _EmptyState(onRefresh: _loadBookings),
      );
    }

    return Column(
      children: _filtered.map((b) {
        final String stylistName = _stylistNameById[b.stylistId] ?? b.stylistId;
        final String stylistPhotoUrl = _stylistPhotoById[b.stylistId] ?? 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800';
        final List<String> serviceNames = b.serviceIds.map((id) => _serviceNameById[id] ?? id).toList(growable: false);

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
      }).toList(growable: false),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

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
            child: const Icon(Icons.history, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Belum ada riwayat booking',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Setelah booking dibuat, riwayat reservasi akan muncul di sini.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => onRefresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }
}
