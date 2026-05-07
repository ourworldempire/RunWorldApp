import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/auth_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/auth_input.dart';
import 'package:runworld/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  String? _error;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(_emailCtrl.text.trim())) {
      setState(() => _error = 'Enter a valid email');
      _shakeCtrl.forward(from: 0);
      return false;
    }
    if (_passCtrl.text.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters');
      _shakeCtrl.forward(from: 0);
      return false;
    }
    return true;
  }

  Future<void> _login() async {
    if (!_validate()) return;
    setState(() { _error = null; _loading = true; });
    try {
      final user = await AuthService.instance.login(
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      ref.read(userProvider.notifier).setUser(user);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
      _shakeCtrl.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnim.value * ((_shakeCtrl.value < 0.5) ? 1 : -1), 0),
            child: child,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text('WELCOME\nBACK', style: AppTextStyles.displayLG),
                const SizedBox(height: AppSpacing.xxl),

                if (_error != null) ...[
                  _ErrorBox(message: _error!),
                  const SizedBox(height: AppSpacing.lg),
                ],

                AuthInput(label: 'Email', icon: Icons.email_outlined, controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: AppSpacing.lg),
                AuthInput(label: 'Password', icon: Icons.lock_outline, controller: _passCtrl, obscureText: true, textInputAction: TextInputAction.done, onSubmitted: _login),
                const SizedBox(height: AppSpacing.md),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text('Forgot Password?', style: AppTextStyles.bodySM.copyWith(color: AppColors.accent)),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'LOGIN', onPressed: _loading ? null : _login, loading: _loading),
                const SizedBox(height: AppSpacing.xxl),

                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted),
                        children: [TextSpan(text: 'Sign Up', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: AppRadius.card, border: Border.all(color: AppColors.error.withValues(alpha: 0.5))),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(message, style: AppTextStyles.bodyMD.copyWith(color: AppColors.error))),
    ]),
  );
}
