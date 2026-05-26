import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/booking/bloc/booking_cubit.dart';
import '../features/booking/data/booking_repository.dart';
import '../features/service/data/service_repository.dart';
import '../features/stylist/data/stylist_repository.dart';

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