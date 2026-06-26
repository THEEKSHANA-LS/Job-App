// lib/screens/shared/conversations_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

/// A simple start-chat dialog — type a receiver user ID to open a chat.
/// In a real app you'd pick from contacts / employer profile.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  // In production you'd store/load past conversations from local DB or an
  // endpoint. For now we keep an in-memory list of opened chats this session.
  final List<_RecentChat> _recent = [];
  final _idCtrl = TextEditingController();

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Start a Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the User ID or email of the person you want to message.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:   _idCtrl,
              decoration:   const InputDecoration(
                labelText: 'User ID',
                hintText:  'Paste user _id here',
                prefixIcon: Icon(Icons.person_search_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { _idCtrl.clear(); Navigator.pop(ctx); },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = _idCtrl.text.trim();
              if (id.isEmpty) return;
              _idCtrl.clear();
              Navigator.pop(ctx);
              _openChat(receiverId: id, receiverName: 'User');
            },
            child: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }

  void _openChat({required String receiverId, required String receiverName}) {
    // Add to recent if not already there
    if (!_recent.any((r) => r.receiverId == receiverId)) {
      setState(() {
        _recent.insert(0, _RecentChat(receiverId: receiverId, name: receiverName));
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(receiverId: receiverId, receiverName: receiverName),
      ),
    );
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon:    const Icon(Icons.edit_rounded),
            tooltip: 'New Chat',
            onPressed: _startNewChat,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:       _startNewChat,
        backgroundColor: AppColors.primary,
        child:           const Icon(Icons.chat_rounded, color: Colors.white),
      ),
      body: _recent.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text('No conversations yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the pencil icon to start a chat',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _startNewChat,
                    icon:  const Icon(Icons.add_rounded),
                    label: const Text('New Message'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding:       const EdgeInsets.symmetric(vertical: 8),
              itemCount:     _recent.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.divider,
                height: 1,
                indent: 74,
              ),
              itemBuilder: (_, i) {
                final chat = _recent[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius:          24,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize:   16,
                      ),
                    ),
                  ),
                  title: Text(
                    chat.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Tap to continue the conversation',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                  onTap: () => _openChat(
                    receiverId:   chat.receiverId,
                    receiverName: chat.name,
                  ),
                );
              },
            ),
    );
  }
}

class _RecentChat {
  final String receiverId;
  final String name;
  _RecentChat({required this.receiverId, required this.name});
}