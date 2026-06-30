// lib/screens/jobseeker/job_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/job_provider.dart';

import '../../widgets/job_card.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _searchCtrl = TextEditingController();

  static const _categories = [
    'All', 'it', 'design', 'writing', 'delivery', 'retail', 'cashier', 'tutor', 'other',
  ];
  static const _jobTypes = [
    'All', 'part-time', 'full-time', 'freelance', 'one-day',
  ];

  String _selectedCategory = 'All';
  String _selectedJobType  = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<JobProvider>().fetchJobs(
      category: _selectedCategory == 'All' ? '' : _selectedCategory,
      jobType:  _selectedJobType  == 'All' ? '' : _selectedJobType,
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        selectedCategory: _selectedCategory,
        selectedJobType:  _selectedJobType,
        categories: _categories,
        jobTypes:   _jobTypes,
        onApply: (cat, type) {
          setState(() {
            _selectedCategory = cat;
            _selectedJobType  = type;
          });
          _applyFilters();
        },
        onClear: () {
          setState(() {
            _selectedCategory = 'All';
            _selectedJobType  = 'All';
          });
          context.read<JobProvider>().clearFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final hasFilters  = _selectedCategory != 'All' || _selectedJobType != 'All';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _showFilterSheet,
              ),
              if (hasFilters)
                Positioned(
                  right: 10,
                  top:   10,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged:  (v) => context.read<JobProvider>().search(v),
              decoration: InputDecoration(
                hintText:    'Search jobs, location, category...',
                prefixIcon:  const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<JobProvider>().search('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // ── Active filter chips ─────────────────────────────────────────
          if (hasFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  if (_selectedCategory != 'All')
                    _FilterChip(
                      label: _selectedCategory,
                      onRemove: () {
                        setState(() => _selectedCategory = 'All');
                        _applyFilters();
                      },
                    ),
                  if (_selectedJobType != 'All') ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: _selectedJobType,
                      onRemove: () {
                        setState(() => _selectedJobType = 'All');
                        _applyFilters();
                      },
                    ),
                  ],
                ],
              ),
            ),

          // ── Job List ────────────────────────────────────────────────────
          Expanded(
            child: jobProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : jobProvider.jobs.isEmpty
                    ? _EmptyState(
                        hasFilters: hasFilters,
                        onClear: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _selectedJobType  = 'All';
                            _searchCtrl.clear();
                          });
                          context.read<JobProvider>().clearFilters();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<JobProvider>().fetchJobs(
                          category: _selectedCategory == 'All' ? '' : _selectedCategory,
                          jobType:  _selectedJobType  == 'All' ? '' : _selectedJobType,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: jobProvider.jobs.length,
                          itemBuilder: (_, i) {
                            final job = jobProvider.jobs[i];
                            return JobCard(
                              job:   job,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(job: job),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String       label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool         hasFilters;
  final VoidCallback onClear;

  const _EmptyState({required this.hasFilters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off_rounded : Icons.work_off_rounded,
              size:  64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No jobs match your filters' : 'No jobs available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters ? 'Try adjusting your search criteria' : 'Check back later for new opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onClear,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final String         selectedCategory;
  final String         selectedJobType;
  final List<String>   categories;
  final List<String>   jobTypes;
  final Function(String, String) onApply;
  final VoidCallback   onClear;

  const _FilterSheet({
    required this.selectedCategory,
    required this.selectedJobType,
    required this.categories,
    required this.jobTypes,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _cat;
  late String _type;

  @override
  void initState() {
    super.initState();
    _cat  = widget.selectedCategory;
    _type = widget.selectedJobType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onClear();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.categories.map((c) => _ChoiceChip(
              label:    c,
              selected: _cat == c,
              onTap:    () => setState(() => _cat = c),
            )).toList(),
          ),

          const SizedBox(height: 20),
          const Text('Job Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.jobTypes.map((t) => _ChoiceChip(
              label:    t,
              selected: _type == t,
              onTap:    () => setState(() => _type = t),
            )).toList(),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(_cat, _type);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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