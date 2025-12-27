import 'package:backup_pro/pages/Utils/backgroundScanner.dart';
import 'package:backup_pro/pages/Utils/fore_ground_uploader.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

// import 'package:permission_handler/permission_handler.dart';
import 'pages/AudioPages/audio_file_screen.dart';
import 'pages/AudioPages/folder_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('🟢 App starting');
  // await Permission.audio.request();
  // ✅ 1. Initialize Foreground Task (MANDATORY)
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'backup_channel',
      channelName: 'Audio Backup',
      channelDescription: 'Uploading audio files in background',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 15000, // 15 sec
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
    iosNotificationOptions: IOSNotificationOptions(),
  );

  // ✅ 2. Request permission ONCE (UI isolate only)
  final PermissionState permission = await PhotoManager.requestPermissionExtend(
    requestOption: const PermissionRequestOption(
      androidPermission: AndroidPermission(
        type: RequestType.audio,
        mediaLocation: false,
      ),
    ),
  );
  await Permission.notification.request();
  if (!permission.isAuth) {
    debugPrint('❌ Media permission denied');
  } else {
    debugPrint('✅ Media permission granted');
    await MediaScanner.scanAndQueueAudios();
  }

  // ✅ 3. Initialize alarm manager
  await AndroidAlarmManager.initialize();
  // await scheduleBackgroundTaskOnce();
  startForegroundBackup();
  runApp(const FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('File Manager'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.image), text: 'Images'),
                Tab(icon: Icon(Icons.music_note), text: 'Audio'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [FolderListScreen(), AudioFolderListScreen()],
          ),
        ),
      ),
    );
  }
}
// :

// 📶 Wi-Fi only uploads

// 🔋 Battery level threshold

// 🧠 Smart resume after reboot

// 🔔 Progress notification

// 🛑 User stop / pause toggle
