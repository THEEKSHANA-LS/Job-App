// lib/screens/shared/conversations_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/conversation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/empty_state.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<ConversationModel> _conversations = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() { _loading = true; _error = null; });

    final token  = context.read<AuthProvider>().user?.token ?? '';
    final result = await ChatService.getMyConversations(token);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _conversations = result['conversations'] as List<ConversationModel>;
        _loading       = false;
      });
    } else {
      setState(() {
        _error   = result['message'] as String? ?? 'Failed to load conversations';
        _loading = false;
      });
    }
  }

  void _openChat(ConversationModel conv) {
    final myId = context.read<AuthProvider>().user?.id ?? '';
    final other = conv.participants.firstWhere(
      (p) => p.id != myId,
      orElse: () => conv.participants.isNotEmpty
          ? conv.participants.first
          : ParticipantInfo(id: '', name: 'Unknown', email: ''),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversation: conv,
          receiverName: other.name,
        ),
      ),
    ).then((_) => _fetchConversations()); // refresh list after returning
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().user?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorState(message: _error!, onRetry: _fetchConversations)
              : _conversations.isEmpty
                  ? const EmptyState(
                      icon:     Icons.chat_bubble_outline_rounded,
                      title:    'No conversations yet',
                      subtitle: 'Messages with employers or job seekers\nwill appear here',
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchConversations,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppColors.divider, height: 1, indent: 74,
                        ),
                        itemBuilder: (_, i) {
                          final conv = _conversations[i];
                          final other = conv.participants.firstWhere(
                            (p) => p.id != myId,
                            orElse: () => conv.participants.isNotEmpty
                                ? conv.participants.first
                                : ParticipantInfo(id: '', name: 'Unknown', email: ''),
                          );

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              radius:          24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                other.name.isNotEmpty ? other.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color:      AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize:   16,
                                ),
                              ),
                            ),
                            title: Text(
                              other.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            subtitle: Text(
                              conv.lastMessage?.isNotEmpty == true
                                  ? conv.lastMessage!
                                  : 'Tap to start chatting',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                            onTap: () => _openChat(conv),
                          );
                        },
                      ),
                    ),
    );
  }
}