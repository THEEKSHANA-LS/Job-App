// lib/providers/application_provider.dart

import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  List<ApplicationModel> _myApplications = [];
  bool    _isLoading    = false;
  String? _errorMessage;

  List<ApplicationModel> get myApplications => _myApplications;
  bool    get isLoading    => _isLoading;
  String? get errorMessage => _errorMessage;

  Set<String> _appliedJobIds = {};
  bool hasApplied(String jobId) => _appliedJobIds.contains(jobId);

  Future<void> fetchMyApplications(String token) async {
    _isLoading = true;
    notifyListeners();

    final result = await ApplicationService.getMyApplications(token);
    if (result['success'] == true) {
      _myApplications = result['applications'] as List<ApplicationModel>;
      _appliedJobIds  = _myApplications
          .where((a) => a.job != null)
          .map((a) => a.job!.id)
          .toSet();
    } else {
      _errorMessage = result['message'] as String?;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> applyForJob({
    required String token,
    required String jobId,
    String coverLetter = '',
  }) async {
    final result = await ApplicationService.applyForJob(
      token:       token,
      jobId:       jobId,
      coverLetter: coverLetter,
    );
    if (result['success'] == true) {
      _appliedJobIds.add(jobId);
      notifyListeners();
      return true;
    }
    _errorMessage = result['message'] as String?;
    return false;
  }

  Future<bool> withdrawApplication({
    required String token,
    required String applicationId,
    required String jobId,
  }) async {
    final result = await ApplicationService.withdrawApplication(
      token:         token,
      applicationId: applicationId,
    );
    if (result['success'] == true) {
      _myApplications.removeWhere((a) => a.id == applicationId);
      _appliedJobIds.remove(jobId);
      notifyListeners();
      return true;
    }
    return false;
  }
}