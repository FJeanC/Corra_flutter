import 'package:corra/services/cloud/cloud_run.dart';
import 'package:flutter/material.dart';

class RunListView extends StatelessWidget {
  const RunListView({
    Key? key,
    required this.runs,
  }) : super(key: key);

  final Iterable<CloudRun> runs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: runs.length,
      itemBuilder: (context, index) {
        final run = runs.elementAt(index);
        return ListTile(
          title: Text(
            run.tempo,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
