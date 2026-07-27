import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/Models/StylistModel.dart';
import 'package:salon_and_beauty/Repositories/StylistRepository.dart';

enum StylistStatus { initial, loading, success, failure }

class StylistListState {
  const StylistListState({
    required this.status,
    required this.stylists,
    this.query = '',
    this.errorMessage,
  });

  const StylistListState.initial()
      : status = StylistStatus.initial,
        stylists = const <StylistModel>[],
        query = '',
        errorMessage = null;

  final StylistStatus status;
  final List<StylistModel> stylists;
  final String query;
  final String? errorMessage;

  StylistListState copyWith({
    StylistStatus? status,
    List<StylistModel>? stylists,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StylistListState(
      status: status ?? this.status,
      stylists: stylists ?? this.stylists,
      query: query ?? this.query,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class StylistDetailState {
  const StylistDetailState({
    required this.status,
    this.stylist,
    this.errorMessage,
  });

  const StylistDetailState.initial()
      : status = StylistStatus.initial,
        stylist = null,
        errorMessage = null;

  final StylistStatus status;
  final StylistModel? stylist;
  final String? errorMessage;

  StylistDetailState copyWith({
    StylistStatus? status,
    StylistModel? stylist,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StylistDetailState(
      status: status ?? this.status,
      stylist: stylist ?? this.stylist,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class StylistListCubit extends Cubit<StylistListState> {
  StylistListCubit(this._repository) : super(const StylistListState.initial());

  final StylistRepository _repository;

  Future<void> loadStylists({bool showLoading = true}) async {
    if (showLoading) {
      emit(state.copyWith(status: StylistStatus.loading, clearError: true));
    }

    try {
      final stylists = await _repository.getAllStylists();
      emit(state.copyWith(
        status: StylistStatus.success,
        stylists: stylists,
        query: '',
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StylistStatus.failure,
        errorMessage: 'Gagal memuat daftar stylist.',
      ));
    }
  }

  Future<void> searchStylists(String query, {double? minRating}) async {
    final normalizedQuery = query.trim();

    try {
      final stylists = await _repository.searchStylists(normalizedQuery, minRating: minRating);
      emit(state.copyWith(
        status: StylistStatus.success,
        stylists: stylists,
        query: normalizedQuery,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StylistStatus.failure,
        errorMessage: 'Pencarian stylist gagal. Coba lagi.',
      ));
    }
  }
}

class StylistDetailCubit extends Cubit<StylistDetailState> {
  StylistDetailCubit(this._repository) : super(const StylistDetailState.initial());

  final StylistRepository _repository;

  Future<void> loadStylistDetail(String id) async {
    emit(state.copyWith(status: StylistStatus.loading, clearError: true));

    try {
      final stylist = await _repository.getStylistById(id);
      emit(state.copyWith(
        status: StylistStatus.success,
        stylist: stylist,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StylistStatus.failure,
        errorMessage: 'Gagal memuat detail stylist.',
      ));
    }
  }
}