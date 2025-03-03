import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> noEntrySignMarkerOpacity() async {
  const String assetPath = 'assets/forbidden-opacity.png';
  final ByteData byteData = await rootBundle.load(assetPath);
  final Uint8List bytes = byteData.buffer.asUint8List();
  return BitmapDescriptor.bytes(bytes);
}

Future<BitmapDescriptor> noEntrySignMarker() async {
  const String assetPath = 'assets/forbidden.png';
  final ByteData byteData = await rootBundle.load(assetPath);
  final Uint8List bytes = byteData.buffer.asUint8List();
  return BitmapDescriptor.bytes(bytes);
}

Future<BitmapDescriptor> createTextBitmapDescriptor(String text) async {
  // Define text style
  TextStyle textStyle = const TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  // Define a TextPainter to draw the text
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  textPainter.layout(minWidth: 0, maxWidth: double.infinity);

  // Create a picture recorder to record the canvas operations
  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas canvas = Canvas(recorder);

  // Calculate the size of the painted text and add padding for the border
  double padding = 2.0;
  double strokeWidth = 1.0; // Width of the border
  Size size =
      Size(textPainter.width + padding * 2, textPainter.height + padding * 2);

  // Draw a white rectangle with black border
  Paint paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
  canvas.drawRect(rect, paint);

  paint
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth;
  canvas.drawRect(rect, paint);

  // Position the text in the center of the rectangle
  Offset textOffset = Offset(padding, padding);
  textPainter.paint(canvas, textOffset);

  // Convert canvas to image
  ui.Image image = await recorder
      .endRecording()
      .toImage(size.width.toInt(), size.height.toInt());
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List pngBytes = byteData!.buffer.asUint8List();

  // Create BitmapDescriptor from image
  return BitmapDescriptor.bytes(pngBytes);
}


class CustomMarkerHelper {
  static const String noEntryAssetPath = 'assets/forbidden.png';

  /// Creates a BitmapDescriptor with a no entry sign from assets and optional text below it
  /// - Text is displayed with black color on white background with black border
  /// - Image and text are center-aligned
  /// - Image has no background
  /// - Text background size adjusts to text length
  static Future<BitmapDescriptor> createNoEntryMarkerWithText({
    String? text,
    double imageSize = 64.0,
    double textFontSize = 14.0,
    double textPadding = 2.0,
    double borderWidth = 1.0,
  }) async {
    // Early return if no text to show just the image
    if (text == null || text.isEmpty) {
      return await _createNoEntryMarker(imageSize: imageSize);
    }

    // Load the image from assets
    final ByteData imageData = await rootBundle.load(noEntryAssetPath);
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image assetImage = frameInfo.image;

    // Calculate the size of the text
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: textFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Calculate the total width and height
    final double totalWidth = math.max(
        imageSize, textPainter.width + (textPadding * 2) + (borderWidth * 2));
    final double totalHeight = imageSize +
        4 +
        textPainter.height +
        (textPadding * 2) +
        (borderWidth * 2);

    // Create a canvas to draw on
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Draw the image centered at the top
    final double imageLeft = (totalWidth - imageSize) / 2;
    canvas.drawImage(assetImage, Offset(imageLeft, 0), Paint());

    // Draw the text background
    final double textBackgroundWidth = textPainter.width + (textPadding * 2);
    final double textBackgroundHeight = textPainter.height + (textPadding * 2);
    final double textBackgroundLeft = (totalWidth - textBackgroundWidth) / 2;
    final double textBackgroundTop = imageSize + 4;

    final Rect textBackgroundRect = Rect.fromLTWH(
      textBackgroundLeft,
      textBackgroundTop,
      textBackgroundWidth,
      textBackgroundHeight,
    );

    // Draw white background
    canvas.drawRect(
      textBackgroundRect,
      Paint()..color = Colors.white,
    );

    // Draw black border
    canvas.drawRect(
      textBackgroundRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Draw the text
    final double textLeft = textBackgroundLeft + textPadding;
    final double textTop = textBackgroundTop + textPadding;
    textPainter.paint(canvas, Offset(textLeft, textTop));

    // Convert to image
    final ui.Picture picture = recorder.endRecording();
    final ui.Image resultImage = await picture.toImage(
      totalWidth.ceil(),
      totalHeight.ceil(),
    );

    // Convert to BitmapDescriptor
    final ByteData? byteData = await resultImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Failed to convert image to byte data');
    }

    final Uint8List uint8List = byteData.buffer.asUint8List();
    return BitmapDescriptor.bytes(uint8List);
  }

  /// Creates a BitmapDescriptor with just the no entry sign from assets
  static Future<BitmapDescriptor> _createNoEntryMarker({
    required double imageSize,
  }) async {
    // Load the image from assets
    final ByteData imageData = await rootBundle.load(noEntryAssetPath);
    final Uint8List imageBytes = imageData.buffer.asUint8List();

    // Convert to BitmapDescriptor directly
    return BitmapDescriptor.bytes(imageBytes);
  }
}
