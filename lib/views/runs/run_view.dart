import 'package:corra/services/cloud/cloud_run.dart';
import 'package:corra/services/cloud/firebase_cloud_run_storage.dart';
import 'package:corra/views/runs/run_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:corra/enums/menu_action.dart';
import 'package:corra/services/auth/auth_service.dart';
import 'package:corra/services/auth/bloc/auth_bloc.dart';
import 'package:corra/services/auth/bloc/auth_event.dart';

import 'package:corra/utilities/dialogs/logout_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RunView extends StatefulWidget {
  const RunView({Key? key}) : super(key: key);

  @override
  State<RunView> createState() => _RunViewState();
}

class _RunViewState extends State<RunView> {
  String get userId => AuthService.firebase().currentUser!.id;
  late final FirebaseCloudRunStorage _runsService;

  @override
  void initState() {
    _runsService = FirebaseCloudRunStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourRuns),
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
                case MenuAction.save:
                  // TODO: Handle this case.
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
      body: StreamBuilder(
        stream: _runsService.allRuns(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allRuns = snapshot.data as Iterable<CloudRun>;
                return RunListView(runs: allRuns);
              } else {
                return const Center(child: CircularProgressIndicator());
              }

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
