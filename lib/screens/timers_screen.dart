import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D111B),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final timerSize = width * 0.58;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Таймер',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Фингерборд / Repeaters',
                        style: TextStyle(
                          color: Color(0xFF97A0B3),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        child: _PremiumTimer(size: timerSize),
                      ),
                      const SizedBox(height: 14),
                      const _StatusCard(),
                      const SizedBox(height: 16),
                      const _ControlsRow(),
                      const Spacer(),
                      const SizedBox(height: 16),
                      const _BottomActions(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x50D7A452),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _RingPainter(progress: 0.7),
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1B2231), Color(0xFF0F1420)],
            ),
            border: Border.all(color: const Color(0xFF283043), width: 1.2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ВИС',
                style: TextStyle(
                  color: Color(0xFF9FAAC1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '00:07',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
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
    const stroke = 12.0;
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - stroke / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0xFF2A3244)
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8D487), Color(0xFFD8A24A), Color(0xFFB67A2B)],
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
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF171E2B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF242E42)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Следующий этап',
            style: TextStyle(
              color: Color(0xFF9AA5BC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'ОТДЫХ: 00:03',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Прогресс',
            style: TextStyle(
              color: Color(0xFF9AA5BC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Сет 3 из 6',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
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
        _RoundControl(icon: Icons.restart_alt_rounded, size: 56),
        SizedBox(width: 20),
        _RoundControl(icon: Icons.pause_rounded, size: 84, isPrimary: true),
        SizedBox(width: 20),
        _RoundControl(icon: Icons.play_arrow_rounded, size: 56),
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
    final bg = isPrimary
        ? const LinearGradient(colors: [Color(0xFFF1CD82), Color(0xFFCB9240)])
        : const LinearGradient(colors: [Color(0xFF232D42), Color(0xFF182133)]);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: bg,
        boxShadow: [
          if (isPrimary)
            const BoxShadow(
              color: Color(0x70D9A24E),
              blurRadius: 24,
              spreadRadius: 1,
            ),
          const BoxShadow(
            color: Color(0x65000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: isPrimary ? 42 : 30,
        color: isPrimary ? const Color(0xFF2E1C0A) : Colors.white,
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
          child: _ActionButton(
            title: 'Пропустить',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            title: 'Завершить',
            isDanger: true,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.title, required this.onTap, this.isDanger = false});

  final String title;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger ? const Color(0xFF4A1E1E) : const Color(0xFF20283A),
          foregroundColor: isDanger ? const Color(0xFFFF9E9E) : const Color(0xFFE7EDF8),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
