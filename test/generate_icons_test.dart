// Run with: flutter test test/generate_icons_test.dart
// Generates LIAQH launcher icons and writes them to the mipmap / assets dirs.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:fitnessapp/utils/liaqh_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Generate LIAQH launcher icons', (tester) async {
    final outputs = {
      // Android mipmap launcher icons
      'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
      'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
      'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
      'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
      'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
      // App logo used by splash screen and in-app header
      'assets/images/app_logo.png': 400,
    };

    for (final entry in outputs.entries) {
      final sz = entry.value.toDouble();
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: sz,
              height: sz,
              child: LiaqhIcon(size: sz),
            ),
          ),
        ),
      );
      await tester.pump();

      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final file = File(entry.key);
      await file.writeAsBytes(bytes);
      debugPrint('✓ Wrote ${entry.key} (${entry.value}×${entry.value})');
    }
  });
}
