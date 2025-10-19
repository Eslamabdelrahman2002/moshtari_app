import 'package:flutter/material.dart';
import 'package:mushtary/features/services/ui/screens/dinat_screen.dart';
import 'package:mushtary/features/services/ui/screens/satha_screen.dart';
import 'package:mushtary/features/services/ui/screens/shrej_screen.dart';
import 'package:mushtary/features/services/ui/screens/worker_screen.dart';

class ServiceScreen extends StatelessWidget {
  final int index;
  ServiceScreen({super.key, required this.index});

  final List<Widget> screens = const [
    WorkerScreen(),
    DinatScreen(),
    SathaScreen(),
    ShrejScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: screens[index]),
    );
  }
}