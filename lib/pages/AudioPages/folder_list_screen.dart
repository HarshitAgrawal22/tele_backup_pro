import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:backup_po/pages/MainPage.dart';
import 'package:backup_pro/pages/AudioPages/image_grid_screen.dart';

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  List<AssetPathEntity> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<bool> _requestPhotoPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<void> _loadFolders() async {
    bool granted = await _requestPhotoPermission();
    if (!granted) return;

    final List<AssetPathEntity> result = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: false, // show real folders
    );

    if (!mounted) return;
    setState(() => folders = result);
  }

  //  int assetCount = await folder.assetCountAsync;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];

          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(folder.name),
            subtitle: FutureBuilder<int>(
              future: folder.assetCountAsync,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text('Loading...');
                }
                return Text('${snapshot.data} images');
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageGridScreen(folder: folder),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
