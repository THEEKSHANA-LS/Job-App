// lib/screens/employer/applicants_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';

class ApplicantsScreen extends StatefulWidget {
  final JobModel job;
  const ApplicantsScreen({super.key, required this.job});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  List<ApplicationModel> _applications = [];
  bool    _loading = true;
  String? _error;

  static const _statuses = [
    'pending', 'reviewing', 'shortlisted', 'accepted', 'rejected',
  ];

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() { _loading = true; _error = null; });

    final token  = context.read<AuthProvider>().user?.token ?? '';
    final result = await ApplicationService.getApplicantsForJob(
      token: token,
      jobId: widget.job.id,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _applications = result['applications'] as List<ApplicationModel>;
        _loading      = false;
      });
    } else {
      setState(() {
        _error   = result['message'] as String? ?? 'Failed to load applicants';
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(ApplicationModel app, String newStatus) async {
    final token  = context.read<AuthProvider>().user?.token ?? '';
    final result = await ApplicationService.updateStatus(
      token:         token,
      applicationId: app.id,
      status:        newStatus,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        final idx = _applications.indexWhere((a) => a.id == app.id);
        if (idx != -1) {
          _applications[idx] = ApplicationModel(
            id:          app.id,
            status:      newStatus,
            coverLetter: app.coverLetter,
            createdAt:   app.createdAt,
            job:         app.job,
            applicant:   app.applicant,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('Status updated to "$newStatus"'),
          backgroundColor: AppColors.success,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         const Text('Failed to update status'),
          backgroundColor: AppColors.error,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showStatusPicker(ApplicationModel app) {
    showModalBottomSheet(
      context:            context,
      backgroundColor:    Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize:      MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Update — ${app.applicant?.name ?? "Applicant"}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Current: ${app.status}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ..._statuses.map((s) {
              final isCurrent = app.status == s;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius:          16,
                  backgroundColor: _statusColor(s).withOpacity(0.15),
                  child: Icon(_statusIcon(s), size: 14, color: _statusColor(s)),
                ),
                title: Text(
                  s[0].toUpperCase() + s.substring(1),
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    color:      isCurrent ? _statusColor(s) : AppColors.textPrimary,
                  ),
                ),
                trailing: isCurrent
                    ? Icon(Icons.check_rounded, color: _statusColor(s))
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (!isCurrent) _updateStatus(app, s);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Applicants', style: TextStyle(fontSize: 16)),
            Text(
              widget.job.title,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          if (_applications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_applications.length}',
                    style: const TextStyle(
                      color:      AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize:   13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchApplicants, child: const Text('Retry')),
                    ],
                  ),
                )
              : _applications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded, size: 64, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text('No applicants yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text('Applications will appear here', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchApplicants,
                      child: ListView.builder(
                        padding:   const EdgeInsets.all(16),
                        itemCount: _applications.length,
                        itemBuilder: (_, i) => _ApplicantCard(
                          app:            _applications[i],
                          onStatusChange: () => _showStatusPicker(_applications[i]),
                        ),
                      ),
                    ),
    );
  }

  Color    _statusColor(String s) {
    switch (s) {
      case 'pending':     return AppColors.warning;
      case 'reviewing':   return AppColors.primary;
      case 'shortlisted': return AppColors.accent;
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      default:            return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':     return Icons.hourglass_empty_rounded;
      case 'reviewing':   return Icons.visibility_outlined;
      case 'shortlisted': return Icons.star_outline_rounded;
      case 'accepted':    return Icons.check_circle_outline_rounded;
      case 'rejected':    return Icons.cancel_outlined;
      default:            return Icons.circle_outlined;
    }
  }
}

// ── Applicant Card ─────────────────────────────────────────────────────────
class _ApplicantCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback     onStatusChange;

  const _ApplicantCard({required this.app, required this.onStatusChange});

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':     return AppColors.warning;
      case 'reviewing':   return AppColors.primary;
      case 'shortlisted': return AppColors.accent;
      case 'accepted':    return AppColors.success;
      case 'rejected':    return AppColors.error;
      default:            return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicant = app.applicant;
    final color     = _statusColor(app.status);

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
          // ── Applicant info ────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius:          22,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  applicant?.name.isNotEmpty == true
                      ? applicant!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      applicant?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (applicant?.phone != null && applicant!.phone!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            applicant.phone!,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app.status[0].toUpperCase() + app.status.substring(1),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),

          // ── Cover letter ──────────────────────────────────────
          if (app.coverLetter.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                app.coverLetter,
                style: const TextStyle(
                  fontSize: 12,
                  color:    AppColors.textSecondary,
                  height:   1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _timeAgo(app.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              GestureDetector(
                onTap: onStatusChange,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:        AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Update Status',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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