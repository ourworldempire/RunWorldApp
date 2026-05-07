import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/api_service.dart';
import 'package:runworld/services/fitness_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/shimmer_box.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  TodayStats _todayStats = TodayStats.mock;
  bool _loading = true;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await FitnessService.instance.getTodayStats();
    if (mounted) {
      setState(() {
        _todayStats = stats;
        _loading    = false;
        _offline    = ApiService.isOffline;
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Simulated dark map background
          const _MockMap(),

          // Top HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar button
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.9),
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: AppColors.accent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(user?.avatar ?? '🏃', style: const TextStyle(fontSize: 22)),
                    ),
                  ),

                  // App name tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.9),
                      borderRadius: AppRadius.pill,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text('RUNWORLD', style: AppTextStyles.displaySM.copyWith(letterSpacing: 3, fontSize: 16)),
                  ),

                  // Notification bell
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.9),
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Text('🔔', style: TextStyle(fontSize: 20)),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Territory legend chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 70, left: AppSpacing.lg),
              child: Row(
                children: [
                  _LegendChip(color: AppColors.accent, label: 'Your zones'),
                  const SizedBox(width: AppSpacing.sm),
                  _LegendChip(color: AppColors.textMuted, label: 'Others'),
                ],
              ),
            ),
          ),

          // Animated user pulse dot (simulated center of Bengaluru)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => CustomPaint(
                painter: _PulsePainter(progress: _pulseCtrl.value),
              ),
            ),
          ),

          // FABs
          Positioned(
            right: AppSpacing.lg,
            bottom: 240,
            child: Column(
              children: [
                _FAB(emoji: '🏆', onTap: () => context.push('/leaderboard')),
                const SizedBox(height: AppSpacing.sm),
                _FAB(emoji: '📍', onTap: () {}),
              ],
            ),
          ),

          // Offline banner
          if (_offline)
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 6),
                  color: const Color(0xCC1A1A2E),
                  child: Row(children: [
                    const Icon(Icons.wifi_off, color: AppColors.error, size: 14),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Offline — showing cached data',
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.error, fontSize: 11),
                    ),
                  ]),
                ),
              ),
            ),

          // Bottom overlay card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _MapOverlayCard(
              user: user,
              todayStats: _todayStats,
              loading: _loading,
              onStartRun: () => context.push('/run/active'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMap extends StatelessWidget {
  const _MockMap();

  // Bengaluru city center
  static const _bengaluru = LatLng(12.9716, 77.5946);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: _bengaluru,
        initialZoom:   14,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // CartoDB Dark Matter — free, no API key, dark-themed
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.ritanjay.runworld',
          retinaMode: true,
        ),
        // User location marker
        MarkerLayer(
          markers: [
            Marker(
              point: _bengaluru,
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: AppShadows.accentGlow,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress;
  _PulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.45, size.height * 0.4);
    final maxRadius = 36.0;
    final pulseRadius = maxRadius * progress;
    final pulseOpacity = (1.0 - progress) * 0.4;

    canvas.drawCircle(
      center, pulseRadius,
      Paint()
        ..color = AppColors.accent.withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center, 7,
      Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center, 7,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.progress != progress;
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.secondary.withValues(alpha: 0.88),
      borderRadius: AppRadius.pill,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.bodySM.copyWith(fontSize: 11)),
    ]),
  );
}

class _FAB extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;
  const _FAB({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.95),
        borderRadius: AppRadius.pill,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const [BoxShadow(color: Color(0x4D000000), blurRadius: 8, offset: Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    ),
  );
}

class _MapOverlayCard extends StatelessWidget {
  final dynamic user;
  final TodayStats todayStats;
  final bool loading;
  final VoidCallback onStartRun;
  const _MapOverlayCard({
    required this.user,
    required this.todayStats,
    required this.loading,
    required this.onStartRun,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User XP header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name?.split(' ').first ?? 'Runner', style: AppTextStyles.bodyBold),
                Text('Lv.${user?.level ?? 1} · Territory Hunter', style: AppTextStyles.bodySM),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Text('${user?.xp ?? 0} XP', style: AppTextStyles.statSM.copyWith(color: AppColors.accent)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Today's stats (shimmer while loading)
          loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (_) => Column(children: [
                    ShimmerBox(width: 52, height: 22, borderRadius: AppRadius.sm_),
                    const SizedBox(height: 4),
                    ShimmerBox(width: 36, height: 10, borderRadius: AppRadius.sm_),
                  ])),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCell(label: 'STEPS', value: '${todayStats.steps}'),
                    _StatCell(label: 'KM',    value: todayStats.distanceKm.toStringAsFixed(1)),
                    _StatCell(label: 'KCAL',  value: '${todayStats.calories}'),
                    _StatCell(label: 'MINS',  value: '${todayStats.activeMinutes}'),
                  ],
                ),
          const SizedBox(height: AppSpacing.lg),

          // Start run button
          GestureDetector(
            onTap: onStartRun,
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: AppGradients.accent,
                borderRadius: AppRadius.card,
                boxShadow: AppShadows.accentGlow,
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.play_circle_outline, color: Colors.white, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text('START RUN', style: AppTextStyles.displaySM.copyWith(letterSpacing: 3)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: AppTextStyles.statMD),
    const SizedBox(height: 2),
    Text(label, style: AppTextStyles.statXS.copyWith(letterSpacing: 1.5, fontSize: 10)),
  ]);
}
