import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/services/api_service.dart';
import 'package:runworld/services/social_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/empty_state.dart';
import 'package:runworld/widgets/pill_tabs.dart';
import 'package:runworld/widgets/shimmer_box.dart';

// Mock data
class _Friend {
  final String id, name, avatar;
  final int level, streak, mutualZones;
  final Color avatarColor;
  final String? lastActivity;
  const _Friend(this.id, this.name, this.avatar, this.level, this.streak,
      this.mutualZones, this.avatarColor, {this.lastActivity});
}

class _Request {
  final String id, name, avatar;
  final int level, mutualFriends;
  const _Request(this.id, this.name, this.avatar, this.level, this.mutualFriends);
}

class _FeedItem {
  final String friendName, friendAvatar, type, location, when;
  final double distanceKm;
  final int xpEarned;
  const _FeedItem(this.friendName, this.friendAvatar, this.type, this.distanceKm,
      this.location, this.when, this.xpEarned);
}

const _kFriends = [
  _Friend('1', 'Arjun Kumar', '🦅', 6, 12, 3, AppColors.accent, lastActivity: '🏃 5.2 km · MG Road · 2h ago'),
  _Friend('2', 'Priya Sharma', '🌙', 4, 7, 1, AppColors.highlight, lastActivity: '🚶 2.1 km · Indiranagar · 5h ago'),
  _Friend('3', 'Rahul Nair', '⚡', 8, 21, 5, AppColors.success, lastActivity: '🏃 8.4 km · Koramangala · 1d ago'),
  _Friend('4', 'Sneha Patel', '🔥', 3, 4, 0, AppColors.textMuted),
];

const _kRequests = [
  _Request('r1', 'Vikram Singh', '🐺', 5, 2),
  _Request('r2', 'Meera Reddy', '💎', 3, 1),
];

const _kFeed = [
  _FeedItem('Arjun Kumar', '🦅', 'run', 5.2, 'MG Road', '2h ago', 104),
  _FeedItem('Rahul Nair', '⚡', 'run', 8.4, 'Koramangala', '5h ago', 168),
  _FeedItem('Priya Sharma', '🌙', 'walk', 2.1, 'Indiranagar', '6h ago', 63),
  _FeedItem('Arjun Kumar', '🦅', 'territory', 0.0, 'Brigade Road', '1d ago', 50),
  _FeedItem('Rahul Nair', '⚡', 'run', 10.0, 'HSR Layout', '1d ago', 200),
];

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int _tab = 0;
  String _query = '';
  String _debounced = '';
  bool _searchFocused = false;
  bool _loading = true;
  bool _offline = false;
  final _searchCtrl = TextEditingController();

  List<_Friend>  _friends  = List.of(_kFriends);
  List<_Request> _requests = List.of(_kRequests);
  List<_FeedItem> _feed    = List.of(_kFeed);

  static const _avatarColors = [
    AppColors.accent, AppColors.highlight, AppColors.success,
    AppColors.textMuted, Color(0xFF9B59B6), Color(0xFF3498DB),
  ];

  @override
  void initState() {
    super.initState();
    _loadFromService();
  }

  Future<void> _loadFromService() async {
    if (mounted) setState(() => _loading = true);
    final results = await Future.wait([
      SocialService.instance.getFriends(),
      SocialService.instance.getFriendRequests(),
      SocialService.instance.getActivityFeed(),
    ]);

    final friends  = results[0] as List<FriendModel>;
    final requests = results[1] as List<FriendRequest>;
    final feed     = results[2] as List<FeedItem>;

    if (!mounted) return;
    setState(() {
      _loading = false;
      _offline = ApiService.isOffline;

      _friends = friends.asMap().entries.map((e) => _Friend(
        e.value.id, e.value.name, e.value.avatar, e.value.level,
        e.value.streak, 0,
        _avatarColors[e.key % _avatarColors.length],
      )).toList();

      _requests = requests.map((r) => _Request(
        r.id, r.fromName, r.fromAvatar, r.fromLevel, 0,
      )).toList();

      _feed = feed.map((f) => _FeedItem(
        f.friendName, f.friendAvatar, f.type, f.distanceKm, '', f.when, f.xpEarned,
      )).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Friend> get _filtered => _debounced.trim().isEmpty
      ? _friends
      : _friends.where((f) => f.name.toLowerCase().contains(_debounced.toLowerCase())).toList();

  void _onQueryChanged(String v) {
    setState(() => _query = v);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _query == v) setState(() => _debounced = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 20),
                  ),
                  Text('FRIENDS', style: AppTextStyles.displayMD.copyWith(letterSpacing: 4)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.pill),
                    child: Text('+ Add', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PillTabs(
                tabs: const ['Friends', 'Activity Feed'],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_tab == 0) ...[
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                    color: _searchFocused
                        ? AppColors.accent.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: _searchFocused
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('🔍', style: TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: AppTextStyles.bodyMD,
                        decoration: InputDecoration(
                          hintText: 'Search friends...',
                          hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _onQueryChanged,
                        onTap: () => setState(() => _searchFocused = true),
                        onTapOutside: (_) => setState(() => _searchFocused = false),
                        cursorColor: AppColors.accent,
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() { _query = ''; _debounced = ''; });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Text('✕', style: AppTextStyles.bodySM.copyWith(fontSize: 12)),
                        ),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Offline banner
              if (_offline)
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppRadius.sm_,
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.wifi_off, color: AppColors.error, size: 13),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Offline — showing cached data',
                        style: AppTextStyles.bodySM.copyWith(color: AppColors.error, fontSize: 11)),
                    ]),
                  ),
                ),

              Expanded(
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: const ShimmerList(count: 5, itemHeight: 72),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        children: [
                          // Friend requests
                          if (_requests.isNotEmpty && _debounced.isEmpty) ...[
                            Text('FRIEND REQUESTS · ${_requests.length}',
                              style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
                            const SizedBox(height: AppSpacing.sm),
                            ..._requests.map((r) => _RequestCard(
                              request: r,
                              onAccept: () => setState(() => _requests.removeWhere((x) => x.id == r.id)),
                              onDecline: () => setState(() => _requests.removeWhere((x) => x.id == r.id)),
                            )),
                            const SizedBox(height: AppSpacing.lg),
                          ],

                          // Friends list label
                          Text(
                            _debounced.isNotEmpty
                                ? 'RESULTS FOR "${_debounced.toUpperCase()}"'
                                : 'ALL FRIENDS · ${_friends.length}',
                            style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if (_filtered.isEmpty && _debounced.isNotEmpty)
                            EmptyState(
                              emoji: '🔍',
                              title: 'No results',
                              subtitle: 'No friends match "$_debounced"',
                            )
                          else if (_friends.isEmpty)
                            EmptyState(
                              emoji: '👥',
                              title: 'No friends yet',
                              subtitle: 'Find runners near you and challenge them for territory',
                              actionLabel: 'Find Runners',
                              onAction: () {},
                            )
                          else
                            ..._filtered.map((f) => _FriendCard(friend: f)),

                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
              ),
            ] else ...[
              // Activity feed
              Expanded(
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: const ShimmerList(count: 4, itemHeight: 64),
                      )
                    : _feed.isEmpty
                        ? EmptyState(
                            emoji: '🏃',
                            title: 'No activity yet',
                            subtitle: 'When your friends complete runs, they\'ll appear here',
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: AppRadius.card,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      child: Text('RECENT ACTIVITY',
                                        style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
                                    ),
                                    ..._feed.map((item) => _FeedRow(item: item)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                            ],
                          ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _Request request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _RequestCard({required this.request, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      color: AppColors.highlight.withValues(alpha: 0.07),
      borderRadius: AppRadius.card,
      border: Border.all(color: AppColors.highlight.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: AppColors.highlight, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(request.avatar, style: const TextStyle(fontSize: 22)),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(request.name, style: AppTextStyles.bodyMedium),
        Text('Lv.${request.level} · ${request.mutualFriends} mutual',
          style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
      ])),
      Row(children: [
        GestureDetector(
          onTap: onAccept,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: const Text('✓', style: TextStyle(color: AppColors.success, fontSize: 16)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onDecline,
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: const Text('✕', style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 14)),
          ),
        ),
      ]),
    ]),
  );
}

