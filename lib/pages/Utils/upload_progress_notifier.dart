import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class UploadProgressNotifier {
  static Future<void> update({
    required int uploaded,
    required int total,
    required String currentFile,
  }) async {
    final percent = total == 0 ? 0 : ((uploaded / total) * 100).floor();

    await FlutterForegroundTask.updateService(
      notificationTitle: 'Uploading audio files',
      notificationText: '$uploaded / $total files ($percent%)\n$currentFile',
    );
  }

  static Future<void> completed() async {
    await FlutterForegroundTask.updateService(
      notificationTitle: 'Backup completed',
      notificationText: 'All audio files uploaded',
    );
  }
}
