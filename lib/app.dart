import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/stylist/data/stylist_repository.dart';

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<StylistRepository>(
      create: (_) => StylistRepository(),
      child: MaterialApp(
        title: 'Glamora Salon & Beauty',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const LoginPage(),
      ),
    );
  }
}
