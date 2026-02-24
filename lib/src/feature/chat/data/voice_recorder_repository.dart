


abstract class IVoiceRepository {
  Future<void> startRecording();
  Future<String?> stopAndUpload();
}

