// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _stats = [
    _ProfileStat('Уровень', '7B', 'боулдеринг'),
    _ProfileStat('Вес', '73', 'кг'),
    _ProfileStat('Рост', '178', 'см'),
  ];

  static const _settingsTop = [
    _SettingsItem(Icons.person_outline_rounded, 'Личные данные', 'Профиль и параметры'),
    _SettingsItem(Icons.notifications_none_rounded, 'Уведомления', 'Таймеры и напоминания'),
    _SettingsItem(Icons.workspace_premium_rounded, 'Подписка Premium', 'Расширенная аналитика'),
  ];

  static const _settingsBottom = [
    _SettingsItem(Icons.straighten_rounded, 'Единицы измерения', 'кг / см'),
    _SettingsItem(Icons.dark_mode_outlined, 'Тёмная тема', 'Включена'),
    _SettingsItem(Icons.download_rounded, 'Экспорт данных', 'CSV / JSON'),
    _SettingsItem(Icons.info_outline_rounded, 'О приложении', 'Версия 1.0.0'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      children: [
        Text(
          'Профиль',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Цели, уровень и настройки приложения.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xB3F6F1E8),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 14),
        const _ProfileHeroCard(),
        const SizedBox(height: 12),
        const _StatsRow(stats: _stats),
        const SizedBox(height: 12),
        const _GoalCard(),
        const SizedBox(height: 12),
        _SettingsGroup(items: _settingsTop),
        const SizedBox(height: 12),
        _SettingsGroup(items: _settingsBottom),
        const SizedBox(height: 12),
        const _LogoutButton(),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x164C5560), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const _AvatarBadge(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Алекс Иванов',
                  style: TextStyle(
                    color: Color(0xFFF6F1E8),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF343039),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x1AD4AF37)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Climbing Grade:',
                        style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 7),
                      Text(
                        '7B boulder',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Цель: 8A за сезон',
                  style: TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4AF37), Color(0xFF3A3545)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x33D4AF37), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF171A1E),
        ),
        child: const Center(
          child: Text(
            'A',
            style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 34, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final List<_ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: _StatCard(stat: stats[i])),
          if (i != stats.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stat.label, style: const TextStyle(color: Color(0x80F6F1E8), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(stat.value, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 23, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 3),
          Text(stat.caption, style: const TextStyle(color: Color(0x80F6F1E8), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Цель месяца', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('12 тренировок', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 19, fontWeight: FontWeight.w900)),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 7,
                    backgroundColor: Color(0x334C5560),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const _GoalRing(),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        fit: StackFit.expand,
        children: const [
          CircularProgressIndicator(
            value: 0.85,
            strokeWidth: 6,
            backgroundColor: Color(0x334C5560),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          ),
          Center(
            child: Text('85%', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SettingsRow(item: items[i]),
            if (i != items.length - 1) const Divider(height: 1, color: Color(0x144C5560), indent: 54),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final isPremium = item.title.contains('Premium');

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isPremium ? const Color(0x22D4AF37) : const Color(0xFF2D333A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: isPremium ? const Color(0xFFD4AF37) : const Color(0xCCF6F1E8), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(item.subtitle, style: const TextStyle(color: Color(0x80F6F1E8), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0x80F6F1E8), size: 24),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE7B2B2),
          side: const BorderSide(color: Color(0x55A85E5E), width: 1.2),
          backgroundColor: const Color(0xFF1B1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.logout_rounded, size: 19),
        label: const Text('Выйти', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ProfileStat {
  const _ProfileStat(this.label, this.value, this.caption);

  final String label;
  final String value;
  final String caption;
}

class _SettingsItem {
  const _SettingsItem(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}
