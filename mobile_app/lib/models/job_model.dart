// lib/models/job_model.dart

class JobModel {
  final String  id;
  final String  title;
  final String  description;
  final String  category;
  final String  jobType;
  final double  salary;
  final String  location;
  final bool    isActive;
  final String  createdAt;
  final EmployerInfo? employer;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.jobType,
    required this.salary,
    required this.location,
    required this.isActive,
    required this.createdAt,
    this.employer,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id:          json['_id'] ?? '',
      title:       json['title'] ?? '',
      description: json['description'] ?? '',
      category:    json['category'] ?? '',
      jobType:     json['jobType'] ?? 'part-time',
      salary:      (json['salary'] as num?)?.toDouble() ?? 0,
      location:    json['location'] ?? '',
      isActive:    json['isActive'] ?? true,
      createdAt:   json['createdAt'] ?? '',
      employer: json['employer'] is Map<String, dynamic>
          ? EmployerInfo.fromJson(json['employer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':         id,
    'title':       title,
    'description': description,
    'category':    category,
    'jobType':     jobType,
    'salary':      salary,
    'location':    location,
    'isActive':    isActive,
    'createdAt':   createdAt,
    'employer':    employer?.toJson(),
  };
}

class EmployerInfo {
  final String  id;
  final String  name;
  final String  email;

  EmployerInfo({required this.id, required this.name, required this.email});

  factory EmployerInfo.fromJson(Map<String, dynamic> json) => EmployerInfo(
    id:    json['_id'] ?? '',
    name:  json['name'] ?? '',
    email: json['email'] ?? '',
  );

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'email': email};
}