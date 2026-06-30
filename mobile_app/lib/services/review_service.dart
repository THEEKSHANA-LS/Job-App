// lib/services/review_service.dart

import '../constants/app_constants.dart';
import '../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  static Future<Map<String, dynamic>> getEmployerReviews(String employerId) async {
    final response = await ApiService.get(
      '${AppConstants.reviewsEndpoint}/employer/$employerId',
    );
    if (response.success && response.data != null) {
      final list    = response.data!['data'] as List<dynamic>;
      final reviews = list.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>)).toList();
      return {'success': true, 'reviews': reviews};
    }
    return {'success': false, 'message': response.message};
  }

  static Future<Map<String, dynamic>> createReview({
    required String token,
    required String employerId,
    required int    rating,
    String comment = '',
  }) async {
    final response = await ApiService.post(
      AppConstants.reviewsEndpoint,
      token: token,
      body:  {'employerId': employerId, 'rating': rating, 'comment': comment},
    );
    return {'success': response.success, 'message': response.message};
  }

  static Future<Map<String, dynamic>> deleteReview({
    required String token,
    required String reviewId,
  }) async {
    final response = await ApiService.delete(
      '${AppConstants.reviewsEndpoint}/$reviewId',
      token: token,
    );
    return {'success': response.success, 'message': response.message};
  }
}