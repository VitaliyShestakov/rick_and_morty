import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/theme/theme.dart';
import 'package:rick_and_morty/shared/widgets/app_loading_indicator.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.errorIcon = Icons.image_not_supported_outlined,
  });

  final String url;
  final String semanticLabel;
  final IconData errorIcon;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    semanticLabel: semanticLabel,
    frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
        frame != null || wasSynchronouslyLoaded
        ? child
        : const ColoredBox(
            color: AppColors.elevated,
            child: Center(child: AppLoadingIndicator()),
          ),
    errorBuilder: (_, _, _) => ColoredBox(
      color: AppColors.elevated,
      child: Center(
        child: Icon(
          errorIcon,
          color: AppColors.muted,
          size: 42,
          semanticLabel: 'Изображение недоступно',
        ),
      ),
    ),
  );
}
