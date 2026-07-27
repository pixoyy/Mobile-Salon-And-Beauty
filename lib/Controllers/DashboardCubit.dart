import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/Models/DashboardData.dart';
import 'package:salon_and_beauty/Repositories/DashboardRepository.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  const DashboardState({
    required this.status,
    this.data,
    this.error,
  });

  const DashboardState.initial()
      : status = DashboardStatus.initial,
        data = null,
        error = null;

  final DashboardStatus status;
  final DashboardData? data;
  final String? error;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? error,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState.initial());

  final DashboardRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final data = await _repository.getDashboard();
      emit(DashboardState(
        status: DashboardStatus.loaded,
        data: data,
      ));
    } catch (e) {
      emit(DashboardState(
        status: DashboardStatus.error,
        error: e.toString(),
      ));
    }
  }
}
