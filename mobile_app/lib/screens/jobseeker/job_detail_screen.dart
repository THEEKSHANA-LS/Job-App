// lib/screens/jobseeker/job_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/job_model.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_job_provider.dart';
import '../../widgets/primary_button.dart';
import '../shared/chat_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplying = false;

  Future<void> _showApplyDialog() async {
    final coverCtrl   = TextEditingController();
    bool  submitted   = false;

    await showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      isDismissible:      true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Apply for ${widget.job.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.job.employer?.name ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller:  coverCtrl,
                  maxLines:    5,
                  minLines:    3,
                  decoration:  const InputDecoration(
                    labelText:          'Cover Letter (optional)',
                    hintText:           'Tell the employer why you are a great fit...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width:  double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      submitted = true;
                      Navigator.pop(ctx);
                    },
                    child: const Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final text = coverCtrl.text.trim();
    coverCtrl.dispose();

    // Only proceed if user tapped Submit (not dismissed)
    if (submitted && mounted) {
      await _applyNow(text);
    }
  }

  Future<void> _applyNow(String coverLetter) async {
    setState(() => _isApplying = true);

    final user    = context.read<AuthProvider>().user;
    final token   = user?.token ?? '';
    final success = await context.read<ApplicationProvider>().applyForJob(
      token:       token,
      jobId:       widget.job.id,
      coverLetter: coverLetter,
    );

    setState(() => _isApplying = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '🎉 Application submitted successfully!'
              : context.read<ApplicationProvider>().errorMessage ?? 'Failed to apply. Please try again.',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job          = widget.job;
    final appProv      = context.watch<ApplicationProvider>();
    final alreadyApplied = appProv.hasApplied(job.id);
    final savedProv    = context.watch<SavedJobProvider>();
    final isSaved      = savedProv.isSaved(job.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isSaved ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () async {
              final token = context.read<AuthProvider>().user?.token ?? '';
              if (isSaved) {
                final saved = savedProv.savedJobs.firstWhere(
                  (s) => s.job?.id == job.id,
                  orElse: () => savedProv.savedJobs.first,
                );
                await savedProv.removeSavedJob(
                  token:      token,
                  savedJobId: saved.id,
                  jobId:      job.id,
                );
              } else {
                await savedProv.saveJob(token: token, jobId: job.id);
              }
            },
            tooltip: isSaved ? 'Remove from saved' : 'Save job',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color:        AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.work_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.employer?.name ?? '—',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 8,
                    children: [
                      _InfoBadge(icon: Icons.location_on_outlined,  label: job.location),
                      _InfoBadge(icon: Icons.schedule_rounded,       label: _formatType(job.jobType)),
                      _InfoBadge(icon: Icons.category_outlined,      label: job.category),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Salary', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            'LKR ${job.salary.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize:   20,
                              fontWeight: FontWeight.w700,
                              color:      AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: job.isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job.isActive ? 'Active' : 'Closed',
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                            color: job.isActive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Description ─────────────────────────────────────────
            const Text('Job Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:        AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.border),
              ),
              child: Text(
                job.description,
                style: const TextStyle(
                  fontSize: 14,
                  color:    AppColors.textSecondary,
                  height:   1.6,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Employer info ────────────────────────────────────────
            if (job.employer != null) ...[
              const Text('About the Employer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:       Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius:          22,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.business_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.employer!.name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            job.employer!.email,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100), // space for bottom bar
          ],
        ),
      ),

      // ── Bottom Action Bar ────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message employer
              if (job.employer != null)
                SizedBox(
                  width:  double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId:   job.employer!.id,
                          receiverName: job.employer!.name,
                        ),
                      ),
                    ),
                    icon:  const Icon(Icons.chat_outlined, size: 18),
                    label: Text('Message ${job.employer!.name.split(' ').first}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side:  const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Apply / Already applied
              if (alreadyApplied)
                Container(
                  height:    50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:        AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Application Submitted',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                PrimaryButton(
                  text:      job.isActive ? 'Apply Now' : 'Job Closed',
                  isLoading: _isApplying,
                  onPressed: job.isActive ? _showApplyDialog : null,
                  color:     job.isActive ? null : AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'part-time':  return 'Part-time';
      case 'full-time':  return 'Full-time';
      case 'freelance':  return 'Freelance';
      case 'one-day':    return 'One-day';
      default:           return type;
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}