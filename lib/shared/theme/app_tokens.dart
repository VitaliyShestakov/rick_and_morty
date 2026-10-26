abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppRadii {
  static const badge = 8.0;
  static const control = 14.0;
  static const card = 20.0;
  static const hero = 28.0;
}

abstract final class AppLayout {
  static const catalogWidth = 640.0;
  static const detailsWidth = 608.0;
  static const gutter = AppSpacing.lg;
  static const splashLogoSize = 144.0;
}

abstract final class AppDurations {
  static const feedback = Duration(milliseconds: 180);
  static const transition = Duration(milliseconds: 250);
  static const appearance = Duration(milliseconds: 400);
  static const scroll = Duration(milliseconds: 450);
}
