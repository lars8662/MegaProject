import 'package:flutter/material.dart';

import '../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderContent(
      title: 'Главная',
      description: 'Обзор активности и быстрый старт тренировок.',
    );
  }
}
