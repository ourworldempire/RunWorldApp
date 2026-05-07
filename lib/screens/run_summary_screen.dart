import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/run_provider.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/fitness_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/utils/fitness_calc.dart';
import 'package:runworld/utils/haptics.dart';

class RunSummaryScreen extends ConsumerStatefulWidget {
  final dynamic params;
  const RunSummaryScreen({super.key, this.params});
  @override
  ConsumerState<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends ConsumerState<RunSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _xpCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _levelUpCtrl;
  late Animation<int>    _xpAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _levelUpAnim;

  int  _targetXP   = 0;
  bool _leveledUp  = false;
  int  _newLevel   = 1;

  @override
  void initState() {
    super.initState();
    final run = widget.params is RunState ? widget.params as RunState : null;
    _targetXP = run?.xp ?? 120;

    // Detect level-up before applying XP
    final prevLevel = ref.read(userProvider)?.level ?? 1;
    if (run != null) {
      final user = ref.read(userProvider);
      ref.read(userProvider.notifier).addXP(run.xp);
      if (user != null) FitnessService.instance.saveSession(run, user);
    }
    final newLevel = ref.read(userProvider)?.level ?? 1;
    _leveledUp = newLevel > prevLevel;
    _newLevel  = newLevel;

    _xpCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _xpAnim = IntTween(begin: 0, end: _targetXP)
        .animate(CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut));

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _levelUpCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _levelUpAnim = CurvedAnimation(parent: _levelUpCtrl, curve: Curves.easeOut);

    _xpCtrl.forward();
    _xpCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        AppHaptics.heavy();
        if (_leveledUp) {
          Future<void>.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              AppHaptics.celebrate();
              _levelUpCtrl.forward();
              // Auto-dismiss after 2.5s
              Future<void>.delayed(const Duration(milliseconds: 2500), () {
                if (mounted) _levelUpCtrl.reverse();
              });
            }
          });
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _xpCtrl.dispose();
    _fadeCtrl.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  RunState get _run => widget.params is RunState
      ? widget.params as RunState
      : const RunState(
          distanceKm: 5.2,
          steps: 6760,
          elapsedSeconds: 1800,
          calories: 420,
          xp: 120,
        );

  @override
  Widget build(BuildContext context) {
    final run = _run;
    final stats = [
      _StatItem('📍', run.distanceKm.toStringAsFixed(2), 'km', 'Distance'),
      _StatItem('⏱', formatDuration(run.elapsedSeconds), '', 'Duration'),
      _StatItem('💨', calcPace(distanceKm: run.distanceKm, durationSeconds: run.elapsedSeconds), 'min/km', 'Pace'),
      _StatItem('🔥', '${run.calories}', 'kcal', 'Calories'),
    ];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Map placeholder with simulated route
                  Container(
                    height: 200,
                    color: const Color(0xFF0D1117),
                    child: Stack(children: [
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 200),
                        painter: _RoutePainter(),
                      ),
                      const Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('🗺️', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 6),
                          Text('Run Route', style: TextStyle(
                            fontFamily: 'DMSans', fontSize: 13,
                            color: AppColors.textMuted,
                          )),
                        ]),
                      ),
                      Positioned(
                        bottom: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.9),
                            borderRadius: AppRadius.pill,
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '${run.distanceKm.toStringAsFixed(2)} km',
                            style: AppTextStyles.statSM.copyWith(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(children: [
                        // XP counter
                        AnimatedBuilder(
                          animation: _xpAnim,
                          builder: (_, _) => Column(children: [
                            Text(
                              '+${_xpAnim.value}',
                              style: AppTextStyles.statLG.copyWith(color: AppColors.accent, fontSize: 48),
                            ),
                            Text('XP EARNED',
                              style: AppTextStyles.statXS.copyWith(letterSpacing: 3, color: AppColors.textMuted)),
                          ]),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Stats 2×2 grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppSpacing.sm,
                          crossAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.5,
                          children: stats.map((s) => _StatCard(item: s)).toList(),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Badge earned
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0x1FF5A623), Color(0x0A16213E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppRadius.card,
                            border: Border.all(color: AppColors.highlight.withValues(alpha: 0.3)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('🏅', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: AppSpacing.md),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Badge Unlocked!',
                                style: AppTextStyles.bodyBold.copyWith(color: AppColors.highlight)),
                              Text('First 5K Run', style: AppTextStyles.bodySM),
                            ]),
                          ]),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Container(
                            width: double.infinity, height: 52,
                            decoration: BoxDecoration(
                              gradient: AppGradients.accent,
                              borderRadius: AppRadius.card,
                              boxShadow: AppShadows.accentGlow,
                            ),
                            alignment: Alignment.center,
                            child: Text('VIEW DASHBOARD', style: AppTextStyles.displaySM.copyWith(letterSpacing: 3)),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined, color: AppColors.accent, size: 18),
                          label: Text('Share Run',
                            style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                            minimumSize: const Size(double.infinity, 52),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Level-up overlay
          if (_leveledUp)
            AnimatedBuilder(
              animation: _levelUpAnim,
              builder: (_, _) => Opacity(
                opacity: _levelUpAnim.value,
                child: IgnorePointer(
                  ignoring: _levelUpAnim.value < 0.5,
                  child: Container(
                    color: AppColors.primary.withValues(alpha: 0.92),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🎉', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: AppSpacing.lg),
                        Text('LEVEL UP!',
                          style: AppTextStyles.displayXL.copyWith(color: AppColors.accent, letterSpacing: 6)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Level $_newLevel',
                          style: AppTextStyles.statLG.copyWith(color: AppColors.highlight)),
                        const SizedBox(height: AppSpacing.md),
                        Text('Territory radius increased',
                          style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String icon, value, unit, label;
  const _StatItem(this.icon, this.value, this.unit, this.label);
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: AppRadius.card,
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(item.icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(item.value, style: AppTextStyles.statMD.copyWith(fontSize: 24)),
      if (item.unit.isNotEmpty)
        Text(item.unit,
          style: AppTextStyles.statXS.copyWith(fontSize: 10, letterSpacing: 0.5, color: AppColors.textMuted)),
      Text(item.label, style: AppTextStyles.bodySM.copyWith(fontSize: 12, color: AppColors.textMuted.withValues(alpha: 0.7))),
    ]),
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final routePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.cubicTo(
      size.width * 0.25, size.height * 0.3,
      size.width * 0.45, size.height * 0.6,
      size.width * 0.55, size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.65, size.height * 0.1,
      size.width * 0.8, size.height * 0.5,
      size.width * 0.9, size.height * 0.4,
    );
    canvas.drawPath(path, routePaint);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 5,
        Paint()..color = AppColors.success);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.4), 5,
        Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
