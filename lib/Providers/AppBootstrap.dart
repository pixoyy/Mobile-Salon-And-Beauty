import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:salon_and_beauty/Controllers/BookingCubit.dart';
import 'package:salon_and_beauty/Repositories/BookingRepository.dart';
import 'package:salon_and_beauty/Repositories/ServiceRepository.dart';
import 'package:salon_and_beauty/Repositories/StylistRepository.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StylistRepository>(create: (_) => StylistRepository()),
        RepositoryProvider<ServiceRepository>(create: (_) => ServiceRepository()),
        RepositoryProvider<BookingRepository>(create: (_) => BookingRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookingCubit>(
            create: (context) => BookingCubit(
              context.read<BookingRepository>(),
              context.read<ServiceRepository>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
