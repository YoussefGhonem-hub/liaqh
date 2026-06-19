import 'dart:async';

import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A rest/workout countdown timer the trainee can use between sets.
/// Presets + custom, with start / pause / reset and a haptic buzz at zero.
class RestTimerSheet extends StatefulWidget {
  const RestTimerSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const RestTimerSheet(),
      );

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  static const _presets = [30, 60, 90, 120, 180];
  int _total = 60; // selected duration (s)
  int _remaining = 60; // countdown (s)
  Timer? _timer;
  bool _running = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _select(int seconds) {
    _timer?.cancel();
    setState(() {
      _total = seconds;
      _remaining = seconds;
      _running = false;
    });
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining == 0) _remaining = _total;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _remaining = 0;
          _running = false;
        });
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = _total;
      _running = false;
    });
  }

  Future<void> _custom() async {
    final ctrl = TextEditingController(text: '$_total');
    final colors = context.colors;
    final secs = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        title: Text(AppLocalizations.of(context).customSeconds,
            style: TextStyle(color: colors.fg, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: colors.fg),
          decoration: const InputDecoration(suffixText: 's'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).cancel)),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, int.tryParse(ctrl.text) ?? _total),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor1,
                foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
    if (secs != null && secs > 0) _select(secs);
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final progress = _total == 0 ? 0.0 : _remaining / _total;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.restTimer,
              style: TextStyle(
                  color: colors.fg, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          // Countdown ring
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: colors.listTile,
                    valueColor: AlwaysStoppedAnimation(
                        _remaining == 0
                            ? const Color(0xFF10B981)
                            : AppColors.primaryColor1),
                  ),
                ),
                Text(_fmt(_remaining),
                    style: TextStyle(
                        color: colors.fg,
                        fontSize: 44,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ..._presets.map((p) {
                final sel = _total == p && !_running;
                return GestureDetector(
                  onTap: () => _select(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryColor1
                          : colors.listTile,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${p}s',
                        style: TextStyle(
                            color: sel ? Colors.white : colors.subFg,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ),
                );
              }),
              GestureDetector(
                onTap: _custom,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.listTile,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(l10n.customLabel,
                      style: TextStyle(
                          color: colors.subFg,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.reset),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.fg,
                    side: BorderSide(color: colors.divider),
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _toggle,
                  icon: Icon(_running
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(_running ? l10n.pause : l10n.start),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor1,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
