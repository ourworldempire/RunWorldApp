import 'package:flutter/material.dart';
import 'package:runworld/utils/constants.dart';

class AuthInput extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const AuthInput({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      style: AppTextStyles.bodyLG,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTextStyles.bodySM,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: Icon(widget.icon, color: AppColors.textMuted, size: 20),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        errorText: widget.errorText,
        errorStyle: AppTextStyles.bodySM.copyWith(color: AppColors.error),
        border: OutlineInputBorder(borderRadius: AppRadius.card, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.card, borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.card, borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppRadius.card, borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: hasError ? AppColors.error : Colors.transparent, width: 1.5),
        ),
      ),
    );
  }
}
