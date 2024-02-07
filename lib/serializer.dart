// serializer.dart
import 'dart:convert';
import 'dart:io';

class Serializer {
  // 데이터를 JSON 형태로 직렬화하는 메서드
  static String serialize(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // JSON 형태의 데이터를 역직렬화하는 메서드
  static Map<String, dynamic> deserialize(String data) {
    return jsonDecode(data);
  }

  // 파일을 읽어서 base64 문자열로 변환하는 메서드
  static Future<String> serializeFile(File file) async {
    final fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  }

  // // 파일을 읽어서 base64 문자열로 변환하고, 그것을 JSON 형식으로 반환하는 메서드
  // static Future<String> fileToJson(File file) async {
  //   final base64Str = await serializeFile(file);
  //   final json = {'file_data': base64Str};
  //   return serialize(json);
  // }
}
