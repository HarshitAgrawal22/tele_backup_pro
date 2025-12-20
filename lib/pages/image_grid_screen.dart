import 'package:backup_pro/pages/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ImageGridScreen extends StatefulWidget {
  final AssetPathEntity folder;

  const ImageGridScreen({super.key, required this.folder});

  @override
  State<ImageGridScreen> createState() => _ImageGridScreenState();
}

class _ImageGridScreenState extends State<ImageGridScreen> {
  static const int pageSize = 50;

  final List<AssetEntity> _images = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    _isLoading = true;

    final List<AssetEntity> pageData = await widget.folder.getAssetListPaged(
      page: _currentPage,
      size: pageSize,
    );

    if (!mounted) return;

    setState(() {
      _currentPage++;
      _images.addAll(pageData);
      _hasMore = pageData.length == pageSize;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _images.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _images.length) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    images: _images,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: AssetEntityImage(
              _images[index],
              fit: BoxFit.cover,
              isOriginal: false,
            ),
          );
        },
      ),
    );
  }
}
