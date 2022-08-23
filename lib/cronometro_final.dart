import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class CronometroFinalView extends StatefulWidget {
  const CronometroFinalView({Key? key}) : super(key: key);

  @override
  State<CronometroFinalView> createState() => _CronometroFinalViewState();
}

class _CronometroFinalViewState extends State<CronometroFinalView> {
  late StreamController<double?> _velocityUpdatedStreamController;
  late StreamController<double?> _distanceUpdatedStreamContoller;
  double _velocity = 0;
  GeolocatorPlatform locator = GeolocatorPlatform.instance;
  late Timer timer;
  int count = 0;
  int countProCount = 4;
  final bool _isHours = true;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  bool playButton = true;

  late Position pointX;

  void _onAccelerate(double speed) {
    print('One time');
    locator.getCurrentPosition().then(
      (Position updatedPosition) {
        _velocity = (speed + updatedPosition.speed) / 2;
        if (count - countProCount >= 0 && !playButton) {
          print("Velo: ${_velocity * 3.6}");
          _velocityUpdatedStreamController.add(_velocity * 3.6);
          // _distanceUpdatedStreamContoller.add(locator.distanceBetween(
          //     pointX.latitude,
          //     pointX.longitude,
          //     updatedPosition.latitude,
          //     updatedPosition.longitude));
          // pointX = updatedPosition;
          count = 0;
        }
      },
    );
  }

  @override
  void initState() {
    _velocityUpdatedStreamController = StreamController<double>();
    _distanceUpdatedStreamContoller = StreamController<double?>();

    _distanceUpdatedStreamContoller.add(0);
    locator
        .getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
          ),
        )
        .listen(
          (Position position) => _onAccelerate(position.speed),
        );

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!playButton) {
          count++;
          print('Count: $count');
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() async {
    timer.cancel();
    _velocityUpdatedStreamController.close();
    _distanceUpdatedStreamContoller.close();
    await _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double distance = 0;

    return Column(
      children: [
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snap) {
            final value = snap.data;
            final displayTime =
                StopWatchTimer.getDisplayTime(value!, hours: _isHours);
            return Text(
              displayTime,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            );
          },
        ),
        StreamBuilder<double?>(
          stream: _velocityUpdatedStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print((snapshot.data!));
              return Text(
                '${(snapshot.data!).toStringAsPrecision(2)} KM/H',
                style: const TextStyle(fontSize: 40),
              );
            } else {
              return Text(
                '${(_velocity).toStringAsPrecision(2)} KM/H',
                style: const TextStyle(fontSize: 40),
              );
            }
          },
        ),
        StreamBuilder<double?>(
          stream: _distanceUpdatedStreamContoller.stream,
          builder: (context, snapshot) {
            // print('I am here  ${distance.toStringAsPrecision(3)}');
            // return Text('Distancia: ${distance.toStringAsPrecision(3)}');

            if (!playButton) {
              distance += (snapshot.data!);
              print('I am here  ${distance.toStringAsFixed(2)}');
            }
            return Text('Distancia: ${distance.toStringAsFixed(3)}');
          },
        ),
        CustumButton(
          color: playButton ? Colors.green : Colors.red,
          onPress: () {
            if (playButton) {
              _stopWatchTimer.onExecute.add(StopWatchExecute.start);
            } else {
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            }
            setState(() {
              playButton = !playButton;
            });
          },
          label: 'Start',
          icon: playButton
              ? const Icon(Icons.play_arrow)
              : const Icon(Icons.pause),
        ),
      ],
    );
  }
}

typedef OnPress = void Function();

class CustumButton extends StatelessWidget {
  final Color color;
  final OnPress onPress;
  final String label;
  final Icon icon;

  const CustumButton(
      {super.key,
      required this.color,
      required this.onPress,
      required this.label,
      required this.icon});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ButtonStyle(
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
        backgroundColor: MaterialStateProperty.all(color),
      ),
      child: icon,
    );
  }
}
