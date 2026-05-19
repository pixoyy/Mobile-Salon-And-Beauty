import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/stylist_cubit.dart';
import '../data/stylist_model.dart';
import '../data/stylist_repository.dart';
import 'stylist_detail_page.dart';

class StylistListPage extends StatelessWidget {
  const StylistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StylistListCubit(context.read<StylistRepository>())..loadStylists(),
      child: const _StylistListView(),
    );
  }
}

class _StylistListView extends StatefulWidget {
  const _StylistListView();

  @override
  State<_StylistListView> createState() => _StylistListViewState();
}

class _StylistListViewState extends State<_StylistListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(width: 72, height: 72, color: AppColors.secondary.withValues(alpha: 0.12)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 120, height: 14, color: AppColors.background),
                    const SizedBox(height: 8),
                    Container(width: 90, height: 12, color: AppColors.background),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: AppColors.background),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StylistListCubit, StylistListState>(
      listener: (context, state) {
        if (state.status == StylistStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Gagal memuat stylist')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pilih Stylist'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => context.read<StylistListCubit>().searchStylists(v),
                    decoration: InputDecoration(
                      hintText: 'Cari stylist atau spesialisasi',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<StylistListCubit>().searchStylists('');
                                setState(() {});
                              },
                            ),
                    ),
                    onSubmitted: (_) => context.read<StylistListCubit>().searchStylists(_searchController.text),
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    StylistStatus.loading || StylistStatus.initial => _buildLoadingSkeleton(),
                    StylistStatus.failure => _ErrorState(
                        onRetry: () => context.read<StylistListCubit>().loadStylists(),
                      ),
                    StylistStatus.success => state.stylists.isEmpty
                        ? _EmptyState(query: state.query)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemBuilder: (_, index) {
                              final stylist = state.stylists[index];
                              return _StylistCard(stylist: stylist);
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: state.stylists.length,
                          ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StylistCard extends StatelessWidget {
  const _StylistCard({required this.stylist});

  final StylistModel stylist;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StylistDetailPage(stylistId: stylist.id),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Avatar(photoUrl: stylist.photoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stylist.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
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
                          stylist.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${stylist.reviewCount} ulasan)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StylistDetailPage(stylistId: stylist.id),
                    ),
                  );
                },
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        photoUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 72,
            height: 72,
            color: AppColors.secondary.withValues(alpha: 0.22),
            child: const Icon(Icons.person, color: AppColors.primary),
          );
        },
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
              'Stylist tidak ditemukan',
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
              'Terjadi kendala saat memuat stylist',
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