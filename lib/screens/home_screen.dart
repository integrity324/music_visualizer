import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'https://www.youtube.com/watch?v=2Vv-BfVoq4g',
  );
  String? _errorMessage;
  String? _videoTitle;

  final AudioService _audioService = AudioService(); // 유튜브 오디오 추출
  final AudioPlayer _audioPlayer = AudioPlayer(); // 오디오 재생기

  void _onPlayPressed() async {
    final link = _controller.text.trim();
    print("🎯 입력된 링크: $link");

    if (!_isValidYoutubeLink(link)) {
      setState(() {
        _errorMessage = '유효하지 않은 유튜브 링크입니다.';
        _videoTitle = null;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _videoTitle = '🎵 오디오 추출 중...';
    });

    try {
      final streamUrl = await _audioService.getAudioStreamUrl(link);

      if (streamUrl != null) {
        await _audioPlayer.stop(); // 재생 중이던 것 멈춤
        await _audioPlayer.play(UrlSource(streamUrl));
        setState(() {
          _videoTitle = '🎶 재생 중!';
        });
      } else {
        setState(() {
          _errorMessage = '오디오 스트리밍에 실패했습니다.';
          _videoTitle = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '예상치 못한 오류가 발생했습니다.';
        _videoTitle = null;
      });
    }
  }

  bool _isValidYoutubeLink(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎵 Music Visualizer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('유튜브 링크를 입력해주세요', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://www.youtube.com/watch?v=...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onPlayPressed,
              child: const Text('재생 ▶️'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_videoTitle != null)
              Text(
                _videoTitle!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
