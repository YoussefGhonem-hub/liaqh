import 'package:fitnessapp/data/models/support_ticket_models.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/support_ticket_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A support-ticket conversation shared by the Platform Owner and the user.
class SupportTicketDetailScreen extends StatefulWidget {
  static const routeName = '/SupportTicketDetailScreen';
  final String ticketId;
  final String subject;
  const SupportTicketDetailScreen({
    Key? key,
    required this.ticketId,
    required this.subject,
  }) : super(key: key);

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SupportTicketProvider>().loadDetail(widget.ticketId));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final ok = await context
        .read<SupportTicketProvider>()
        .postMessage(widget.ticketId, text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _ctrl.clear();
  }

  Future<void> _close() async {
    final ok = await context.read<SupportTicketProvider>().close(widget.ticketId);
    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ticket closed.'),
          backgroundColor: AppColors.successColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<SupportTicketProvider>();
    final detail = provider.detail;
    final isOwner = context.read<AuthProvider>().isPlatformOwner;
    final myId = context.read<AuthProvider>().currentUser?.userId ?? '';
    final loadedThis = detail != null && detail.id == widget.ticketId;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(widget.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
        actions: [
          if (isOwner && loadedThis && detail.isOpen)
            TextButton.icon(
              onPressed: _close,
              icon: const Icon(Icons.check_circle_outline_rounded,
                  size: 18, color: AppColors.successColor),
              label: const Text('Close',
                  style: TextStyle(color: AppColors.successColor)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: !loadedThis
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: detail.messages.length,
                    itemBuilder: (_, i) => _Bubble(
                      msg: detail.messages[i],
                      mine: detail.messages[i].senderUserId == myId,
                      colors: colors,
                    ),
                  ),
          ),
          if (loadedThis && !detail.isOpen)
            Container(
              width: double.infinity,
              color: colors.card,
              padding: const EdgeInsets.all(12),
              child: Text(
                isOwner
                    ? 'This ticket is closed. A new reply from the user re-opens it.'
                    : 'This ticket is closed. Send a message to re-open it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.subFg, fontSize: 12),
              ),
            ),
          // Composer
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              color: colors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: colors.fg),
                      decoration: InputDecoration(
                        hintText: 'Write a message…',
                        hintStyle: TextStyle(color: colors.mutedFg),
                        filled: true,
                        fillColor: colors.card,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: AppColors.primaryColor1,
                          shape: BoxShape.circle),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final SupportMessageModel msg;
  final bool mine;
  final AppThemeColors colors;
  const _Bubble({required this.msg, required this.mine, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryColor1 : colors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 4),
            bottomRight: Radius.circular(mine ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.isFromOwner ? 'Support' : msg.senderName,
                style: TextStyle(
                    color: mine ? Colors.white70 : colors.subFg,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(msg.body,
                style: TextStyle(
                    color: mine ? Colors.white : colors.fg, fontSize: 14)),
            const SizedBox(height: 3),
            Text(fmt.format(msg.createdAt.toLocal()),
                style: TextStyle(
                    color: mine ? Colors.white60 : colors.mutedFg,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
