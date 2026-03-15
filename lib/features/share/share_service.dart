import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class ShareService {
  static Future<void> captureAndShare({
    required GlobalKey repaintKey,
    required String projectName,
    required String agentName,
  }) async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/idle_agent_share.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My AI agent is building: $projectName\n\nIdle Agent — idleagent.app',
        subject: 'Idle Agent — $agentName at work',
      );
    } catch (e) {
      // Silently fail
    }
  }
}
