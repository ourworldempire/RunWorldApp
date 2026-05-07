import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/utils/constants.dart';

class _Notif {
  final String title;
  final String body;
  final IconData icon;
  final bool isToday;
  bool read = false;
  _Notif({required this.title, required this.body, required this.icon, required this.isToday});
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_Notif> _notifs = [
    _Notif(title: 'Zone Captured!',   body: 'Arjun just took your MG Road territory.',          icon: Icons.flag,            isToday: true),
    _Notif(title: 'Level Up! 🎉',     body: 'You reached Level 4! Keep running.',                icon: Icons.trending_up,     isToday: true),
    _Notif(title: 'Friend Request',   body: 'Priya wants to be your running buddy.',             icon: Icons.person_add,      isToday: false),
    _Notif(title: 'Challenge Alert',  body: 'Capture MG Road challenge ends in 2 days.',         icon: Icons.emoji_events,    isToday: false),
    _Notif(title: 'Achievement',      body: "You unlocked '10K Club'!",                          icon: Icons.military_tech,   isToday: false),
  ];

  void _clearAll() => setState(() { for (final n in _notifs) { n.read = true; } });

  @override
  Widget build(BuildContext context) {
    final today  = _notifs.where((n) => n.isToday).toList();
    final earlier = _notifs.where((n) => !n.isToday).toList();
    final hasUnread = _notifs.any((n) => !n.read);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.textLight), onPressed: () => context.pop()),
                Expanded(child: Text('NOTIFICATIONS', style: AppTextStyles.displayMD)),
                if (hasUnread) TextButton(
                  onPressed: _clearAll,
                  child: Text('Clear all', style: AppTextStyles.bodySM.copyWith(color: AppColors.accent)),
                ),
              ]),
            ),

            Expanded(
              child: _notifs.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.notifications_none, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: AppSpacing.md),
                      Text('No notifications yet', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                    ]))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      children: [
                        if (today.isNotEmpty) ...[
                          _GroupLabel('Today'),
                          ...today.map((n) => _NotifRow(notif: n, onTap: () => setState(() => n.read = true))),
                        ],
                        if (earlier.isNotEmpty) ...[
                          _GroupLabel('Earlier'),
                          ...earlier.map((n) => _NotifRow(notif: n, onTap: () => setState(() => n.read = true))),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(text, style: AppTextStyles.bodySM.copyWith(letterSpacing: 1.5)),
  );
}

class _NotifRow extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifRow({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.card,
        border: notif.read ? null : Border(left: BorderSide(color: AppColors.accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.pill),
            child: Icon(notif.icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.title, style: AppTextStyles.bodyBold)),
              if (!notif.read) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 2),
            Text(notif.body, style: AppTextStyles.bodySM, maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    ),
  );
}
