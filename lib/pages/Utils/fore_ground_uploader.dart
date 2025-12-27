import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'backgroundScanner.dart';
import 'Background_uploader.dart';

/// REQUIRED entry po
@pragma('vm:entry-point')
void foregroundBackupCallback() {
  FlutterForegroundTask.setTaskHandler(_BackupTaskHandler());
}

class _BackupTaskHandler extends TaskHandler {
  bool _scanned = false;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    debugPrint('🚀 Foreground backup started');

    if (!_scanned) {
      await MediaScanner.scanAndQueueAudios();
      _scanned = true;
    }

    await BackgroundUploader.run();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    await BackgroundUploader.run(); // upload only
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {
    debugPrint('🛑 Foreground backup stopped');
  }
}

Future<void> startForegroundBackup() async {
  debugPrint('▶️ Starting foreground backup service');
  await FlutterForegroundTask.startService(
    notificationTitle: 'Preparing backup',
    notificationText: 'Waiting for Wi-Fi…',
    callback: foregroundBackupCallback,
  );
}

Future<void> stopForegroundBackup() async {
  debugPrint('⏹ Stopping foreground backup service');
  await FlutterForegroundTask.stopService();
}
