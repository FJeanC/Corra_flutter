import 'dart:async';
import 'dart:collection';

import 'package:corra/constants/routes.dart';
import 'package:corra/enums/menu_action.dart';
import 'package:corra/services/auth/auth_service.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as developer;

// TODO: get raw time, convert all to mSec and use it to calculate the distance using the Queue.

class CronometroView extends StatefulWidget {
  const CronometroView({Key? key}) : super(key: key);

  @override
  State<CronometroView> createState() => _CronometroViewState();
}

class _CronometroViewState extends State<CronometroView> {
  late StreamController<double?> _velocityUpdatedStreamController;
  late StreamController<double?> _distanceUpdatedStreamContoller;
  double _velocity = 0;
  GeolocatorPlatform locator = GeolocatorPlatform.instance;
  late Timer timer;
  int count = 0;
  int countProCount = 5;
  final bool _isHours = true;
  late StopWatchTimer _stopWatchTimer;
  bool playButton = true;
  late String globalTime;
  Queue<double> lastSpeed = Queue<double>();
  Queue<double> velocidades = Queue<double>();
  double averageSpeed = 0;

  // Firebase variables
  late final FirebaseCloudRunStorage _runsSerivce;

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
        if (!playButton) {
          _velocity = (speed + updatedPosition.speed) / 2;
          calculateAverageSpeed(_velocity);
        }
      },
    );
  }

  @override
  void initState() {
    _velocityUpdatedStreamController = StreamController<double>();
    _distanceUpdatedStreamContoller = StreamController<double?>();
    _stopWatchTimer = StopWatchTimer();
    _runsSerivce = FirebaseCloudRunStorage();

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
          if (count % 3 == 0 && !playButton) {
            velocidades.add(averageSpeed);
            final dist = (velocidades.average) * (getTimeInMilli() / 3600000);
            developer.log(
                'Distancia: ${dist.toStringAsFixed(2)}, last: ${velocidades.last.toStringAsFixed(2)}',
                name: 'onAccelerate');
            _distanceUpdatedStreamContoller.add(dist);
            _velocityUpdatedStreamController.add(_velocity * 3.6);
          }
        }
      },
    );
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    timer.cancel();
    _velocityUpdatedStreamController.close();
    _distanceUpdatedStreamContoller.close();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (!mounted) {
                      // Solving a warning
                      return;
                    }
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: 0,
            builder: (context, snap) {
              final value = snap.data;
              final displayTime =
                  StopWatchTimer.getDisplayTime(value!, hours: _isHours);
              globalTime = displayTime;

              return Text(
                displayTime,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
          CustumButton(
            color: Colors.pink,
            onPress: () async {
              _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              setState(() {
                playButton = !playButton;
              });
              final currentUser = AuthService.firebase().currentUser!;
              await _runsSerivce.createNewRun(
                ownerUserId: currentUser.id,
                tempo: globalTime,
                velocidade: (velocidades.average).toStringAsPrecision(2),
                data: '26/08/2022',
              );
              if (!mounted) return;
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     mainPage, ModalRoute.withName('/runs'));
              context.read<AuthBloc>().add(const AuthEventListRuns());

              // Navigator.of(context).pop();
            },
            label: 'Save',
            icon: const Icon(Icons.stop),
          ),
        ],
      ),
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