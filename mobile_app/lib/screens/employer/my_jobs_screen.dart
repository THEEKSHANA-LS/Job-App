// lib/screens/employer/my_jobs_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile_app/screens/employer/applicants_screen.dart';
import 'package:mobile_app/screens/employer/post_job_screen.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../services/job_service.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<JobModel> _myJobs  = [];
  bool           _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  Future<void> _fetchMyJobs() async {
    setState(() => _loading = true);
    final token  = context.read<AuthProvider>().user?.token ?? '';
    final userId = context.read<AuthProvider>().user?.id ?? '';

    // Fetch all jobs then filter by employer id
    final result = await JobService.getAllJobs();
    if (result['success'] == true) {
      final all = result['jobs'] as List<JobModel>;
      setState(() {
        _myJobs  = all.where((j) => j.employer?.id == userId).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteJob(JobModel job) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Job'),
        content: Text('Delete "${job.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final token   = context.read<AuthProvider>().user?.token ?? '';
    final success = await context.read<JobProvider>().deleteJob(
      token: token,
      jobId: job.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(success ? 'Job deleted' : 'Failed to delete'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (success) _fetchMyJobs();
    }
  }

  Future<void> _toggleActive(JobModel job) async {
    final token = context.read<AuthProvider>().user?.token ?? '';
    final result = await JobService.updateJob(
      token: token,
      jobId: job.id,
      data:  {'isActive': !job.isActive},
    );
    if (result['success'] == true && mounted) _fetchMyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Job Listings'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.add_circle_outline_rounded),
            color:     AppColors.primary,
            tooltip:   'Post a Job',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
              _fetchMyJobs();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostJobScreen()),
          );
          _fetchMyJobs();
        },
        backgroundColor: AppColors.primary,
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Post Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _myJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_off_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('No jobs posted yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('Tap + to post your first job', style: TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen()));
                          _fetchMyJobs();
                        },
                        icon:  const Icon(Icons.add_rounded),
                        label: const Text('Post a Job'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMyJobs,
                  child: ListView.builder(
                    padding:   const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _myJobs.length,
                    itemBuilder: (_, i) => _EmployerJobCard(
                      job:          _myJobs[i],
                      onDelete:     () => _deleteJob(_myJobs[i]),
                      onToggle:     () => _toggleActive(_myJobs[i]),
                      onApplicants: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplicantsScreen(job: _myJobs[i]),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ── Employer Job Card ──────────────────────────────────────────────────────
class _EmployerJobCard extends StatelessWidget {
  final JobModel     job;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onApplicants;

  const _EmployerJobCard({
    required this.job,
    required this.onDelete,
    required this.onToggle,
    required this.onApplicants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              // Active toggle
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.isActive
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        job.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size:  12,
                        color: job.isActive ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.isActive ? 'Active' : 'Closed',
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                          color: job.isActive ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Meta ───────────────────────────────────────────────────
          Wrap(
            spacing: 12,
            children: [
              _Meta(icon: Icons.location_on_outlined,   text: job.location),
              _Meta(icon: Icons.schedule_rounded,        text: job.jobType),
              _Meta(icon: Icons.payments_outlined,       text: 'LKR ${job.salary.toStringAsFixed(0)}'),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),

          // ── Actions row ────────────────────────────────────────────
          Row(
            children: [
              // View Applicants
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onApplicants,
                  icon:  const Icon(Icons.people_outline_rounded, size: 16),
                  label: const Text('Applicants', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side:    const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              OutlinedButton.icon(
                onPressed: onDelete,
                icon:  const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Delete', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side:    const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String   text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}