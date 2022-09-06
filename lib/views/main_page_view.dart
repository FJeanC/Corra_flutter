import 'package:corra/views/cronometro/cronometro_view.dart';
import 'package:corra/views/runs/run_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({Key? key}) : super(key: key);

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    void navCallBack() {
      setState(() {
        index = 0;
      });
    }

    final screens = [
      const RunView(),
      CronometroView(
        onSaveChangeNavBar: navCallBack,
      ),
    ];

    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.shade100,
        ),
        child: NavigationBar(
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          selectedIndex: index,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.listRun,
            ),
            NavigationDestination(
              icon: const Icon(Icons.timer),
              label: AppLocalizations.of(context)!.timer,
            ),
          ],
        ),
      ),
    );
  }
}
