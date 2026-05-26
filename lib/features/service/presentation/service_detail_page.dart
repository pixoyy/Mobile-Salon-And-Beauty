import 'package:flutter/material.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_menu_page.dart';

import '../../../core/theme/app_colors.dart';
import '../../booking/presentation/booking_schedule_page.dart';
import '../data/service_model.dart';
import '../data/service_repository.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({
    required this.serviceId,
    super.key,
  });

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceModel?>(
      future: ServiceRepository().getServiceById(serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Layanan')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Layanan')),
            body: const _ErrorState(
              message: 'Detail layanan tidak dapat dimuat. Silakan coba lagi.',
            ),
          );
        }

        final ServiceModel service = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Layanan'),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur bagikan akan hadir di phase berikutnya.')),
                  );
                },
                icon: const Icon(Icons.ios_share_outlined),
              ),
            ],
          ),
          body: _DetailBody(service: service),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: () async {
                  final BookingModel? created = await Navigator.of(context).push<BookingModel?>(
                    MaterialPageRoute<BookingModel?>(
                      builder: (_) => BookingSchedulePage(prefillServiceIds: [service.id]),
                    ),
                  );

                  if (!context.mounted) return;
                  if (created != null) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingMenuPage()));
                  }
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Book Layanan'),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B3A62), Color(0xFFB45A86)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.cut,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${service.durationMinutes} menit',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _formatPrice(service.price),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (service.isPopular)
                      ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFD700)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Populer',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFFFD700),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Description Section
          Text(
            'Deskripsi',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              service.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: AppColors.mutedText,
                  ),
            ),
          ),
          const SizedBox(height: 20),
          // Service Details Grid
          Text(
            'Detail Layanan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _DetailRow(
                icon: Icons.timer_outlined,
                label: 'Durasi',
                value: '${service.durationMinutes} menit',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.local_offer_outlined,
                label: 'Harga',
                value: _formatPrice(service.price),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.category_outlined,
                label: 'Kategori',
                value: service.category,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outlined, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tekan tombol "Book Layanan" untuk menambahkan layanan ini ke booking Anda.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return 'Rp${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: AppColors.mutedText),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_outlined),
              label: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
