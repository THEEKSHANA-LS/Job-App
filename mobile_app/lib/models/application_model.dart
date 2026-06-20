// lib/models/application_model.dart

import 'job_model.dart';

class ApplicationModel {
  final String    id;
  final String    status; // pending | reviewing | shortlisted | accepted | rejected
  final String    coverLetter;
  final String    createdAt;
  final JobModel? job;
  final ApplicantInfo? applicant;

  ApplicationModel({
    required this.id,
    required this.status,
    required this.coverLetter,
    required this.createdAt,
    this.job,
    this.applicant,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id:          json['_id'] ?? '',
      status:      json['status'] ?? 'pending',
      coverLetter: json['coverLetter'] ?? '',
      createdAt:   json['createdAt'] ?? '',
      job: json['job'] is Map<String, dynamic>
          ? JobModel.fromJson(json['job'] as Map<String, dynamic>)
          : null,
      applicant: json['applicant'] is Map<String, dynamic>
          ? ApplicantInfo.fromJson(json['applicant'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApplicantInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;

  ApplicantInfo({required this.id, required this.name, required this.email, this.phone});

  factory ApplicantInfo.fromJson(Map<String, dynamic> json) => ApplicantInfo(
    id:    json['_id'] ?? '',
    name:  json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'],
  );
}