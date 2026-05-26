import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/user_model.dart';
import '../data/user_repository.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  UserLoaded(this.user);

  final UserModel user;
}

class UserError extends UserState {
  UserError(this.message);

  final String message;
}

class ChangePasswordLoading extends UserState {}

class ChangePasswordSuccess extends UserState {}

class ChangePasswordError extends UserState {
  ChangePasswordError(this.message);

  final String message;
}

class UserCubit extends Cubit<UserState> {
  UserCubit(this.repository) : super(UserInitial());

  final UserRepository repository;

  Future<void> loadUser() async {
    try {
      emit(UserLoading());

      final user = await repository.getProfile();

      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> updateUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      emit(UserLoading());

      final currentUser = await repository.getProfile();

      final updatedUser = currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      final result = await repository.updateProfile(updatedUser);

      emit(UserLoaded(result));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      emit(ChangePasswordLoading());

      await repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordError(e.toString()));
    }
  }
}