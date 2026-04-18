import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../models/app_models.dart';

class BadgeCenterData {
  const BadgeCenterData({
    required this.currentRank,
    required this.nextRank,
    required this.xp,
    required this.unlockedCount,
    required this.badges,
  });

  final BadgeRank currentRank;
  final BadgeRank? nextRank;
  final int xp;
  final int unlockedCount;
  final List<BadgeMedal> badges;

  List<BadgeMedal> get unlockedBadges =>
      badges.where((badge) => badge.unlocked).toList(growable: false);

  List<BadgeMedal> get lockedBadges =>
      badges.where((badge) => !badge.unlocked).toList(growable: false);

  double get progressToNextRank {
    final next = nextRank;
    if (next == null) {
      return 1;
    }

    final span = next.minXp - currentRank.minXp;
    if (span <= 0) {
      return 1;
    }

    return ((xp - currentRank.minXp) / span).clamp(0, 1);
  }

  int get xpToNextRank {
    final next = nextRank;
    if (next == null) {
      return 0;
    }

    return (next.minXp - xp).clamp(0, 99999);
  }
}

class BadgeRank {
  const BadgeRank({
    required this.title,
    required this.subtitle,
    required this.minXp,
    required this.color,
  });

  final String title;
  final String subtitle;
  final int minXp;
  final Color color;
}

