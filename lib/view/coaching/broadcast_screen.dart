import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/providers/coaching_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BroadcastScreen extends StatefulWidget {
  static const routeName = '/BroadcastScreen';
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (_bodyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      final count = await context
          .read<CoachingProvider>()
          .broadcast(_titleCtrl.text.trim(), _bodyCtrl.text.trim());
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.broadcastSent(count)),
          backgroundColor: AppColors.successColor));
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(l10n.failedGeneric),
          backgroundColor: AppColors.errorColor));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.fg,
        elevation: 0,
        title: Text(l10n.broadcast,
            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryG),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.broadcastSub,
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: TextStyle(color: colors.fg),
            decoration: InputDecoration(
              hintText: l10n.broadcastTitleHint,
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 6,
            style: TextStyle(color: colors.fg),
            decoration: InputDecoration(
              hintText: l10n.broadcastBodyHint,
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(l10n.send),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
