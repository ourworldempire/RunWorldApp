import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/models/challenge_model.dart';
import 'package:runworld/services/api_service.dart';
import 'package:runworld/services/challenges_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/empty_state.dart';
import 'package:runworld/widgets/pill_tabs.dart';
import 'package:runworld/widgets/shimmer_box.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});
  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  int _tab = 0;
  bool _loading = true;
  bool _offline = false;
  List<ChallengeModel> _challenges = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final data = await ChallengesService.instance.getChallenges();
    if (mounted) {
      setState(() {
        _challenges = data;
        _loading    = false;
        _offline    = ApiService.isOffline;
      });
    }
  }

  List<ChallengeModel> get _active    => _challenges.where((c) => c.status == 'active').toList();
  List<ChallengeModel> get _upcoming  => _challenges.where((c) => c.status == 'upcoming').toList();
  List<ChallengeModel> get _completed => _challenges.where((c) => c.status == 'completed').toList();

  Future<void> _toggleJoin(ChallengeModel c) async {
    final wasJoined = c.joined;
    // Optimistic update
    setState(() {
      _challenges = _challenges.map((x) =>
        x.id == c.id ? ChallengeModel.fromJson({
          'id': x.id, 'emoji': x.emoji, 'title': x.title,
          'description': x.description, 'type': x.type,
          'goal_value': x.goalValue, 'goal_unit': x.goalUnit,
          'start_date': x.startDate.toIso8601String(),
          'end_date': x.endDate.toIso8601String(),
          'reward_xp': x.rewardXp, 'participant_count': x.participantCount,
          'joined': !wasJoined, 'user_progress': x.userProgress,
          'user_completed': x.userCompleted, 'status': x.status,
        }) : x,
      ).toList();
    });

    final ok = wasJoined
        ? await ChallengesService.instance.leaveChallenge(c.id)
        : await ChallengesService.instance.joinChallenge(c.id);

    // Revert on failure
    if (!ok && mounted) {
      setState(() {
        _challenges = _challenges.map((x) =>
          x.id == c.id ? c : x,
        ).toList();
      });
    }
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
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('CHALLENGES', style: AppTextStyles.displayMD.copyWith(letterSpacing: 3)),
              ]),
            ),

            // Stats strip
            _loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ShimmerBox(height: 60, borderRadius: AppRadius.card),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Row(children: [
                      _StripCell('${_active.length}',    'Active'),
                      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.07)),
                      _StripCell('${_upcoming.length}',  'Upcoming'),
                      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.07)),
                      _StripCell('${_completed.length}', 'Completed'),
                    ]),
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

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PillTabs(
                tabs: const ['Active', 'Upcoming', 'Completed'],
                selected: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Column(children: [
                        const ShimmerList(count: 3, itemHeight: 140),
                      ]),
                    )
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final List<ChallengeModel> items;
    final String label;

    switch (_tab) {
      case 0:
        items = _active;
        label = 'ACTIVE CHALLENGES · ${_active.length}';
      case 1:
        items = _upcoming;
        label = 'UPCOMING · ${_upcoming.length}';
      default:
        items = _completed;
        label = 'COMPLETED · ${_completed.length}';
    }

    if (items.isEmpty) {
      return EmptyState(
        emoji: _tab == 0 ? '🏁' : _tab == 1 ? '📅' : '🏅',
        title: _tab == 0
            ? 'No active challenges'
            : _tab == 1
                ? 'Nothing upcoming'
                : 'No completed challenges',
        subtitle: _tab == 0
            ? 'Check back soon — new challenges drop weekly'
            : _tab == 1
                ? 'New challenges are on the way'
                : 'Complete a challenge to see it here',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Text(label,
          style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),

        if (_tab == 0)
          ...items.map((c) => _ActiveCard(challenge: c)),

        if (_tab == 1)
          ...items.map((c) => _UpcomingCard(
            challenge: c,
            onToggle: () => _toggleJoin(c),
          )),

        if (_tab == 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: AppRadius.card,
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              children: items.map((c) => _CompletedRow(challenge: c)).toList(),
            ),
          ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Strip cell ────────────────────────────────────────────────────────────────

class _StripCell extends StatelessWidget {
  final String value, label;
  const _StripCell(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: AppTextStyles.statMD.copyWith(fontSize: 22)),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
    ]),
  );
}

