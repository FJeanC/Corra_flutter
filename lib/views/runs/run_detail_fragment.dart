import 'package:corra/services/cloud/cloud_run.dart';
import 'package:flutter/material.dart';

class RunDetailView extends StatelessWidget {
  const RunDetailView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final run = ModalRoute.of(context)!.settings.arguments as CloudRun;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail view'),
      ),
      body: Column(
        children: [Text(run.data), Text(run.velocidade), Text(run.tempo)],
      ),
    );
  }
}
