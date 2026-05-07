import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/providers/settings_provider.dart';
import 'package:runworld/utils/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _lineWidth;
  late Animation<double> _versionOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

    _logoScale     = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _logoOpacity   = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.30, curve: Curves.easeOut)));
    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.20, 0.50, curve: Curves.easeOut)));
    _lineWidth     = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.60, curve: Curves.easeOut)));
    _versionOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)));

    _ctrl.forward();

    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      ref.read(userProvider.notifier).hydrate(),
      ref.read(settingsProvider.notifier).hydrate(),
      Future.delayed(const Duration(milliseconds: 2400)),
    ]);
    if (!mounted) return;
    final user = ref.read(userProvider);
    context.go(user != null ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Column(
                        children: [
                          const Text('🌍', style: TextStyle(fontSize: 72)),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'RUNWORLD',
                            style: AppTextStyles.displayXL.copyWith(
                              color: AppColors.accent,
                              letterSpacing: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Accent line
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _lineWidth.value,
                      child: Container(
                        width: 120,
                        height: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Tagline
                  Opacity(
                    opacity: _taglineOpacity.value,
                    child: Text(
                      'OWN BENGALURU. ONE RUN AT A TIME.',
                      style: AppTextStyles.bodyMD.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Version
                  Opacity(
                    opacity: _versionOpacity.value,
                    child: Text('v1.0.0', style: AppTextStyles.statXS),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
