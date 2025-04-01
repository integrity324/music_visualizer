import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioService {
  final String _serverUrl = 'http://172.30.1.98:5001/extract'; // 🌐 Flask 서버 주소

  /// 📡 YouTube 링크로부터 오디오 스트림 URL과 제목을 가져오는 함수
  Future<Map<String, dynamic>> getAudioStreamUrl(String youtubeUrl) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': youtubeUrl}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('서버 오류: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('서버 요청 실패: $e');
    }
  }
}
