import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/dashboard_repository.dart';

enum DashboardStatus { initial, loading, loaded }

class DashboardState {
  const DashboardState({
    required this.status,
    this.snapshot,
  });

  const DashboardState.initial()
      : status = DashboardStatus.initial,
        snapshot = null;

  final DashboardStatus status;
  final DashboardSnapshot? snapshot;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSnapshot? snapshot,
  }) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState.initial());

  final DashboardRepository _repository;

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 250));
    emit(DashboardState(
      status: DashboardStatus.loaded,
      snapshot: _repository.getSnapshot(),
    ));
  }
}
