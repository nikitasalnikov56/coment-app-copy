import 'dart:io';


abstract class IFileRepository {
  Future<List<String>> uploadChatFiles(List<File> files);
  Future<String> uploadVoice(File voiceFile);
}

