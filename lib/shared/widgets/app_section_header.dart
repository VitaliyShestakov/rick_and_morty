import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.muted),
        ),
      ),
      if (trailing case final trailing?) ...[
        const SizedBox(width: AppSpacing.sm),
        trailing,
      ],
    ],
  );
}
