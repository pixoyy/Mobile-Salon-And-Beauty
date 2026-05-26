import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_menu_page.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/stylist_cubit.dart';
import '../../booking/presentation/booking_schedule_page.dart';
import '../data/stylist_model.dart';
import '../data/stylist_repository.dart';

class StylistDetailPage extends StatelessWidget {
  const StylistDetailPage({
    required this.stylistId,
    super.key,
  });

  final String stylistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StylistDetailCubit(context.read<StylistRepository>())..loadStylistDetail(stylistId),
      child: const _StylistDetailView(),
    );
  }
}

class _StylistDetailView extends StatelessWidget {
  const _StylistDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StylistDetailCubit, StylistDetailState>(
      builder: (context, state) {
        final stylist = state.stylist;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Stylist'),
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
          body: switch (state.status) {
            StylistStatus.initial || StylistStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            StylistStatus.failure => _ErrorState(
                message: state.errorMessage ?? 'Gagal memuat detail stylist.',
              ),
            StylistStatus.success when stylist != null =>
              _DetailBody(stylist: stylist),
            _ => const _ErrorState(message: 'Data stylist tidak tersedia.'),
          },
          bottomNavigationBar: stylist == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                      onPressed: () async {
                        final BookingModel? created = await Navigator.of(context).push<BookingModel?>(
                          MaterialPageRoute<BookingModel?>(builder: (_) => BookingSchedulePage(prefillStylistId: stylist.id)),
                        );

                        if (!context.mounted) return;
                        if (created != null) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingMenuPage()));
                        }
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Book Stylist'),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.stylist});

  final StylistModel stylist;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Semantics(
                  label: 'Foto stylist ${stylist.name}',
                  child: Image.network(
                    stylist.photoUrl,
                    width: 104,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 104,
                        height: 120,
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        child: const Icon(Icons.person, size: 44, color: AppColors.primary),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: 104,
                        height: 120,
                        color: AppColors.secondary.withValues(alpha: 0.25),
                        child: const Icon(Icons.person, size: 44, color: AppColors.primary),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stylist.specialization,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${stylist.rating.toStringAsFixed(1)} (${stylist.reviewCount} ulasan)',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang Stylist',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  stylist.bio,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.workspace_premium_outlined,
                      label: '${stylist.experienceYears} tahun pengalaman',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.forum_outlined,
                      label: '${stylist.reviewCount} review',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Keahlian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stylist.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      skill,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          Text(
            'Ulasan Terbaru',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...stylist.reviews.map(_ReviewCard.new),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard(this.review);

  final StylistReview review;

  static const List<String> _months = <String>[
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.customerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                _formatDate(review.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                review.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: Theme.of(context).textTheme.bodyMedium,
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
              ),
        ),
      ),
    );
  }
}