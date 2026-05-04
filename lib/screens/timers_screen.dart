import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const card = Color(0xFF2A2F34);
    const inner = Color(0xFF1F2328);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final timerSize = (maxWidth * 0.54).clamp(190.0, 250.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            children: [
              Container(
                width: timerSize,
                height: timerSize,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFFE1BE52),
                      Color(0xFFC39A2F),
                      Color(0xFFE1BE52),
                    ],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: inner,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '01:24',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Раунд 2 / 6',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: gold, size: 10),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Отдых между подходами · 45 сек',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleActionButton(
                    icon: Icons.replay_rounded,
                    size: 54,
                    background: const Color(0xFF30353A),
                    onTap: () {},
                  ),
                  const SizedBox(width: 18),
                  _CircleActionButton(
                    icon: Icons.pause_rounded,
                    size: 72,
                    background: gold,
                    iconColor: Colors.black,
                    glow: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 18),
                  _CircleActionButton(
                    icon: Icons.play_arrow_rounded,
                    size: 54,
                    background: const Color(0xFF30353A),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF4D535A)),
                        foregroundColor: const Color(0xFFE6DFD1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Пропустить'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Завершить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.size,
    required this.background,
    required this.onTap,
    this.iconColor = Colors.white,
    this.glow = false,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: glow
            ? const [
                BoxShadow(
                  color: Color(0x66D4AF37),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: iconColor, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}
