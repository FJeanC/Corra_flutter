import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as developer;

// TODO: get raw time, convert all to mSec and use it to calculate the distance using the Queue.

class RunView extends StatefulWidget {
  const RunView({Key? key}) : super(key: key);

  @override
  State<RunView> createState() => _RunViewState();
}

class _RunViewState extends State<RunView> {
  late StreamController<double?> _velocityUpdatedStreamController;
  late StreamController<double?> _distanceUpdatedStreamContoller;
  double _velocity = 0;
  GeolocatorPlatform locator = GeolocatorPlatform.instance;
  late Timer timer;
  int count = 0;
  int countProCount = 3;
  final bool _isHours = true;
  late StopWatchTimer _stopWatchTimer;
  bool playButton = true;
  late String globalTime;
  Queue<double> lastSpeed = Queue<double>();
  Queue<double> velocidades = Queue<double>();
  double averageSpeed = 0;

  void calculateAverageSpeed(double velocity) {
    lastSpeed.add(_velocity * 3.6);
    double auxSum = 0;
    for (var num in lastSpeed) {
      auxSum += num;
    }
    averageSpeed = auxSum / lastSpeed.length;
    while (lastSpeed.length > 5) {
      lastSpeed.removeFirst();
    }
    developer.log('Average speed: ${averageSpeed.toStringAsFixed(2)}',
        name: 'calculateAverageSpeed');
  }

  int getTimeInMilli() {
    final timeStr = globalTime;
    final format = DateFormat('HH:mm:ss.S');
    final dt = format.parse(timeStr, true);
    print('MILLIE: ${dt.millisecondsSinceEpoch}');
    return dt.millisecondsSinceEpoch;
  }

  void _onAccelerate(double speed) {
    locator.getCurrentPosition().then(
      (Position updatedPosition) {
        _velocity = (speed + updatedPosition.speed) / 2;
        calculateAverageSpeed(_velocity);
        if (count - countProCount >= 0 && !playButton) {
          velocidades.add((averageSpeed * (getTimeInMilli() / 3600000)));
          final dist = velocidades.average;
          developer.log(
              'Distancia: ${dist.toStringAsFixed(2)}, last: ${velocidades.last.toStringAsFixed(2)}',
              name: 'onAccelerate');
          _distanceUpdatedStreamContoller.add(dist);
          _velocityUpdatedStreamController.add(_velocity * 3.6);
          count = 0;
        }
      },
    );
  }

  @override
  void initState() {
    _velocityUpdatedStreamController = StreamController<double>();
    _distanceUpdatedStreamContoller = StreamController<double?>();
    _stopWatchTimer = StopWatchTimer();

    _velocityUpdatedStreamController.add(0);
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
    return Column(
      children: [
        StreamBuilder<int>(
          stream: _stopWatchTimer.rawTime,
          initialData: 0,
          builder: (context, snap) {
            final value = snap.data;
            final displayTime =
                StopWatchTimer.getDisplayTime(value!, hours: _isHours);
            //List<String> aux = displayTime.split(':');
            //print(aux);
            globalTime = displayTime;

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
              print((snapshot.data!).toStringAsPrecision(2));
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
          initialData: 0.0,
          builder: (context, snapshot) {
            // print('I am here  ${distance.toStringAsPrecision(3)}');
            // return Text('Distancia: ${distance.toStringAsPrecision(3)}');

            if (!playButton) {
              //distance += (snapshot.data!);
              print('I am here  ${snapshot.data!.toStringAsFixed(2)}');
            }
            return Text('Distancia: ${snapshot.data!.toStringAsFixed(2)}');
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
