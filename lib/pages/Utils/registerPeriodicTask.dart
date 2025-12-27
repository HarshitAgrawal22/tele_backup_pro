// import 'package:backup_pro/main.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// Future<void> scheduleBackgroundTaskOnce() async {
//   final prefs = await SharedPreferences.getInstance();
//   final alreadyScheduled = prefs.getBool('alarm_scheduled') ?? false;

//   if (alreadyScheduled) {
//     debugPrint('⚠️ Alarm already scheduled, skipping');
//     return;
//   }
//   final prefss = await SharedPreferences.getInstance();
//   prefss.setStringList('pending_uploads', [
//     '/storage/emulated/0/Music/Recordings/Call Recordings/Papa-2512232146.mp3',
//   ]);

//   // await AndroidAlarmManager.periodic(
//   //   const Duration(minutes: 1),
//   //   1001, // fixed unique ID
//   //   backgroundUploadTask,
//   //   wakeup: true,
//   //   rescheduleOnReboot: false,
//   // );

//   await prefs.setBool('alarm_scheduled', true);
//   debugPrint('✅ Alarm scheduled for the first time');
// }
