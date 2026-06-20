// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // jobseeker | employer | admin
  final String? phone;
  final String? profileImage;
  final String? cvUrl;
  final List<String> skills;
  final bool isVerified;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.cvUrl,
    this.skills = const [],
    this.isVerified = false,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
      id:           json['_id'] ?? '',
      name:         json['name'] ?? '',
      email:        json['email'] ?? '',
      role:         json['role'] ?? 'jobseeker',
      phone:        json['phone'],
      profileImage: json['profileImage'],
      cvUrl:        json['cvUrl'],
      skills:       List<String>.from(json['skills'] ?? []),
      isVerified:   json['isVerified'] ?? false,
      token:        token,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':          id,
    'name':         name,
    'email':        email,
    'role':         role,
    'phone':        phone,
    'profileImage': profileImage,
    'cvUrl':        cvUrl,
    'skills':       skills,
    'isVerified':   isVerified,
    'token':        token,
  };

  bool get isJobSeeker => role == 'jobseeker';
  bool get isEmployer  => role == 'employer';
  bool get isAdmin     => role == 'admin';
}