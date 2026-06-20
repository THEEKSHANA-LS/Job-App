// lib/screens/employer/post_job_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _salaryCtrl  = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _category = 'it';
  String _jobType  = 'part-time';
  bool   _isPosting = false;

  static const _categories = [
    'it', 'design', 'writing', 'delivery', 'retail', 'cashier', 'tutor', 'other',
  ];
  static const _jobTypes = [
    'part-time', 'full-time', 'freelance', 'one-day',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _salaryCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _postJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    final token   = context.read<AuthProvider>().user?.token ?? '';
    final success = await context.read<JobProvider>().createJob(
      token:       token,
      title:       _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category:    _category,
      jobType:     _jobType,
      salary:      double.tryParse(_salaryCtrl.text.trim()) ?? 0,
      location:    _locationCtrl.text.trim(),
    );

    setState(() => _isPosting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         const Text('🎉 Job posted successfully!'),
          backgroundColor: AppColors.success,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(context.read<JobProvider>().errorMessage ?? 'Failed to post job'),
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
        title: const Text('Post a Job'),
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title ────────────────────────────────────────────────
              CustomTextField(
                label:      'Job Title',
                hint:       'e.g. Flutter Developer',
                controller: _titleCtrl,
                prefixIcon: Icons.title_rounded,
                validator:  (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────────
              CustomTextField(
                label:      'Job Description',
                hint:       'Describe the role, responsibilities, requirements...',
                controller: _descCtrl,
                maxLines:   5,
                prefixIcon: Icons.description_outlined,
                validator:  (v) => v == null || v.isEmpty ? 'Description is required' : null,
              ),

              const SizedBox(height: 16),

              // ── Salary ───────────────────────────────────────────────
              CustomTextField(
                label:        'Salary (LKR)',
                hint:         'e.g. 50000',
                controller:   _salaryCtrl,
                keyboardType: TextInputType.number,
                prefixIcon:   Icons.payments_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Salary is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ── Location ─────────────────────────────────────────────
              CustomTextField(
                label:      'Location',
                hint:       'e.g. Colombo, Negombo',
                controller: _locationCtrl,
                prefixIcon: Icons.location_on_outlined,
                validator:  (v) => v == null || v.isEmpty ? 'Location is required' : null,
              ),

              const SizedBox(height: 20),

              // ── Category ─────────────────────────────────────────────
              _SectionLabel(label: 'Category'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _categories.map((c) => _SelectChip(
                  label:    c,
                  selected: _category == c,
                  onTap:    () => setState(() => _category = c),
                )).toList(),
              ),

              const SizedBox(height: 20),

              // ── Job Type ─────────────────────────────────────────────
              _SectionLabel(label: 'Job Type'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _jobTypes.map((t) => _SelectChip(
                  label:    t,
                  selected: _jobType == t,
                  onTap:    () => setState(() => _jobType = t),
                )).toList(),
              ),

              const SizedBox(height: 32),

              // ── Submit ───────────────────────────────────────────────
              PrimaryButton(
                text:      'Post Job',
                isLoading: _isPosting,
                onPressed: _postJob,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}