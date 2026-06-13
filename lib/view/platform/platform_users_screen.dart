import 'package:fitnessapp/data/models/platform_models.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'platform_widgets.dart';
import 'user_detail_screen.dart';

class PlatformUsersScreen extends StatefulWidget {
  static const routeName = '/PlatformUsersScreen';
  const PlatformUsersScreen({super.key});

  @override
  State<PlatformUsersScreen> createState() => _PlatformUsersScreenState();
}

class _PlatformUsersScreenState extends State<PlatformUsersScreen> {
  String _search = '';
  String? _role; // null = All

  static const _roles = <String, String>{
    'All': '',
    'GymAdmin': 'GymAdmin',
    'Coach': 'Coach',
    'Trainee': 'Trainee',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<PlatformProvider>().loadUsers(role: _role, search: _search);
  }

  /// Apply role + search filters on the client so results update instantly and
  /// are never affected by out-of-order server responses.
  List<PlatformUser> _applyFilters(List<PlatformUser> items) {
    final s = _search.trim().toLowerCase();
    return items.where((u) {
      final roleOk = _role == null || u.role == _role;
      final searchOk = s.isEmpty ||
          u.fullName.toLowerCase().contains(s) ||
          u.email.toLowerCase().contains(s);
      return roleOk && searchOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = context.watch<PlatformProvider>();
    final data = p.users;
    final items = data == null ? <PlatformUser>[] : _applyFilters(data.items);

    return Scaffold(
      backgroundColor: colors.bg,
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: PlatformGradientHeader(
                title: 'Users',
                subtitle: 'All users across the platform',
                icon: Icons.group_rounded,
                showBack: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    PlatformSearchField(
                      hint: 'Search users...',
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final e in _roles.entries) ...[
                            _roleChip(e.key, e.value.isEmpty ? null : e.value),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (p.usersLoading && data == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (p.usersError != null && data == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformErrorState(
                    message: p.usersError!, onRetry: _load),
              )
            else if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: PlatformEmptyState(
                    icon: Icons.group_rounded, message: 'No users found'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _userTile(items[i]),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String label, String? value) {
    final selected = _role == value;
    return GestureDetector(
      onTap: () {
        setState(() => _role = value);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient:
              selected ? LinearGradient(colors: AppColors.primaryG) : null,
          color: selected ? null : context.colors.chipUnselected,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : context.colors.subFg,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'GymAdmin':
        return const Color(0xFFF59E0B);
      case 'Coach':
        return const Color(0xFF8B5CF6);
      case 'Trainee':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.primaryColor1;
    }
  }

  Widget _userTile(PlatformUser u) {
    final colors = context.colors;
    final rc = _roleColor(u.role);
    return PlatformCard(
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UserDetailScreen(userId: u.id)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: rc.withValues(alpha: 0.15),
            child: Text(
              u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
              style: TextStyle(color: rc, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(u.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: colors.fg,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: rc.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(u.role,
                          style: TextStyle(
                              color: rc,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(u.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.subFg, fontSize: 12)),
                if (u.gymName.isNotEmpty)
                  Text(u.gymName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: colors.mutedFg, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: u.isActive,
            onChanged: (v) => _toggle(u, v),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(PlatformUser u, bool v) async {
    try {
      await context.read<PlatformProvider>().setUserStatus(u.id, v);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }
}
