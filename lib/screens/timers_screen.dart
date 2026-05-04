// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final timerSize = (constraints.maxWidth * 0.64).clamp(220.0, 270.0);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 12, 18, 120 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Таймер',
                style: TextStyle(
                  color: Color(0xFFF6F1E8),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Фингерборд / Repeaters',
                style: TextStyle(
                  color: Color(0xB3F6F1E8),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Center(child: _PremiumTimer(size: timerSize)),
              const SizedBox(height: 16),
              const _StatusCard(),
              const SizedBox(height: 16),
              const _ControlsRow(),
              const SizedBox(height: 22),
              const _BottomActions(),
            ],
          ),
        );
      },
    );
  }
}

class _PremiumTimer extends StatelessWidget {
  const _PremiumTimer({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x48D4AF37),
            blurRadius: 34,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RingPainter(progress: 0.78),
        child: Container(
          margin: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF222A35), Color(0xFF151A22)],
            ),
            border: Border.all(color: const Color(0xFF303746), width: 1.2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ВИС',
                style: TextStyle(
                  color: Color(0xB3F6F1E8),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
              SizedBox(height: 9),
              Text(
                '00:07',
                style: TextStyle(
                  color: Color(0xFFF6F1E8),
                  fontSize: 54,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - stroke / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0x334C5560)
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDE83), Color(0xFFD4AF37), Color(0xFF9D7A18)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      6.28318 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x224C5560), width: 1.2),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Следующий этап',
            style: TextStyle(
              color: Color(0x99F6F1E8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'ОТДЫХ: 00:03',
            style: TextStyle(
              color: Color(0xFFF6F1E8),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Прогресс',
            style: TextStyle(
              color: Color(0x99F6F1E8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Сет 3 из 6',
            style: TextStyle(
              color: Color(0xFFF6F1E8),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _RoundControl(icon: Icons.restart_alt_rounded, size: 60),
        SizedBox(width: 26),
        _RoundControl(icon: Icons.pause_rounded, size: 88, isPrimary: true),
        SizedBox(width: 26),
        _RoundControl(icon: Icons.play_arrow_rounded, size: 60),
      ],
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({required this.icon, required this.size, this.isPrimary = false});

  final IconData icon;
  final double size;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final gradient = isPrimary
        ? const LinearGradient(colors: [Color(0xFFF5CF63), Color(0xFFD4AF37)])
        : const LinearGradient(colors: [Color(0xFF2C3137), Color(0xFF20262D)]);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          if (isPrimary)
            const BoxShadow(
              color: Color(0x5CD4AF37),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          const BoxShadow(
            color: Color(0x44000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: isPrimary ? 42 : 30,
        color: isPrimary ? const Color(0xFF1A1D20) : const Color(0xFFF6F1E8),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF6F1E8),
                side: const BorderSide(color: Color(0x334C5560), width: 1.2),
                backgroundColor: const Color(0xFF252A2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Пропустить'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE7B2B2),
                side: const BorderSide(color: Color(0x66A85E5E), width: 1.2),
                backgroundColor: const Color(0xFF252A2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Завершить'),
            ),
          ),
        ),
      ],
    );
  }
}
