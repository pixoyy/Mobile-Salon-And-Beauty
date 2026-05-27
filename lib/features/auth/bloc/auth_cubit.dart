// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:salon_and_beauty/core/session/auth_session.dart';
// import 'package:salon_and_beauty/features/user/data/user_model.dart';

// import '../data/auth_repository.dart';
// // import '../data/user_model.dart';

// enum AuthStatus { initial, loading, authenticated, failure }

// class AuthState {
//   const AuthState({required this.status, this.errorMessage, this.currentUser});

//   const AuthState.initial()
//     : status = AuthStatus.initial,
//       errorMessage = null,
//       currentUser = null;

//   final AuthStatus status;
//   final String? errorMessage;
//   final UserModel? currentUser;

//   AuthState copyWith({
//     AuthStatus? status,
//     String? errorMessage,
//     UserModel? currentUser,
//   }) {
//     return AuthState(
//       status: status ?? this.status,
//       errorMessage: errorMessage,
//       currentUser: currentUser ?? this.currentUser,
//     );
//   }
// }

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit(this._repository) : super(const AuthState.initial());

//   final AuthRepository _repository;

//   Future<void> submitLogin({
//     required String identifier,
//     required String password,
//   }) async {
//     emit(const AuthState(status: AuthStatus.loading));

//     await Future<void>.delayed(const Duration(milliseconds: 450));

//     final user = _repository.validateLogin(
//       identifier: identifier,
//       password: password,
//     );

//     if (user != null) {
//       // SAVE SESSION
//       AuthSession.currentUser = user;

//       emit(AuthState(status: AuthStatus.authenticated, currentUser: user));

//       return;
//     }

//     emit(
//       const AuthState(
//         status: AuthStatus.failure,
//         errorMessage: 'Email/username atau password tidak valid.',
//       ),
//     );
//   }
// }


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

import '../data/auth_repository.dart';

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

    await Future<void>.delayed(const Duration(milliseconds: 450));

    final user = await _repository.validateLogin(
      identifier: identifier,
      password: password,
    );

    if (user != null) {

      // SAVE SESSION (persisted by repository)
      AuthSession.currentUser = user;

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          currentUser: user,
        ),
      );

      return;
    }

    emit(
      const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Email/username atau password tidak valid.',
      ),
    );
  }

  Future<void> logout() async {

    // CLEAR SESSION
    AuthSession.logout();

    // RESET STATE
    emit(const AuthState.initial());
  }
}