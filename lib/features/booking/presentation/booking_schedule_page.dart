import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/data/service_model.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/stylist_model.dart';
import '../../stylist/data/stylist_repository.dart';
import '../bloc/booking_cubit.dart';
import '../domain/booking_rules_service.dart';
import 'checkout_page.dart';

class BookingSchedulePage extends StatelessWidget {
  const BookingSchedulePage({
    super.key,
    this.prefillStylistId,
    this.prefillServiceIds,
    this.prefillDateTime,
  });

  final String? prefillStylistId;
  final List<String>? prefillServiceIds;
  final DateTime? prefillDateTime;

  @override
  Widget build(BuildContext context) {
    return _BookingScheduleView(
      prefillStylistId: prefillStylistId,
      prefillServiceIds: prefillServiceIds,
      prefillDateTime: prefillDateTime,
    );
  }
}

class _BookingScheduleView extends StatefulWidget {
  const _BookingScheduleView({
    this.prefillStylistId,
    this.prefillServiceIds,
    this.prefillDateTime,
  });

  final String? prefillStylistId;
  final List<String>? prefillServiceIds;
  final DateTime? prefillDateTime;

  @override
  State<_BookingScheduleView> createState() => _BookingScheduleViewState();
}

class _BookingScheduleViewState extends State<_BookingScheduleView> {
  static const List<String> _allTimeSlots = <String>[
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  final TextEditingController _notesController = TextEditingController();

  List<StylistModel> _stylists = const <StylistModel>[];
  List<ServiceModel> _services = const <ServiceModel>[];
  bool _isFetchingMasterData = true;

  // Track where prefill came from for UI hints
  bool _stylistPrefilled = false;
  bool _servicePrefilled = false;

  @override
  void initState() {
    super.initState();
    _stylistPrefilled = widget.prefillStylistId != null;
    _servicePrefilled =
        widget.prefillServiceIds != null &&
        widget.prefillServiceIds!.isNotEmpty;
    _loadMasterData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      final StylistRepository stylistRepository = context
          .read<StylistRepository>();
      final ServiceRepository serviceRepository = context
          .read<ServiceRepository>();

      final List<dynamic> loaded = await Future.wait<dynamic>([
        stylistRepository.getAllStylists(),
        serviceRepository.getAllServices(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _stylists = loaded[0] as List<StylistModel>;
        _services = loaded[1] as List<ServiceModel>;
        _isFetchingMasterData = false;
      });
      // Apply any prefill parameters (from deep-link or navigation)
      if (widget.prefillStylistId != null ||
          (widget.prefillServiceIds?.isNotEmpty ?? false) ||
          widget.prefillDateTime != null) {
        // run after frame to ensure UI and providers are ready
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _applyPrefill();
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isFetchingMasterData = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data stylist dan layanan.')),
      );
    }
  }

  Future<void> _applyPrefill() async {
    final BookingCubit cubit = context.read<BookingCubit>();

    if (widget.prefillStylistId != null) {
      await cubit.selectStylist(widget.prefillStylistId!);

      if (widget.prefillDateTime != null) {
        final DateTime dt = widget.prefillDateTime!;
        final DateTime normalized = DateTime(dt.year, dt.month, dt.day);
        await cubit.loadAvailableSlots(widget.prefillStylistId!, normalized);

        final String time =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        // try selecting the specific time if available
        await cubit.selectDateTime(normalized, time);
      }
    }

    if (widget.prefillServiceIds != null &&
        widget.prefillServiceIds!.isNotEmpty) {
      cubit.selectServices(widget.prefillServiceIds!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          _syncNotesFromState(state.scheduleState);
        }

        if (state is BookingScheduleState) {
          _syncNotesFromState(state);
        }
      },
      builder: (context, state) {
        final BookingScheduleState scheduleState = _resolveScheduleState(
          context,
          state,
        );
        final bool isLoadingSlots = state is BookingLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Booking Schedule')),
          body: SafeArea(
            child: _isFetchingMasterData
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMasterData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        _SectionCard(
                          title: '1. Pilih Stylist',
                          child: _buildStylistPicker(context, scheduleState),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: '2. Pilih Layanan',
                          child: _buildServicePicker(context, scheduleState),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: '3. Tanggal & Jam',
                          child: _buildDateTimePicker(
                            context,
                            scheduleState,
                            isLoadingSlots,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: '4. Catatan (Opsional)',
                          child: _buildNotesField(context),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: scheduleState.canProceedToCheckout
                              ? () => _goToCheckout(context, scheduleState)
                              : () => _showValidationSnackbar(
                                  context,
                                  scheduleState,
                                ),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Lanjut ke Checkout'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStylistPicker(
    BuildContext context,
    BookingScheduleState scheduleState,
  ) {
    final String? selectedId = scheduleState.selectedStylistId;
    final StylistModel? selectedStylist = _stylists
        .where((s) => s.id == selectedId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_stylistPrefilled && selectedStylist != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ditambahkan dari Stylist',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                selectedStylist == null
                    ? 'Belum ada stylist dipilih'
                    : '${selectedStylist.name} • ${selectedStylist.specialization}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () => _showStylistPickerSheet(context, scheduleState),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedId,
          hint: const Text('Pilih stylist'),
          items: _stylists
              .map(
                (stylist) => DropdownMenuItem<String>(
                  value: stylist.id,
                  child: Text(
                    '${stylist.name} (${stylist.rating.toStringAsFixed(1)})',
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            context.read<BookingCubit>().selectStylist(value);
          },
        ),
      ],
    );
  }

  Widget _buildServicePicker(
    BuildContext context,
    BookingScheduleState scheduleState,
  ) {
    final Set<String> selectedIds = scheduleState.selectedServiceIds.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_servicePrefilled && selectedIds.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_stories_outlined,
                  size: 14,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ditambahkan dari Layanan',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (selectedIds.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _services
                .where((service) => selectedIds.contains(service.id))
                .map(
                  (service) => Chip(
                    label: Text(service.name),
                    onDeleted: () {
                      final List<String> updated = scheduleState
                          .selectedServiceIds
                          .where((id) => id != service.id)
                          .toList(growable: false);
                      context.read<BookingCubit>().selectServices(updated);
                    },
                  ),
                )
                .toList(growable: false),
          )
        else
          Text(
            'Belum ada layanan dipilih',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
        const SizedBox(height: 10),
        ..._services.map((service) {
          final bool isSelected = selectedIds.contains(service.id);

          return CheckboxListTile(
            value: isSelected,
            contentPadding: EdgeInsets.zero,
            title: Text(service.name),
            subtitle: Text(
              '${service.durationMinutes} menit • ${_toRupiah(service.price)}',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (value) {
              final Set<String> next = Set<String>.from(selectedIds);
              if (value == true) {
                next.add(service.id);
              } else {
                next.remove(service.id);
              }

              context.read<BookingCubit>().selectServices(
                next.toList(growable: false),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context,
    BookingScheduleState scheduleState,
    bool isLoadingSlots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pickDate(context, scheduleState),
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            scheduleState.selectedDate == null
                ? 'Pilih Tanggal'
                : _formatDateLabel(scheduleState.selectedDate!),
          ),
        ),

        const SizedBox(height: 10),

        if (isLoadingSlots)
          const LinearProgressIndicator(minHeight: 4)
        else if (scheduleState.selectedStylistId == null)
          Text(
            'Pilih stylist untuk melihat slot waktu.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          )
        else if (scheduleState.selectedDate == null)
          Text(
            'Pilih tanggal untuk memuat slot tersedia.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
          )
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (() {
              final List<ServiceModel> selectedServices = _services
                  .where(
                    (service) => scheduleState.selectedServiceIds.contains(service.id),
                  )
                  .toList(growable: false);
              final int totalDuration = BookingRulesService.totalDurationMinutes(
                selectedServices,
              );
              final List<String> bookingRange = BookingRulesService.highlightedSlots(
                allSlots: _allTimeSlots,
                selectedTime: scheduleState.selectedTime,
                totalDurationMinutes: totalDuration,
              );

              return _allTimeSlots.map((slot) {
                final bool isAvailable = scheduleState.availableSlots.contains(slot);
                final bool isSelected = scheduleState.selectedTime == slot;
                final bool isInBookingRange = bookingRange.contains(slot);

                return ChoiceChip(
                  label: Text(slot),

                  selected: isSelected || isInBookingRange,

                  onSelected: isAvailable
                      ? (_) {
                          context.read<BookingCubit>().selectDateTime(
                            scheduleState.selectedDate!,
                            slot,
                          );
                        }
                      : null,

                  backgroundColor: isInBookingRange
                      ? AppColors.primary.withValues(alpha: 0.18)
                      : AppColors.surface,

                  selectedColor: AppColors.primary,

                  disabledColor: AppColors.border,

                  labelStyle: TextStyle(
                    color: !isAvailable
                        ? Colors.black
                        : isInBookingRange
                            ? Colors.black
                            : AppColors.text,
                  ),
                );
              }).toList(growable: false);
            })(),
          ),

          if (scheduleState.availableSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Tidak tersedia',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildNotesField(BuildContext context) {
    return TextField(
      controller: _notesController,
      maxLines: 3,
      minLines: 2,
      onChanged: (value) => context.read<BookingCubit>().updateNotes(value),
      decoration: const InputDecoration(
        hintText:
            'Contoh: Tolong mulai tepat waktu karena ada acara setelahnya.',
      ),
    );
  }

  Future<void> _showStylistPickerSheet(
    BuildContext context,
    BookingScheduleState scheduleState,
  ) async {
    final String? pickedId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: _stylists.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final stylist = _stylists[index];
              return ListTile(
                title: Text(stylist.name),
                subtitle: Text(stylist.specialization),
                trailing: Text('⭐ ${stylist.rating.toStringAsFixed(1)}'),
                onTap: () => Navigator.of(context).pop(stylist.id),
              );
            },
          ),
        );
      },
    );

    if (!context.mounted || pickedId == null) {
      return;
    }

    context.read<BookingCubit>().selectStylist(pickedId);
    if (scheduleState.selectedDate != null) {
      await context.read<BookingCubit>().loadAvailableSlots(
        pickedId,
        scheduleState.selectedDate!,
      );
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    BookingScheduleState scheduleState,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        scheduleState.selectedDate ?? DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
    );

    if (!context.mounted || picked == null) {
      return;
    }

    final BookingCubit cubit = context.read<BookingCubit>();
    final DateTime normalized = DateTime(picked.year, picked.month, picked.day);

    final String? stylistId = scheduleState.selectedStylistId;
    if (stylistId != null) {
      await cubit.loadAvailableSlots(stylistId, normalized);
      return;
    }

    cubit.selectDate(normalized);
  }

  void _goToCheckout(BuildContext context, BookingScheduleState scheduleState) {
    // Navigate to checkout and await created booking result; bubble it up
    // to the caller so they can react and refresh booking lists.
    () async {
      final BookingModel? created = await Navigator.of(context)
          .push<BookingModel?>(
            MaterialPageRoute<BookingModel?>(
              builder: (_) =>
                  CheckoutPage(stylists: _stylists, services: _services),
            ),
          );

      if (!mounted) return;

      if (created != null) {
        // Bubble the created booking to whoever opened BookingSchedulePage.
        Navigator.of(context).pop(created);
      }
    }();
  }

  void _showValidationSnackbar(
    BuildContext context,
    BookingScheduleState state,
  ) {
    final String message = BookingRulesService.validateSelection(
          selectedStylistId: state.selectedStylistId,
          selectedServiceIds: state.selectedServiceIds,
          selectedDate: state.selectedDate,
          selectedTime: state.selectedTime,
        ) ??
        'Lengkapi data booking terlebih dahulu.';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  BookingScheduleState _resolveScheduleState(
    BuildContext context,
    BookingState state,
  ) {
    if (state is BookingScheduleState) {
      return state;
    }

    if (state is BookingLoading && state.previousState != null) {
      return state.previousState!;
    }

    if (state is BookingError) {
      return state.scheduleState;
    }

    if (state is BookingSuccess) {
      return state.scheduleState;
    }

    return context.read<BookingCubit>().scheduleState;
  }

  void _syncNotesFromState(BookingScheduleState state) {
    if (_notesController.text == state.notes) {
      return;
    }

    _notesController
      ..text = state.notes
      ..selection = TextSelection.collapsed(offset: state.notes.length);
  }

  String _formatDateLabel(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  String _toRupiah(int value) {
    final String digits = value.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final int reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
