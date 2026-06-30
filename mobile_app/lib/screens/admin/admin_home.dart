// lib/screens/admin/admin_home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Map<String, dynamic>? _stats;
  List<dynamic>         _users       = [];
  bool _loadingStats = true;
  bool _loadingUsers = true;
  String? _statsError;
  String? _usersError;
  int  _tab = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchUsers();
  }

  Future<void> _fetchStats() async {
    setState(() { _loadingStats = true; _statsError = null; });
    final token    = context.read<AuthProvider>().user?.token ?? '';
    final response = await ApiService.get(AppConstants.adminStatsEndpoint, token: token);
    if (!mounted) return;
    if (response.success && response.data != null) {
      setState(() {
        _stats        = response.data!['data'] as Map<String, dynamic>;
        _loadingStats = false;
      });
    } else {
      setState(() {
        _statsError   = response.message;
        _loadingStats = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    setState(() { _loadingUsers = true; _usersError = null; });
    final token    = context.read<AuthProvider>().user?.token ?? '';
    final response = await ApiService.get(AppConstants.adminUsersEndpoint, token: token);
    if (!mounted) return;
    if (response.success && response.data != null) {
      setState(() {
        _users        = response.data!['data'] as List<dynamic>;
        _loadingUsers = false;
      });
    } else {
      setState(() {
        _usersError   = response.message;
        _loadingUsers = false;
      });
    }
  }

  Future<void> _deleteUser(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:   const Text('Delete User'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:     const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:     const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token    = context.read<AuthProvider>().user?.token ?? '';
    final response = await ApiService.delete(
      '${AppConstants.adminUsersEndpoint}/$userId',
      token: token,
    );

    if (!mounted) return;
    if (response.success) {
      setState(() => _users.removeWhere((u) => u['_id'] == userId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         const Text('User deleted'),
          backgroundColor: AppColors.success,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _fetchStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(response.message.isNotEmpty ? response.message : 'Failed to delete'),
          backgroundColor: AppColors.error,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.logout_rounded),
            color:     AppColors.error,
            tooltip:   'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Tab bar ───────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: Row(
              children: [
                _TabBtn(label: 'Overview', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                _TabBtn(label: 'Users',    selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              ],
            ),
          ),
          Expanded(
            child: _tab == 0 ? _buildOverview() : _buildUsers(),
          ),
        ],
      ),
    );
  }

  // ── Overview tab ──────────────────────────────────────────────────────────
  Widget _buildOverview() {
    if (_loadingStats) return const Center(child: CircularProgressIndicator());

    if (_statsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_statsError!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchStats, child: const Text('Retry')),
          ],
        ),
      );
    }

    final s = _stats ?? {};

    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platform Overview',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text('PodiWeda-LK Admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.admin_panel_settings_rounded, color: Colors.white38, size: 48),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Platform Stats', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount:   2,
              shrinkWrap:       true,
              physics:          const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing:  12,
              childAspectRatio: 1.2,
              children: [
                _StatCard(label: 'Total Users',   value: '${s['totalUsers'] ?? 0}',        color: AppColors.primary,   icon: Icons.people_alt_rounded),
                _StatCard(label: 'Total Jobs',    value: '${s['totalJobs'] ?? 0}',         color: AppColors.secondary, icon: Icons.work_rounded),
                _StatCard(label: 'Applications',  value: '${s['totalApplications'] ?? 0}', color: AppColors.accent,    icon: Icons.assignment_rounded),
                _StatCard(label: 'Active Jobs',   value: '${s['activeJobs'] ?? 0}',        color: AppColors.success,   icon: Icons.check_circle_rounded),
              ],
            ),

            const SizedBox(height: 20),
            const Text('User Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _BreakdownCard(
                    label: 'Job Seekers',
                    value: '${s['jobseekers'] ?? 0}',
                    icon:  Icons.person_search_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BreakdownCard(
                    label: 'Employers',
                    value: '${s['employers'] ?? 0}',
                    icon:  Icons.business_center_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Users tab ─────────────────────────────────────────────────────────────
  Widget _buildUsers() {
    if (_loadingUsers) return const Center(child: CircularProgressIndicator());

    if (_usersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_usersError!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchUsers, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text('No users found', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      child: ListView.builder(
        padding:   const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u    = _users[i] as Map<String, dynamic>;
          final role = u['role'] as String? ?? 'jobseeker';
          final name = u['name'] as String? ?? '?';

          return Container(
            margin:  const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius:          20,
                  backgroundColor: _roleColor(role).withOpacity(0.15),
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w700, color: _roleColor(role)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        u['email'] as String? ?? '',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        _roleColor(role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.w600,
                      color:      _roleColor(role),
                    ),
                  ),
                ),
                if (role != 'admin') ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon:      const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                    onPressed: () => _deleteUser(u['_id'] as String, name),
                    tooltip:   'Delete user',
                    padding:   EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':    return const Color(0xFF7C3AED);
      case 'employer': return AppColors.secondary;
      default:         return AppColors.primary;
    }
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;

  const _BreakdownCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}