// lib/screens/shared/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/conversation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  /// Pass either a ready conversation OR just the receiverId to auto-start one.
  final ConversationModel? conversation;
  final String?            receiverId;
  final String             receiverName;

  const ChatScreen({
    super.key,
    this.conversation,
    this.receiverId,
    required this.receiverName,
  }) : assert(
    conversation != null || receiverId != null,
    'Provide either conversation or receiverId',
  );

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool  _isSending = false;
  String? _otherUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final auth     = context.read<AuthProvider>();
    final chat     = context.read<ChatProvider>();
    final token    = auth.user?.token ?? '';
    final myId     = auth.user?.id    ?? '';

    chat.connectSocket(myId);

    ConversationModel? conv = widget.conversation;

    if (conv == null && widget.receiverId != null) {
      conv = await chat.startConversation(
        token:         token,
        receiverId:    widget.receiverId!,
        currentUserId: myId,
      );
    }

    if (conv == null || !mounted) return;

    // Identify the other participant safely
    final others = conv.participants.where((p) => p.id != myId).toList();
    if (others.isNotEmpty) {
      _otherUserId = others.first.id;
    } else if (conv.participants.isNotEmpty) {
      // Fallback: use first participant (e.g. talking to yourself in dev)
      _otherUserId = conv.participants.first.id;
    } else {
      // No participants at all — use the receiverId we started with
      _otherUserId = widget.receiverId;
    }

    if (_otherUserId == null || !mounted) return;

    await chat.loadMessages(
      token:          token,
      conversationId: conv.id,
      currentUserId:  myId,
      otherUserId:    _otherUserId!,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text  = _msgCtrl.text.trim();
    if (text.isEmpty || _otherUserId == null) return;

    final myId = context.read<AuthProvider>().user?.id ?? '';
    context.read<ChatProvider>().sendMessage(
      senderId:   myId,
      receiverId: _otherUserId!,
      text:       text,
    );

    _msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    context.read<ChatProvider>().clearChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat  = context.watch<ChatProvider>();
    final myId  = context.read<AuthProvider>().user?.id ?? '';
    final msgs  = chat.messages;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius:          18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                widget.receiverName.isNotEmpty
                    ? widget.receiverName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color:      AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize:   14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const Text(
                  'Online',
                  style: TextStyle(fontSize: 11, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────────────────
          Expanded(
            child: chat.loadingMessages
                ? const Center(child: CircularProgressIndicator())
                : msgs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 56, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              'Say hi to ${widget.receiverName}!',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding:    const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        itemCount:  msgs.length,
                        itemBuilder: (_, i) {
                          final msg    = msgs[i];
                          final isMe   = msg.senderId == myId;
                          final showDate = i == 0 ||
                              !_sameDay(msgs[i - 1].createdAt, msg.createdAt);

                          return Column(
                            children: [
                              if (showDate) _DateDivider(iso: msg.createdAt),
                              _MessageBubble(msg: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
          ),

          // ── Input bar ─────────────────────────────────────────────
          Container(
            color:   AppColors.surface,
            padding: EdgeInsets.fromLTRB(
              12, 8, 12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:  _msgCtrl,
                    maxLines:    4,
                    minLines:    1,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:        'Type a message...',
                      contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:   BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:   BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      fillColor: AppColors.background,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width:  46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color:  AppColors.primary,
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(String isoA, String isoB) {
    try {
      final a = DateTime.parse(isoA);
      final b = DateTime.parse(isoB);
      return a.year == b.year && a.month == b.month && a.day == b.day;
    } catch (_) {
      return true;
    }
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final dynamic msg;
  final bool    isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:  const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4  : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset:     const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.text ?? '',
              style: TextStyle(
                fontSize: 14,
                color:    isMe ? Colors.white : AppColors.textPrimary,
                height:   1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.createdAt ?? ''),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white60 : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h  = dt.hour.toString().padLeft(2, '0');
      final m  = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}

// ── Date divider ───────────────────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final String iso;
  const _DateDivider({required this.iso});

  @override
  Widget build(BuildContext context) {
    String label;
    try {
      final dt   = DateTime.parse(iso).toLocal();
      final now  = DateTime.now();
      final diff = now.difference(dt).inDays;
      if (diff == 0)      label = 'Today';
      else if (diff == 1) label = 'Yesterday';
      else                label = '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      label = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}