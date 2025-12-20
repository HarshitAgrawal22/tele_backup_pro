import 'package:backup_pro/pages/folder_list_screen.dart';
import 'package:flutter/material.dart';

void main() {
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
            title: Text('File Manager'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.image), text: 'Images'),
                // Tab(icon: Icon(Icons.music_note), text: 'Audio'),
              ],
            ),
          ),
          body: TabBarView(children: [FolderListScreen()]),
        ),
      ),
    );
  }
}
