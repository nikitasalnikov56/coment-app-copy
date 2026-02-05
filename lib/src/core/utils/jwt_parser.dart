import 'dart:convert';
import 'dart:typed_data';

class JwtParser {
  /// Парсит payload из JWT токена
  /// Возвращает Map<String, dynamic> или null при ошибке
  static Map<String, dynamic>? parsePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payloadPart = _base64UrlDecode(parts[1]);
      final payloadString = utf8.decode(payloadPart);
      return json.decode(payloadString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Декодирует base64url в Uint8List (без использования библиотек)
  static Uint8List _base64UrlDecode(String input) {
    // base64url использует '-' вместо '+' и '_' вместо '/'
    String normalized = input.replaceAll('-', '+').replaceAll('_', '/');

    // Добавляем паддинг до кратности 4
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }

    return base64.decode(normalized);
  }
}