import 'package:corra/views/cronometro/cronometro_view.dart';
import 'package:corra/views/runs/run_view.dart';
import 'package:flutter/material.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({Key? key}) : super(key: key);

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  final screens = const [
    RunView(),
    CronometroView(),
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'ListRuns',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer),
              label: 'Cronometro',
            ),
          ],
        ),
      ),
    );
  }
}
