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
