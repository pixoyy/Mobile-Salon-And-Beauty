import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/core/theme/app_colors.dart';
import 'package:salon_and_beauty/features/auth/presentation/login_page.dart';
import 'package:salon_and_beauty/features/user/bloc/user_bloc.dart';
import 'package:salon_and_beauty/features/user/data/user_repository.dart';
import 'package:salon_and_beauty/features/user/presentation/change_password_page.dart';
import 'package:salon_and_beauty/features/user/presentation/edit_profile_page.dart';
import 'package:salon_and_beauty/features/user/presentation/faq_page.dart';

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
      backgroundColor: AppColors.background,
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

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _buildHeader(context, user),

                          const SizedBox(height: 28),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildMenuCard(
                                  icon: Icons.person_outline_rounded,
                                  title: 'Edit Profile',
                                  subtitle: 'Ubah informasi profile Anda',
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (_) => const EditProfilePage(),
                                  //     ),
                                  //   );
                                  // },
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const EditProfilePage(),
                                      ),
                                    );

                                    if (result == true && context.mounted) {
                                      context.read<UserBloc>().add(
                                        LoadUserEvent(),
                                      );
                                    }
                                  },
                                ),

                                _buildMenuCard(
                                  icon: Icons.help_outline_rounded,
                                  title: 'Bantuan & FAQ',
                                  subtitle:
                                      'Panduan penggunaan aplikasi salon booking',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const FaqPage(),
                                      ),
                                    );
                                  },
                                ),

                                _buildMenuCard(
                                  icon: Icons.lock_outline_rounded,
                                  title: 'Keamanan Akun',
                                  subtitle: 'Ubah password dan keamanan akun',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<UserBloc>(),
                                          child: const ChangePasswordPage(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          /// PUSH LOGOUT KE BAWAH
                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                            child: _buildLogoutCard(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final hasImage =
        user.imageUrl != null && user.imageUrl.toString().isNotEmpty;

    final initial = user.name.toString().isNotEmpty
        ? user.name.toString()[0].toUpperCase()
        : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.secondary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                backgroundImage: hasImage ? NetworkImage(user.imageUrl) : null,
                child: !hasImage
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      user.email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    user.phone?.isNotEmpty == true
                        ? user.phone
                        : 'Nomor telepon belum ditambahkan',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right_rounded, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Apakah kamu yakin ingin keluar dari akun?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 28),
                      Row(
                        children: [
                          // CANCEL
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  side: BorderSide(
                                    color: AppColors.text,
                                    width: 0.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                                  side: BorderSide(
                                    color: AppColors.primary,
                                    width: 0.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(fontWeight: FontWeight.w700),
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

            if (shouldLogout != true) return;

            AuthSession.logout();

            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Keluar dari akun Anda',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _showFaqDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) {
  //       return Container(
  //         padding: const EdgeInsets.all(24),
  //         decoration: const BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Container(
  //               width: 50,
  //               height: 5,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade300,
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //             ),

  //             const SizedBox(height: 24),

  //             const Text(
  //               'Bantuan & FAQ',
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //             ),

  //             const SizedBox(height: 24),

  //             _faqItem(
  //               question: 'Bagaimana cara booking layanan?',
  //               answer:
  //                   'Pilih layanan salon, pilih stylist, lalu tentukan jadwal booking.',
  //             ),

  //             _faqItem(
  //               question: 'Bagaimana melihat riwayat booking?',
  //               answer:
  //                   'Masuk ke halaman booking untuk melihat seluruh riwayat reservasi Anda.',
  //             ),

  //             _faqItem(
  //               question: 'Bagaimana mengubah profile?',
  //               answer: 'Masuk ke menu Edit Profile pada halaman akun.',
  //             ),

  //             _faqItem(
  //               question: 'Apakah pembayaran bisa dilakukan di tempat?',
  //               answer: 'Ya, pembayaran dapat dilakukan langsung di salon.',
  //             ),

  //             const SizedBox(height: 20),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _faqItem({required String question, required String answer}) {
  //   return Align(
  //     alignment: Alignment.centerLeft,
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 16),
  //       constraints: const BoxConstraints(maxWidth: 400),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           /// AVATAR FAQ
  //           Container(
  //             height: 38,
  //             width: 38,
  //             decoration: BoxDecoration(
  //               color: AppColors.primary.withOpacity(0.12),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(
  //               Icons.support_agent_rounded,
  //               color: AppColors.primary,
  //               size: 20,
  //             ),
  //           ),

  //           const SizedBox(width: 12),

  //           /// BUBBLE CHAT
  //           Expanded(
  //             child: Container(
  //               padding: const EdgeInsets.all(16),
  //               decoration: BoxDecoration(
  //                 color: AppColors.background,
  //                 borderRadius: BorderRadius.circular(
  //                   20,
  //                 ).copyWith(topLeft: const Radius.circular(6)),
  //                 border: Border.all(color: AppColors.border),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     question,
  //                     style: const TextStyle(
  //                       fontWeight: FontWeight.w700,
  //                       fontSize: 14,
  //                     ),
  //                   ),

  //                   const SizedBox(height: 8),

  //                   Text(
  //                     answer,
  //                     style: TextStyle(
  //                       color: AppColors.mutedText,
  //                       height: 1.5,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
