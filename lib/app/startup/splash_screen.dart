import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/shared.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const logoSize = AppLayout.splashLogoSize;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: PortalMark(size: logoSize)),
          Positioned(
            top: (constraints.maxHeight + logoSize) / 2 + AppSpacing.lg,
            left: AppLayout.gutter,
            right: AppLayout.gutter,
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
            child: SingleChildScrollView(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: AppDurations.appearance,
                curve: Curves.easeOut,
                builder: (_, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rick and Morty',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Вселенная в лицах',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const AppLoadingIndicator(label: 'Открываем портал…'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
