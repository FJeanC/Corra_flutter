import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntervaladaProvider {
  static final IntervaladaProvider _shared =
      IntervaladaProvider._sharedInstance();
  IntervaladaProvider._sharedInstance();
  factory IntervaladaProvider() => _shared;

  bool _nextVibrationType =
      true; // true para walkTime VIB, falso para runTime VIB
  int _repeat = 0;
  int _walkTime = 0;
  int _runTime = 0;
  int _holdTime = 0;
  bool _intervalsIsOn = false;
  final pattern = [0, 1000, 300, 1000];

  set addTime(int value) {
    _holdTime += value;
  }

  int get getRepeat => _repeat;
  bool get userWantsInterval => _intervalsIsOn;
  bool get intervalType => _nextVibrationType;
  void resetInterval() {
    _repeat = 0;
    _walkTime = 0;
    _runTime = 0;
    _holdTime = 0;
    _intervalsIsOn = false;
  }

  void initialize({required bool interval}) async {
    _intervalsIsOn = interval;
    final prefs = await SharedPreferences.getInstance();
    _repeat = prefs.getInt('repeat') ?? 0;
    _walkTime = prefs.getInt('walk') ?? 0;
    _runTime = prefs.getInt('run') ?? 0;
    _holdTime = 0;
  }

  void disposeprefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('repeat');
    await prefs.remove('walk');
    await prefs.remove('run');
  }

  void walkLoop() {
    Vibration.vibrate(duration: 1400);
    _nextVibrationType = !_nextVibrationType;
  }

  void runLoop() {
    Vibration.vibrate(pattern: pattern);
    _nextVibrationType = !_nextVibrationType;
  }

  void handleRepetion() {
    if (_nextVibrationType && _holdTime % _walkTime == 0) {
      runLoop();
      _holdTime = 0;
    } else if (!_nextVibrationType && _holdTime % _runTime == 0) {
      walkLoop();
      _holdTime = 0;
      _repeat -= 1;
    }
  }
}
