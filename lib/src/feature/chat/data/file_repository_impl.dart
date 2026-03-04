import 'dart:developer';
import 'dart:io';

import 'package:coment_app/src/feature/chat/data/file_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FileRepositoryImpl implements IFileRepository {
  final SupabaseClient _supabase;

  FileRepositoryImpl(this._supabase);

  @override
  Future<List<String>> uploadChatFiles(List<File> files) async {
    final List<String> urls = [];

    for (var file in files) {
      try {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        log('[FileRepository] Загрузка файла: $fileName');

        // Загружаем в бакет 'chat_attachments'
        await _supabase.storage.from('chat_attachments').upload(
              fileName,
              file,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        // Получаем публичную ссылку
        final String publicUrl =
            _supabase.storage.from('chat_attachments').getPublicUrl(fileName);
        urls.add(publicUrl);
      } catch (e) {
        log('[FileRepository] Ошибка при работе с Supabase Storage: $e');
        rethrow;
      }
    }
    return urls;
  }

  @override
  Future<String> uploadVoice(File voiceFile) async {
    // Аналогичная логика для аудио
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _supabase.storage.from('chat_voices').upload(fileName, voiceFile);
    return _supabase.storage.from('chat_voices').getPublicUrl(fileName);
  }
}
