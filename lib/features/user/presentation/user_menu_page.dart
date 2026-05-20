import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                    onTap: () {
                      // logout action
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
