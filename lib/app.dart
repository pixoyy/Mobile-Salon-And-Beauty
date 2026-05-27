import 'package:flutter/material.dart';

import 'bootstrap/app_bootstrap.dart';
import 'core/session/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/shell/presentation/app_shell.dart';

class GlamoraApp extends StatefulWidget {
  const GlamoraApp({super.key});

  @override
  State<GlamoraApp> createState() => _GlamoraAppState();
}

class _GlamoraAppState extends State<GlamoraApp> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = AuthSession.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return AppBootstrap(
      child: FutureBuilder<void>(
        future: _bootstrapFuture,
        builder: (context, snapshot) {
          final bool isReady = snapshot.connectionState == ConnectionState.done;

          if (!isReady) {
            return MaterialApp(
              title: 'Glamora Salon & Beauty',
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(),
              home: const _StartupScreen(),
            );
          }

          return MaterialApp(
            title: 'Glamora Salon & Beauty',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            home: AuthSession.isLoggedIn ? const AppShell() : const LoginPage(),
          );
        },
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
