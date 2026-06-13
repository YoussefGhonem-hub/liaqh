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

  // Pending context reference to attach to the next message.
  String? _pendingContextType;
  String? _pendingContextLabel;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _currentUserId = auth.currentUser?.userId ?? '';
    _isCoach = auth.isCoach;

    final chat = context.read<ChatProvider>();
    chat.listenMessages(widget.conversation.id);
    chat.markRead(widget.conversation.id, _isCoach, _currentUserId);
    // Re-mark as read whenever new messages arrive while this screen is open,
    // so the other person's "seen" updates in real time.
    chat.addListener(_markReadOnNewMessages);
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

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_markReadOnNewMessages);
    _ctrl.dispose();
    _scroll.dispose();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _labelForType(AppLocalizations l10n, String type) {
    switch (type) {
      case ChatContextType.inbody:
        return l10n.chatReferenceInBody;
      case ChatContextType.workout:
        return l10n.chatReferenceWorkout;
      case ChatContextType.mealplan:
        return l10n.chatReferenceMeal;
      default:
        return '';
    }
  }

  Future<void> _pickContext() async {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final type = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: AppColors.primaryColor1, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.chatAttachReference,
                      style: TextStyle(
                          color: colors.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            _ContextOption(
              icon: Icons.monitor_heart_rounded,
              color: const Color(0xFF6C63FF),
              label: l10n.chatReferenceInBody,
              onTap: () => Navigator.pop(ctx, ChatContextType.inbody),
            ),
            _ContextOption(
              icon: Icons.fitness_center_rounded,
              color: const Color(0xFF8B5CF6),
              label: l10n.chatReferenceWorkout,
              onTap: () => Navigator.pop(ctx, ChatContextType.workout),
            ),
            _ContextOption(
              icon: Icons.restaurant_rounded,
              color: const Color(0xFF10B981),
              label: l10n.chatReferenceMeal,
              onTap: () => Navigator.pop(ctx, ChatContextType.mealplan),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (type != null && mounted) {
      setState(() {
        _pendingContextType = type;
        _pendingContextLabel = _labelForType(l10n, type);
      });
    }
  }

  void _clearContext() {
    setState(() {
      _pendingContextType = null;
      _pendingContextLabel = null;
    });
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
    _clearContext();
    await context.read<ChatProvider>().sendMessage(
          conversationId: conv.id,
          senderId: _currentUserId,
          senderName: auth.currentUser?.fullName ?? '',
          text: text,
          senderIsCoach: _isCoach,
          recipientId: recipientId,
          contextType: ctxType,
          contextLabel: ctxLabel,
        );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final chat = context.watch<ChatProvider>();
    final otherName = widget.conversation.otherName(_currentUserId);

    if (chat.messages.isNotEmpty) _scrollToBottom();

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
                Text(_isCoach ? l10n.chatTrainee : l10n.chatCoach,
                    style: TextStyle(color: colors.subFg, fontSize: 11)),
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
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) {
                      final msg = chat.messages[i];
                      final isMine = msg.senderId == _currentUserId;
                      final showDate = i == 0 ||
                          !_sameDay(chat.messages[i - 1].sentAt, msg.sentAt);
                      return Column(
                        children: [
                          if (showDate) _DateChip(date: msg.sentAt),
                          _Bubble(msg: msg, isMine: isMine),
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
          _InputBar(
            ctrl: _ctrl,
            onSend: _send,
            onAttach: _pickContext,
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

class _ContextOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ContextOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: colors.fg,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
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
  const _Bubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = DateFormat('h:mm a').format(msg.sentAt.toLocal());

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
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

// ── Input bar ─────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final dynamic colors;
  final String hint;
  const _InputBar({
    required this.ctrl,
    required this.onSend,
    required this.onAttach,
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
          // Attach / link reference
          GestureDetector(
            onTap: onAttach,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: Icon(Icons.add_link_rounded,
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
