import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.leading,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor ?? color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(AppRadii.badge),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading case final leading?) ...[
          leading,
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}
