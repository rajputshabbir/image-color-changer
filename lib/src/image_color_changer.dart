import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class ImageColorChanger {
  static Future<ui.Image> changeColor({
    required ui.Image image,
    required int targetColor,
    required int newColor,
    int tolerance = 100,
  }) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception("Unable to get byte data from image");
    }
    final Uint8List data = byteData.buffer.asUint8List();

    for (int i = 0; i < data.length; i += 4) {
      int r = data[i];
      int g = data[i + 1];
      int b = data[i + 2];

      if (_approximateColor(r, g, b, targetColor, tolerance)) {
        data[i] = (newColor >> 16) & 0xFF; // Red
        data[i + 1] = (newColor >> 8) & 0xFF; // Green
        data[i + 2] = newColor & 0xFF; // Blue
      }
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: image.width,
      height: image.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    return frameInfo.image;
  }

  static bool _approximateColor(int r1, int g1, int b1, int color, int tolerance) {
    int r2 = (color >> 16) & 0xFF;
    int g2 = (color >> 8) & 0xFF;
    int b2 = color & 0xFF;

    return (r1 - r2).abs() <= tolerance &&
        (g1 - g2).abs() <= tolerance &&
        (b1 - b2).abs() <= tolerance;
  }
}
