import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> noEntrySignMarker() async {
  const String assetPath = 'assets/forbidden.png';
  final ByteData byteData = await rootBundle.load(assetPath);
  final Uint8List bytes = byteData.buffer.asUint8List();
  return BitmapDescriptor.bytes(bytes);
}

Future<BitmapDescriptor> noEntrySignMarkerOpacity() async {
  const String assetPath = 'assets/forbidden-opacity.png';
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
