import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/models/leaderboard_entry_model.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/api_service.dart';
import 'package:runworld/services/leaderboard_service.dart';
import 'package:runworld/widgets/pill_tabs.dart';
import 'package:runworld/widgets/shimmer_box.dart';
import 'package:runworld/utils/constants.dart';

const _kMedalColors = [Color(0xFFFFD700), Color(0xFFC0C0C0), Color(0xFFCD7F32)];
const _kMedalEmoji  = ['🥇', '🥈', '🥉'];
const _kPodiumH     = [110.0, 80.0, 64.0];

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _tab    = 0;
  int _period = 0;
  bool _loading = true;
  bool _isError = false;

  List<LeaderboardEntryModel> _data = LeaderboardEntryModel.mockList;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _isError = false; });
    final userId = ref.read(userProvider)?.id;
    final List<LeaderboardEntryModel> result;
    if (_tab == 0) {
      result = await LeaderboardService.instance.getCityLeaderboard(periodIndex: _period, currentUserId: userId);
    } else if (_tab == 1) {
      result = await LeaderboardService.instance.getFriendsLeaderboard(periodIndex: _period, currentUserId: userId);
    } else {
      result = await LeaderboardService.instance.getNearbyLeaderboard(currentUserId: userId);
    }
    if (mounted) {
      setState(() {
        _data     = result;
        _loading  = false;
        _isError  = ApiService.isOffline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final top3 = _data.take(3).toList();
    final rest = _data.skip(3).toList();
    final myEntry = _data.firstWhere((e) => e.isYou, orElse: () => _data.first);
    final showStickyRank = myEntry.rank > 10;

    // Podium order: 2nd left, 1st center, 3rd right
    final podiumOrder = [top3[1], top3[0], top3[2]];
    final podiumPos   = [2, 1, 3];

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
                Text('LEADERBOARD', style: AppTextStyles.displayMD.copyWith(letterSpacing: 4)),
              ]),
            ),

            // Ambient glow
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: Center(
                child: Container(
                  width: 300, height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      AppColors.accent.withValues(alpha: 0.3),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),

            // Scope tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PillTabs(
                tabs: const ['City', 'Friends', 'Nearby'],
                selected: _tab,
                onChanged: (i) { setState(() => _tab = i); _load(); },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Period buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(2, (i) {
                  final labels = ['This Week', 'All Time'];
                  final active = _period == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () { setState(() => _period = i); _load(); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.highlight.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                            color: active ? AppColors.highlight : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Text(
                          labels[i],
                          style: AppTextStyles.bodySM.copyWith(
                            color: active ? AppColors.highlight : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Offline banner
            if (_isError)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
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

            if (_isError) const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(children: [
                        // Podium shimmer
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(child: ShimmerBox(height: 130, borderRadius: AppRadius.card)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: ShimmerBox(height: 160, borderRadius: AppRadius.card)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: ShimmerBox(height: 110, borderRadius: AppRadius.card)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const ShimmerList(count: 5, itemHeight: 60),
                      ]),
                    )
                  : ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg,
                  showStickyRank ? 90 : AppSpacing.xl,
                ),
                children: [
                  // Podium
                  if (top3.length == 3)
                    SizedBox(
                      height: 220,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(3, (i) {
                          final entry = podiumOrder[i];
                          final pos   = podiumPos[i];
                          final color = _kMedalColors[pos - 1];
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(_kMedalEmoji[pos - 1], style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 6),
                                Container(
                                  width: 54, height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.06),
                                    border: Border.all(color: color, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Stack(alignment: Alignment.center, children: [
                                    Text(entry.avatar, style: const TextStyle(fontSize: 26)),
                                    if (entry.isYou)
                                      Positioned(
                                        bottom: 0, right: 0,
                                        child: Container(
                                          width: 14, height: 14,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent, shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.primary, width: 2),
                                          ),
                                        ),
                                      ),
                                  ]),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.isYou ? 'You' : entry.name.split(' ').first,
                                  style: AppTextStyles.bodySM.copyWith(
                                    color: entry.isYou ? AppColors.accent : AppColors.textLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: _kPodiumH[i],
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.18),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    border: Border(top: BorderSide(color: color, width: 2)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(entry.xp / 1000).toStringAsFixed(1)}k',
                                        style: AppTextStyles.statSM.copyWith(color: color, fontSize: 13),
                                      ),
                                      Text(
                                        '${entry.distanceKm} km',
                                        style: AppTextStyles.bodySM.copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // Rankings label
                  Text('RANKINGS', style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),

                  // Rank rows
                  ...rest.map((entry) => _RankRow(entry: entry)),
                ],
              ),
            ),

            // Sticky own rank
            if (showStickyRank && !_loading)
              Container(
                margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFA16213E), Color(0xFA0F3460)],
                  ),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                    child: Text('YOUR RANK', style: AppTextStyles.statXS.copyWith(color: AppColors.accent, letterSpacing: 2)),
                  ),
                  _RankRow(entry: myEntry),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _RankRow({required this.entry});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    decoration: BoxDecoration(
      color: entry.isYou
          ? AppColors.accent.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.03),
      borderRadius: AppRadius.card,
      border: Border.all(
        color: entry.isYou
            ? AppColors.accent.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
      ),
    ),
    child: Row(children: [
      SizedBox(
        width: 32,
        child: Text(
          '#${entry.rank}',
          style: AppTextStyles.statSM.copyWith(
            color: entry.isYou ? AppColors.accent : AppColors.textMuted,
          ),
        ),
      ),
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: entry.isYou ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(entry.avatar, style: const TextStyle(fontSize: 20)),
      ),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          entry.isYou ? '${entry.name} (You)' : entry.name,
          style: AppTextStyles.bodyMedium.copyWith(
            color: entry.isYou ? AppColors.accent : AppColors.textLight,
          ),
        ),
        Text(
          'Lv.${entry.level} · ${entry.distanceKm} km',
          style: AppTextStyles.bodySM.copyWith(fontSize: 11),
        ),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(
          '${(entry.xp / 1000).toStringAsFixed(1)}k',
          style: AppTextStyles.statSM.copyWith(
            color: entry.isYou ? AppColors.accent : AppColors.textLight,
          ),
        ),
        Text('XP', style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
      ]),
    ]),
  );
}
