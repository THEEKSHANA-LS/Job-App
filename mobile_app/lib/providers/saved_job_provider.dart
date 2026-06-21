// lib/providers/saved_job_provider.dart

import 'package:flutter/foundation.dart';
import '../models/saved_job_model.dart';
import '../services/saved_job_service.dart';

class SavedJobProvider extends ChangeNotifier {
  List<SavedJobModel> _savedJobs   = [];
  Set<String>         _savedJobIds = {};
  bool    _isLoading    = false;
  String? _errorMessage;

  List<SavedJobModel> get savedJobs    => _savedJobs;
  bool    get isLoading                => _isLoading;
  String? get errorMessage             => _errorMessage;

  bool isSaved(String jobId) => _savedJobIds.contains(jobId);

  Future<void> fetchSavedJobs(String token) async {
    _isLoading = true;
    notifyListeners();

    final result = await SavedJobService.getSavedJobs(token);
    if (result['success'] == true) {
      _savedJobs   = result['savedJobs'] as List<SavedJobModel>;
      _savedJobIds = _savedJobs
          .where((s) => s.job != null)
          .map((s) => s.job!.id)
          .toSet();
    } else {
      _errorMessage = result['message'] as String?;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveJob({required String token, required String jobId}) async {
    final result = await SavedJobService.saveJob(token: token, jobId: jobId);
    if (result['success'] == true) {
      _savedJobIds.add(jobId);
      notifyListeners();
      // Re-fetch to get the full saved job object with populated job data
      fetchSavedJobs(token);
      return true;
    }
    _errorMessage = result['message'] as String?;
    return false;
  }

  Future<bool> removeSavedJob({
    required String token,
    required String savedJobId,
    required String jobId,
  }) async {
    final result = await SavedJobService.removeSavedJob(
      token:      token,
      savedJobId: savedJobId,
    );
    if (result['success'] == true) {
      _savedJobs.removeWhere((s) => s.id == savedJobId);
      _savedJobIds.remove(jobId);
      notifyListeners();
      return true;
    }
    return false;
  }
}