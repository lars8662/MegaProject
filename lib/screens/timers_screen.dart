import 'dart:math' as math;

import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xFFD4AF37);
    const warmText = Color(0xFFF6F1E8);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Таймер',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: warmText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Фингерборд / Repeaters',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: warmText.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 26),
          const Center(
            child: _TimerDial(
              progress: 0.78,
              phaseLabel: 'ВИС',
              remaining: '00:07',
            ),
          ),
          const SizedBox(height: 22),
          _StatusCard(theme: theme, accent: accent, warmText: warmText),
          const SizedBox(height: 24),
          const _TimerControls(accent: accent),
          const SizedBox(height: 28),
          Row(
            children: const [
              Expanded(child: _BottomActionButton(label: 'Пропустить')),
              SizedBox(width: 12),
              Expanded(child: _BottomActionButton(label: 'Завершить')),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  const _TimerDial({required this.progress, required this.phaseLabel, required this.remaining});

  final double progress;
  final String phaseLabel;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 274,
      height: 274,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0x22D4AF37), Color(0x081A1D20)],
          radius: 0.92,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            spreadRadius: 2,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x2CD4AF37),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 252,
            height: 252,
            child: CustomPaint(
              painter: _RingPainter(progress: progress),
            ),
          ),
          Container(
            width: 214,
            height: 214,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B3138), Color(0xFF1C2025)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phaseLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.1,
                    color: const Color(0xFFF6F1E8).withValues(alpha: 0.88),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  remaining,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF6F1E8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final base = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13;

    canvas.drawCircle(center, radius - 6.5, base);

    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF8A6C12), Color(0xFFD4AF37), Color(0xFFFFE197)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13;

    final start = -math.pi / 2;
    final sweep = (math.pi * 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6.5),
      start,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.theme, required this.accent, required this.warmText});

  final ThemeData theme;
  final Color accent;
  final Color warmText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Следующий этап',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: warmText.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ОТДЫХ: 00:03',
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Прогресс',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: warmText.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Сет 3 из 6',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SmallControlButton(icon: Icons.restart_alt_rounded, onTap: () {}),
        Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF3CE64), Color(0xFFD4AF37)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4DD4AF37),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            iconSize: 38,
            color: const Color(0xFF1D2126),
            icon: const Icon(Icons.pause_rounded),
          ),
        ),
        _SmallControlButton(icon: Icons.play_arrow_rounded, onTap: () {}),
      ],
    );
  }
}

class _SmallControlButton extends StatelessWidget {
  const _SmallControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2A2F34),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: const Color(0xFFF6F1E8), size: 30),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF6F1E8),
        side: const BorderSide(color: Color(0x33FFFFFF)),
        backgroundColor: const Color(0xFF252A2F),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}
