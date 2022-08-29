import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

class RunListView extends StatelessWidget {
  RunListView({
    Key? key,
    required this.runs,
  }) : super(key: key);

  final Iterable<CloudRun> runs;
  final FirebaseCloudRunStorage _runsService = FirebaseCloudRunStorage();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: runs.length,
      itemBuilder: (context, index) {
        final run = runs.elementAt(index);
        return ListTile(
          onLongPress: () async {
            final shouldDelete = await showDeleteDialog(context);
            if (shouldDelete) {
              await _runsService.deleteRun(documentId: run.documentId);
            }
          },
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