class _FriendCard extends StatelessWidget {
  final _Friend friend;
  const _FriendCard({required this.friend});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: AppRadius.card,
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Row(children: [
      Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: friend.avatarColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(friend.avatar, style: const TextStyle(fontSize: 24)),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(friend.name, style: AppTextStyles.bodyMedium.copyWith(fontSize: 15)),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.15), borderRadius: AppRadius.pill,
            ),
            child: Text('LV.${friend.level}', style: AppTextStyles.statXS.copyWith(color: AppColors.highlight, fontSize: 10)),
          ),
        ]),
        if (friend.lastActivity != null) ...[
          const SizedBox(height: 3),
          Text(friend.lastActivity!, style: AppTextStyles.bodySM.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
        if (friend.streak > 0) ...[
          const SizedBox(height: 2),
          Text('🔥 ${friend.streak}-day streak', style: AppTextStyles.bodySM.copyWith(color: AppColors.highlight.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ])),
      Column(children: [
        if (friend.mutualZones > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12), borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
            ),
            child: Text('⚔️ ${friend.mutualZones}', style: AppTextStyles.statXS.copyWith(color: AppColors.accent, fontSize: 10)),
          ),
        Text('›', style: AppTextStyles.bodyLG.copyWith(color: AppColors.textMuted, fontSize: 20)),
      ]),
    ]),
  );
}

class _FeedRow extends StatelessWidget {
  final _FeedItem item;
  const _FeedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isRun  = item.type == 'run';
    final isWalk = item.type == 'walk';
    final typeIcon = isRun ? '🏃' : isWalk ? '🚶' : '🗺️';
    final loc = item.location.isNotEmpty ? ' in ${item.location}' : '';
    final typeText = isRun
        ? 'ran ${item.distanceKm} km$loc'
        : isWalk
        ? 'walked ${item.distanceKm} km$loc'
        : 'captured territory$loc';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          alignment: Alignment.center,
          child: Text(item.friendAvatar, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RichText(text: TextSpan(
            style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted, height: 1.4),
            children: [
              TextSpan(text: item.friendName, style: AppTextStyles.bodyMedium),
              TextSpan(text: ' $typeText'),
            ],
          )),
          const SizedBox(height: 4),
          Row(children: [
            Text(item.when, style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 11)),
            const SizedBox(width: AppSpacing.sm),
            Text('+${item.xpEarned} XP', style: AppTextStyles.statXS.copyWith(color: AppColors.highlight)),
          ]),
        ])),
        Text(typeIcon, style: const TextStyle(fontSize: 20)),
      ]),
    );
  }
}
