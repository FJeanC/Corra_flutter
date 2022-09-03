import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTS {
  late final FlutterTts tts;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  TTS() {
    initTTS();
  }
  void initTTS() async {
    tts = FlutterTts();
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
  }

  Future<void> speak() async {
    await tts.setLanguage(Platform.localeName);
    await tts.speak("You've ran one kilometer");
  }
}
