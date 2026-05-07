import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/utils/constants.dart';

class _Slide {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color glowColor;
  const _Slide(this.emoji, this.title, this.subtitle, this.accentColor, this.glowColor);
}

const _slides = [
  _Slide('🗺️', 'OWN THE MAP',
    'Run, walk, and paint Bengaluru in your color. Every street you cover becomes your territory.',
    AppColors.accent, Color(0xFFE94560)),
  _Slide('⚡', 'EARN & LEVEL UP',
    'Gain XP, unlock badges, and climb the leaderboard. Turn every run into a victory.',
    AppColors.highlight, Color(0xFFF5A623)),
  _Slide('🏆', 'DOMINATE THE CITY',
    "Challenge friends, form squads, and compete in city-wide events. The streets are waiting.",
    AppColors.success, Color(0xFF27C93F)),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      context.go('/signup');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    final accent = _slides[_currentPage].accentColor;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md, right: AppSpacing.lg),
                    child: TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text('Skip', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                    ),
                  ),
                ),
              ),

              // Slides
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
                ),
              ),

              // Dot indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? accent : AppColors.textMuted.withValues(alpha: 0.4),
                      borderRadius: AppRadius.pill,
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xl),

              // CTA button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.card,
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: AppRadius.card,
                      onTap: _next,
                      child: Center(
                        child: Text(
                          isLast ? "LET'S GO" : 'NEXT',
                          style: AppTextStyles.displaySM.copyWith(letterSpacing: 3, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ambient glow
        Positioned(
          top: size.height * 0.05,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.glowColor.withValues(alpha: 0.07),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: slide.accentColor, width: 1.5),
                  gradient: LinearGradient(
                    colors: [
                      slide.accentColor.withValues(alpha: 0.13),
                      slide.accentColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.glowColor.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(slide.emoji, style: const TextStyle(fontSize: 72)),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Accent line
              Container(
                width: 40, height: 3,
                decoration: BoxDecoration(
                  color: slide.accentColor,
                  borderRadius: AppRadius.pill,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                slide.title,
                style: AppTextStyles.displayLG.copyWith(
                  fontSize: 40,
                  letterSpacing: 4,
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Subtitle
              Text(
                slide.subtitle,
                style: AppTextStyles.bodyLG.copyWith(
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
