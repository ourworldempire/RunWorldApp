import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/services/achievements_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/pill_tabs.dart';
import 'package:runworld/widgets/shimmer_box.dart';

// ── Static badge definitions ─────────────────────────────────────────────────

class _BadgeDef {
  final String id, emoji, title, category;
  final Color color;
  const _BadgeDef(this.id, this.emoji, this.title, this.category, this.color);
}

const _kBadges = [
  // Running
  _BadgeDef('first_run',     '🏃', 'First Run',        'running',   Color(0xFFE94560)),
  _BadgeDef('run_5k',        '🏅', 'First 5K',         'running',   Color(0xFFE94560)),
  _BadgeDef('run_10k',       '🏅', '10K Club',         'running',   Color(0xFFE94560)),
  _BadgeDef('run_50k',       '💎', '50K Legend',       'running',   Color(0xFF9B59B6)),
  _BadgeDef('morning_runner','☀️', 'Morning Runner',   'running',   Color(0xFFF5A623)),
  _BadgeDef('speed_demon',   '⚡', 'Speed Demon',      'running',   Color(0xFFF5A623)),
  // Territory
  _BadgeDef('first_capture', '📍', 'First Capture',    'territory', Color(0xFF27C93F)),
  _BadgeDef('zone_lord',     '🗺️', 'Zone Lord',        'territory', Color(0xFF27C93F)),
  _BadgeDef('district_king', '👑', 'District King',    'territory', Color(0xFF27C93F)),
  _BadgeDef('city_dominator','🌍', 'City Dominator',   'territory', Color(0xFF27C93F)),
  _BadgeDef('night_raider',  '🌙', 'Night Raider',     'territory', Color(0xFF3498DB)),
  _BadgeDef('comeback_king', '🔥', 'Comeback King',    'territory', Color(0xFFE94560)),
  // Social
  _BadgeDef('first_friend',  '👥', 'First Friend',     'social',    Color(0xFF3498DB)),
  _BadgeDef('squad_up',      '🤝', 'Squad Up',         'social',    Color(0xFF3498DB)),
  _BadgeDef('social_butterfly','🦋','Social Butterfly', 'social',   Color(0xFF3498DB)),
  _BadgeDef('community_leader','🏆','Community Leader', 'social',   Color(0xFFFFD700)),
  _BadgeDef('rival',         '⚔️', 'Rival',            'social',    Color(0xFFE94560)),
  _BadgeDef('mentor',        '🎓', 'Mentor',           'social',    Color(0xFF9B59B6)),
  // Streaks
  _BadgeDef('streak_3',      '🔥', '3-Day Streak',     'streaks',   Color(0xFFE94560)),
  _BadgeDef('streak_7',      '🔥', '7-Day Streak',     'streaks',   Color(0xFFE94560)),
  _BadgeDef('streak_30',     '🔥', '30-Day Streak',    'streaks',   Color(0xFFE94560)),
  _BadgeDef('streak_100',    '💪', '100-Day Streak',   'streaks',   Color(0xFFFFD700)),
  _BadgeDef('unstoppable',   '⚡', 'Unstoppable',      'streaks',   Color(0xFF9B59B6)),
  _BadgeDef('legend',        '👑', 'Legend',           'streaks',   Color(0xFFFFD700)),
];

const _kCategories = ['All', 'Running', 'Territory', 'Social', 'Streaks'];
const _kCatKeys    = [null, 'running', 'territory', 'social', 'streaks'];

// ── Screen ───────────────────────────────────────────────────────────────────

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});
  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  int _catIndex = 0;
  bool _loading = true;

  // badge_id → earned_at string (formatted)
  Map<String, String> _earnedDates = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final badges = await AchievementsService.instance.getMyAchievements();
    if (mounted) {
      setState(() {
        _earnedDates = {
          for (final b in badges)
            b.badgeId: _formatDate(b.earnedAt),
        };
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  List<_BadgeDef> get _filtered => _kCatKeys[_catIndex] == null
      ? _kBadges
      : _kBadges.where((b) => b.category == _kCatKeys[_catIndex]).toList();

  @override
  Widget build(BuildContext context) {
    final earnedCount = _earnedDates.length;
    final total       = _kBadges.length;
    final pct         = total > 0 ? (earnedCount / total * 100).round() : 0;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('ACHIEVEMENTS', style: AppTextStyles.displayMD.copyWith(letterSpacing: 3)),
              ]),
            ),

            // Summary card
            _loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ShimmerBox(height: 72, borderRadius: AppRadius.card),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0x1FF5A623), Color(0x0A16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.highlight.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      Column(children: [
                        Text('$earnedCount',
                          style: AppTextStyles.displayLG.copyWith(color: AppColors.highlight, fontSize: 36)),
                        Text('of $total earned',
                          style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
                      ]),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('$pct%', style: AppTextStyles.statMD.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: AppRadius.pill,
                          child: LinearProgressIndicator(
                            value: total > 0 ? earnedCount / total : 0,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('completion', style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
                      ])),
                      const Text('🏆', style: TextStyle(fontSize: 36)),
                    ]),
                  ),
            const SizedBox(height: AppSpacing.sm),

            // Category tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PillTabs(
                tabs: _kCategories,
                selected: _catIndex,
                onChanged: (i) => setState(() => _catIndex = i),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: 12,
                        itemBuilder: (_, _) => ShimmerBox(height: 110, borderRadius: AppRadius.card),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          _kCatKeys[_catIndex] != null
                              ? '${_kCategories[_catIndex].toUpperCase()} · ${_filtered.where((b) => _earnedDates.containsKey(b.id)).length}/${_filtered.length}'
                              : 'ALL BADGES · $earnedCount/$total',
                          style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final badge    = _filtered[i];
                            final earnedAt = _earnedDates[badge.id];
                            return _BadgeCard(badge: badge, earnedAt: earnedAt);
                          },
                        ),

                        const SizedBox(height: AppSpacing.xxl),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge card ────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final _BadgeDef badge;
  final String?   earnedAt; // null = not yet earned

  const _BadgeCard({required this.badge, required this.earnedAt});

  bool get earned => earnedAt != null;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: earned ? 1.0 : 0.45,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: earned
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: earned
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: earned ? badge.color : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              color: earned ? badge.color.withValues(alpha: 0.2) : Colors.transparent,
            ),
            alignment: Alignment.center,
            child: Text(badge.emoji, style: const TextStyle(fontSize: 26)),
          ),
          if (earned)
            Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: badge.color,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text('✓',
                style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ]),

        const SizedBox(height: 6),

        Text(
          badge.title,
          style: AppTextStyles.bodySM.copyWith(
            fontSize: 9.5,
            color: earned ? AppColors.textLight : AppColors.textMuted,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),

        const SizedBox(height: 4),

        if (earned)
          Text(earnedAt!, style: AppTextStyles.bodySM.copyWith(color: badge.color, fontSize: 8.5))
        else
          Text('🔒 Locked', style: AppTextStyles.bodySM.copyWith(fontSize: 8.5)),
      ]),
    ),
  );
}
