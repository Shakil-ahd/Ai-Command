import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _stt = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _stt.initialize(
      onError: (errorNotification) {
        _isListening = false;
      },
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    required void Function() onDone,
    required String localeId,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    if (_isListening) return;

    _isListening = true;
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);
        if (result.finalResult) {
          _isListening = false;
          onDone();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId.isNotEmpty ? localeId : null,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _stt.stop();
      _isListening = false;
    }
  }

  Future<void> cancelListening() async {
    await _stt.cancel();
    _isListening = false;
  }

  void dispose() {
    _stt.cancel();
  }
}
