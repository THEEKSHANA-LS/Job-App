// lib/screens/shared/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().user?.token ?? '';
      context.read<NotificationProvider>().fetchNotifications(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov  = context.watch<NotificationProvider>();
    final token = context.read<AuthProvider>().user?.token ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (prov.unreadCount > 0)
            TextButton(
              onPressed: () => prov.markAllRead(token),
              child: const Text('Mark all read', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      const Text('No notifications yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text("You're all caught up!", style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => prov.fetchNotifications(token),
                  child: ListView.builder(
                    padding:   const EdgeInsets.symmetric(vertical: 8),
                    itemCount: prov.notifications.length,
                    itemBuilder: (_, i) => _NotificationTile(
                      notification: prov.notifications[i],
                      onTap: () => prov.markAsRead(token: token, notificationId: prov.notifications[i].id),
                    ),
                  ),
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback      onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n     = notification;
    final color = _typeColor(n.type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:   const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding:  const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        n.isRead ? AppColors.surface : AppColors.primaryLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isRead ? AppColors.border : AppColors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color:        color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(n.type), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize:   14,
                            color:      AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width:  8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(n.createdAt),
                    style: TextStyle(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'application': return AppColors.primary;
      case 'message':     return AppColors.secondary;
      case 'job':         return AppColors.accent;
      default:            return AppColors.textSecondary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'application': return Icons.assignment_rounded;
      case 'message':     return Icons.chat_bubble_outline_rounded;
      case 'job':         return Icons.work_outline_rounded;
      default:            return Icons.notifications_outlined;
    }
  }

  String _timeAgo(String iso) {
    try {
      final d    = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inDays > 0)   return '${diff.inDays}d ago';
      if (diff.inHours > 0)  return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}