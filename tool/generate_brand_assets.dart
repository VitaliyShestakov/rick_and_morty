import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty/shared/shared.dart';

Future<void> _writePng(
  String path,
  int pixels, {
  bool background = false,
  double markScale = 1,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background) {
    canvas.drawColor(AppColors.background, BlendMode.src);
  }
  final markSize = pixels * markScale;
  canvas.translate((pixels - markSize) / 2, (pixels - markSize) / 2);
  const PortalPainter().paint(canvas, Size.square(markSize));
  final picture = recorder.endRecording();
  final image = await picture.toImage(pixels, pixels);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'generate launcher and splash assets from the shared portal painter',
    () async {
      await _writePng(
        'assets/branding/app_icon.png',
        1024,
        background: true,
        markScale: 0.78,
      );

      final androidResources = 'android/app/src/main/res';
      for (final (density, scale) in [
        ('mdpi', 1.0),
        ('hdpi', 1.5),
        ('xhdpi', 2.0),
        ('xxhdpi', 3.0),
        ('xxxhdpi', 4.0),
      ]) {
        await _writePng(
          '$androidResources/mipmap-$density/ic_launcher.png',
          (48 * scale).round(),
          background: true,
          markScale: 0.78,
        );
        await _writePng(
          '$androidResources/drawable-$density/splash_logo.png',
          (144 * scale).round(),
        );
      }
      await _writePng(
        '$androidResources/drawable-nodpi/ic_launcher_foreground.png',
        432,
        markScale: 0.6,
      );

      const iosAssets = 'ios/Runner/Assets.xcassets';
      final icons = jsonDecode(
        await File('$iosAssets/AppIcon.appiconset/Contents.json')
            .readAsString(),
      ) as Map<String, dynamic>;
      for (final item in icons['images'] as List<dynamic>) {
        final icon = item as Map<String, dynamic>;
        final points = double.parse((icon['size'] as String).split('x').first);
        final scale = double.parse(
          (icon['scale'] as String).replaceAll('x', ''),
        );
        await _writePng(
          '$iosAssets/AppIcon.appiconset/${icon['filename']}',
          (points * scale).round(),
          background: true,
          markScale: 0.78,
        );
      }
      for (final scale in [1, 2, 3]) {
        final suffix = scale == 1 ? '' : '@${scale}x';
        await _writePng(
          '$iosAssets/LaunchImage.imageset/LaunchImage$suffix.png',
          144 * scale,
        );
      }
    },
  );
}
