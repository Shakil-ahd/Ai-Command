import 'package:flutter_tts/flutter_tts.dart';

/// Wraps flutter_tts for text-to-speech output.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _isSpeaking = false;
  bool _isEnabled = true; // User can toggle TTS on/off

  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;

  TtsService() {
    _configure();
  }

  Future<void> _configure() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);
  }

  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  void toggle() => _isEnabled = !_isEnabled;

  void dispose() {
    _tts.stop();
  }
}
