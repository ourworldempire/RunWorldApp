import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/providers/user_provider.dart';
import 'package:runworld/services/auth_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/auth_input.dart';
import 'package:runworld/widgets/primary_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  String _selectedAvatar = '🏃';
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _shake() {
    _shakeCtrl.forward(from: 0);
  }

  bool _validateStep0() {
    if (_nameCtrl.text.trim().length < 2) { setState(() => _error = 'Name must be at least 2 characters'); _shake(); return false; }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(_emailCtrl.text.trim())) { setState(() => _error = 'Enter a valid email'); _shake(); return false; }
    if (_passCtrl.text.length < 8) { setState(() => _error = 'Password must be at least 8 characters'); _shake(); return false; }
    if (_passCtrl.text != _confirmCtrl.text) { setState(() => _error = 'Passwords do not match'); _shake(); return false; }
    return true;
  }

  Future<void> _signUpWithGoogle() async {
    setState(() { _error = null; _googleLoading = true; });
    try {
      final user = await AuthService.instance.loginWithGoogle();
      ref.read(userProvider.notifier).setUser(user);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      _shake();
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _submit() async {
    setState(() { _error = null; _loading = true; });
    try {
      final user = await AuthService.instance.signUp(
        name:     _nameCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
        avatar:   _selectedAvatar,
      );
      ref.read(userProvider.notifier).setUser(user);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
      _shake();
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
                Text('CREATE\nACCOUNT', style: AppTextStyles.displayLG),
                const SizedBox(height: AppSpacing.sm),
                Text('Step ${_step + 1} of 2', style: AppTextStyles.bodySM),
                const SizedBox(height: AppSpacing.xxl),

                if (_error != null) _ErrorBox(message: _error!),
                if (_error != null) const SizedBox(height: AppSpacing.lg),

                if (_step == 0) ...[
                  AuthInput(label: 'Full Name',        icon: Icons.person_outline,    controller: _nameCtrl),
                  const SizedBox(height: AppSpacing.lg),
                  AuthInput(label: 'Email',            icon: Icons.email_outlined,    controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: AppSpacing.lg),
                  AuthInput(label: 'Password',         icon: Icons.lock_outline,      controller: _passCtrl,    obscureText: true),
                  const SizedBox(height: AppSpacing.lg),
                  AuthInput(label: 'Confirm Password', icon: Icons.lock_outline,      controller: _confirmCtrl, obscureText: true),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: 'NEXT',
                    onPressed: () {
                      if (_validateStep0()) setState(() { _error = null; _step = 1; });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _OrDivider(),
                  const SizedBox(height: AppSpacing.lg),
                  _GoogleButton(loading: _googleLoading, onTap: _signUpWithGoogle),
                ] else ...[
                  Text('CHOOSE YOUR AVATAR', style: AppTextStyles.displaySM.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12),
                    itemCount: kAvatarOptions.length,
                    itemBuilder: (_, i) {
                      final av = kAvatarOptions[i];
                      final selected = av == _selectedAvatar;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAvatar = av),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.card,
                            border: Border.all(color: selected ? AppColors.accent : Colors.transparent, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Center(child: Text(av, style: const TextStyle(fontSize: 32))),
                              if (selected)
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(label: 'CREATE ACCOUNT', onPressed: _loading ? null : _submit, loading: _loading),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _step = 0),
                      child: Text('Back', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted),
                        children: [TextSpan(text: 'Login', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent))],
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text('OR', style: AppTextStyles.bodySM.copyWith(color: AppColors.textMuted, letterSpacing: 2)),
    ),
    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
  ]);
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: AppRadius.card,
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('G', style: AppTextStyles.displaySM.copyWith(color: const Color(0xFF4285F4), fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text('Continue with Google', style: AppTextStyles.bodyBold.copyWith(color: AppColors.textLight)),
            ]),
    ),
  );
}