// ── Active card ───────────────────────────────────────────────────────────────

class _ActiveCard extends StatelessWidget {
  final ChallengeModel challenge;
  const _ActiveCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final c   = challenge;
    final pct = (c.progressRatio * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.color.withValues(alpha: 0.18), const Color(0xCC16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: c.color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(c.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, style: AppTextStyles.bodyMedium.copyWith(fontSize: 15)),
            const SizedBox(height: 2),
            Text(c.description,
              style: AppTextStyles.bodySM.copyWith(height: 1.4), maxLines: 2),
          ])),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.color, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text('$pct%',
              style: AppTextStyles.statXS.copyWith(color: c.color, fontSize: 11)),
          ),
        ]),

        const SizedBox(height: AppSpacing.sm),

        ClipRRect(
          borderRadius: AppRadius.pill,
          child: LinearProgressIndicator(
            value: c.progressRatio,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(c.color),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            '${_fmtProgress(c.userProgress, c.goalUnit)} / ${_fmtProgress(c.goalValue, c.goalUnit)} ${c.goalUnit}',
            style: AppTextStyles.statXS.copyWith(fontSize: 11),
          ),
          Text('⏱ ${c.deadlineLabel}',
            style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
        ]),

        const SizedBox(height: AppSpacing.sm),

        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.highlight.withValues(alpha: 0.12),
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.highlight.withValues(alpha: 0.2)),
            ),
            child: Text('⚡ +${c.rewardXp} XP',
              style: AppTextStyles.statXS.copyWith(color: AppColors.highlight, fontSize: 11)),
          ),
          Text('👥 ${c.participantCount} runners',
            style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
        ]),
      ]),
    );
  }

  String _fmtProgress(double v, String unit) {
    if (unit == 'km' || unit == 'zones') return v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1);
    return v.toInt().toString();
  }
}

// ── Upcoming card ─────────────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onToggle;
  const _UpcomingCard({required this.challenge, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(children: [
        Text(c.emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(c.title, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14)),
          const SizedBox(height: 2),
          Text(c.description,
            style: AppTextStyles.bodySM.copyWith(fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.highlight.withValues(alpha: 0.1),
                borderRadius: AppRadius.pill,
              ),
              child: Text('⚡ +${c.rewardXp} XP',
                style: AppTextStyles.statXS.copyWith(color: AppColors.highlight, fontSize: 10)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(c.deadlineLabel,
              style: AppTextStyles.bodySM.copyWith(fontSize: 10)),
          ]),
        ])),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 7),
            decoration: BoxDecoration(
              color: c.joined ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: AppRadius.pill,
              border: Border.all(color: AppColors.accent),
            ),
            child: Text(
              c.joined ? '✓ Joined' : '+ Join',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent, fontSize: 12),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Completed row ─────────────────────────────────────────────────────────────

class _CompletedRow extends StatelessWidget {
  final ChallengeModel challenge;
  const _CompletedRow({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final c = challenge;
    return Opacity(
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: Row(children: [
          Text(c.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
            Text(c.description,
              style: AppTextStyles.bodySM.copyWith(fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('✓', style: TextStyle(color: AppColors.success, fontSize: 14)),
            Text('+${c.rewardXp}',
              style: AppTextStyles.statXS.copyWith(color: AppColors.highlight, fontSize: 13)),
            Text('XP', style: AppTextStyles.bodySM.copyWith(fontSize: 9)),
          ]),
        ]),
      ),
    );
  }
}
