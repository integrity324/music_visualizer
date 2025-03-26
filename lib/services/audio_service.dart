import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioService {
  final String serverUrl = 'http://172.30.1.44:5001/extract'; // 로컬 서버

  Future<String?> getAudioStreamUrl(String youtubeUrl) async {
    try {
      print("📡 [AudioService] 서버에 POST 요청 보냄: $youtubeUrl");

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': youtubeUrl}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ [AudioService] 오디오 URL 응답: ${data['audio_url']}");
        return data['audio_url'];
      } else {
        print("❌ [AudioService] 서버 오류: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ [AudioService] 요청 실패: $e");
      return null;
    }
  }
}
