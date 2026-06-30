// lib/widgets/job_card.dart

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/job_model.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final Widget? trailing;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin:  const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:       Colors.black.withOpacity(0.04),
              blurRadius:  8,
              offset:      const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              children: [
                // Category icon
                Container(
                  width:  44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:        _categoryColor(job.category).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _categoryIcon(job.category),
                    color: _categoryColor(job.category),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize:   15,
                          color:      AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.employer?.name ?? 'Unknown Employer',
                        style: TextStyle(
                          fontSize: 12,
                          color:    AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),

            const SizedBox(height: 12),

            // ── Tags row ─────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(
                  icon:  Icons.location_on_outlined,
                  label: job.location,
                  color: AppColors.textSecondary,
                ),
                _Tag(
                  icon:  Icons.schedule_rounded,
                  label: _formatJobType(job.jobType),
                  color: AppColors.primary,
                  bg:    AppColors.primaryLight,
                ),
                _Tag(
                  icon:  Icons.category_outlined,
                  label: job.category,
                  color: _categoryColor(job.category),
                  bg:    _categoryColor(job.category).withOpacity(0.1),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),

            // ── Salary ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LKR ${job.salary.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                    color:      AppColors.secondary,
                  ),
                ),
                Text(
                  _timeAgo(job.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color:    AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatJobType(String type) {
    switch (type) {
      case 'part-time':  return 'Part-time';
      case 'full-time':  return 'Full-time';
      case 'freelance':  return 'Freelance';
      case 'one-day':    return 'One-day';
      default:           return type;
    }
  }

  String _timeAgo(String iso) {
    try {
      final d    = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      return '${diff.inMinutes}m ago';
    } catch (_) {
      return '';
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'it':       return const Color(0xFF6366F1);
      case 'design':   return const Color(0xFFEC4899);
      case 'writing':  return const Color(0xFF14B8A6);
      case 'delivery': return const Color(0xFFF97316);
      case 'retail':   return const Color(0xFF8B5CF6);
      case 'cashier':  return const Color(0xFF06B6D4);
      case 'tutor':    return const Color(0xFFEAB308);
      default:         return AppColors.primary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'it':       return Icons.computer_rounded;
      case 'design':   return Icons.brush_rounded;
      case 'writing':  return Icons.edit_note_rounded;
      case 'delivery': return Icons.delivery_dining_rounded;
      case 'retail':   return Icons.store_rounded;
      case 'cashier':  return Icons.point_of_sale_rounded;
      case 'tutor':    return Icons.school_rounded;
      default:         return Icons.work_outline_rounded;
    }
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final Color?   bg;

  const _Tag({required this.icon, required this.label, required this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:        bg ?? AppColors.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}