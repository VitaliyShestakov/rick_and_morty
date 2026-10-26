import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/branding/portal_mark.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';

class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
        child: const PortalMark(size: 30),
      ),
      const SizedBox(width: AppSpacing.sm),
      const Expanded(
        child: Text(
          'RICK AND MORTY',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const Icon(
        Icons.auto_awesome_outlined,
        color: AppColors.accent,
        size: 22,
      ),
    ],
  );
}
