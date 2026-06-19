import 'package:fitnessapp/common_widgets/user_avatar.dart';
import 'package:fitnessapp/common_widgets/liaqh_loaders.dart';
import 'package:fitnessapp/data/repositories/trainee_repository.dart';
import 'package:fitnessapp/data/repositories/gym_admin_repository.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/data/services/chat_service.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/chat/chat_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/chat_models.dart';

/// A person the current user can chat with, whether or not a conversation
/// already exists. Conversation is keyed by (coachUserId, traineeUserId).
class _Contact {
  final String coachUserId;
  final String traineeUserId;
  final String coachName;
  final String traineeName;
  final String gymId;
  final String? coachImageUrl;
  final String? traineeImageUrl;

  _Contact({
    required this.coachUserId,
    required this.traineeUserId,
    required this.coachName,
    required this.traineeName,
    required this.gymId,
    this.coachImageUrl,
    this.traineeImageUrl,
  });

  String get convId => ChatService.convId(coachUserId, traineeUserId);

  /// The other party's name from the current user's perspective.
  String otherName(String myUserId) =>
      myUserId == coachUserId ? traineeName : coachName;

  /// The other party's avatar from the current user's perspective.
  String? otherImage(String myUserId) =>
      myUserId == coachUserId ? traineeImageUrl : coachImageUrl;
}

class ChatListScreen extends StatefulWidget {
  static const routeName = '/ChatListScreen';
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<_Contact> _contacts = [];
  bool _contactsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      if (user != null) {
        context
            .read<ChatProvider>()
            .listenConversations(user.userId, auth.isCoach);
      }
      _loadContacts();
    });
  }

  Future<void> _loadContacts() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) {
      setState(() => _contactsLoaded = true);
      return;
    }
    final repo = TraineeRepository(context.read<ApiService>());
    final contacts = <_Contact>[];
    try {
      if (auth.isCoach) {
        // Coach: every trainee is a chat contact.
        final trainees = (await repo.getMyTrainees(pageSize: 100)).items;
        for (final t in trainees) {
          if (t.userId.isEmpty) continue;
          contacts.add(_Contact(
            coachUserId: user.userId,
            traineeUserId: t.userId,
            coachName: user.fullName,
            traineeName: t.fullName,
            gymId: user.gymId,
            coachImageUrl: user.profileImageUrl,
            traineeImageUrl: t.profileImageUrl,
          ));
        }
      } else if (auth.isGymAdmin) {
        // Gym admin: chat with every coach they manage (admin sits on the
        // "trainee" side of the conversation key — it's just two user ids).
        final coaches =
            (await GymAdminRepository(context.read<ApiService>())
                    .getCoaches(pageSize: 100))
                .items;
        for (final c in coaches) {
          contacts.add(_Contact(
            coachUserId: c.userId,
            traineeUserId: user.userId,
            coachName: c.fullName,
            traineeName: user.fullName,
            gymId: user.gymId,
            coachImageUrl: c.profileImageUrl,
            traineeImageUrl: user.profileImageUrl,
          ));
        }
      } else if (auth.isTrainee) {
        // Trainee: their coach is the default contact.
        final me = await repo.getMyProfile();
        if (me.coachUserId != null && me.coachUserId!.isNotEmpty) {
          contacts.add(_Contact(
            coachUserId: me.coachUserId!,
            traineeUserId: user.userId,
            coachName: me.coachName ?? 'Coach',
            traineeName: user.fullName,
            gymId: user.gymId,
            coachImageUrl: me.coachImageUrl,
            traineeImageUrl: user.profileImageUrl,
          ));
        }
      }
    } catch (_) {
      // Ignore — existing conversations still show.
    }
    if (mounted) {
      setState(() {
        _contacts = contacts;
        _contactsLoaded = true;
      });
    }
  }

  Future<void> _openContact(_Contact c) async {
    final conv = ChatConversation(
      id: c.convId,
      coachId: c.coachUserId,
      traineeId: c.traineeUserId,
      coachName: c.coachName,
      traineeName: c.traineeName,
      gymId: c.gymId,
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCoach: 0,
      unreadTrainee: 0,
    );

    // Best-effort create the conversation doc, but ALWAYS open the room even
    // if the write fails — so tapping a contact never silently does nothing.
    try {
      await context.read<ChatProvider>().openOrCreateConversation(
            coachId: c.coachUserId,
            traineeId: c.traineeUserId,
            coachName: c.coachName,
            traineeName: c.traineeName,
            gymId: c.gymId,
          );
    } catch (e) {
      debugPrint('openOrCreateConversation failed: $e');
    }
    if (!mounted) return;
    Navigator.pushNamed(context, ChatRoomScreen.routeName, arguments: conv);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final user = auth.currentUser;
    final myId = user?.userId ?? '';

    // Merge contacts with live conversations (conversation data wins for
    // last message / unread / time; contacts ensure everyone is listed).
    final convById = {for (final c in chat.conversations) c.id: c};
    final items = <_ChatRow>[];
    final seen = <String>{};

    for (final c in _contacts) {
      final conv = convById[c.convId];
      items.add(_ChatRow(
        title: c.otherName(myId),
        avatarUrl: c.otherImage(myId),
        lastMessage: conv?.lastMessage ?? '',
        time: conv?.lastMessageAt,
        unread: conv != null ? conv.unreadFor(myId) : 0,
        onTap: () => _openContact(c),
      ));
      seen.add(c.convId);
    }
    // Any conversation not represented by a contact (e.g. legacy / cross-gym).
    for (final conv in chat.conversations) {
      if (seen.contains(conv.id)) continue;
      items.add(_ChatRow(
        title: conv.otherName(myId),
        avatarUrl: null,
        lastMessage: conv.lastMessage,
        time: conv.lastMessageAt,
        unread: conv.unreadFor(myId),
        onTap: () => Navigator.pushNamed(
          context,
          ChatRoomScreen.routeName,
          arguments: conv,
        ),
      ));
    }

    // Sort: most-recent conversation first, then contacts with no messages.
    items.sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return 1;
      if (b.time == null) return -1;
      return b.time!.compareTo(a.time!);
    });

    final totalUnread = chat.totalUnread;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.chatMessages,
            style: TextStyle(
                color: colors.fg, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          if (totalUnread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$totalUnread',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
      body: !_contactsLoaded
          ? const LiaqhPageLoader()
          : items.isEmpty
              ? _EmptyState(
                  colors: colors,
                  title: l10n.chatNoConversations,
                  hint: l10n.chatNoConversationsHint)
              : ListView.separated(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 90),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: colors.divider, indent: 76),
                  itemBuilder: (context, i) => _ConvTile(
                    row: items[i],
                    noMessagesLabel: l10n.chatNoMessages,
                  ),
                ),
    );
  }
}

