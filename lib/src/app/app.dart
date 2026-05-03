import 'package:climbing_diary/src/navigation/app_router.dart';
import 'package:climbing_diary/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ClimbingDiaryApp extends StatelessWidget {
  const ClimbingDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Climbing Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
