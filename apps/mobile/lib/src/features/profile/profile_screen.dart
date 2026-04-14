import 'package:flutter/material.dart';

import '../../core/i18n/app_i18n.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import 'account_center_screens.dart';
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
    required this.currentLocale,
    required this.onChangeLocale,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onEditProfile;
  final VoidCallback onStartPhoneLogin;
  final Future<void> Function() onLogout;
  final Future<void> Function() onOpenAstralChart;
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
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Cerrar sesión'),
                      textColor: const Color(0xFF8B3A18),
                      iconColor: const Color(0xFF8B3A18),
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