class _ChatRow {
  final String title;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime? time;
  final int unread;
  final VoidCallback onTap;
  _ChatRow({
    required this.title,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });
}

// ── Conversation tile ─────────────────────────────────────────────────────────
class _ConvTile extends StatelessWidget {
  final _ChatRow row;
  final String noMessagesLabel;
  const _ConvTile({required this.row, required this.noMessagesLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timeStr = row.time != null
        ? DateFormat('h:mm a').format(row.time!.toLocal())
        : '';
    final unread = row.unread;

    return InkWell(
      onTap: row.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: row.avatarUrl,
              name: row.title,
              radius: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.title,
                      style: TextStyle(
                          color: colors.fg,
                          fontSize: 15,
                          fontWeight:
                              unread > 0 ? FontWeight.w700 : FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    row.lastMessage.isEmpty ? noMessagesLabel : row.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: unread > 0 ? colors.fg : colors.subFg,
                        fontSize: 13,
                        fontWeight:
                            unread > 0 ? FontWeight.w500 : FontWeight.w400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (timeStr.isNotEmpty)
                  Text(timeStr,
                      style: TextStyle(
                          color: unread > 0
                              ? AppColors.primaryColor1
                              : colors.mutedFg,
                          fontSize: 11)),
                const SizedBox(height: 4),
                if (unread > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                        color: AppColors.primaryColor1, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final dynamic colors;
  final String title;
  final String hint;
  const _EmptyState(
      {required this.colors, required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: colors.mutedFg),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  color: colors.subFg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(hint,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.mutedFg, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
