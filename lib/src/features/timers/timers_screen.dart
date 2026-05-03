import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Таймеры', style: Theme.of(context).textTheme.headlineSmall));
  }
}
