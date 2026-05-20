part of 'user_bloc.dart';

abstract class UserEvent {}

class LoadUserEvent extends UserEvent {}

class UpdateUserEvent extends UserEvent {
  final String name;
  final String phone;

  UpdateUserEvent({
    required this.name,
    required this.phone,
  });
}