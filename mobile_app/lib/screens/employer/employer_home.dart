// lib/screens/employer/employer_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/shared/notifications_screen.dart';
import '../../screens/shared/conversations_screen.dart';
import '../../widgets/theme_toggle_tile.dart';
import 'my_jobs_screen.dart';
import 'post_job_screen.dart';

class EmployerHome extends StatefulWidget {
  const EmployerHome({super.key});

  @override
  State<EmployerHome> createState() => _EmployerHomeState();
}

class _EmployerHomeState extends State<EmployerHome> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token ?? '';
      context.read<NotificationProvider>().fetchNotifications(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MyJobsScreen(),
          // Key forces PostJobScreen to rebuild fresh each time tab is visited
          _PostJobTab(),
          ConversationsScreen(),
          _EmployerProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex:         _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor:       AppColors.surface,
        indicatorColor:        AppColors.primaryLight,
        destinations: [
          const NavigationDestination(
            icon:         Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded, color: AppColors.primary),
            label:        'My Jobs',
          ),
          const NavigationDestination(
            icon:         Icon(Icons.add_circle_outline_rounded),
            selectedIcon: Icon(Icons.add_circle_rounded, color: AppColors.primary),
            label:        'Post Job',
          ),
          const NavigationDestination(
            icon:         Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
            label:        'Messages',
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

// ── Post Job Tab wrapper — using a PageStorageKey so the form state
//   is preserved while the tab is active but can be reset on demand ─────────
class _PostJobTab extends StatelessWidget {
  const _PostJobTab();

  @override
  Widget build(BuildContext context) {
    return const PostJobScreen(isTab: true);
  }
}

// ── Employer Profile Tab ───────────────────────────────────────────────────
class _EmployerProfileTab extends StatelessWidget {
  const _EmployerProfileTab();

  @override
  Widget build(BuildContext context) {
    final user   = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
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
                        color:      Colors.white,
                        fontSize:   9,
                        fontWeight: FontWeight.w700,
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
            // Avatar
            CircleAvatar(
              radius:          44,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize:   32,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color:        const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Employer',
                style: TextStyle(
                  color:      AppColors.secondary,
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            _Tile(
              icon:  Icons.notifications_outlined,
              label: 'Notifications',
              badge: unread,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            _Tile(icon: Icons.rate_review_outlined, label: 'Reviews',  badge: 0, onTap: () {}),
            _Tile(icon: Icons.settings_outlined,    label: 'Settings', badge: 0, onTap: () {}),
            const Divider(),
            const ThemeToggleTile(),
            const SizedBox(height: 32),
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
                  shape:   RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final int          badge;
  final VoidCallback onTap;

  const _Tile({
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