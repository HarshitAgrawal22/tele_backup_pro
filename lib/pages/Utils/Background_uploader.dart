import 'dart:io';
import 'package:backup_pro/pages/Utils/apibot.dart';
import 'package:backup_pro/pages/Utils/upload_progress_notifier.dart';
import 'package:backup_pro/pages/Utils/wifi-checker.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UploadRegistry {
  static const _key = 'uploaded_files';

  static Future<Set<String>> getUploaded() async {
    debugPrint('📦 UploadRegistry.getUploaded() called');
    final prefs = await SharedPreferences.getInstance();
    final data = (prefs.getStringList(_key) ?? []).toSet();

    debugPrint('📦 Uploaded files count: ${data.length}');
    return data;
  }

  static Future<void> markUploaded(String path) async {
    debugPrint('✅ Marking uploaded: $path');
    final prefs = await SharedPreferences.getInstance();
    final files = (prefs.getStringList(_key) ?? []).toSet();
    files.add(path);
    await prefs.setStringList(_key, files.toList());
    debugPrint('✅ Saved uploaded file path');
  }
}

class BackgroundUploader {
  static bool _running = false;
  static const int maxPerRun = 8; // 🔋 battery safe

  static final RegExp _deleteRegex = RegExp(
    r'^.+-\d{10}\.mp3$',
    caseSensitive: false,
  );

  static Future<void> run() async {
    if (_running) {
      debugPrint('⏸ Upload already running');
      return;
    }

    final bool wifiConnected = await WifiUtils.isWifiConnected();
    if (!wifiConnected) {
      debugPrint('📡 Wi-Fi not connected. Upload paused.');
      await FlutterForegroundTask.updateService(
        notificationTitle: 'Backup paused',
        notificationText: 'Waiting for Wi-Fi connection',
      );
      return;
    }
    _running = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploaded = await UploadRegistry.getUploaded();

      final List<String> pending = List.from(
        prefs.getStringList('pending_uploads') ?? [],
      );

      if (pending.isEmpty) {
        debugPrint('✅ No pending uploads');
        // FlutterForegroundTask.stopService();
        return;
      }

      int uploadedThisRun = 0;
      final int total = pending.length;
      int completedOverall = uploaded.length;
      final List<String> remaining = [];

      for (final path in pending) {
        if (uploadedThisRun >= maxPerRun) {
          remaining.add(path);
          continue;
        }
        if (!await WifiUtils.isWifiConnected()) {
          debugPrint('📡 Wi-Fi lost. Stopping upload loop.');
          remaining.add(path);
          break;
        }
        if (uploaded.contains(path)) continue;

        final file = File(path);
        if (!file.existsSync()) continue;

        debugPrint('⬆️ Uploading: $path');

        final ok = await TelegramUploader.uploadFile(file);

        if (ok) {
          await UploadRegistry.markUploaded(path);
          uploadedThisRun++;
          completedOverall++;
          // 🗑 Delete only if regex matches
          final name = file.path.split('/').last;
          if (_deleteRegex.hasMatch(name)) {
            try {
              await file.delete();
              debugPrint('🗑 Deleted after upload: $name');
            } catch (e) {
              debugPrint('❌ Delete failed: $e');
            }
          }
          await UploadProgressNotifier.update(
            uploaded: completedOverall,
            total: total,
            currentFile: file.path.split('/').last,
          );
        } else {
          remaining.add(path);
        }
      }

      await prefs.setStringList('pending_uploads', remaining);

      debugPrint('📦 Remaining pending: ${remaining.length}');

      if (remaining.isEmpty) {
        debugPrint('✅ All uploads completed');
        await UploadProgressNotifier.completed();
        FlutterForegroundTask.stopService();
      }
    } finally {
      _running = false;
    }
  }
}
