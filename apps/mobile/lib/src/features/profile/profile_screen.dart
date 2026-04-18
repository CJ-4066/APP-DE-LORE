import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import 'account_center_screens.dart';
import 'profile_badges_screen.dart';
import 'profile_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onEditProfile,
    required this.onStartPhoneLogin,
    required this.onLogout,
    required this.onOpenAstralChart,
    required this.onEnterSpecialistMode,
    required this.onExitSpecialistMode,
    required this.currentLocale,
    required this.onChangeLocale,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onEditProfile;
  final VoidCallback onStartPhoneLogin;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenAstralChart;
  final Future<String?> Function() onEnterSpecialistMode;
  final Future<String?> Function() onExitSpecialistMode;
  final Locale currentLocale;
  final Future<void> Function(Locale locale) onChangeLocale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLanguage =
        AppLocalizations.languageOptionForLocale(currentLocale);
    final canManageSubscription =
        data.plans.isNotEmpty && data.subscription.platform.trim().isNotEmpty;
    final canOpenPrivacy = data.user.id.trim().isNotEmpty;
    final canOpenSupport = data.admin.activeUsers >= 0;
    final isGuestMode = data.user.id.trim().isEmpty;
    final isAdmin = data.user.roles.contains('admin');
    final badgeCenter = buildBadgeCenterData(data);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              l10n.tr('profileTitle'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(
                          firstName: data.user.firstName,
                          lastName: data.user.lastName,
                          avatarUrl: data.user.avatarUrl,
                          radius: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayUserName(data.user),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              if (data.user.nickname.trim().isNotEmpty)
                                Text(
                                  '@${data.user.nickname.trim()}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              if (data.user.nickname.trim().isNotEmpty)
                                const SizedBox(height: 4),
                              Text(
                                l10n.tr(
                                  'currentPlan',
                                  {'plan': data.subscription.planName},
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppPalette.softLilac,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${badgeCenter.currentRank.title} · ${badgeCenter.xp} XP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppPalette.butterflyInk,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  if (isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppPalette.orchid.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Usuario madre',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: AppPalette.indigo,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tr('email'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.user.email.isEmpty
                          ? l10n.tr('noEmail')
                          : data.user.email,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tr('location'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.user.location.isEmpty
                          ? l10n.tr('noLocation')
                          : data.user.location,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tr('natalData'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.user.natalChart.birthDate} · ${data.user.natalChart.birthTime}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.user.natalChart.city}, ${data.user.natalChart.country}',
                    ),
                    if (data.user.natalChart.utcOffset.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.tr(
                          'utcOffset',
                          {'offset': data.user.natalChart.utcOffset},
                        ),
                      ),
                    ],
                    if (data.user.natalChart.latitude != null &&
                        data.user.natalChart.longitude != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.tr(
                          'coords',
                          {
                            'lat': '${data.user.natalChart.latitude}',
                            'lng': '${data.user.natalChart.longitude}',
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (isGuestMode) ...[
                      Text(
                        l10n.tr('guestModeTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.tr('guestModeSubtitle')),
                      const SizedBox(height: 20),
                    ],
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (isGuestMode)
                          FilledButton(
                            onPressed: onStartPhoneLogin,
                            child: Text(l10n.tr('guestModeAction')),
                          )
                        else
                          FilledButton(
                            onPressed: onEditProfile,
                            child: Text(l10n.tr('editProfile')),
                          ),
                        FilledButton.tonal(
                          onPressed: onOpenAstralChart,
                          child: Text(l10n.tr('astralChart')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SpecialistModeCard(
              user: data.user,
              isGuestMode: isGuestMode,
              onStartPhoneLogin: onStartPhoneLogin,
              onEditProfile: onEditProfile,
              onEnterSpecialistMode: onEnterSpecialistMode,
              onExitSpecialistMode: onExitSpecialistMode,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('preferences'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...data.user.preferences.focusAreas
                            .map((item) => Chip(label: Text(item))),
                        ...data.user.preferences.preferredSessionModes
                            .map((item) => Chip(label: Text(item))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('subscription'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tr(
                        'status',
                        {'status': data.subscription.status},
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tr(
                        'billing',
                        {'provider': data.subscription.billingProvider},
                      ),
                    ),
                    if (data.subscription.renewsAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.tr(
                          'renewsOn',
                          {
                            'date': formatSchedule(data.subscription.renewsAt!),
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ...data.subscription.entitlements
                        .take(5)
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('• $item'),
                            )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('payments'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tr(
                        'consultations',
                        {'provider': data.payments.consultationProvider},
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tr(
                        'premium',
                        {'provider': data.payments.premiumProvider},
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...data.payments.notes.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $item'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.tr('language')),
                    subtitle: Text(
                      '${currentLanguage.nativeLabel} · ${l10n.tr('languageDescription')}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (sheetContext) {
                          final sheetL10n = sheetContext.l10n;
                          return SafeArea(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                ListTile(
                                  title: Text(sheetL10n.tr('chooseLanguage')),
                                  subtitle: Text(
                                    sheetL10n.tr('languageDescription'),
                                  ),
                                ),
                                ...supportedAppLanguages.map(
                                  (option) => ListTile(
                                    leading: Icon(
                                      option.locale.languageCode ==
                                              currentLocale.languageCode
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                    ),
                                    title: Text(option.nativeLabel),
                                    subtitle: Text(option.label),
                                    onTap: () async {
                                      Navigator.of(sheetContext).pop();
                                      await onChangeLocale(option.locale);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  if (canManageSubscription) ...[
                    ListTile(
                      leading: const Icon(Icons.workspace_premium_outlined),
                      title: Text(l10n.tr('manageSubscription')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                SubscriptionOverviewScreen(data: data),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  if (canOpenPrivacy) ...[
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(l10n.tr('privacyData')),
                      subtitle: Text(data.user.email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PrivacyDataScreen(
                              user: data.user,
                              onEditProfile: onEditProfile,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],
                  ListTile(
                    leading: const Icon(Icons.military_tech_outlined),
                    title: const Text('Insignias'),
                    subtitle: Text(
                      '${badgeCenter.currentRank.title} · ${badgeCenter.unlockedCount} activas',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProfileBadgesScreen(data: data),
                        ),
                      );
                    },
                  ),
                  if (canOpenSupport || !isGuestMode || canManageSubscription || canOpenPrivacy)
                    const Divider(height: 1),
                  if (canOpenSupport)
                    ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: Text(l10n.tr('support')),
                      subtitle: Text(
                        l10n.tr(
                          'activeUsers',
                          {'count': '${data.admin.activeUsers}'},
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SupportScreen(data: data),
                          ),
                        );
                      },
                    ),
                  if (!isGuestMode) ...[
                    if (canOpenSupport) const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      textColor: AppPalette.berry,
                      iconColor: AppPalette.berry,
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Cerrar sesión'),
                                  content: const Text(
                                    'Se cerrará tu sesión en este dispositivo.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(false);
                                      },
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(true);
                                      },
                                      child: const Text('Cerrar sesión'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (!confirmed) {
                          return;
                        }

                        await onLogout();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialistModeCard extends StatelessWidget {
  const _SpecialistModeCard({
    required this.user,
    required this.isGuestMode,
    required this.onStartPhoneLogin,
    required this.onEditProfile,
    required this.onEnterSpecialistMode,
    required this.onExitSpecialistMode,
  });

  final UserProfile user;
  final bool isGuestMode;
  final VoidCallback onStartPhoneLogin;
  final Future<void> Function() onEditProfile;
  final Future<String?> Function() onEnterSpecialistMode;
  final Future<String?> Function() onExitSpecialistMode;

  @override
  Widget build(BuildContext context) {
    final isSpecialist = user.accountType == 'specialist';
    final hasRequiredProfileData = _hasRequiredSpecialistProfileData(user);
    final buttonLabel = isSpecialist ? 'Usuario' : 'Especialista';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.midnight,
            AppPalette.indigo,
            AppPalette.orchid,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.indigo.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSpecialist
                          ? 'Vista especialista activa'
                          : 'Administrar como especialista',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSpecialist
                          ? 'Tu cuenta ya puede gestionar cursos, productos, citas, precios y comunidad desde el panel operativo.'
                          : 'Usa los mismos datos de tu perfil para habilitar gestión de cursos, productos, citas, precios y comunidad.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SpecialistModePill(label: 'Cursos/PDF'),
              _SpecialistModePill(label: 'Productos'),
              _SpecialistModePill(label: 'Citas'),
              _SpecialistModePill(label: 'Comunidad'),
            ],
          ),
          if (!hasRequiredProfileData && !isSpecialist) ...[
            const SizedBox(height: 12),
            Text(
              isGuestMode
                  ? 'Para administrar primero necesitas registrarte con teléfono y completar tu perfil.'
                  : 'Antes de administrar necesitamos nombre, nacimiento, ciudad, país, zona horaria y coordenadas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPalette.moonIvory,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSpecialist
                  ? () => _handleClientModeTap(context)
                  : () => _handleSpecialistModeTap(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppPalette.butterflyInk,
              ),
              icon: Icon(
                isSpecialist
                    ? Icons.person_outline_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSpecialistModeTap(BuildContext context) async {
    if (isGuestMode) {
      final shouldRegister = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Registro requerido'),
                content: const Text(
                  'Para administrar cursos, productos, citas y comunidad necesitas registrarte primero con tu teléfono.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Registrarme'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (shouldRegister && context.mounted) {
        onStartPhoneLogin();
      }
      return;
    }

    if (!_hasRequiredSpecialistProfileData(user)) {
      final shouldEdit = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Completa tus datos'),
                content: const Text(
                  'Antes de activar la vista especialista necesitamos tus datos base completos. Así podrás administrar cursos, productos, citas, precios y comunidad con una cuenta identificada.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Luego'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Completar perfil'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (shouldEdit && context.mounted) {
        await onEditProfile();
      }
      return;
    }

    if (user.accountType != 'specialist') {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Activar vista especialista'),
                content: const Text(
                  'Se usará este mismo perfil para habilitar el panel de administración de cursos, productos, citas, precios y comunidad.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Activar'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmed) {
        return;
      }
    }

    final error = await onEnterSpecialistMode();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Vista especialista lista para administrar tu operación.',
        ),
      ),
    );
  }

  Future<void> _handleClientModeTap(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Volver a vista usuario'),
              content: const Text(
                'Tu perfil y tus datos se mantienen. Solo se ocultará el panel especialista y volverás a la navegación normal de usuario.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Volver'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    final error = await onExitSpecialistMode();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? 'Vista usuario activada.',
        ),
      ),
    );
  }
}

class _SpecialistModePill extends StatelessWidget {
  const _SpecialistModePill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppPalette.moonIvory.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

bool _hasRequiredSpecialistProfileData(UserProfile user) {
  return user.id.trim().isNotEmpty &&
      user.firstName.trim().isNotEmpty &&
      user.lastName.trim().isNotEmpty &&
      user.natalChart.birthDate.trim().isNotEmpty &&
      user.natalChart.birthTime.trim().isNotEmpty &&
      user.natalChart.city.trim().isNotEmpty &&
      user.natalChart.country.trim().isNotEmpty &&
      user.natalChart.timeZoneId.trim().isNotEmpty &&
      user.natalChart.utcOffset.trim().isNotEmpty &&
      user.natalChart.latitude != null &&
      user.natalChart.longitude != null;
}
