// lib/screens/jobseeker/jobseeker_home.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/screens/jobseeker/saved_job_screen.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/saved_job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/shared/notifications_screen.dart';
import '../../screens/shared/edit_profile_screen.dart';
import '../../screens/shared/conversations_screen.dart';
import '../../widgets/theme_toggle_tile.dart';
import 'job_list_screen.dart';
import 'my_applications_screen.dart';
import 'ai_recommendations_screen.dart';

class JobSeekerHome extends StatefulWidget {
  const JobSeekerHome({super.key});

  @override
  State<JobSeekerHome> createState() => _JobSeekerHomeState();
}

class _JobSeekerHomeState extends State<JobSeekerHome> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token ?? '';
      context.read<ApplicationProvider>().fetchMyApplications(token);
      context.read<SavedJobProvider>().fetchSavedJobs(token);
      context.read<NotificationProvider>().fetchNotifications(token);
    });
  }

  final _screens = const [
    JobListScreen(),
    SavedJobScreen(),
    MyApplicationsScreen(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex:         _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor:       AppColors.surface,
        indicatorColor:        AppColors.primaryLight,
        destinations: [
          const NavigationDestination(
            icon:         Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            label:        'Browse',
          ),
          const NavigationDestination(
            icon:         Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primary),
            label:        'Saved',
          ),
          const NavigationDestination(
            icon:         Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded, color: AppColors.primary),
            label:        'Applied',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label:          Text('$unread'),
              child:          const Icon(Icons.person_outline_rounded),
            ),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
            label:        'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab ─────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user   = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Notifications bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
              if (unread > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar + info ────────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius:          52,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize:   36,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(user?.name ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(user?.email ?? '', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            if (user?.phone != null && user!.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(user.phone!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:        AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Job Seeker',
                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            // ── CV status ────────────────────────────────────────────
            if (user?.cvUrl != null && user!.cvUrl!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:        AppColors.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: 6),
                    Text('CV Uploaded', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ── Skills ───────────────────────────────────────────────
            if (user?.skills.isNotEmpty == true) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8, runSpacing: 6,
                  children: user!.skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color:        AppColors.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(),
            const SizedBox(height: 8),

            // ── Menu items ───────────────────────────────────────────
            _ProfileTile(
              icon:  Icons.edit_outlined,
              label: 'Edit Profile & CV',
              badge: 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _ProfileTile(
              icon:  Icons.auto_awesome_rounded,
              label: 'AI Job Recommendations',
              badge: 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiRecommendationsScreen()),
              ),
            ),
            _ProfileTile(
              icon:  Icons.chat_bubble_outline_rounded,
              label: 'Messages',
              badge: 0,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConversationsScreen()),
              ),
            ),
            _ProfileTile(
              icon:  Icons.notifications_outlined,
              label: 'Notifications',
              badge: unread,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            _ProfileTile(icon: Icons.settings_outlined, label: 'Settings', badge: 0, onTap: () {}),
            const Divider(),
            const ThemeToggleTile(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.read<AuthProvider>().logout(),
                icon:  const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side:    const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final int          badge;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  Icon(icon, color: AppColors.primary),
      title:    Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: badge > 0
          ? Badge(
              label: Text('$badge'),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            )
          : Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      contentPadding: EdgeInsets.zero,
      onTap:          onTap,
    );
  }
}