import 'package:flutter/material.dart';
import 'package:rick_and_morty/shared/controllers/paginated_scroll_controller.dart';
import 'package:rick_and_morty/shared/theme/app_tokens.dart';

class ScrollToTopButton extends StatelessWidget {
  const ScrollToTopButton({super.key, required this.controller});

  final PaginatedScrollController controller;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
    valueListenable: controller.showScrollToTop,
    builder: (context, visible, _) => IgnorePointer(
      ignoring: !visible,
      child: AnimatedSwitcher(
        duration: AppDurations.feedback,
        child: visible
            ? FloatingActionButton(
                tooltip: 'Наверх',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.scrollToTop(
                    animated: !MediaQuery.disableAnimationsOf(context),
                  );
                },
                child: const Icon(Icons.arrow_upward_rounded),
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
}
