// lib/constants/app_constants.dart

class AppConstants {
  // ─── API ───────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  // Auth
  static const String registerEndpoint  = '/auth/register';
  static const String loginEndpoint     = '/auth/login';

  // Jobs
  static const String jobsEndpoint      = '/jobs';

  // Applications
  static const String applicationsEndpoint    = '/applications';
  static const String myApplicationsEndpoint  = '/applications/my-applications';

  // Saved Jobs
  static const String savedJobsEndpoint = '/saved-jobs';

  // AI
  static const String aiRecommendationsEndpoint = '/ai/recommendations';

  // Notifications
  static const String notificationsEndpoint = '/notifications';

  // Reviews
  static const String reviewsEndpoint = '/reviews';

  // Chat
  static const String chatConversationEndpoint = '/chat/conversation';
  static const String chatMessagesEndpoint     = '/chat/messages';

  // Admin
  static const String adminStatsEndpoint = '/admin/stats';
  static const String adminUsersEndpoint = '/admin/users';

  // ─── Local Storage Keys ────────────────────────────────────────────────────
  static const String tokenKey    = 'auth_token';
  static const String userKey     = 'auth_user';

  // ─── App ──────────────────────────────────────────────────────────────────
  static const String appName = 'PodiWeda-LK';
}