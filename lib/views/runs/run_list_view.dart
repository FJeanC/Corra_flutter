import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/cloud_storage_exceptions.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/utilities/dialogs/delete_dialog.dart';
import 'package:corra/utilities/dialogs/error_dialog.dart';
import 'package:corra/views/runs/run_detail_fragment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RunListView extends StatelessWidget {
  RunListView({
    Key? key,
    required this.runs,
  }) : super(key: key);

  final Iterable<CloudRun> runs;
  final FirebaseCloudRunStorage _runsService = FirebaseCloudRunStorage();

  @override
  Widget build(BuildContext context) {
    //int count = runs.length + 1;
    return ListView.builder(
      itemCount: runs.length,
      itemBuilder: (context, index) {
        int invertedIndex = runs.length - 1 - index;
        final run = runs.elementAt(index);
        //count--;
        return Card(
          elevation: 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 102, 200, 217),
              child: Text(
                '${invertedIndex + 1}',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            onLongPress: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                try {
                  await _runsService.deleteRun(documentId: run.documentId);
                } on CouldNotDeleteRunException {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                      context, AppLocalizations.of(context)!.couldNotDeleteRun);
                }
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
              run.data.substring(0, 10).replaceAll("-", "/"),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle:
                Text('${AppLocalizations.of(context)!.duration}: ${run.tempo}'),
          ),
        );
      },
    );
  }
}
