class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.memberLevel,
    required this.points,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String memberLevel;
  final int points;

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? memberLevel,
    int? points,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      memberLevel: memberLevel ?? this.memberLevel,
      points: points ?? this.points,
    );
  }
}
