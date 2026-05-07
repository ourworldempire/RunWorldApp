import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/models/user_model.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/utils/constants.dart';

const _kMockBadges = [
  _Badge('🏃', 'First 5K', Color(0xFFE94560), 'May 1'),
  _Badge('⚡', 'Speed\nDemon', Color(0xFFF5A623), 'May 3'),
  _Badge('🗺️', 'Territory\nKing', Color(0xFF27C93F), 'May 5'),
  _Badge('🔥', '7-Day\nStreak', Color(0xFFE94560), 'May 6'),
];

class _Badge {
  final String emoji;
  final String title;
  final Color color;
  final String earned;
  const _Badge(this.emoji, this.title, this.color, this.earned);
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider) ?? UserModel.mock;
    final xpToNext = user.xpToNext;
    final xpPct = (user.xp / xpToNext).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.textLight, size: 20),
                  ),
                  Text('PROFILE', style: AppTextStyles.displayMD.copyWith(letterSpacing: 4)),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: const Text('⚙️', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(children: [
                  // Hero card
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0x26E94560), Color(0xCC16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(children: [
                      Stack(children: [
                        Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.accent, width: 3),
                            boxShadow: AppShadows.glow(AppColors.accent),
                          ),
                          alignment: Alignment.center,
                          child: Text(user.avatar, style: const TextStyle(fontSize: 48)),
                        ),
                        Positioned(
                          bottom: 4, right: 4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.success, shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2.5),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.md),

                      Text(user.name, style: AppTextStyles.displayLG.copyWith(letterSpacing: 2)),
                      Text('@${user.name.toLowerCase().replaceAll(' ', '_')}',
                        style: AppTextStyles.bodySM),
                      const SizedBox(height: AppSpacing.sm),

                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.highlight, borderRadius: AppRadius.sm_,
                          ),
                          child: Text('LV.${user.level}',
                            style: AppTextStyles.displaySM.copyWith(color: Colors.black, fontSize: 14, letterSpacing: 1)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Territory Hunter', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: AppSpacing.lg),

                      Column(children: [
                        ClipRRect(
                          borderRadius: AppRadius.pill,
                          child: LinearProgressIndicator(
                            value: xpPct,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${user.xp} XP',
                            style: AppTextStyles.statXS.copyWith(color: AppColors.highlight)),
                          Text('$xpToNext XP',
                            style: AppTextStyles.statXS),
                        ]),
                      ]),
                    ]),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Stats row
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Row(children: [
                      _StatPill('4', 'Runs'),
                      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.07)),
                      _StatPill('30 km', 'Distance'),
                      Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.07)),
                      _StatPill('40.8k', 'Steps'),
                    ]),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(children: [
                    Expanded(child: _InfoCard(icon: '🔥', value: '${user.streak}', label: 'Day Streak')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _InfoCard(
                      icon: '🗺️', value: '${user.territoryPercent}%',
                      label: 'Bengaluru', valueColor: AppColors.accent,
                    )),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _XpRingCard(xp: user.xp, xpToNext: xpToNext)),
                  ]),

                  const SizedBox(height: AppSpacing.md),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('BADGES EARNED', style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
                    GestureDetector(
                      onTap: () => context.push('/achievements'),
                      child: Text('See all →', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent, fontSize: 13)),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: _kMockBadges.map((b) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: b.color, width: 1.5),
                              color: b.color.withValues(alpha: 0.15),
                            ),
                            alignment: Alignment.center,
                            child: Text(b.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(height: 4),
                          Text(b.title, style: AppTextStyles.bodySM.copyWith(fontSize: 9, color: AppColors.textMuted), textAlign: TextAlign.center),
                          Text(b.earned, style: AppTextStyles.bodySM.copyWith(fontSize: 9, color: AppColors.textMuted.withValues(alpha: 0.5)), textAlign: TextAlign.center),
                        ]),
                      ),
                    )).toList(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('THIS WEEK', style: AppTextStyles.bodySM.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600)),
                    GestureDetector(
                      onTap: () => context.push('/dashboard'),
                      child: Text('Full stats →', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accent, fontSize: 13)),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: AppRadius.card,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: Row(children: [
                      _WeekCell('👟', '40.8k', 'steps'),
                      _WeekCell('📍', '30 km', 'distance'),
                      _WeekCell('🔥', '2,410', 'kcal'),
                    ]),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: AppRadius.card,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      alignment: Alignment.center,
                      child: Text('✏️  Edit Profile', style: AppTextStyles.bodyMedium.copyWith(fontSize: 15)),
                    ),
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

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(children: [
        Text(value, style: AppTextStyles.statMD.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySM),
      ]),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color? valueColor;
  const _InfoCard({required this.icon, required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: AppRadius.card,
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Text(value, style: AppTextStyles.statMD.copyWith(fontSize: 20, color: valueColor ?? AppColors.highlight)),
      Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}

class _XpRingCard extends StatelessWidget {
  final int xp;
  final int xpToNext;
  const _XpRingCard({required this.xp, required this.xpToNext});

  @override
  Widget build(BuildContext context) {
    final filled = ((xp / xpToNext) * 20).round().clamp(0, 20);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: [
        const Text('⚡', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        SizedBox(
          width: 60, height: 60,
          child: CustomPaint(
            painter: _XpRingPainter(filled: filled),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${xp ~/ 1000}k', style: AppTextStyles.statSM.copyWith(color: AppColors.textLight, fontSize: 12)),
                Text('/ ${xpToNext ~/ 1000}k', style: AppTextStyles.bodySM.copyWith(fontSize: 8)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('XP', style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
      ]),
    );
  }
}

class _XpRingPainter extends CustomPainter {
  final int filled;
  const _XpRingPainter({required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const segW = 3.0;
    const segH = 8.0;
    const radius = 26.0;

    for (int i = 0; i < 20; i++) {
      final angleDeg = i * 18.0 - 90.0;
      final angle = angleDeg * math.pi / 180.0;
      final color = i < filled ? AppColors.highlight : Colors.white.withValues(alpha: 0.1);
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: segW, height: segH),
          const Radius.circular(1.5),
        ),
        Paint()..color = color,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_XpRingPainter old) => old.filled != filled;
}

class _WeekCell extends StatelessWidget {
  final String icon;
  final String value;
  final String unit;
  const _WeekCell(this.icon, this.value, this.unit);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.statSM.copyWith(color: AppColors.textLight, fontSize: 16)),
        Text(unit, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
      ]),
    ),
  );
}
