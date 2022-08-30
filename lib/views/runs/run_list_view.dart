import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/utilities/dialogs/delete_dialog.dart';
import 'package:corra/views/runs/run_detail_fragment.dart';
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
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RunDetailView(),
                settings: RouteSettings(
                  arguments: run,
                ),
              ),
            );
          },
          title: Text(
            run.data,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('Duration: ${run.tempo}'),
        );
      },
    );
  }
}
