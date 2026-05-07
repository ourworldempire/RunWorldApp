import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runworld/router/app_router.dart';
import 'package:runworld/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.primary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: RunWorldApp()));
}

class RunWorldApp extends ConsumerWidget {
  const RunWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'RunWorld',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary:   AppColors.accent,
          secondary: AppColors.highlight,
          surface:   AppColors.secondary,
          error:     AppColors.error,
        ),
        fontFamily: 'DMSans',
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(fontFamily: 'DMSans', color: AppColors.textLight),
          bodyMedium: TextStyle(fontFamily: 'DMSans', color: AppColors.textLight),
          bodySmall:  TextStyle(fontFamily: 'DMSans', color: AppColors.textMuted),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.accent : AppColors.textMuted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.accent.withValues(alpha: 0.3) : AppColors.surface,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        }),
      ),
    );
  }
}
