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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  String? intervalNameType;
  bool walking = true;
  //TTS variables
  final _ttsObj = TTS();
  double auxTTS = 1;

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

    bool aux = interObj.intervalType;
    interObj.handleRepetion();
    print("I have a pen");
    if (aux != interObj.intervalType) {
      print("I have an apple");
      print('Interval name type: $intervalNameType');
      print(intervalNameType == AppLocalizations.of(context)!.walking);
      print("AUX ${aux}");
      setState(() {
        // intervalNameType =
        //     (intervalNameType == AppLocalizations.of(context)!.walking)
        //         ? AppLocalizations.of(context)!.running
        //         : AppLocalizations.of(context)!.walking;
        if (intervalNameType == null ||
            intervalNameType == AppLocalizations.of(context)!.walking) {
          print("è true da true man");
          intervalNameType = AppLocalizations.of(context)!.running;
        } else {
          print("è false da false  da true man");
          intervalNameType = AppLocalizations.of(context)!.walking;
        }
      });
    }
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
            if (auxpace < 60.0) {
              setState(() {
                pace = auxpace;
              });
            }

            if (dist >= auxTTS) {
              print('SHOULD SPEAK');
              _ttsObj.speak(context);
              auxTTS += 1;
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
    interObj.resetInterval();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.run),
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
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(AppLocalizations.of(context)!.logout),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData: 0,
                    builder: (context, snap) {
                      final value = snap.data;
                      final displayTime = StopWatchTimer.getDisplayTime(value!,
                          hours: _isHours);
                      globalTime = displayTime;
                      return Text(
                        displayTime,
                        style: const TextStyle(
                            fontSize: 27, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<double?>(
                    stream: _distanceUpdatedStreamContoller.stream,
                    initialData: 0.0,
                    builder: (context, snapshot) {
                      if (!showPlayButton) {
                        //distance += (snapshot.data!);
                        print(
                            'I am here  ${snapshot.data!.toStringAsFixed(2)}');
                      }
                      return Text(
                        'Dist: ${snapshot.data!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 27,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<double?>(
                    stream: _velocityUpdatedStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print((snapshot.data!).toStringAsPrecision(2));
                        return Text(
                          '${(snapshot.data!).toStringAsPrecision(2)} KM/H',
                          style: const TextStyle(fontSize: 27),
                        );
                      } else {
                        return Text(
                          '${(_velocity).toStringAsPrecision(2)} KM/H',
                          style: const TextStyle(fontSize: 27),
                        );
                      }
                    },
                  ),
                ),
                // const SizedBox(
                //   width: 50,
                // ),
                Expanded(
                  child: Text(
                    'Pace: ${pace.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 27,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color.fromARGB(255, 0, 123, 255)),
                bottom: BorderSide(color: Color.fromARGB(255, 0, 64, 255)),
              ),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.interval}: ${interObj.userWantsInterval ? (intervalNameType ?? AppLocalizations.of(context)!.walking) : AppLocalizations.of(context)!.disabled},',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color.fromARGB(255, 28, 17, 17), fontSize: 40),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustumButton(
                  color: interObj.userWantsInterval
                      ? const Color.fromARGB(255, 107, 107, 107)
                      : const Color.fromARGB(255, 235, 212, 0),
                  onPress: () {
                    interObj.userWantsInterval
                        ? (_) => {}
                        : Navigator.of(context).pushNamed(intervaladaRoute);
                  },
                  label: 'Intervalada',
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
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
                data: DateTime.now()
                    .toString(), // 0 - 10 é a data  12 a 19 horario
              );
              print(DateTime.now().toString());
              // Callback para mudar o view para a run list view
              interObj.disposeprefs();
              widget.onSaveChangeNavBar();
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
