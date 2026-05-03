import 'package:climbing_diary/src/features/diary/diary_screen.dart';
import 'package:climbing_diary/src/features/home/home_screen.dart';
import 'package:climbing_diary/src/features/profile/profile_screen.dart';
import 'package:climbing_diary/src/features/progress/progress_screen.dart';
import 'package:climbing_diary/src/features/timers/timers_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/diary', builder: (_, __) => const DiaryScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/timers', builder: (_, __) => const TimersScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
      ],
    ),
  ],
);

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: navigationShell),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index,
            initialLocation: index == navigationShell.currentIndex),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Дневник'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Таймеры'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_outlined), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        ],
      ),
    );
  }
}
