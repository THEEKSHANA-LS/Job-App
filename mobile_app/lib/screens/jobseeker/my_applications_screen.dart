// lib/screens/jobseeker/my_applications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token ?? '';
      context.read<ApplicationProvider>().fetchMyApplications(token);
    });
  }

  Future<void> _withdraw(ApplicationModel app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Withdraw Application'),
        content: Text('Withdraw your application for "${app.job?.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Withdraw', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token   = context.read<AuthProvider>().user?.token ?? '';
    final success = await context.read<ApplicationProvider>().withdrawApplication(
      token:         token,
      applicationId: app.id,
      jobId:         app.job?.id ?? '',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Application withdrawn' : 'Failed to withdraw'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<ApplicationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Applications')),
      body: appProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appProv.myApplications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('No applications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('Start applying for jobs!', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () {
                    final token = context.read<AuthProvider>().user?.token ?? '';
                    return context.read<ApplicationProvider>().fetchMyApplications(token);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appProv.myApplications.length,
                    itemBuilder: (_, i) {
                      final app = appProv.myApplications[i];
                      return _ApplicationCard(app: app, onWithdraw: () => _withdraw(app));
                    },
                  ),
                ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback     onWithdraw;

  const _ApplicationCard({required this.app, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    final status = app.status;
    final color  = _statusColor(status);

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  app.job?.title ?? 'Unknown Job',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (app.job != null) ...[
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(app.job!.location, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.attach_money_rounded, size: 13, color: AppColors.textSecondary),
                Text('LKR ${app.job!.salary.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
          if (app.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              app.coverLetter,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeAgo(app.createdAt),
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              if (status == 'pending')
                GestureDetector(
                  onTap: onWithdraw,
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':     return AppColors.warning;
      case 'reviewing':   return AppColors.primary;
      case 'shortlisted': return AppColors.accent;
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      default:            return AppColors.textSecondary;
    }
  }

  String _timeAgo(String iso) {
    try {
      final d    = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 0)  return 'Applied ${diff.inDays}d ago';
      if (diff.inHours > 0) return 'Applied ${diff.inHours}h ago';
      return 'Applied just now';
    } catch (_) {
      return '';
    }
  }
}