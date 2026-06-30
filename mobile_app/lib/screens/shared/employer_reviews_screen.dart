// lib/screens/shared/employer_reviews_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/review_service.dart';
import '../../widgets/primary_button.dart';

class EmployerReviewsScreen extends StatefulWidget {
  final String employerId;
  final String employerName;

  const EmployerReviewsScreen({
    super.key,
    required this.employerId,
    required this.employerName,
  });

  @override
  State<EmployerReviewsScreen> createState() => _EmployerReviewsScreenState();
}

class _EmployerReviewsScreenState extends State<EmployerReviewsScreen> {
  List<ReviewModel> _reviews     = [];
  bool              _loading     = true;
  double            _avgRating   = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _loading = true);
    final result = await ReviewService.getEmployerReviews(widget.employerId);
    if (result['success'] == true) {
      final reviews = result['reviews'] as List<ReviewModel>;
      double avg = 0;
      if (reviews.isNotEmpty) {
        avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
      }
      setState(() {
        _reviews   = reviews;
        _avgRating = avg;
      });
    }
    setState(() => _loading = false);
  }

  void _showWriteReview() {
    final user = context.read<AuthProvider>().user;
    if (user == null || !user.isJobSeeker) return;

    int    selectedRating = 5;
    final  commentCtrl    = TextEditingController();
    bool   isSubmitting   = false;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
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
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Review ${widget.employerName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                // Star rating
                const Text('Your Rating', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedRating = star),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.accent,
                          size:  36,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Comment
                TextField(
                  controller: commentCtrl,
                  maxLines:   4,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText:  'Share your experience working with this employer...',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 20),

                PrimaryButton(
                  text:      'Submit Review',
                  isLoading: isSubmitting,
                  onPressed: () async {
                    setLocal(() => isSubmitting = true);
                    final token  = context.read<AuthProvider>().user?.token ?? '';
                    final result = await ReviewService.createReview(
                      token:      token,
                      employerId: widget.employerId,
                      rating:     selectedRating,
                      comment:    commentCtrl.text.trim(),
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    commentCtrl.dispose();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:         Text(result['success'] == true ? 'Review submitted!' : result['message'] ?? 'Failed'),
                        backgroundColor: result['success'] == true ? AppColors.success : AppColors.error,
                        behavior:        SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    if (result['success'] == true) _fetchReviews();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final token   = context.read<AuthProvider>().user?.token ?? '';
    final result  = await ReviewService.deleteReview(token: token, reviewId: review.id);
    if (result['success'] == true) {
      _fetchReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         const Text('Review deleted'),
            backgroundColor: AppColors.success,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.employerName} Reviews'),
        actions: [
          if (user?.isJobSeeker == true)
            TextButton.icon(
              onPressed: _showWriteReview,
              icon:  const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Write Review'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Summary card ────────────────────────────────────
                if (_reviews.isNotEmpty)
                  Container(
                    margin:  const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:        AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border:       Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              _avgRating.toStringAsFixed(1),
                              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < _avgRating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.accent,
                                size:  16,
                              )),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: List.generate(5, (i) {
                              final star  = 5 - i;
                              final count = _reviews.where((r) => r.rating == star).length;
                              final pct   = _reviews.isEmpty ? 0.0 : count / _reviews.length;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text('$star', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star_rounded, size: 10, color: AppColors.accent),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value:           pct,
                                          backgroundColor: AppColors.divider,
                                          valueColor:      const AlwaysStoppedAnimation(AppColors.accent),
                                          minHeight:       6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('$count', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Review list ─────────────────────────────────────
                Expanded(
                  child: _reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Icon(Icons.star_outline_rounded, size: 64, color: AppColors.textHint),
                              const SizedBox(height: 16),
                              const Text('No reviews yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              if (user?.isJobSeeker == true) ...[
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _showWriteReview,
                                  child: const Text('Be the first to review'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:   const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _reviews.length,
                          itemBuilder: (_, i) => _ReviewCard(
                            review:   _reviews[i],
                            currentUserId: user?.id ?? '',
                            onDelete: () => _deleteReview(_reviews[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel  review;
  final String       currentUserId;
  final VoidCallback onDelete;

  const _ReviewCard({required this.review, required this.currentUserId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOwner = review.reviewer?.id == currentUserId;

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
              CircleAvatar(
                radius:          18,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  review.reviewer?.name.isNotEmpty == true
                      ? review.reviewer!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.name ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.accent,
                          size:  13,
                        )),
                        const SizedBox(width: 6),
                        Text(
                          _timeAgo(review.createdAt),
                          style: TextStyle(fontSize: 11, color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwner)
                IconButton(
                  icon:      const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                  onPressed: onDelete,
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    try {
      final d    = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
      if (diff.inDays > 0)  return '${diff.inDays}d ago';
      return '${diff.inHours}h ago';
    } catch (_) {
      return '';
    }
  }
}