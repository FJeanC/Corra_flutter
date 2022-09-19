import 'package:flutter/material.dart';
import 'package:corra/views/intervalada/intervalada_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntervaladaView extends StatefulWidget {
  const IntervaladaView({Key? key}) : super(key: key);

  @override
  State<IntervaladaView> createState() => _IntervaladaViewState();
}

class _IntervaladaViewState extends State<IntervaladaView> {
  late final TextEditingController _walkTime;
  late final TextEditingController _runTime;
  late final TextEditingController _repeat;
  bool userWantsIntervals = false;
  final intervaladaController = IntervaladaProvider();

  @override
  void initState() {
    _walkTime = TextEditingController();
    _runTime = TextEditingController();
    _repeat = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _walkTime.dispose();
    _runTime.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _setPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setInt('walk', int.parse(_walkTime.text));
      prefs.setInt('run', int.parse(_runTime.text));
      prefs.setInt('repeat', int.parse(_repeat.text));
    });
    intervaladaController.initialize(interval: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.intevals),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Center(
              child: Text(AppLocalizations.of(context)!.activateIntervals),
            ),
            Switch(
              value: userWantsIntervals,
              activeColor: Colors.red,
              onChanged: (bool value) => setState(() {
                userWantsIntervals = value;
              }),
            ),
            userWantsIntervals
                ? TextField(
                    controller: _walkTime,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterWalkTime,
                    ),
                  )
                : Container(),
            userWantsIntervals
                ? TextField(
                    controller: _runTime,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterRunTime,
                    ),
                  )
                : Container(),
            userWantsIntervals
                ? TextField(
                    controller: _repeat,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterRepeat,
                    ),
                  )
                : Container(),
            userWantsIntervals
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _setPrefs();

                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
