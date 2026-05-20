class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String password;

  final String? imageUrl;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
