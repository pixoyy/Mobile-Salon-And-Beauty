import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/Models/LoginResult.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';
import 'package:salon_and_beauty/Repositories/AuthRepository.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';

enum AuthStatus { initial, loading, authenticated, failure }

class AuthState {
  const AuthState({
    required this.status,
    this.errorMessage,
    this.currentUser,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        errorMessage = null,
        currentUser = null;

  final AuthStatus status;
  final String? errorMessage;
  final UserModel? currentUser;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? currentUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.initial());

  final AuthRepository _repository;

  Future<void> submitLogin({
    required String identifier,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.loading));

    final LoginResult result = await _repository.validateLogin(
      identifier: identifier,
      password: password,
    );

    if (result.isSuccess) {
      await AuthSession.persistLogin(result.token!, result.user!);
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          currentUser: result.user,
        ),
      );
      return;
    }

    emit(
      AuthState(
        status: AuthStatus.failure,
        errorMessage: result.error ?? 'Email/username atau password tidak valid.',
      ),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthState.initial());
  }
}
