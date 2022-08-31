import 'package:flutter/material.dart';
import 'package:corra/views/intervalada/intervalada_provider.dart';

class IntervaladaView extends StatefulWidget {
  const IntervaladaView({Key? key}) : super(key: key);

  @override
  State<IntervaladaView> createState() => _IntervaladaViewState();
}

class _IntervaladaViewState extends State<IntervaladaView> {
  late final TextEditingController _walkTime;
  late final TextEditingController _runTime;
  late final TextEditingController _repeat;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Intervalada'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              TextField(
                controller: _walkTime,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter walk time',
                ),
              ),
              TextField(
                controller: _runTime,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter run time',
                ),
              ),
              TextField(
                controller: _repeat,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter repeat',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: () {
                    intervaladaController.initializeIntervalada(
                      r: int.parse(_repeat.text),
                      wT: int.parse(_walkTime.text),
                      rT: int.parse(_runTime.text),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ));
  }
}
