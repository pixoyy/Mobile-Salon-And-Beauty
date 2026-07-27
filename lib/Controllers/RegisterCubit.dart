import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/Repositories/AuthRepository.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  const RegisterState({
    required this.status,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  const RegisterState.initial()
      : status = RegisterStatus.initial,
        errorMessage = null,
        fieldErrors = const {};

  final RegisterStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
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
    required String passwordConfirmation,
  }) async {
    emit(const RegisterState(status: RegisterStatus.loading));

    try {
      final result = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result.isSuccess) {
        emit(const RegisterState(status: RegisterStatus.success));
        return;
      }

      emit(RegisterState(
        status: RegisterStatus.failure,
        errorMessage: result.error ?? 'Pendaftaran gagal',
        fieldErrors: result.fieldErrors,
      ));
    } catch (_) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        errorMessage: 'Terjadi kesalahan. Silakan coba lagi.',
      ));
    }
  }
}
