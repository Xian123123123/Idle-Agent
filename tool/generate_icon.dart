import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Black background
  img.fill(image, color: img.ColorRgb8(10, 14, 10));

  // Draw green cursor block in center
  final cursorWidth = 200;
  final cursorHeight = 300;
  final cx = (size - cursorWidth) ~/ 2;
  final cy = (size - cursorHeight) ~/ 2 + 80;
  img.fillRect(image,
      x1: cx, y1: cy, x2: cx + cursorWidth, y2: cy + cursorHeight,
      color: img.ColorRgb8(0, 255, 65));

  // Draw "IA" text approximation using rectangles
  // I character
  final textY = size ~/ 2 - 120;
  final textH = 180;
  final iX = size ~/ 2 - 140;
  img.fillRect(image,
      x1: iX, y1: textY, x2: iX + 40, y2: textY + textH,
      color: img.ColorRgb8(10, 14, 10));
  // Top serif of I
  img.fillRect(image,
      x1: iX - 20, y1: textY, x2: iX + 60, y2: textY + 30,
      color: img.ColorRgb8(10, 14, 10));
  // Bottom serif of I
  img.fillRect(image,
      x1: iX - 20, y1: textY + textH - 30, x2: iX + 60, y2: textY + textH,
      color: img.ColorRgb8(10, 14, 10));

  // A character
  final aX = size ~/ 2 + 40;
  // Left leg
  img.fillRect(image,
      x1: aX, y1: textY, x2: aX + 40, y2: textY + textH,
      color: img.ColorRgb8(10, 14, 10));
  // Right leg
  img.fillRect(image,
      x1: aX + 100, y1: textY, x2: aX + 140, y2: textY + textH,
      color: img.ColorRgb8(10, 14, 10));
  // Top bar
  img.fillRect(image,
      x1: aX, y1: textY, x2: aX + 140, y2: textY + 30,
      color: img.ColorRgb8(10, 14, 10));
  // Middle bar
  img.fillRect(image,
      x1: aX, y1: textY + 75, x2: aX + 140, y2: textY + 105,
      color: img.ColorRgb8(10, 14, 10));

  // Save
  final dir = Directory('assets/icon');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  File('assets/icon/app_icon.png').writeAsBytesSync(img.encodePng(image));
  File('assets/icon/app_icon_foreground.png').writeAsBytesSync(img.encodePng(image));
  print('Icons generated.');
}
