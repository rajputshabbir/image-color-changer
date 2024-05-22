import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'image_color_changer.dart';

class ImageColorChangerWidget extends StatefulWidget {
  final String assetPath;
  final int targetColor;
  final int newColor;
  final int tolerance;

  const ImageColorChangerWidget({
    required this.assetPath,
    required this.targetColor,
    required this.newColor,
    this.tolerance = 100,
    Key? key,
  }) : super(key: key);

  @override
  ImageColorChangerWidgetState createState() => ImageColorChangerWidgetState();
}

class ImageColorChangerWidgetState extends State<ImageColorChangerWidget> {
  ui.Image? _image;
  ui.Image? _modifiedImage;

  @override
  void initState() {
    super.initState();
    _loadImage(widget.assetPath);
  }

  Future<void> _loadImage(String asset) async {
    final ByteData data = await rootBundle.load(asset);
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
    });
    _changeColor();
  }

  void _changeColor() async {
    if (_image == null) return;

    final modifiedImage = await ImageColorChanger.changeColor(
      image: _image!,
      targetColor: widget.targetColor,
      newColor: widget.newColor,
      tolerance: widget.tolerance,
    );

    setState(() {
      _modifiedImage = modifiedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _modifiedImage == null
          ? const CircularProgressIndicator()
          : RawImage(image: _modifiedImage),
    );
  }
}

extension ImageExtension on ui.Image{
  Future<ui.Image> changeColor(int targetColor, int newColor, int tolerance, ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final Uint8List data = byteData!.buffer.asUint8List();

    // /// Target color which you want to change in your image
    // int targetColor = targetColor;
    //
    // /// New color which you want to replace to target color
    // int newColor = AppColors.clr00D1FF.value;

    for (int i = 0; i < data.length; i += 4) {
      int r = data[i];
      int g = data[i + 1];
      int b = data[i + 2];

      /// Check if the pixel color is approximately equal to the target color
      if (_approximateColor(r, g, b, targetColor)) {
        data[i] = (newColor >> 16) & 0xFF; // Red
        data[i + 1] = (newColor >> 8) & 0xFF; // Green
        data[i + 2] = newColor & 0xFF; // Blue
      }
    }

    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(data);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(buffer, width: image.width, height: image.height, pixelFormat: ui.PixelFormat.rgba8888);
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  bool _approximateColor(int r1, int g1, int b1, int color) {
    int r2 = (color >> 16) & 0xFF;
    int g2 = (color >> 8) & 0xFF;
    int b2 = color & 0xFF;

    /// Define a tolerance level for color approximation
    int tolerance = 30;

    /// Check if the difference between the RGB values is within the tolerance level
    return (r1 - r2).abs() <= tolerance && (g1 - g2).abs() <= tolerance && (b1 - b2).abs() <= tolerance;
  }
}