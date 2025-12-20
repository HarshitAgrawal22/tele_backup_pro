import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'dart:io';

class ImageManagerScreen extends StatefulWidget {
  const ImageManagerScreen({super.key});

  @override
  State<ImageManagerScreen> createState() => _ImageManagerScreenState();
}

class _ImageManagerScreenState extends State<ImageManagerScreen> {
  List<AssetEntity> images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PhotoManager.openSetting();
    });
    _loadImages();
  }

  Future<void> openAppSettingsManually() async {
    await openAppSettings();
  }

  Future<bool> _requestPhotoPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<void> _loadImages() async {
    final granted = await _requestPhotoPermission();
    if (!granted) {
      debugPrint('Permission denied by permission_handler');
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    debugPrint('Album count: ${albums.length}');

    if (albums.isEmpty) return;

    final List<AssetEntity> media = await albums.first.getAssetListPaged(
      page: 0,
      size: 500,
    );

    if (!mounted) return;
    setState(() => images = media);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: images.length,
        itemBuilder: (_, index) {
          return AssetEntityImage(images[index], fit: BoxFit.cover);
        },
      ),
    );
  }
}
