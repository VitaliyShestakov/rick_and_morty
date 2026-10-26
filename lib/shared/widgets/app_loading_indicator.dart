import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.label, this.size = 24});

  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      if (label case final label?) ...[
        const SizedBox(height: AppSpacing.md),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
      ],
    ],
  );
}
