import 'package:flutter/material.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/core/theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final user = AuthSession.currentUser;

    nameController = TextEditingController(text: user?.name ?? '');

    emailController = TextEditingController(text: user?.email ?? '');

    phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSession.currentUser;

    final hasImage =
        user?.imageUrl != null && user!.imageUrl.toString().isNotEmpty;

    final initial = user?.name.toString().isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              _buildHeader(context, hasImage, initial, user?.imageUrl),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInputCard(
                      title: 'Nama Lengkap',
                      icon: Icons.person_outline_rounded,
                      controller: nameController,
                    ),

                    const SizedBox(height: 18),

                    _buildInputCard(
                      title: 'Email',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),

                    const SizedBox(height: 18),

                    _buildInputCard(
                      title: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      controller: phoneController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          // color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                final updatedUser = AuthSession.currentUser?.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                );

                if (updatedUser != null) {
                  AuthSession.currentUser = updatedUser;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: const Text('Profile berhasil diperbarui'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );

                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.save_as_outlined, size: 24),
              label: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool hasImage,
    String initial,
    String? imageUrl,
  ) {

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
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                const Expanded(
                  child: Text(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(width: 42),
              ],
            ),

            const SizedBox(height: 20),

            Stack(
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
                    backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
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

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),


            const Text(
              'Ubah informasi profile Anda',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),

          const SizedBox(height: 14),

          TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.background,
              hintText: title,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
