abstract class IVoiceRepository {
  Future<void> startRecording();
  // Future<String?> stopAndUpload();
  Future<String?> stopRecording(); // Теперь возвращает путь к локальному файлу
  Future<String?> uploadFile(String path);
}
