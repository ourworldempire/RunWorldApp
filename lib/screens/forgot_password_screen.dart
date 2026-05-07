import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runworld/services/auth_service.dart';
import 'package:runworld/utils/constants.dart';
import 'package:runworld/widgets/auth_input.dart';
import 'package:runworld/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  bool _loading = false;
  String? _error;
  String? _resetToken;

  int _resendSeconds = 0;

  final _emailCtrl   = TextEditingController();
  final _otpCtrl     = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(_emailCtrl.text.trim())) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() { _error = null; _loading = true; });
    try {
      await AuthService.instance.sendOtp(_emailCtrl.text.trim());
      if (mounted) setState(() { _loading = false; _step = 1; _resendSeconds = 60; });
      _startResendTimer();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length != 6) { setState(() => _error = 'Enter the 6-digit OTP'); return; }
    setState(() { _error = null; _loading = true; });
    try {
      _resetToken = await AuthService.instance.verifyOtp(
        email: _emailCtrl.text.trim(),
        otp:   _otpCtrl.text.trim(),
      );
      if (mounted) setState(() { _loading = false; _step = 2; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    if (_passCtrl.text.length < 8) { setState(() => _error = 'Password must be at least 8 characters'); return; }
    if (_passCtrl.text != _confirmCtrl.text) { setState(() => _error = 'Passwords do not match'); return; }
    if (_resetToken == null) { setState(() => _error = 'Session expired. Please restart.'); return; }
    setState(() { _error = null; _loading = true; });
    try {
      await AuthService.instance.resetPassword(
        resetToken:  _resetToken!,
        newPassword: _passCtrl.text,
      );
      if (mounted) setState(() { _loading = false; _step = 3; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.textLight),
                onPressed: () => _step > 0 ? setState(() { _step--; _error = null; }) : context.pop(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Step indicator
              if (_step < 3)
                Row(
                  children: List.generate(3, (i) {
                    Color color;
                    if (i < _step) { color = AppColors.success; }
                    else if (i == _step) { color = AppColors.accent; }
                    else { color = AppColors.surface; }
                    return Expanded(child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(color: color, borderRadius: AppRadius.pill),
                    ));
                  }),
                ),

              const SizedBox(height: AppSpacing.xxl),

              if (_error != null) ...[
                _ErrorBox(message: _error!),
                const SizedBox(height: AppSpacing.lg),
              ],

              if (_step == 0) ...[
                Text('FORGOT\nPASSWORD', style: AppTextStyles.displayLG),
                const SizedBox(height: AppSpacing.sm),
                Text("Enter your email and we'll send you an OTP", style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.xxl),
                AuthInput(label: 'Email', icon: Icons.email_outlined, controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(label: 'SEND OTP', onPressed: _loading ? null : _sendOtp, loading: _loading),
              ],

              if (_step == 1) ...[
                Text('VERIFY OTP', style: AppTextStyles.displayLG),
                const SizedBox(height: AppSpacing.sm),
                Text('Code sent to ${_emailCtrl.text}', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSpacing.xxl),
                AuthInput(label: '6-digit OTP', icon: Icons.pin_outlined, controller: _otpCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _resendSeconds == 0 ? _sendOtp : null,
                  child: Text(
                    _resendSeconds > 0 ? 'Resend in ${_resendSeconds}s' : 'Resend OTP',
                    style: AppTextStyles.bodySM.copyWith(color: _resendSeconds > 0 ? AppColors.textMuted : AppColors.accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(label: 'VERIFY', onPressed: _loading ? null : _verifyOtp, loading: _loading),
              ],

              if (_step == 2) ...[
                Text('NEW\nPASSWORD', style: AppTextStyles.displayLG),
                const SizedBox(height: AppSpacing.xxl),
                AuthInput(label: 'New Password', icon: Icons.lock_outline, controller: _passCtrl, obscureText: true),
                const SizedBox(height: AppSpacing.lg),
                AuthInput(label: 'Confirm Password', icon: Icons.lock_outline, controller: _confirmCtrl, obscureText: true),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(label: 'RESET PASSWORD', onPressed: _loading ? null : _resetPassword, loading: _loading),
              ],

              if (_step == 3) ...[
                const SizedBox(height: AppSpacing.xxxl),
                Center(
                  child: Column(children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: AppColors.success, size: 40),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('PASSWORD RESET!', style: AppTextStyles.displayMD.copyWith(color: AppColors.success)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Your password has been updated.', style: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.xxxl),
                    PrimaryButton(label: 'BACK TO LOGIN', onPressed: () => context.go('/login')),
                  ]),
                ),
              ],
            ],
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
