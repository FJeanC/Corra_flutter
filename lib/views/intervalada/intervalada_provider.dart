import 'package:vibration/vibration.dart';

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

  int get getRepeat => _repeat;
  set addTime(int value) {
    _holdTime += value;
  }

  bool get userWantsInterval => _intervalsIsOn;
  void initializeIntervalada(
      {required int r,
      required int wT,
      required int rT,
      required bool interval}) {
    _repeat = r;
    _walkTime = wT;
    _runTime = rT;
    _holdTime = 0;
    _intervalsIsOn = interval;
    print(_repeat);
    print(_walkTime);
    print(_runTime);
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
    print('HoldTIme: $_holdTime');
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
