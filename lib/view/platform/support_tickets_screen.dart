import 'package:fitnessapp/data/models/support_ticket_models.dart';
import 'package:fitnessapp/providers/support_ticket_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/support/support_ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Platform Owner: list support tickets and open the conversation.
class SupportTicketsScreen extends StatefulWidget {
  static const routeName = '/SupportTicketsScreen';
  const SupportTicketsScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  String _status = 'Open';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<SupportTicketProvider>().loadAll(status: _status);

  Future<void> _open(SupportTicketModel t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupportTicketDetailScreen(ticketId: t.id, subject: t.subject),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<SupportTicketProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text('Support Tickets',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['Open', 'Closed'].map((s) {
                final selected = _status == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: selected,
                    selectedColor: AppColors.primaryColor1,
                    backgroundColor: colors.card,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : colors.fg,
                        fontWeight: FontWeight.w600),
                    onSelected: (_) {
                      setState(() => _status = s);
                      _load();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: provider.loading && provider.tickets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.tickets.isEmpty
                    ? Center(
                        child: Text('No $_status tickets.',
                            style: TextStyle(color: colors.subFg)))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: provider.tickets.length,
                          itemBuilder: (_, i) => _TicketCard(
                            t: provider.tickets[i],
                            colors: colors,
                            onTap: () => _open(provider.tickets[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel t;
  final AppThemeColors colors;
  final VoidCallback onTap;
  const _TicketCard(
      {required this.t, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    final statusColor = t.isOpen ? Colors.orange : Colors.green;
    final time = t.lastMessageAt ?? t.createdAt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(t.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.fg,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(t.status,
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('${t.userName} · ${t.userEmail}',
                style: TextStyle(color: colors.subFg, fontSize: 12)),
            if (t.lastMessage != null && t.lastMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.lastMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.fg, fontSize: 13, height: 1.3)),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fmt.format(time.toLocal()),
                    style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                const Row(
                  children: [
                    Text('Open chat',
                        style: TextStyle(
                            color: AppColors.primaryColor1,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryColor1, size: 18),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
