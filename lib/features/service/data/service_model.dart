class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.price,
    required this.isPopular,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final int durationMinutes;
  final int price;
  final bool isPopular;

  ServiceModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    int? durationMinutes,
    int? price,
    bool? isPopular,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}
