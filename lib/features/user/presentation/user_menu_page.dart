import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/core/theme/app_colors.dart';
import 'package:salon_and_beauty/features/auth/presentation/login_page.dart';
import 'package:salon_and_beauty/features/user/bloc/user_bloc.dart';
import 'package:salon_and_beauty/features/user/data/user_repository.dart';
import 'package:salon_and_beauty/features/user/presentation/user_header.dart';

class UserMenuPage extends StatelessWidget {
  const UserMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(UserRepository())..add(LoadUserEvent()),
      child: const _UserView(),
    );
  }
}

class _UserView extends StatelessWidget {
  const _UserView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(child: Text(state.message));
          }

          if (state is UserLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserHeader(
                    name: user.name,
                    email: user.email,
                    imageUrl: user.imageUrl,
                  ),
                  const SizedBox(height: 24),
                  _buildTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: user.email,
                  ),
                  _buildTile(
                    icon: Icons.history,
                    title: 'Booking History',
                    subtitle: 'View all booking history',
                    onTap: () {
                      // navigate booking history
                    },
                  ),
                  _buildTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out from account',
                    onTap: () async {
                      // final shouldLogout = await showDialog<bool>(
                      //   context: context,
                      //   builder: (context) {
                      //     return AlertDialog(
                      //       title: const Text('Logout'),
                      //       content: const Text(
                      //         'Apakah kamu yakin ingin keluar?',
                      //       ),
                      //       actions: [
                      //         TextButton(
                      //           onPressed: () {
                      //             Navigator.pop(context, false);
                      //           },
                      //           child: const Text('Batal'),
                      //         ),
                      //         ElevatedButton(
                      //           onPressed: () {
                      //             Navigator.pop(context, true);
                      //           },
                      //           child: const Text('Logout'),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );

                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          final theme = Theme.of(context);

                          return AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              24,
                              24,
                              24,
                              20,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ICON
                                Container(
                                  height: 72,
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.25,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: AppColors.primary,
                                    size: 36,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // TITLE
                                Text(
                                  'Logout',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // DESCRIPTION
                                Text(
                                  'Apakah kamu yakin ingin keluar?',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedText,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // BUTTONS
                                Row(
                                  children: [
                                    // CANCEL
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.border,
                                            foregroundColor: AppColors.text,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text(
                                            'Batal',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // LOGOUT
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text(
                                            'Logout',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      if (shouldLogout != true) {
                        return;
                      }

                      // CLEAR SESSION
                      AuthSession.logout();

                      // NAVIGATE TO LOGIN
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
