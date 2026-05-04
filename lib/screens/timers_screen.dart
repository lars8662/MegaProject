import 'package:flutter/material.dart';

class TimersScreen extends StatelessWidget {
  const TimersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomInset + 84),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimerDialCard(),
                const SizedBox(height: 16),
                _StatusCard(),
                const SizedBox(height: 16),
                _ControlRow(),
                const Spacer(),
                const SizedBox(height: 20),
                _BottomActions(bottomInset: bottomInset),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TimerDialCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: SizedBox(
          height: 260,
          width: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF333A42), width: 10),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E2328),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('ОТДЫХ', style: TextStyle(fontSize: 13, color: Color(0xB3F6F1E8))),
                  SizedBox(height: 6),
                  Text('02:00', style: TextStyle(fontSize: 54, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.flag_rounded, color: Color(0xFFD4AF37)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Подход 3 из 5 · Отдых между попытками',
              style: TextStyle(fontSize: 15, color: Color(0xD9F6F1E8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _CircleControl(icon: Icons.replay_10_rounded)),
        SizedBox(width: 14),
        Expanded(child: _CircleControl(icon: Icons.pause_rounded, isPrimary: true)),
        SizedBox(width: 14),
        Expanded(child: _CircleControl(icon: Icons.forward_10_rounded)),
      ],
    );
  }
}

class _CircleControl extends StatelessWidget {
  const _CircleControl({required this.icon, this.isPrimary = false});

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFD4AF37) : const Color(0xFF2C3137),
          foregroundColor: isPrimary ? const Color(0xFF1A1D20) : const Color(0xFFF6F1E8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.bottomInset});

  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3137),
                  foregroundColor: const Color(0xFFF6F1E8),
                  elevation: 0,
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
                  backgroundColor: const Color(0xFF292D33),
                  foregroundColor: const Color(0xFFE1A7A7),
                  side: const BorderSide(color: Color(0x80A85E5E), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Завершить'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
