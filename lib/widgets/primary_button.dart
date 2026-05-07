import 'package:flutter/material.dart';
import 'package:runworld/utils/constants.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final LinearGradient? gradient;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: loading ? null : (gradient ?? AppGradients.accent),
          color: loading ? AppColors.surface : null,
          borderRadius: AppRadius.card,
          boxShadow: loading ? [] : AppShadows.accentGlow,
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
              )
            : Text(label, style: AppTextStyles.displaySM),
      ),
    );
  }
}
