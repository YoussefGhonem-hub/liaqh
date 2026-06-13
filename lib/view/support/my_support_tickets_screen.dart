import 'package:fitnessapp/data/models/support_ticket_models.dart';
import 'package:fitnessapp/providers/support_ticket_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/support/support_ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A user's own support tickets + the ability to open a new one.
class MySupportTicketsScreen extends StatefulWidget {
  static const routeName = '/MySupportTicketsScreen';
  const MySupportTicketsScreen({Key? key}) : super(key: key);

  @override
  State<MySupportTicketsScreen> createState() => _MySupportTicketsScreenState();
}

class _MySupportTicketsScreenState extends State<MySupportTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<SupportTicketProvider>().loadMine());
  }

  Future<void> _create() async {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New support ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                  labelText: 'Subject', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: 'How can we help?', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit')),
        ],
      ),
    );

    if (submit == true &&
        subjectCtrl.text.trim().isNotEmpty &&
        messageCtrl.text.trim().isNotEmpty &&
        mounted) {
      final ok = await context
          .read<SupportTicketProvider>()
          .create(subjectCtrl.text.trim(), messageCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok ? 'Ticket submitted.' : 'Failed to submit.'),
            backgroundColor:
                ok ? AppColors.successColor : AppColors.errorColor));
      }
    }
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
        title: Text('Support',
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppColors.primaryColor1,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New ticket', style: TextStyle(color: Colors.white)),
      ),
      body: provider.loading && provider.myTickets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.myTickets.isEmpty
              ? Center(
                  child: Text('No tickets yet. Tap "New ticket" to ask for help.',
                      style: TextStyle(color: colors.subFg)))
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<SupportTicketProvider>().loadMine(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    itemCount: provider.myTickets.length,
                    itemBuilder: (_, i) =>
                        _MyTicketCard(t: provider.myTickets[i], colors: colors),
                  ),
                ),
    );
  }
}

class _MyTicketCard extends StatelessWidget {
  final SupportTicketModel t;
  final AppThemeColors colors;
  const _MyTicketCard({required this.t, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    final statusColor = t.isOpen ? Colors.orange : Colors.green;
    final time = t.lastMessageAt ?? t.createdAt;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SupportTicketDetailScreen(ticketId: t.id, subject: t.subject),
        ),
      ),
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
            if (t.lastMessage != null && t.lastMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.lastMessage!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(color: colors.subFg, fontSize: 13, height: 1.3)),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fmt.format(time.toLocal()),
                    style: TextStyle(color: colors.mutedFg, fontSize: 11)),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primaryColor1, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
