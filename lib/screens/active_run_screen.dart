import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/run_provider.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/utils/fitness_calc.dart';
import 'package:runworld/utils/haptics.dart';

class ActiveRunScreen extends ConsumerStatefulWidget {
  const ActiveRunScreen({super.key});
  @override
  ConsumerState<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends ConsumerState<ActiveRunScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    // Start run in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(runProvider.notifier).startRun();
      AppHaptics.medium();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _stop() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Stop Run?', style: AppTextStyles.displaySM),
        content: Text('Your run will be saved.', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppHaptics.heavy();
              final run = ref.read(runProvider.notifier).stopRun();
              context.go('/run/summary', extra: run);
            },
            child: Text('Stop', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final run = ref.watch(runProvider);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close, color: AppColors.textLight), onPressed: _stop),
                  _ActivityToggle(
                    value: run.activityType,
                    onChange: (v) => ref.read(runProvider.notifier).setActivityType(v),
                  ),
                  // GPS signal dots
                  Row(children: List.generate(3, (i) => Container(
                    width: 8, height: 8,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: i < (run.distanceKm > 0 ? 3 : 1)
                          ? AppColors.success
                          : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ))),
                ],
              ),
            ),

            const Spacer(),

            // Concentric rings + distance
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, anim) {
                final pulse = 1.0 + _pulseCtrl.value * 0.05;
                return Stack(alignment: Alignment.center, children: [
                  Container(width: 280 * pulse, height: 280 * pulse, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent.withValues(alpha: 0.1), width: 1))),
                  Container(width: 240, height: 240, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1))),
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface, border: Border.all(color: AppColors.accent, width: 2), boxShadow: AppShadows.glow(AppColors.accent)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(run.distanceKm.toStringAsFixed(2), style: AppTextStyles.statXL),
                      Text('KILOMETERS', style: AppTextStyles.statXS.copyWith(letterSpacing: 2)),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.sm_),
                        child: Text(formatDuration(run.elapsedSeconds), style: AppTextStyles.statSM.copyWith(color: AppColors.accent)),
                      ),
                    ]),
                  ),
                ]);
              },
            ),

            const Spacer(),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _RunStat(label: 'STEPS',    value: '${run.steps}'),
                  _RunStat(label: 'PACE',     value: calcPace(distanceKm: run.distanceKm, durationSeconds: run.elapsedSeconds)),
                  _RunStat(label: 'CALORIES', value: '${run.calories}'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlBtn(icon: Icons.stop, color: AppColors.error, onTap: _stop),
                  _ControlBtn(
                    icon: run.isPaused ? Icons.play_arrow : Icons.pause,
                    color: AppColors.accent,
                    size: 72,
                    onTap: () {
                      if (run.isPaused) {
                        AppHaptics.medium();
                        ref.read(runProvider.notifier).resumeRun();
                      } else {
                        AppHaptics.selection();
                        ref.read(runProvider.notifier).pauseRun();
                      }
                    },
                  ),
                  _ControlBtn(icon: Icons.flag_outlined, color: AppColors.textMuted, onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _ActivityToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const _ActivityToggle({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: 'RUN',  active: value == kActivityRunning, onTap: () => onChange(kActivityRunning)),
          _Pill(label: 'WALK', active: value == kActivityWalking, color: AppColors.highlight, onTap: () => onChange(kActivityWalking)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color color;
  const _Pill({required this.label, required this.active, required this.onTap, this.color = AppColors.accent});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: active ? color : Colors.transparent, borderRadius: AppRadius.pill),
      child: Text(label, style: AppTextStyles.bodySM.copyWith(color: active ? AppColors.white : AppColors.textMuted, fontWeight: FontWeight.w700)),
    ),
  );
}

class _RunStat extends StatelessWidget {
  final String label;
  final String value;
  const _RunStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: AppTextStyles.statMD),
    const SizedBox(height: 2),
    Text(label, style: AppTextStyles.statXS),
  ]);
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.color, required this.onTap, this.size = 56});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.15), border: Border.all(color: color, width: 2)),
      child: Icon(icon, color: color, size: size * 0.45),
    ),
  );
}
