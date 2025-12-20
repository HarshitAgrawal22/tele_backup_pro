import 'dart:io';
import 'package:backup_pro/pages/AudioPages/audio_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioFolder {
  final String name;
  final Directory dir;
  AudioFolder(this.name, this.dir);
}

class AudioFolderListScreen extends StatefulWidget {
  const AudioFolderListScreen({super.key});

  @override
  State<AudioFolderListScreen> createState() => _AudioFolderListScreenState();
}

class _AudioFolderListScreenState extends State<AudioFolderListScreen> {
  final List<AudioFolder> folders = [];

  @override
  void initState() {
    super.initState();
    _scanAudioFolders();
  }

  Future<void> _scanAudioFolders() async {
    final granted = await Permission.audio.request().isGranted;
    if (!granted) {
      debugPrint('❌ Audio permission denied');
      return;
    }

    const roots = [
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
      '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
    ];

    for (final path in roots) {
      final dir = Directory(path);
      if (!dir.existsSync()) continue;

      final hasAudio = dir
          .listSync(recursive: true)
          .any((f) => f.path.endsWith('.mp3') || f.path.endsWith('.m4a'));

      if (hasAudio) {
        debugPrint('🟢 Found audio folder: $path');
        folders.add(AudioFolder(path.split('/').last, dir));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Folders')),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (_, i) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AudioFileScreen(directory: folders[i].dir),
                ),
              );
            },

            leading: const Icon(Icons.folder),
            title: Text(folders[i].name),
            subtitle: Text(folders[i].dir.path),
          );
        },
      ),
    );
  }
}
