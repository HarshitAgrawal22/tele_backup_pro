import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'Background_uploader.dart';

class MediaScanner {
  static Future<void> scanAndQueueAudios() async {
    final prefs = await SharedPreferences.getInstance();
    final uploaded = await UploadRegistry.getUploaded();

    final Set<String> pending = (prefs.getStringList('pending_uploads') ?? [])
        .toSet();

    final folders = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
      hasAll: true,
    );

    for (final folder in folders) {
      final assets = await folder.getAssetListRange(
        start: 0,
        end: await folder.assetCountAsync,
      );

      for (final asset in assets) {
        final file = await asset.file;
        if (file == null) continue;

        final path = file.path;

        if (!uploaded.contains(path)) {
          pending.add(path);
        }
      }
    }

    await prefs.setStringList('pending_uploads', pending.toList());
    debugPrint('📥 Pending uploads total: ${pending.length}');
  }
}
