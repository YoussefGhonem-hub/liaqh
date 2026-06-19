import 'dart:async';

import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/chat_models.dart';

class ChatRoomScreen extends StatefulWidget {
  static const routeName = '/ChatRoomScreen';
  final ChatConversation conversation;

  const ChatRoomScreen({Key? key, required this.conversation})
      : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  late String _currentUserId;
  late bool _isCoach;

  /// Id of the newest message we last auto-scrolled to, so we only jump to the
  /// bottom for genuinely new messages — not when older ones are prepended.
  String? _lastMsgId;

  // Pending context reference to attach to the next message.
  String? _pendingContextType;
  String? _pendingContextLabel;

  // Pending reply (quote) to attach to the next message.
  ChatMessage? _replyTo;

  static const _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _currentUserId = auth.currentUser?.userId ?? '';
    // Slot is decided by identity (who is the coachId of THIS conversation),
    // not the user's global role — so owner↔anyone chats stay consistent.
    _isCoach = widget.conversation.coachId == _currentUserId;

    final chat = context.read<ChatProvider>();
    chat.listenMessages(widget.conversation.id);
    chat.listenTyping(widget.conversation.id, _isCoach);
    chat.markRead(widget.conversation.id, _isCoach, _currentUserId);
    // Re-mark as read whenever new messages arrive while this screen is open,
    // so the other person's "seen" updates in real time.
    chat.addListener(_markReadOnNewMessages);
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    // Near the top → load older messages.
    if (_scroll.hasClients && _scroll.position.pixels <= 80) {
      context.read<ChatProvider>().loadMoreMessages();
    }
  }

  void _markReadOnNewMessages() {
    if (!mounted) return;
    final chat = context.read<ChatProvider>();
    final hasUnseenFromOther =
        chat.messages.any((m) => m.senderId != _currentUserId && !m.isRead);
    if (hasUnseenFromOther) {
      chat.markRead(widget.conversation.id, _isCoach, _currentUserId);
    }
  }

  Timer? _typingTimer;

  void _onTyping(String value) {
    final chat = context.read<ChatProvider>();
    chat.setTyping(widget.conversation.id, _isCoach, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      chat.setTyping(widget.conversation.id, _isCoach, false);
    });
  }

  @override
  void dispose() {
    final chat = context.read<ChatProvider>();
    chat.removeListener(_markReadOnNewMessages);
    _typingTimer?.cancel();
    chat.stopTyping(widget.conversation.id, _isCoach);
    _ctrl.dispose();
    _scroll.dispose();
    chat.clearMessages();
    super.dispose();
  }

  bool _firstScrollDone = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (!_firstScrollDone) {
        // First open: jump instantly so the latest message is visible at once.
        _scroll.jumpTo(target);
        _firstScrollDone = true;
      } else {
        _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearContext() {
    setState(() {
      _pendingContextType = null;
      _pendingContextLabel = null;
    });
  }

  void _react(ChatMessage msg, String emoji) {
    context
        .read<ChatProvider>()
        .reactToMessage(widget.conversation.id, msg.id, _currentUserId, emoji);
  }

  /// Double-tap = quick ❤️ like (toggles).
  void _quickReact(ChatMessage msg) => _react(msg, '❤️');

  void _startReply(ChatMessage msg) {
    setState(() => _replyTo = msg);
  }

  void _clearReply() => setState(() => _replyTo = null);

  /// WhatsApp-style action sheet: react row, Reply (all), Edit/Delete (own).
  Future<void> _showMessageActions(ChatMessage msg, bool isMine) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            // Quick reactions row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _quickEmojis.map((e) {
                final selected = msg.reactions[_currentUserId] == e;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _react(msg, e);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primaryColor1.withValues(alpha: 0.18)
                          : Colors.transparent,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply_rounded,
                  color: AppColors.primaryColor1),
              title: Text(l10n.reply, style: TextStyle(color: colors.fg)),
              onTap: () => Navigator.pop(ctx, 'reply'),
            ),
            if (isMine) ...[
              ListTile(
                leading: const Icon(Icons.edit_rounded,
                    color: AppColors.primaryColor1),
                title: Text(l10n.editMessage,
                    style: TextStyle(color: colors.fg)),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444)),
                title: Text(l10n.deleteMessage,
                    style: const TextStyle(color: Color(0xFFEF4444))),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == 'reply') {
      _startReply(msg);
    } else if (action == 'edit') {
      await _editMessage(msg);
    } else if (action == 'delete') {
      final ok = await _confirmDelete();
      if (ok && mounted) {
        await context
            .read<ChatProvider>()
            .deleteMessage(widget.conversation.id, msg.id);
      }
    }
  }

  Future<void> _editMessage(ChatMessage msg) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final ctrl = TextEditingController(text: msg.text);
    final newText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.editMessage,
            style: TextStyle(
                color: colors.fg, fontSize: 17, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 5,
          minLines: 1,
          style: TextStyle(color: colors.fg),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.inputFill,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (newText != null && newText.isNotEmpty && newText != msg.text && mounted) {
      await context
          .read<ChatProvider>()
          .editMessage(widget.conversation.id, msg.id, newText);
    }
  }

  Future<bool> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteMessage,
            style: TextStyle(
                color: colors.fg, fontSize: 17, fontWeight: FontWeight.w800)),
        content: Text(l10n.deleteMessageConfirm,
            style: TextStyle(color: colors.subFg)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// Inserts an emoji at the current cursor position (or appends).
  void _insertEmoji(String emoji) {
    final sel = _ctrl.selection;
    final text = _ctrl.text;
    if (sel.isValid) {
      final newText = text.replaceRange(sel.start, sel.end, emoji);
      _ctrl.value = TextEditingValue(
        text: newText,
        selection:
            TextSelection.collapsed(offset: sel.start + emoji.length),
      );
    } else {
      _ctrl.text = text + emoji;
      _ctrl.selection =
          TextSelection.collapsed(offset: _ctrl.text.length);
    }
  }

  void _showEmojiPicker() {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 280,
                child: GridView.count(
                  crossAxisCount: 8,
                  children: _chatEmojis
                      .map((e) => InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _insertEmoji(e),
                            child: Center(
                              child: Text(e,
                                  style: const TextStyle(fontSize: 26)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _ctrl.text;
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    final auth = context.read<AuthProvider>();
    final conv = widget.conversation;
    final recipientId = _isCoach ? conv.traineeId : conv.coachId;
    final ctxType = _pendingContextType;
    final ctxLabel = _pendingContextLabel;
    final reply = _replyTo;
    _clearContext();
    _clearReply();
    await context.read<ChatProvider>().sendMessage(
          conversationId: conv.id,
          senderId: _currentUserId,
          senderName: auth.currentUser?.fullName ?? '',
          text: text,
          senderIsCoach: _isCoach,
          recipientId: recipientId,
          contextType: ctxType,
          contextLabel: ctxLabel,
          replyToId: reply?.id,
          replyToText: reply?.text,
          replyToSender: reply == null
              ? null
              : (reply.senderId == _currentUserId
                  ? AppLocalizations.of(context).chatYou
                  : reply.senderName),
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final chat = context.watch<ChatProvider>();
    final otherName = widget.conversation.otherName(_currentUserId);

    // Auto-scroll to the bottom only when the newest message changes (new
    // message sent/received), not when older messages are prepended.
    final newestId = chat.messages.isNotEmpty ? chat.messages.last.id : null;
    if (newestId != null && newestId != _lastMsgId) {
      _lastMsgId = newestId;
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: colors.fg),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryColor1.withValues(alpha: 0.15),
              child: Text(
                otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppColors.primaryColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(otherName,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Text(
                    chat.otherTyping
                        ? l10n.typing
                        : (_isCoach ? l10n.chatTrainee : l10n.chatCoach),
                    style: TextStyle(
                        color: chat.otherTyping
                            ? const Color(0xFF10B981)
                            : colors.subFg,
                        fontSize: 11,
                        fontWeight: chat.otherTyping
                            ? FontWeight.w600
                            : FontWeight.w400)),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 18),
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
                color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(height: 1, color: colors.divider),
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Text(l10n.chatSayHi,
                        style: TextStyle(color: colors.mutedFg, fontSize: 15)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: chat.messages.length +
                        (chat.messagesHasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      final offset = chat.messagesHasMore ? 1 : 0;
                      // Top "load older" spinner.
                      if (chat.messagesHasMore && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor1),
                            ),
                          ),
                        );
                      }
                      final i = index - offset;
                      final msg = chat.messages[i];
                      final isMine = msg.senderId == _currentUserId;
                      final showDate = i == 0 ||
                          !_sameDay(chat.messages[i - 1].sentAt, msg.sentAt);
                      return Column(
                        children: [
                          if (showDate) _DateChip(date: msg.sentAt),
                          GestureDetector(
                            onLongPress: () => _showMessageActions(msg, isMine),
                            onDoubleTap: () => _quickReact(msg),
                            child: _Bubble(
                              msg: msg,
                              isMine: isMine,
                              currentUserId: _currentUserId,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (_pendingContextType != null)
            _PendingContextBanner(
              type: _pendingContextType!,
              label: _pendingContextLabel ?? '',
              onClear: _clearContext,
            ),
          if (_replyTo != null)
            _ReplyBanner(
              sender: _replyTo!.senderId == _currentUserId
                  ? l10n.chatYou
                  : _replyTo!.senderName,
              text: _replyTo!.text,
              onClear: _clearReply,
            ),
          _InputBar(
            ctrl: _ctrl,
            onSend: _send,
            onEmoji: _showEmojiPicker,
            onChanged: _onTyping,
            colors: colors,
            hint: l10n.chatTypeMessage,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Context helpers ────────────────────────────────────────────────────────────
IconData contextIcon(String type) {
  switch (type) {
    case ChatContextType.inbody:
      return Icons.monitor_heart_rounded;
    case ChatContextType.workout:
      return Icons.fitness_center_rounded;
    case ChatContextType.mealplan:
      return Icons.restaurant_rounded;
    default:
      return Icons.link_rounded;
  }
}

Color contextColor(String type) {
  switch (type) {
    case ChatContextType.inbody:
      return const Color(0xFF6C63FF);
    case ChatContextType.workout:
      return const Color(0xFF8B5CF6);
    case ChatContextType.mealplan:
      return const Color(0xFF10B981);
    default:
      return AppColors.primaryColor1;
  }
}

// ── Pending context banner (above input) ──────────────────────────────────────
class _PendingContextBanner extends StatelessWidget {
  final String type;
  final String label;
  final VoidCallback onClear;
  const _PendingContextBanner({
    required this.type,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final color = contextColor(type);
    return Container(
      color: colors.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          Container(width: 3, height: 32, color: color),
          const SizedBox(width: 10),
          Icon(contextIcon(type), color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.chatReferencing,
                    style: TextStyle(
                        color: colors.mutedFg,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
                Text(label,
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.chatRemoveReference,
            icon: Icon(Icons.close_rounded, color: colors.mutedFg, size: 20),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

// ── Reply banner (above the composer) ──────────────────────────────────────────
class _ReplyBanner extends StatelessWidget {
  final String sender;
  final String text;
  final VoidCallback onClear;
  const _ReplyBanner(
      {required this.sender, required this.text, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    return Container(
      color: colors.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Container(width: 3, height: 36, color: AppColors.primaryColor1),
          const SizedBox(width: 10),
          const Icon(Icons.reply_rounded,
              color: AppColors.primaryColor1, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.reply} · $sender',
                    style: const TextStyle(
                        color: AppColors.primaryColor1,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.subFg, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: colors.mutedFg, size: 20),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────
class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = l10n.chatToday;
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = l10n.chatYesterday;
    } else {
      label = DateFormat('MMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.listTile,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              style: TextStyle(
                  color: context.colors.subFg,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMine;
  final String currentUserId;
  const _Bubble({
    required this.msg,
    required this.isMine,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = DateFormat('h:mm a').format(msg.sentAt.toLocal());

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          gradient: isMine
              ? LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMine ? null : colors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.hasReply) _ReplyQuote(msg: msg, isMine: isMine),
            if (msg.hasContext)
              _ContextChip(
                type: msg.contextType!,
                label: msg.contextLabel ?? '',
                isMine: isMine,
              ),
            Text(msg.text,
                style: TextStyle(
                    color: isMine ? Colors.white : colors.fg,
                    fontSize: 14,
                    height: 1.4)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg.isEdited) ...[
                  Text(AppLocalizations.of(context).edited,
                      style: TextStyle(
                          color: isMine
                              ? Colors.white.withValues(alpha: 0.7)
                              : colors.mutedFg,
                          fontSize: 10,
                          fontStyle: FontStyle.italic)),
                  const SizedBox(width: 5),
                ],
                Text(time,
                    style: TextStyle(
                        color: isMine
                            ? Colors.white.withValues(alpha: 0.7)
                            : colors.mutedFg,
                        fontSize: 10)),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  // WhatsApp-style ticks: double-check, blue once read (seen),
                  // faint white while only sent/delivered.
                  Icon(
                    Icons.done_all_rounded,
                    size: 15,
                    color: msg.isRead
                        ? const Color(0xFF34B7F1) // WhatsApp blue = seen
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
          if (msg.reactions.isNotEmpty)
            _ReactionsChip(
                reactions: msg.reactions,
                isMine: isMine,
                colors: colors),
        ],
      ),
    );
  }
}

// ── Reply quote shown at the top of a bubble ───────────────────────────────────
class _ReplyQuote extends StatelessWidget {
  final ChatMessage msg;
  final bool isMine;
  const _ReplyQuote({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onMine = isMine;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onMine
            ? Colors.white.withValues(alpha: 0.18)
            : AppColors.primaryColor1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
              color: onMine ? Colors.white : AppColors.primaryColor1,
              width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(msg.replyToSender ?? '',
              style: TextStyle(
                  color: onMine ? Colors.white : AppColors.primaryColor1,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(msg.replyToText ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: onMine
                      ? Colors.white.withValues(alpha: 0.85)
                      : colors.subFg,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Reactions chip shown under a bubble ────────────────────────────────────────
class _ReactionsChip extends StatelessWidget {
  final Map<String, String> reactions;
  final bool isMine;
  final dynamic colors;
  const _ReactionsChip(
      {required this.reactions, required this.isMine, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Count each emoji.
    final counts = <String, int>{};
    for (final e in reactions.values) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: counts.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(
              e.value > 1 ? '${e.key} ${e.value}' : e.key,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Context reference chip inside a bubble ─────────────────────────────────────
class _ContextChip extends StatelessWidget {
  final String type;
  final String label;
  final bool isMine;
  const _ContextChip({
    required this.type,
    required this.label,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final onMine = isMine;
    final bg = onMine
        ? Colors.white.withValues(alpha: 0.2)
        : contextColor(type).withValues(alpha: 0.12);
    final fg = onMine ? Colors.white : contextColor(type);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(contextIcon(type), color: fg, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// A compact set of common emojis for the in-chat picker.
const List<String> _chatEmojis = [
  '😀', '😁', '😂', '🤣', '😊', '😇', '🙂', '😉',
  '😍', '😘', '😋', '😎', '🤩', '🥳', '😴', '🤔',
  '🤗', '🙃', '😅', '😢', '😭', '😡', '😱', '😬',
  '👍', '👎', '👏', '🙏', '💪', '🤝', '👌', '✌️',
  '🔥', '⭐', '✨', '🎉', '❤️', '🧡', '💛', '💚',
  '💙', '💜', '💯', '✅', '❌', '⚡', '🏆', '🥇',
  '🏋️', '🤸', '🏃', '🚴', '🥗', '🍎', '🥦', '🍗',
  '🥚', '🥛', '💧', '☕', '😋', '😴', '⏰', '📅',
];

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final VoidCallback onEmoji;
  final ValueChanged<String> onChanged;
  final dynamic colors;
  final String hint;
  const _InputBar({
    required this.ctrl,
    required this.onSend,
    required this.onEmoji,
    required this.onChanged,
    required this.colors,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Blend with the screen background; a thin top line separates it from
      // the message list (matches the reference design).
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(top: BorderSide(color: colors.divider, width: 0.6)),
      ),
      padding: EdgeInsets.fromLTRB(
          10, 8, 10, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Emoji picker
          GestureDetector(
            onTap: onEmoji,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.only(right: 4, bottom: 6),
              child: Icon(Icons.emoji_emotions_outlined,
                  color: AppColors.primaryColor1, size: 26),
            ),
          ),
          // Clean filled pill (no hard border; orange ring only on focus)
          Expanded(
            child: TextField(
              controller: ctrl,
              style: TextStyle(color: colors.fg, fontSize: 15, height: 1.3),
              maxLines: 5,
              minLines: 1,
              cursorColor: AppColors.primaryColor1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: colors.mutedFg, fontSize: 15),
                filled: true,
                fillColor: colors.inputFill,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: AppColors.primaryColor1, width: 1.3),
                ),
              ),
              onChanged: onChanged,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor1.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}
