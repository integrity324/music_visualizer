import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // ✅ just_audio 사용
import '../services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // 🎵 오디오 재생기 인스턴스 생성
  final AudioService _audioService =
      AudioService(); // 📡 서버 통신 및 URL 추출 서비스 인스턴스 생성
  final TextEditingController _controller = TextEditingController(
    text:
        'https://www.youtube.com/watch?v=2Vv-BfVoq4g', // 🧪 테스트용 기본 YouTube URL
  );

  String? _errorMessage; // ❗ 에러 메시지 저장 변수
  String? _videoTitle; // 📺 영상 제목 저장 변수
  bool _isLoading = false; // 🔄 로딩 상태
  bool _isPlaying = false; // ▶️ 재생 상태
  bool _isPaused = false; // ⏸️ 일시정지 상태
  bool _hasStartedPlaying = false; // ✅ 최초 재생 여부 확인용

  // 🎧 오디오 상태 스트림을 감지하여 UI 상태를 업데이트
  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      final processing = state.processingState;

      setState(() {
        _isPlaying = playing && processing == ProcessingState.ready;
        _isPaused = !playing && processing == ProcessingState.ready;
        _isLoading =
            processing == ProcessingState.loading ||
            processing == ProcessingState.buffering;

        // ✅ 재생이 시작된 후 제목을 표시하기 위한 상태값 설정
        if (_isPlaying && _videoTitle != null) {
          _hasStartedPlaying = true;
        }
      });
    });
  }

  // 🎯 재생 버튼 클릭 시 실행되는 함수
  Future<void> _play() async {
    final link = _controller.text.trim();
    debugPrint("🎯 입력된 링크: $link");

    if (link.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _videoTitle = null;
      _hasStartedPlaying = false;
    });

    try {
      debugPrint("📡 [AudioService] 서버에 POST 요청 보냄: $link");
      final result = await _audioService.getAudioStreamUrl(link);

      final streamUrl = result['audio_url'];
      final title = result['title'];

      if (streamUrl == null || streamUrl.isEmpty) {
        throw Exception("오디오 URL이 비어 있음");
      }

      setState(() {
        _videoTitle = title;
        _hasStartedPlaying = true;
      });

      await _audioPlayer.setUrl(streamUrl); // ▶️ 오디오 설정
      await _audioPlayer.play(); // ▶️ 오디오 재생 시작
    } catch (e) {
      debugPrint("❌ [AudioService] 요청 실패: $e");
      setState(() {
        _errorMessage = '재생 불가한 링크입니다. 유효한 YouTube URL을 입력해주세요.';
        _isPlaying = false;
        _isPaused = false;
        _hasStartedPlaying = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ⏹️ 정지 버튼 클릭 시 실행되는 함수
  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _videoTitle = null;
      _hasStartedPlaying = false;
    });
  }

  // ⏸️ 일시정지 버튼 클릭 시 실행되는 함수
  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() {
      _isPaused = true;
      _isPlaying = false;
    });
  }

  // ▶️ 일시정지에서 다시 재생하는 함수
  Future<void> _resume() async {
    await _audioPlayer.play();
    setState(() {
      _isPaused = false;
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎧 Music Visualizer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '🎥 YouTube 링크를 입력하세요',
                border: OutlineInputBorder(),
              ),
              enabled: !_isPlaying && !_isLoading, // 재생 중일 땐 입력 비활성화
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_isLoading)
              const Text(
                '🔄 오디오 불러오는 중...',
                style: TextStyle(color: Colors.orange),
              )
            else if (_isPlaying)
              const Text('▶️ 재생 중입니다', style: TextStyle(color: Colors.green))
            else if (_isPaused)
              const Text('⏸️ 일시정지됨', style: TextStyle(color: Colors.blue)),
            if (_videoTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.music_note, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _videoTitle!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isLoading
                          ? null
                          : (_isPlaying
                              ? _pause
                              : (_isPaused ? _resume : _play)),
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause
                        : (_isPaused ? Icons.play_arrow : Icons.play_arrow),
                  ),
                  label: Text(_isPlaying ? '일시정지' : (_isPaused ? '재개' : '재생')),
                ),
                ElevatedButton.icon(
                  onPressed: (_isPlaying || _isPaused) ? _stop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('정지'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
