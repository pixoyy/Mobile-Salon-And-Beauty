part of 'user_bloc.dart';

abstract class UserEvent {}

class LoadUserEvent extends UserEvent {}

class UpdateUserEvent extends UserEvent {
  final String name;
  final String email;
  final String phone;

  UpdateUserEvent({
    required this.name,
    required this.email,
    required this.phone,
  });
}

class ChangePasswordEvent extends UserEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordEvent({required this.oldPassword, required this.newPassword});
}
