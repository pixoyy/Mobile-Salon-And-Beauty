import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/user_model.dart';
import '../data/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(UserInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<UpdateUserEvent>(_onUpdateUser);
  }

  Future<void> _onLoadUser(
    LoadUserEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      final user = await repository.getProfile();

      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event,Emitter<UserState> emit,) 
  async {
    try {
      emit(UserLoading());

      final currentUser = await repository.getProfile();

      final updatedUser = currentUser.copyWith(
        name: event.name,
        email: event.email,
        phone: event.phone,
      );

      final result = await repository.updateProfile(updatedUser);

      emit(UserLoaded(result));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
  
}