import 'package:flutter/material.dart';
import 'package:salon_and_beauty/core/utils/profile_image.dart';

class UserHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;

  const UserHeader({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final avatarImage = profileImageProvider(imageUrl);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
