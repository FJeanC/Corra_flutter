import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<void> speak(BuildContext context) async {
    await tts.setLanguage(Platform.localeName);
    await tts.speak(AppLocalizations.of(context)!.ttsPhrase);
  }
}
