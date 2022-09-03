import 'dart:async';
import 'dart:collection';
import 'package:corra/constants/routes.dart';
import 'package:corra/enums/menu_action.dart';
import 'package:corra/services/auth/auth_service.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/utilities/dialogs/logout_dialog.dart';
import 'package:corra/utilities/textToSpeech/text_to_speech.dart';
import 'package:corra/views/intervalada/intervalada_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as developer;

class CronometroView extends StatefulWidget {
  final VoidCallback onSaveChangeNavBar;
  const CronometroView({Key? key, required this.onSaveChangeNavBar})
      : super(key: key);

  @override
  State<CronometroView> createState() => _CronometroViewState();
}

class _CronometroViewState extends State<CronometroView> {
  late StreamController<double?> _velocityUpdatedStreamController;
  late StreamController<double?> _distanceUpdatedStreamContoller;
  late StreamController<double?> _paceUpdatedStreamController;
  double _velocity = 0;
  GeolocatorPlatform locator = GeolocatorPlatform.instance;
  late Timer timer;
  int count = 0;
  int countProCount = 5;
  final bool _isHours = true;
  late StopWatchTimer _stopWatchTimer;
  bool showPlayButton = true;
  late String globalTime;
  Queue<double> lastSpeed = Queue<double>();
  Queue<double> velocidades = Queue<double>();
  double averageSpeed = 0;
  double pace = 0;
  // Firebase variables
  late final FirebaseCloudRunStorage _runsSerivce;

  //Intervalada variables
  final interObj = IntervaladaProvider();

  //TTS variables
  var _ttsObj = TTS();
  double auxTTS = 0.2;

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
        if (!showPlayButton) {
          _velocity = (speed + updatedPosition.speed) / 2;
          print('VELOCITY HERE: ${_velocity.toStringAsFixed(2)}');
          calculateAverageSpeed(_velocity);
        }
      },
    );
  }

  void handleIntervalada() {
    interObj.addTime = 1;
    interObj.handleRepetion();
    if (interObj.getRepeat == 0) {
      setState(() {
        showPlayButton = !showPlayButton;
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      });
    }
  }

  @override
  void initState() {
    _velocityUpdatedStreamController = StreamController<double>();
    _distanceUpdatedStreamContoller = StreamController<double?>();
    _paceUpdatedStreamController = StreamController<double?>();
    _stopWatchTimer = StopWatchTimer();
    _runsSerivce = FirebaseCloudRunStorage();

    // _velocityUpdatedStreamController.add(0);
    // _distanceUpdatedStreamContoller.add(0);
    // _paceUpdatedStreamController.add(0);
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
        if (!showPlayButton) {
          count++;
          if (interObj.userWantsInterval) {
            handleIntervalada();
          }
          print('Count: $count');

          if (count % 3 == 0 && !showPlayButton) {
            velocidades.add(averageSpeed);
            final dist = (velocidades.average) * (getTimeInMilli() / 3600000);
            developer.log(
                'Distancia: ${dist.toStringAsFixed(2)}, last: ${velocidades.last.toStringAsFixed(2)}',
                name: 'onAccelerate');
            _distanceUpdatedStreamContoller.add(dist);
            if (_velocity * 3.6 < 2) {
              print('Im here');
              _velocityUpdatedStreamController.add(0);
            } else {
              _velocityUpdatedStreamController.add(_velocity * 3.6);
            }
            double auxpace = (count / 60) / dist;
            if (pace < 60.0) {
              //_paceUpdatedStreamController.add(pace);
              setState(() {
                pace = auxpace;
              });
            }

            if (dist >= auxTTS) {
              print('SHOULD SPEAK');
              _ttsObj.speak();
              auxTTS += 0.2;
            }
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
    _paceUpdatedStreamController.close();

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
              if (!showPlayButton) {
                //distance += (snapshot.data!);
                print('I am here  ${snapshot.data!.toStringAsFixed(2)}');
              }
              return Text('Distancia: ${snapshot.data!.toStringAsFixed(2)}');
            },
          ),
          Text('Pace: ${pace.toStringAsFixed(2)}'),
          // StreamBuilder<double?>(
          //   stream: _paceUpdatedStreamController.stream,
          //   initialData: 0,
          //   builder: (context, snapshot) {
          //     if (!showPlayButton) {
          //       print('Pace ${snapshot.data}');
          //       return Text(
          //           'Pace: ${snapshot.data!.toStringAsFixed(1)} min/km');
          //     }
          //     return const Text('Pace: 0.0 min/km');
          //   },
          // ),
          CustumButton(
            color: showPlayButton ? Colors.green : Colors.red,
            onPress: () {
              if (showPlayButton) {
                _stopWatchTimer.onExecute.add(StopWatchExecute.start);
              } else {
                _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
              }
              setState(() {
                showPlayButton = !showPlayButton;
              });
            },
            label: 'Start',
            icon: showPlayButton
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause),
          ),
          CustumButton(
            color: const Color.fromARGB(255, 0, 0, 0),
            onPress: () async {
              if (!showPlayButton) {
                _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
                setState(() {
                  showPlayButton = !showPlayButton;
                });
              }
              final currentUser = AuthService.firebase().currentUser!;
              await _runsSerivce.createNewRun(
                ownerUserId: currentUser.id,
                tempo: globalTime,
                velocidade: velocidades.isEmpty
                    ? '0'
                    : (velocidades.average > 2
                        ? (velocidades.average).toStringAsPrecision(2)
                        : '0'),
                data: DateTime.now().toString().substring(0, 10),
              );
              widget.onSaveChangeNavBar();
            },
            label: 'Save',
            icon: const Icon(Icons.stop),
          ),
          CustumButton(
            color: const Color.fromARGB(255, 200, 180, 2),
            onPress: () {
              Navigator.of(context).pushNamed(intervaladaRoute);
            },
            label: 'Intervalada',
            icon: const Icon(Icons.settings),
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
