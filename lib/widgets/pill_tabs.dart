import 'package:flutter/material.dart';
import 'package:runworld/utils/constants.dart';

class PillTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color accentColor;

  const PillTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
    this.accentColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.pill),
    child: Row(
      children: List.generate(tabs.length, (i) => Expanded(
        child: GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: selected == i ? accentColor : Colors.transparent,
              borderRadius: AppRadius.pill,
            ),
            alignment: Alignment.center,
            child: Text(
              tabs[i],
              style: AppTextStyles.bodySM.copyWith(
                color: selected == i ? AppColors.white : AppColors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      )),
    ),
  );
}
