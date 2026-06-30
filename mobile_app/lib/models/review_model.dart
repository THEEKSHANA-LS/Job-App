// lib/models/review_model.dart

class ReviewModel {
  final String id;
  final int    rating;
  final String comment;
  final String createdAt;
  final ReviewerInfo? reviewer;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reviewer,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:        json['_id'] ?? '',
      rating:    (json['rating'] as num?)?.toInt() ?? 0,
      comment:   json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      reviewer: json['reviewer'] is Map<String, dynamic>
          ? ReviewerInfo.fromJson(json['reviewer'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReviewerInfo {
  final String  id;
  final String  name;
  final String? profileImage;

  ReviewerInfo({required this.id, required this.name, this.profileImage});

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) => ReviewerInfo(
    id:           json['_id'] ?? '',
    name:         json['name'] ?? '',
    profileImage: json['profileImage'],
  );
}