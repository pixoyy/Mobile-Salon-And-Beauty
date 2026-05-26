import 'package:flutter/material.dart';

import 'bootstrap/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';

class GlamoraApp extends StatelessWidget {
  const GlamoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBootstrap(
      child: MaterialApp(
          title: 'Glamora Salon & Beauty',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const LoginPage(),
      ),
    );
  }
}
