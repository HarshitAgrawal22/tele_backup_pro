import 'dart:io';
import 'package:flutter/material.dart';

class AudioFileScreen extends StatefulWidget {
  final Directory directory;

  const AudioFileScreen({super.key, required this.directory});

  @override
  State<AudioFileScreen> createState() => _AudioFileScreenState();
}

class _AudioFileScreenState extends State<AudioFileScreen> {
  static const int pageSize = 50;

  final List<File> _audioFiles = [];
  late final List<File> _allFiles;

  int _currentIndex = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('📂 Opening folder: ${widget.directory.path}');
    _scanAllFiles();
    _controller.addListener(_onScroll);
  }

  void _scanAllFiles() {
    _allFiles = widget.directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) {
          final path = file.path.toLowerCase();
          return path.endsWith('.mp3') ||
              path.endsWith('.m4a') ||
              path.endsWith('.wav') ||
              path.endsWith('.aac') ||
              path.endsWith('.ogg');
        })
        .toList();

    debugPrint('🎵 Total audio files found: ${_allFiles.length}');
    _loadNextPage();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    _isLoading = true;

    final nextFiles = _allFiles.skip(_currentIndex).take(pageSize).toList();

    setState(() {
      _audioFiles.addAll(nextFiles);
      _currentIndex += nextFiles.length;
      _hasMore = _currentIndex < _allFiles.length;
      _isLoading = false;
    });

    debugPrint('📄 Loaded ${_audioFiles.length}/${_allFiles.length}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.directory.path.split('/').last)),
      body: ListView.builder(
        controller: _controller,
        itemCount: _audioFiles.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _audioFiles.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final file = _audioFiles[index];

          return ListTile(
            leading: const Icon(Icons.audiotrack),
            title: Text(file.path.split('/').last),
            subtitle: Text(
              file.path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // This is the EXACT path you will send to Raspberry Pi
              debugPrint('➡️ Selected audio: ${file.path}');
            },
          );
        },
      ),
    );
  }
}
