class StylistReview {
  const StylistReview({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime date;

  StylistReview copyWith({
    String? id,
    String? customerName,
    double? rating,
    String? comment,
    DateTime? date,
  }) {
    return StylistReview(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }
}

class StylistModel {
  const StylistModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.photoUrl,
    required this.skills,
    required this.reviews,
    required this.bio,
  });

  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final String photoUrl;
  final List<String> skills;
  final List<StylistReview> reviews;
  final String bio;

  StylistModel copyWith({
    String? id,
    String? name,
    String? specialization,
    double? rating,
    int? reviewCount,
    int? experienceYears,
    String? photoUrl,
    List<String>? skills,
    List<StylistReview>? reviews,
    String? bio,
  }) {
    return StylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      reviews: reviews ?? this.reviews,
      bio: bio ?? this.bio,
    );
  }
}
