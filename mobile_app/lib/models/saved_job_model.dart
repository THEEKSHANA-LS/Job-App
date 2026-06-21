// lib/models/saved_job_model.dart

import 'job_model.dart';

class SavedJobModel {
  final String   id;
  final String   createdAt;
  final JobModel? job;

  SavedJobModel({
    required this.id,
    required this.createdAt,
    this.job,
  });

  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    return SavedJobModel(
      id:        json['_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      job: json['job'] is Map<String, dynamic>
          ? JobModel.fromJson(json['job'] as Map<String, dynamic>)
          : null,
    );
  }
}