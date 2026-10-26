import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';
import 'package:rick_and_morty/shared/widgets/app_loading_indicator.dart';

class AppPaginationFooter extends StatelessWidget {
  const AppPaginationFooter({
    super.key,
    required this.isLoading,
    required this.hasNextPage,
    required this.onRetry,
    required this.endLabel,
    this.error,
  });

  final bool isLoading;
  final bool hasNextPage;
  final String? error;
  final VoidCallback onRetry;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (isLoading) {
      content = const Center(child: AppLoadingIndicator());
    } else if (error case final error?) {
      content = Column(
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить загрузку'),
          ),
        ],
      );
    } else if (!hasNextPage) {
      content = Text(
        endLabel,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, fontSize: 12),
      );
    } else {
      content = const SizedBox(height: AppSpacing.lg);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: content,
    );
  }
}
