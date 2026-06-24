// lib/screens/jobseeker/ai_recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../widgets/job_card.dart';
import 'job_detail_screen.dart';

class AiRecommendationsScreen extends StatefulWidget {
  const AiRecommendationsScreen({super.key});

  @override
  State<AiRecommendationsScreen> createState() => _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState extends State<AiRecommendationsScreen> {
  List<JobModel> _jobs    = [];
  String?        _rawText;
  bool           _loading = false;
  String?        _error;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() { _loading = true; _error = null; _rawText = null; _jobs = []; });

    final token  = context.read<AuthProvider>().user?.token ?? '';
    final result = await AiService.getRecommendations(token);

    if (!mounted) return;

    if (result['success'] == true) {
      final jobs = result['jobs'] as List<JobModel>;
      final raw  = result['raw'];
      setState(() {
        _jobs    = jobs;
        _rawText = jobs.isEmpty && raw != null ? raw.toString() : null;
        _loading = false;
      });
    } else {
      setState(() {
        _error   = result['message'] as String? ?? 'Failed to get recommendations';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Recommendations'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.refresh_rounded),
            tooltip:   'Refresh',
            onPressed: _loading ? null : _fetchRecommendations,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? _buildShimmer()
                : _error != null
                    ? _buildError()
                    : _jobs.isEmpty && _rawText != null
                        ? _buildRawResponse()
                        : _jobs.isEmpty
                            ? _buildNoSkills()
                            : _buildJobList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = context.watch<AuthProvider>().user;
    return Container(
      margin:  const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Powered Matches',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.skills.isNotEmpty == true
                      ? 'Based on: ${user!.skills.take(3).join(', ')}${user.skills.length > 3 ? '...' : ''}'
                      : 'Add skills in profile to improve matches',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding:   const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        margin:  const EdgeInsets.only(bottom: 12),
        height:  140,
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border),
        ),
        child: const _ShimmerBox(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Could not load recommendations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchRecommendations,
              icon:      const Icon(Icons.refresh_rounded),
              label:     const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSkills() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text('No Recommendations Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Add skills to your profile so our AI can find the best matching jobs for you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon:  const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawResponse() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: AppColors.border),
        ),
        child: Text(
          _rawText ?? '',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return RefreshIndicator(
      onRefresh: _fetchRecommendations,
      child: ListView.builder(
        padding:   const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: _jobs.length,
        itemBuilder: (_, i) {
          final job = _jobs[i];
          return Stack(
            children: [
              JobCard(
                job:   job,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
                ),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 10),
                      SizedBox(width: 3),
                      Text('AI Match',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox();

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end:   Alignment(_anim.value,     0),
            colors: const [AppColors.background, AppColors.divider, AppColors.background],
          ),
        ),
      ),
    );
  }
}