class BadgeMedal {
  const BadgeMedal({
    required this.id,
    required this.title,
    required this.description,
    required this.requirement,
    required this.icon,
    required this.color,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final String requirement;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

BadgeCenterData buildBadgeCenterData(AppBootstrap data) {
  final profileComplete = _hasCompletedProfile(data.user);
  final bookingCount = data.bookings.length;
  final activeBookingCount = data.bookings
      .where((booking) => booking.status != 'cancelled')
      .length;
  final completedBookingCount = data.bookings
      .where((booking) => booking.status == 'completed')
      .length;
  final coursesInProgress = data.courses
      .where((course) => course.progressPercent > 0)
      .length;
  final courseProgressPoints = data.courses.fold<int>(
    0,
    (sum, course) => sum + course.progressPercent,
  );
  final isPremium = data.subscription.planId == 'premium' ||
      data.subscription.planName.toLowerCase().contains('premium');
  final isSpecialist = data.user.accountType == 'specialist';
  final specialistServiceCount = isSpecialist ? data.services.length : 0;

  final xp = (profileComplete ? 60 : 0) +
      (data.user.email.trim().isNotEmpty ? 20 : 0) +
      (bookingCount * 18) +
      (completedBookingCount * 12) +
      (coursesInProgress * 16) +
      (courseProgressPoints ~/ 10) +
      (data.user.preferences.focusAreas.length.clamp(0, 3) * 6) +
      (data.user.preferences.preferredSessionModes.length.clamp(0, 3) * 8) +
      (isPremium ? 45 : 0) +
      (isSpecialist ? 60 : 0) +
      (specialistServiceCount.clamp(0, 5) * 14) +
      (activeBookingCount.clamp(0, 6) * 10);

  const ranks = <BadgeRank>[
    BadgeRank(
      title: 'Semilla Lunar',
      subtitle: 'Acabas de abrir tu mapa dentro de la app.',
      minXp: 0,
      color: AppPalette.roseDust,
    ),
    BadgeRank(
      title: 'Buscador Estelar',
      subtitle: 'Ya exploras tu proceso con intención.',
      minXp: 120,
      color: AppPalette.royalViolet,
    ),
    BadgeRank(
      title: 'Intérprete Sutil',
      subtitle: 'Tu práctica ya tiene continuidad y lectura propia.',
      minXp: 240,
      color: AppPalette.orchid,
    ),
    BadgeRank(
      title: 'Alquimista Interior',
      subtitle: 'Conviertes experiencia en ritual y criterio.',
      minXp: 400,
      color: AppPalette.flameGold,
    ),
    BadgeRank(
      title: 'Oráculo Renaciente',
      subtitle: 'Tu presencia ya deja huella en el ecosistema.',
      minXp: 620,
      color: AppPalette.midnight,
    ),
  ];

  var currentRank = ranks.first;
  BadgeRank? nextRank;
  for (var index = 0; index < ranks.length; index += 1) {
    final rank = ranks[index];
    final next = index + 1 < ranks.length ? ranks[index + 1] : null;
    if (xp >= rank.minXp) {
      currentRank = rank;
      nextRank = next;
    }
  }

  final badges = <BadgeMedal>[
    BadgeMedal(
      id: 'profile-complete',
      title: 'Perfil Radiante',
      description: 'Completaste tu identidad base dentro del ritual digital.',
      requirement: 'Completa nombre, email y datos natales.',
      icon: Icons.auto_awesome_outlined,
      color: AppPalette.flameGold,
      unlocked: profileComplete,
    ),
    BadgeMedal(
      id: 'first-reading',
      title: 'Primera Consulta',
      description: 'Abriste tu primera experiencia guiada dentro de la app.',
      requirement: 'Agenda al menos una consulta.',
      icon: Icons.local_fire_department_outlined,
      color: AppPalette.berry,
      unlocked: bookingCount >= 1,
    ),
    BadgeMedal(
      id: 'active-agenda',
      title: 'Agenda Viva',
      description: 'Tienes movimiento real en tu calendario espiritual.',
      requirement: 'Mantén al menos una cita activa.',
      icon: Icons.calendar_month_outlined,
      color: AppPalette.royalViolet,
      unlocked: activeBookingCount >= 1,
    ),
    BadgeMedal(
      id: 'study-circle',
      title: 'Aprendiz Constante',
      description: 'Ya empezaste a convertir contenido en práctica.',
      requirement: 'Avanza en al menos un curso.',
      icon: Icons.auto_stories_outlined,
      color: AppPalette.indigo,
      unlocked: coursesInProgress >= 1,
    ),
    BadgeMedal(
      id: 'deep-focus',
      title: 'Mapa Profundo',
      description: 'Tu perfil ya tiene focos y modos de trabajo claros.',
      requirement: 'Define varias áreas de enfoque y modos preferidos.',
      icon: Icons.explore_outlined,
      color: AppPalette.orchid,
      unlocked: data.user.preferences.focusAreas.length >= 2 &&
          data.user.preferences.preferredSessionModes.length >= 2,
    ),
    BadgeMedal(
      id: 'premium-circle',
      title: 'Círculo Premium',
      description: 'Accedes a una capa más profunda del ecosistema.',
      requirement: 'Activa un plan Premium.',
      icon: Icons.workspace_premium_outlined,
      color: AppPalette.flameGold,
      unlocked: isPremium,
    ),
    BadgeMedal(
      id: 'guide-mode',
      title: 'Guía Activa',
      description: 'Entraste en modo especialista y abriste tu panel operativo.',
      requirement: 'Activa el perfil especialista.',
      icon: Icons.psychology_alt_outlined,
      color: AppPalette.midnight,
      unlocked: isSpecialist,
    ),
    BadgeMedal(
      id: 'service-keeper',
      title: 'Custodio del Servicio',
      description: 'Tu oferta ya está visible y lista para sostener sesiones.',
      requirement: 'Ten al menos un servicio disponible como especialista.',
      icon: Icons.style_outlined,
      color: AppPalette.warning,
      unlocked: isSpecialist && specialistServiceCount >= 1,
    ),
  ];

  return BadgeCenterData(
    currentRank: currentRank,
    nextRank: nextRank,
    xp: xp,
    unlockedCount: badges.where((badge) => badge.unlocked).length,
    badges: badges,
  );
}

class ProfileBadgesScreen extends StatelessWidget {
  const ProfileBadgesScreen({
    super.key,
    required this.data,
  });

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    final center = buildBadgeCenterData(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insignias'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _RankHeroCard(
            userName: data.user.firstName.trim().isEmpty
                ? 'Tu perfil'
                : data.user.firstName.trim(),
            center: center,
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Progreso',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.currentRank.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: center.progressToNextRank,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                        backgroundColor: AppPalette.softLilac,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(center.currentRank.color),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${center.xp} XP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  center.nextRank == null
                      ? 'Ya alcanzaste el rango más alto disponible.'
                      : 'Te faltan ${center.xpToNextRank} XP para ${center.nextRank!.title}.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.mutedLavender,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Insignias activas',
            subtitle:
                '${center.unlockedCount} desbloqueadas en este momento.',
          ),
          const SizedBox(height: 12),
          if (center.unlockedBadges.isEmpty)
            const _EmptyBadgeState(
              title: 'Todavía no hay insignias activas',
              subtitle:
                  'Completa tu perfil o agenda tu primera consulta para empezar a desbloquearlas.',
            )
          else
            ...center.unlockedBadges.map(
              (badge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BadgeCard(badge: badge, unlocked: true),
              ),
            ),
          const SizedBox(height: 12),
          _SectionHeader(
            title: 'Por desbloquear',
            subtitle: 'Estas son las siguientes metas visibles.',
          ),
          const SizedBox(height: 12),
          ...center.lockedBadges.map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BadgeCard(badge: badge, unlocked: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankHeroCard extends StatelessWidget {
  const _RankHeroCard({
    required this.userName,
    required this.center,
  });

  final String userName;
  final BadgeCenterData center;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.midnight,
            AppPalette.indigo,
            AppPalette.royalViolet,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.indigo.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -12,
            child: Icon(
              Icons.military_tech_outlined,
              size: 144,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insignias de $userName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  center.currentRank.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  center.currentRank.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroPill(label: '${center.xp} XP'),
                    _HeroPill(label: '${center.unlockedCount} insignias'),
                    _HeroPill(
                      label: center.nextRank == null
                          ? 'Rango máximo'
                          : 'Siguiente: ${center.nextRank!.title}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppPalette.butterflyInk,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppPalette.mutedLavender,
              ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
    required this.unlocked,
  });

  final BadgeMedal badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : AppPalette.petalSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: unlocked
              ? badge.color.withValues(alpha: 0.28)
              : AppPalette.borderSoft,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? badge.color.withValues(alpha: 0.14)
                  : AppPalette.softLilac,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              badge.icon,
              color: unlocked ? badge.color : AppPalette.mutedLavender,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: unlocked
                                  ? AppPalette.butterflyInk
                                  : AppPalette.mutedLavender,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? badge.color.withValues(alpha: 0.12)
                            : AppPalette.candleGlow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        unlocked ? 'Activa' : 'Meta',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: unlocked
                                  ? badge.color
                                  : AppPalette.mutedLavender,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  badge.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: unlocked
                            ? AppPalette.butterflyInk
                            : AppPalette.mutedLavender,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  badge.requirement,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.mutedLavender,
                        fontWeight: FontWeight.w700,
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

class _EmptyBadgeState extends StatelessWidget {
  const _EmptyBadgeState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.petalSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.mutedLavender,
                  height: 1.45,
                ),
          ),
        ],
      ),
    );
  }
}

bool _hasCompletedProfile(UserProfile user) {
  return user.firstName.trim().isNotEmpty &&
      user.lastName.trim().isNotEmpty &&
      user.email.trim().isNotEmpty &&
      user.natalChart.birthDate.trim().isNotEmpty &&
      user.natalChart.birthTime.trim().isNotEmpty &&
      user.natalChart.city.trim().isNotEmpty &&
      user.natalChart.country.trim().isNotEmpty &&
      user.natalChart.timeZoneId.trim().isNotEmpty &&
      user.natalChart.utcOffset.trim().isNotEmpty &&
      user.natalChart.latitude != null &&
      user.natalChart.longitude != null;
}
