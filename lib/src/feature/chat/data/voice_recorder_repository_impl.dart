import 'dart:io';

import 'package:coment_app/src/feature/chat/data/voice_recorder_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceRepositoryImpl implements IVoiceRepository {
  final AudioRecorder _recorder = AudioRecorder();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      await _recorder.start(const RecordConfig(), path: path);
    }
  }

  @override
  Future<String?> stopAndUpload() async {
    final path = await _recorder.stop();
    if (path == null) return null;

    final file = File(path);
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    // Загрузка в бакет 'voice_messages'
    await _supabase.storage.from('voice_messages').upload(fileName, file);
    
    // Получаем публичную ссылку
    return _supabase.storage.from('voice_messages').getPublicUrl(fileName);
  }
}