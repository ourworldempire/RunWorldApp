import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/services/api_service.dart';
import 'package:runworld/services/fitness_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/empty_state.dart';
import 'package:runworld/widgets/pill_tabs.dart';
import 'package:runworld/widgets/shimmer_box.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _periodTab = 0;
  int _metricTab = 0;
  bool _loading = true;
  bool _offline = false;
  WeeklyStats _stats = WeeklyStats.mock;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final stats = await FitnessService.instance.getWeeklyStats();
    if (mounted) {
      setState(() {
        _stats   = stats;
        _loading = false;
        _offline = ApiService.isOffline;
      });
    }
  }

  bool get _hasNoData => _stats.steps.every((s) => s == 0);

  List<num> get _data => _metricTab == 0
      ? _stats.steps
      : _metricTab == 1
          ? _stats.distanceKm
          : _stats.calories;

  int get _todayIndex => (DateTime.now().weekday - 1).clamp(0, 6);

  @override
  Widget build(BuildContext context) {
    final maxVal = _data.reduce((a, b) => a > b ? a : b);
    final todaySteps = _stats.steps[_todayIndex];
    const dailyGoal = 10000;
    final goalPct = (todaySteps / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('STATS', style: AppTextStyles.displayMD),
                  const Spacer(),
                ],
              ),
            ),

            // Period toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: PillTabs(
                tabs: const ['This Week', 'This Month'],
                selected: _periodTab,
                onChanged: (i) => setState(() => _periodTab = i),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(height: 16, width: 80, borderRadius: AppRadius.sm_),
                          const SizedBox(height: AppSpacing.sm),
                          ShimmerBox(height: 110, borderRadius: AppRadius.card),
                          const SizedBox(height: AppSpacing.xl),
                          ShimmerBox(height: 16, width: 120, borderRadius: AppRadius.sm_),
                          const SizedBox(height: AppSpacing.sm),
                          ShimmerBox(height: 200, borderRadius: AppRadius.card),
                        ],
                      ),
                    )
                  : _hasNoData
                      ? EmptyState(
                          emoji: '🏃',
                          title: 'No runs yet',
                          subtitle: 'Complete your first run to see\nyour stats here',
                          actionLabel: 'Start Running',
                          onAction: () => context.pop(),
                        )
                      : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total cards 2×2
                    _SectionLabel('TOTALS'),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.5,
                      children: const [
                        _TotalCard(icon: '🏃', value: '4',      label: 'Total Runs',  color: AppColors.accent),
                        _TotalCard(icon: '📍', value: '30.0 km', label: 'Distance',   color: AppColors.highlight),
                        _TotalCard(icon: '🔥', value: '2,410',  label: 'Calories',    color: Color(0xFF27C93F)),
                        _TotalCard(icon: '👟', value: '40,800', label: 'Steps',       color: Color(0xFF3498DB)),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Bar chart section
                    if (_periodTab == 0) ...[
                      _SectionLabel('WEEKLY CHART'),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: AppRadius.card,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                        ),
                        child: Column(
                          children: [
                            // Metric selector
                            Row(
                              children: List.generate(3, (i) {
                                final labels = ['STEPS', 'DISTANCE', 'CALORIES'];
                                final active = _metricTab == i;
                                return Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _metricTab = i),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: active ? AppColors.accent : Colors.transparent,
                                        borderRadius: AppRadius.pill,
                                        border: Border.all(
                                          color: active ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Text(
                                        labels[i],
                                        style: AppTextStyles.bodySM.copyWith(
                                          color: active ? Colors.white : AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // Bars
                            SizedBox(
                              height: 140,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(_stats.days.length, (i) {
                                  final val = _data[i];
                                  final ratio = maxVal > 0 ? (val / maxVal) : 0.0;
                                  final isToday = i == _todayIndex;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isToday)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            _formatVal(val),
                                            style: AppTextStyles.statXS.copyWith(
                                              color: AppColors.accent, fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeOut,
                                        width: 28,
                                        height: (120 * ratio).clamp(2.0, 120.0),
                                        decoration: BoxDecoration(
                                          gradient: isToday ? AppGradients.accent : null,
                                          color: isToday ? null : Colors.white.withValues(alpha: 0.1),
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _stats.days[i].substring(0, 2),
                                        style: AppTextStyles.statXS.copyWith(
                                          color: isToday ? AppColors.accent : AppColors.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Breakdown card
                    _SectionLabel('BREAKDOWN'),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: AppRadius.card,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            _BreakdownCell(emoji: '💨', value: '5\'42"', unit: 'min/km', label: 'Avg Pace'),
                            _BreakdownDivider(),
                            _BreakdownCell(emoji: '🏅', value: '6.5 km', unit: '', label: 'Best Run'),
                          ]),
                          const SizedBox(height: AppSpacing.sm),
                          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                          const SizedBox(height: AppSpacing.sm),
                          Row(children: [
                            _BreakdownCell(emoji: '📅', value: '5/7', unit: 'days', label: 'Active'),
                            _BreakdownDivider(),
                            _BreakdownCell(emoji: '🔥', value: '7', unit: 'days', label: 'Streak'),
                          ]),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Today highlight
                    if (_periodTab == 0) ...[
                      _SectionLabel('TODAY'),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0x1FE94560), Color(0x0AE94560)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppRadius.card,
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Text('TODAY', style: AppTextStyles.statXS.copyWith(color: AppColors.accent, letterSpacing: 2)),
                              const SizedBox(height: 4),
                              Text(
                                todaySteps.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (m) => '${m[1]},',
                                ),
                                style: AppTextStyles.statLG.copyWith(fontSize: 32),
                              ),
                              Text('steps', style: AppTextStyles.bodySM),
                            ]),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('Daily goal', style: AppTextStyles.bodySM),
                                  Text('${(dailyGoal / 1000).toStringAsFixed(0)}k', style: AppTextStyles.statSM),
                                ]),
                                const SizedBox(height: AppSpacing.sm),
                                ClipRRect(
                                  borderRadius: AppRadius.pill,
                                  child: LinearProgressIndicator(
                                    value: goalPct,
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${(goalPct * 100).round()}% complete',
                                  style: AppTextStyles.bodySM.copyWith(color: AppColors.accent, fontSize: 11),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVal(num v) {
    if (_metricTab == 1) return '${v.toStringAsFixed(1)} km';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toString();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600),
  );
}

class _TotalCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  const _TotalCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: AppRadius.card,
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.statMD.copyWith(color: color, fontSize: 22)),
      Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
    ]),
  );
}

class _BreakdownCell extends StatelessWidget {
  final String emoji;
  final String value;
  final String unit;
  final String label;
  const _BreakdownCell({required this.emoji, required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.statMD.copyWith(fontSize: 20)),
      if (unit.isNotEmpty) Text(unit, style: AppTextStyles.statXS.copyWith(fontSize: 10, letterSpacing: 0.5)),
      Text(label, style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted.withValues(alpha: 0.6), fontSize: 11)),
    ]),
  );
}

class _BreakdownDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.07));
}
