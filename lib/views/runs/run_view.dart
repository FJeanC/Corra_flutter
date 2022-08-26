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
        title: const Text('Your Runs'),
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
                return const CircularProgressIndicator();
              }

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}



// class RunListView extends StatelessWidget {
//   const RunListView({
//     Key? key,
//     required this.runs,
//   }) : super(key: key);
//   final Iterable<CloudRun> runs;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Lista Corridas'),
//         ),
//         body: ListView.builder(
//           itemCount: runs.length,
//           itemBuilder: (context, index) {
//             final run = runs.elementAt(index);
//             return ListTile(
//               title: Text(run.data + ' ' + run.tempo + ' ' + run.velocidade),
//             );
//           },
//         ));
//   }
// }
