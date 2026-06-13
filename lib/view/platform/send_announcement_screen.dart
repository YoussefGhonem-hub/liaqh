import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';

class SendAnnouncementScreen extends StatefulWidget {
  static const routeName = '/SendAnnouncementScreen';
  const SendAnnouncementScreen({super.key});

  @override
  State<SendAnnouncementScreen> createState() => _SendAnnouncementScreenState();
}

class _SendAnnouncementScreenState extends State<SendAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  // null targetRole == All Users
  static const _roles = <String, String?>{
    'All Users': null,
    'Gym Admins': 'GymAdmin',
    'Coaches': 'Coach',
    'Trainees': 'Trainee',
  };

  String _roleLabel = 'All Users';
  String? _gymId; // null = all gyms

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PlatformProvider>();
      if (p.gyms.isEmpty) p.loadGyms();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PlatformGradientHeader(
              title: 'Send Announcement',
              subtitle: 'Broadcast a notification',
              icon: Icons.campaign_rounded,
              showBack: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PlatformSectionTitle('Message'),
                      const SizedBox(height: 12),
                      _field(_titleCtrl, 'Title',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Title is required'
                              : null),
                      const SizedBox(height: 12),
                      _field(_bodyCtrl, 'Body', maxLines: 5,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Body is required'
                              : null),
                      const SizedBox(height: 24),
                      const PlatformSectionTitle('Audience'),
                      const SizedBox(height: 12),
                      _dropdown<String>(
                        label: 'Target role',
                        value: _roleLabel,
                        items: [
                          for (final k in _roles.keys)
                            DropdownMenuItem(value: k, child: Text(k)),
                        ],
                        onChanged: (v) =>
                            setState(() => _roleLabel = v ?? 'All Users'),
                      ),
                      const SizedBox(height: 12),
                      _dropdown<String?>(
                        label: 'Gym',
                        value: _gymId,
                        items: [
                          const DropdownMenuItem<String?>(
                              value: null, child: Text('All gyms')),
                          for (final GymSummary g in p.gyms)
                            DropdownMenuItem<String?>(
                                value: g.id, child: Text(g.name)),
                        ],
                        onChanged: (v) => setState(() => _gymId = v),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: p.announcementSending ? null : _send,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor1,
                            minimumSize: const Size(0, 52),
                          ),
                          icon: p.announcementSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                          label: Text(
                              p.announcementSending ? 'Sending...' : 'Send',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PlatformProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final sent = await provider.sendAnnouncement(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        targetRole: _roles[_roleLabel],
        gymId: _gymId,
      );
      messenger.showSnackBar(
        SnackBar(content: Text('Sent to $sent users')),
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    }
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final colors = context.colors;
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final colors = context.colors;
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      items: items,
      onChanged: onChanged,
      style: TextStyle(color: colors.fg),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
