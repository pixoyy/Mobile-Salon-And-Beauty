part of 'user_bloc.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class ChangePasswordLoading extends UserState {}

class ChangePasswordSuccess extends UserState {}

class ChangePasswordError extends UserState {
  final String message;

  ChangePasswordError(this.message);
}
