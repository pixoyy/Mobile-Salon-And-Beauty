import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory StylistReview.fromMap(Map<String, dynamic> map) {
    return StylistReview(
      id: map['id']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      rating: _toDouble(map['rating']),
      comment: map['comment']?.toString() ?? '',
      date: _toDateTime(map['date']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'rating': rating,
      'reviewCount': reviewCount,
      'experienceYears': experienceYears,
      'avatar': photoUrl,
      'skills': jsonEncode(skills),
      'reviews': jsonEncode(reviews.map((review) => review.toMap()).toList()),
      'bio': bio,
    };
  }

  factory StylistModel.fromMap(Map<String, dynamic> map) {
    final String skillsRaw = map['skills']?.toString() ?? '[]';
    final String reviewsRaw = map['reviews']?.toString() ?? '[]';

    List<String> skills = <String>[];
    List<StylistReview> reviews = <StylistReview>[];

    try {
      final decodedSkills = jsonDecode(skillsRaw);
      if (decodedSkills is List) {
        skills = decodedSkills.map((item) => item.toString()).toList(growable: false);
      }
    } catch (_) {
      skills = <String>[];
    }

    try {
      final decodedReviews = jsonDecode(reviewsRaw);
      if (decodedReviews is List) {
        reviews = decodedReviews
            .whereType<Map>()
            .map((item) => StylistReview.fromMap(Map<String, dynamic>.from(item)))
            .toList(growable: false);
      }
    } catch (_) {
      reviews = <StylistReview>[];
    }

    return StylistModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      specialization: map['specialization']?.toString() ?? '',
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount']),
      experienceYears: _toInt(map['experienceYears']),
      photoUrl: map['avatar']?.toString() ?? '',
      skills: skills,
      reviews: reviews,
      bio: map['bio']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
