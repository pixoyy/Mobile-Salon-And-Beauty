import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  const RegisterState({
    required this.status,
    this.errorMessage,
  });

  const RegisterState.initial()
      : status = RegisterStatus.initial,
        errorMessage = null;

  final RegisterStatus status;
  final String? errorMessage;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._repository) : super(const RegisterState.initial());

  final AuthRepository _repository;

  Future<void> submitRegister({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    emit(const RegisterState(status: RegisterStatus.loading));

    await Future<void>.delayed(const Duration(milliseconds: 450));

    final result = await _repository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (result.isSuccess) {
      emit(const RegisterState(status: RegisterStatus.success));
      return;
    }

    emit(RegisterState(
      status: RegisterStatus.failure,
      errorMessage: result.error ?? 'Pendaftaran gagal',
    ));
  }
}
