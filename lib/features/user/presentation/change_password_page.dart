import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/core/theme/app_colors.dart';
import 'package:salon_and_beauty/features/user/bloc/user_bloc.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();

    _newPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final password = _newPasswordController.text;

    if (password.isEmpty) return 0;

    double strength = 0;

    if (password.length >= 6) {
      strength += 0.25;
    }

    if (password.length >= 8) {
      strength += 0.25;
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength += 0.25;
    }

    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength += 0.25;
    }

    return strength.clamp(0, 1);
  }

  Color _strengthColor(double strength) {
    if (strength <= 0.25) {
      return Colors.red;
    }

    if (strength <= 0.5) {
      return Colors.orange;
    }

    if (strength <= 0.75) {
      return Colors.amber;
    }

    return Colors.green;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitChangePassword() {
    final oldPassword =
        _oldPasswordController.text.trim();

    final newPassword =
        _newPasswordController.text.trim();

    final confirmPassword =
        _confirmPasswordController.text.trim();

    /// VALIDASI
    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Semua field wajib diisi');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Password minimal 6 karakter');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Konfirmasi password tidak cocok');
      return;
    }

    context.read<UserBloc>().add(
          ChangePasswordEvent(
            oldPassword: oldPassword,
            newPassword: newPassword,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) async {
        if (state is ChangePasswordLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }

        if (state is ChangePasswordSuccess) {
          Navigator.pop(context);

          _showMessage('Password berhasil diubah');

          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          if (context.mounted) {
            Navigator.pop(context, true);
          }
        }

        if (state is ChangePasswordError) {
          Navigator.pop(context);

          _showMessage(
            state.message.replaceAll(
              'Exception: ',
              '',
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Ubah Password',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.text,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPasswordField(
                  title: 'Password Lama',
                  hint: 'Masukkan password lama',
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  onToggle: () {
                    setState(() {
                      _obscureOld = !_obscureOld;
                    });
                  },
                ),

                const SizedBox(height: 20),

                _buildPasswordField(
                  title: 'Password Baru',
                  hint: 'Masukkan password baru',
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  onToggle: () {
                    setState(() {
                      _obscureNew = !_obscureNew;
                    });
                  },
                ),

                const SizedBox(height: 20),

                _buildPasswordField(
                  title: 'Konfirmasi Password Baru',
                  hint: 'Konfirmasi password baru',
                  controller:
                      _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  onToggle: () {
                    setState(() {
                      _obscureConfirm =
                          !_obscureConfirm;
                    });
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kekuatan Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Minimal 6 karakter',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: List.generate(
                    4,
                    (index) {
                      final active =
                          strength >=
                              ((index + 1) * 0.25);

                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: EdgeInsets.only(
                            right:
                                index == 3 ? 0 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? _strengthColor(
                                    strength,
                                  )
                                : Colors.grey
                                    .shade300,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),
                    onPressed:
                        _submitChangePassword,
                    child: const Text(
                      'Simpan Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons
                        .visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade600,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}