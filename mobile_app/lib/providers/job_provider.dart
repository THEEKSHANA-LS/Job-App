// lib/providers/job_provider.dart

import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

enum JobsStatus { initial, loading, loaded, error }

class JobProvider extends ChangeNotifier {
  JobsStatus       _status      = JobsStatus.initial;
  List<JobModel>   _jobs        = [];
  List<JobModel>   _filtered    = [];
  String?          _errorMessage;

  // Active filter values
  String _filterCategory = '';
  String _filterLocation = '';
  String _filterJobType  = '';
  String _searchQuery    = '';

  JobsStatus     get status        => _status;
  List<JobModel> get jobs          => _filtered;
  String?        get errorMessage  => _errorMessage;
  bool           get isLoading     => _status == JobsStatus.loading;

  String get filterCategory => _filterCategory;
  String get filterJobType  => _filterJobType;
  String get filterLocation => _filterLocation;
  String get searchQuery    => _searchQuery;

  // ─── Fetch from backend ───────────────────────────────────────────────
  Future<void> fetchJobs({
    String category = '',
    String location = '',
    String jobType  = '',
  }) async {
    _status = JobsStatus.loading;
    _filterCategory = category;
    _filterLocation = location;
    _filterJobType  = jobType;
    notifyListeners();

    final result = await JobService.getAllJobs(
      category: category.isEmpty ? null : category,
      location: location.isEmpty ? null : location,
      jobType:  jobType.isEmpty  ? null : jobType,
    );

    if (result['success'] == true) {
      _jobs     = result['jobs'] as List<JobModel>;
      _applySearch();
      _status   = JobsStatus.loaded;
    } else {
      _errorMessage = result['message'] as String?;
      _status       = JobsStatus.error;
    }
    notifyListeners();
  }

  // ─── Client-side search on loaded jobs ───────────────────────────────
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_jobs);
    } else {
      _filtered = _jobs.where((j) {
        return j.title.toLowerCase().contains(_searchQuery) ||
               j.location.toLowerCase().contains(_searchQuery) ||
               j.category.toLowerCase().contains(_searchQuery) ||
               j.description.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  // ─── Employer: create a job ───────────────────────────────────────────
  Future<bool> createJob({
    required String token,
    required String title,
    required String description,
    required String category,
    required String jobType,
    required double salary,
    required String location,
  }) async {
    final result = await JobService.createJob(
      token:       token,
      title:       title,
      description: description,
      category:    category,
      jobType:     jobType,
      salary:      salary,
      location:    location,
    );
    if (result['success'] == true) {
      _jobs.insert(0, result['job'] as JobModel);
      _applySearch();
      notifyListeners();
      return true;
    }
    _errorMessage = result['message'] as String?;
    return false;
  }

  // ─── Employer: delete a job ───────────────────────────────────────────
  Future<bool> deleteJob({required String token, required String jobId}) async {
    final result = await JobService.deleteJob(token: token, jobId: jobId);
    if (result['success'] == true) {
      _jobs.removeWhere((j) => j.id == jobId);
      _applySearch();
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearFilters() {
    _filterCategory = '';
    _filterLocation = '';
    _filterJobType  = '';
    _searchQuery    = '';
    fetchJobs();
  }
}