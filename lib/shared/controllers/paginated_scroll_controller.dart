import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rick_and_morty/shared/theme/app_tokens.dart';

class PaginatedScrollController extends ScrollController {
  PaginatedScrollController({
    required this.onLoadMore,
    this.prefetchExtent = 500,
    this.topButtonScreens = 2,
  }) {
    addListener(refreshMetrics);
  }

  final VoidCallback onLoadMore;
  final double prefetchExtent;
  final double topButtonScreens;
  final _showScrollToTop = ValueNotifier(false);

  ValueListenable<bool> get showScrollToTop => _showScrollToTop;

  void refreshMetrics() {
    if (!hasClients || !position.hasContentDimensions) return;
    _showScrollToTop.value =
        position.pixels >= position.viewportDimension * topButtonScreens;
    if (position.extentAfter < prefetchExtent) onLoadMore();
  }

  void reset() {
    if (hasClients && position.hasContentDimensions) jumpTo(0);
    _showScrollToTop.value = false;
  }

  Future<void> scrollToTop({bool animated = true}) async {
    if (!hasClients) return;
    if (!animated) {
      jumpTo(0);
      return;
    }
    await animateTo(
      0,
      duration: AppDurations.scroll,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    removeListener(refreshMetrics);
    _showScrollToTop.dispose();
    super.dispose();
  }
}
