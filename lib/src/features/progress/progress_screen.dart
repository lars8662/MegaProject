import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Прогресс', style: Theme.of(context).textTheme.headlineSmall));
  }
}
