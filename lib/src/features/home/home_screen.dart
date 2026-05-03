import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TabPlaceholder(title: 'Главная');
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: Theme.of(context).textTheme.headlineSmall));
  }
}
