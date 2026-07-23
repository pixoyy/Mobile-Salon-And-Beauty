class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.password,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? password;

  final String? imageUrl;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? imageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'imageUrl': imageUrl,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image_url': imageUrl,
    };
  }

  static UserModel fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
      email: m['email']?.toString() ?? '',
      phone: m['phone']?.toString() ?? '',
      password: m['password']?.toString() ?? '',
      imageUrl: m['imageUrl']?.toString(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      password: json['password']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
