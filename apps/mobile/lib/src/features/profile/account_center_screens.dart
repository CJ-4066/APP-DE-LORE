import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/app_i18n.dart';
import '../../core/utils/formatters.dart';
import '../../models/app_models.dart';
import 'profile_avatar.dart';

class SubscriptionOverviewScreen extends StatelessWidget {
  const SubscriptionOverviewScreen({
    super.key,
    required this.data,
  });

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentPlan = data.plans.firstWhere(
      (plan) => plan.id == data.subscription.planId,
      orElse: () => data.plans.first,
    );
    final premiumPlan = data.plans.firstWhere(
      (plan) => plan.id == 'premium',
      orElse: () => currentPlan,
    );
    final hasPremiumNow =
        currentPlan.id == 'premium' && data.subscription.status == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ts('Suscripción')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2D160F),
                  Color(0xFF7C4023),
                  Color(0xFFB96C3D),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPremiumNow
                      ? l10n.ts('Centro de suscripción')
                      : l10n.ts('Centro Premium'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasPremiumNow
                      ? l10n.ts(
                          'Tu plan está activo. Desde aquí puedes revisar beneficios, comparar planes y saltar a la gestión de tu plataforma.',
                        )
                      : l10n.ts(
                          'Aquí comparas planes, entiendes qué desbloquea Premium y saltas al centro de compra o gestión de tu plataforma.',
                        ),
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroTag(
                      label: l10n.ts(
                        'Plan {plan}',
                        {'plan': data.subscription.planName},
                      ),
                    ),
                    _HeroTag(
                      label: hasPremiumNow
                          ? l10n.ts('Premium activo')
                          : l10n.ts('Upgrade disponible'),
                    ),
                    _HeroTag(
                      label: premiumPlan.priceMonthly == 0
                          ? l10n.ts('Gratis')
                          : '${premiumPlan.currency} ${premiumPlan.priceMonthly.toStringAsFixed(2)}/mes',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _handlePlanAction(
                        context,
                        data.subscription,
                        premiumPlan,
                        isCurrent: hasPremiumNow,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7C4023),
                      ),
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: Text(
                        hasPremiumNow
                            ? l10n.ts('Gestionar en plataforma')
                            : l10n.ts('Ir a Premium'),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareText(
                        context,
                        _subscriptionShareText(data, currentPlan),
                        successMessage: l10n.ts(
                          'Resumen de planes listo para compartir.',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.ts('Compartir')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Estado actual'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.subscription.planName} · ${data.subscription.status}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ts(
                    'Plataforma: {platform}',
                    {'platform': data.subscription.platform},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Facturación: {provider}',
                    {'provider': data.subscription.billingProvider},
                  ),
                ),
                if (data.subscription.renewsAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.ts(
                      'Renueva: {date}',
                      {'date': formatSchedule(data.subscription.renewsAt!)},
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.subscription.entitlements
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _handlePlanAction(
                        context,
                        data.subscription,
                        premiumPlan,
                        isCurrent: hasPremiumNow,
                      ),
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: Text(
                        hasPremiumNow
                            ? l10n.ts('Gestionar renovación')
                            : l10n.ts('Ver upgrade'),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareText(
                        context,
                        _subscriptionShareText(data, currentPlan),
                        successMessage: l10n.ts(
                          'Resumen de planes listo para compartir.',
                        ),
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(l10n.ts('Compartir planes')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Planes disponibles'),
            child: Column(
              children: data.plans
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plan,
                        isCurrent: plan.id == currentPlan.id,
                        actionLabel: plan.id == currentPlan.id
                            ? l10n.ts('Gestionar')
                            : plan.id == 'premium'
                                ? l10n.ts('Elegir Premium')
                                : l10n.ts('Ver alternativa'),
                        onAction: () => _handlePlanAction(
                          context,
                          data.subscription,
                          plan,
                          isCurrent: plan.id == currentPlan.id,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Pagos y métodos'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts(
                    'Consultas: {provider}',
                    {'provider': data.payments.consultationProvider},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Premium: {provider}',
                    {'provider': data.payments.premiumProvider},
                  ),
                ),
                const SizedBox(height: 12),
                ...data.payments.supportedMethods.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $item'),
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
        ],
      ),
    );
  }
}

class PrivacyDataScreen extends StatelessWidget {
  const PrivacyDataScreen({
    super.key,
    required this.user,
    this.onEditProfile,
  });

  final UserProfile user;
  final Future<void> Function()? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final natal = user.natalChart;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ts('Privacidad y datos')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.ts('Editar perfil')),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareText(
                  context,
                  _privacyShareText(user),
                  successMessage: l10n.ts(
                    'Resumen de privacidad listo para compartir.',
                  ),
                ),
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(l10n.ts('Exportar resumen')),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyText(
                  context,
                  _privacyShareText(user),
                  successMessage: l10n.ts('Resumen copiado al portapapeles.'),
                ),
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.ts('Copiar')),
              ),
              OutlinedButton.icon(
                onPressed: () => _openPrivacyEmail(context, user),
                icon: const Icon(Icons.mail_outline),
                label: Text(l10n.ts('Solicitar revisión')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Datos visibles en tu cuenta'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts(
                    'Nombre: {name}',
                    {'name': displayUserName(user)},
                  ),
                ),
                if (user.nickname.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.ts(
                      'Apodo: @{nickname}',
                      {'nickname': user.nickname.trim()},
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Email: {email}',
                    {
                      'email': user.email.isEmpty
                          ? l10n.ts('No registrado')
                          : user.email,
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Ubicación: {location}',
                    {
                      'location': user.location.isEmpty
                          ? l10n.ts('No registrada')
                          : user.location,
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Zona horaria: {timezone}',
                    {'timezone': user.timezone},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Datos natales guardados'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ts('Fecha: {date}', {'date': natal.birthDate})),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Hora: {time}',
                    {
                      'time': natal.birthTimeUnknown
                          ? l10n.ts('Desconocida')
                          : natal.birthTime,
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Lugar: {place}',
                    {
                      'place':
                          '${natal.city}, ${natal.state}, ${natal.country}',
                    },
                  ),
                ),
                if (natal.timeZoneId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.ts(
                      'Zona IANA: {zone}',
                      {'zone': natal.timeZoneId},
                    ),
                  ),
                ],
                if (natal.utcOffset.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(l10n.ts('UTC: {offset}', {'offset': natal.utcOffset})),
                ],
                if (natal.latitude != null && natal.longitude != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.ts(
                      'Coordenadas: {lat}, {lng}',
                      {
                        'lat': '${natal.latitude}',
                        'lng': '${natal.longitude}',
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Preferencias guardadas'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts(
                    'Áreas de foco: {areas}',
                    {
                      'areas': user.preferences.focusAreas.isEmpty
                          ? l10n.ts('Ninguna')
                          : user.preferences.focusAreas.join(', '),
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Modos preferidos: {modes}',
                    {
                      'modes': user.preferences.preferredSessionModes.isEmpty
                          ? l10n.ts('Ninguno')
                          : user.preferences.preferredSessionModes.join(', '),
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Push activadas: {value}',
                    {
                      'value': user.preferences.receivesPush
                          ? l10n.ts('Sí')
                          : l10n.ts('No'),
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Estado actual'),
            child: Text(
              l10n.ts(
                'Desde aquí ya puedes revisar qué datos están visibles, copiar o exportar un resumen y enviar una solicitud de revisión si necesitas ajustar algo.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({
    super.key,
    required this.data,
  });

  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ts('Soporte')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _openSupportEmail(context, data),
                icon: const Icon(Icons.mail_outline),
                label: Text(l10n.ts('Escribir a soporte')),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareText(
                  context,
                  _supportShareText(data),
                  successMessage: l10n.ts('Diagnóstico listo para compartir.'),
                ),
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.ts('Compartir diagnóstico')),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyText(
                  context,
                  _supportShareText(data),
                  successMessage:
                      l10n.ts('Diagnóstico copiado al portapapeles.'),
                ),
                icon: const Icon(Icons.copy_outlined),
                label: Text(l10n.ts('Copiar')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Canales disponibles'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts('• Correo directo a soporte desde esta pantalla'),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ts(
                    '• Copia y comparte un diagnóstico resumido de tu cuenta',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ts(
                    '• Estado operativo: {count} incidencias abiertas en este momento',
                    {'count': '${data.admin.openIncidents}'},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Estado operativo'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts(
                    'Usuarios activos: {count}',
                    {'count': '${data.admin.activeUsers}'},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Suscriptores premium: {count}',
                    {'count': '${data.admin.premiumSubscribers}'},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Reservas del mes: {count}',
                    {'count': '${data.admin.monthlyBookings}'},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Especialistas activos: {count}',
                    {'count': '${data.admin.activeSpecialists}'},
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.ts(
                    'Incidencias abiertas: {count}',
                    {'count': '${data.admin.openIncidents}'},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: l10n.ts('Qué puedes gestionar desde aquí'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ts(
                    '• Reportar problemas de navegación, pagos o acceso',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ts(
                    '• Compartir contexto técnico mínimo para acelerar la respuesta',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.ts(
                    '• Escalar temas de privacidad, suscripción o reservas',
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.actionLabel,
    required this.onAction,
  });

  final Plan plan;
  final bool isCurrent;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF7EADB) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? const Color(0xFFB96C3D) : const Color(0xFFE7DDD0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB96C3D),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.ts('Actual'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.priceMonthly == 0
                ? l10n.ts('Gratis')
                : '${plan.currency} ${plan.priceMonthly.toStringAsFixed(2)} / mes',
          ),
          const SizedBox(height: 12),
          ...plan.features.take(5).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $item'),
                ),
              ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _handlePlanAction(
  BuildContext context,
  SubscriptionData subscription,
  Plan plan, {
  required bool isCurrent,
}) async {
  if (isCurrent || plan.id == 'premium') {
    await _openSubscriptionManagement(context, subscription);
    return;
  }

  _showSnackBar(
    context,
    context.l10n.ts(
      'Ese plan no requiere gestión extra desde la app en este momento.',
    ),
  );
}

Future<void> _openSubscriptionManagement(
  BuildContext context,
  SubscriptionData subscription,
) async {
  final uri = _subscriptionManagementUri(subscription);
  if (uri == null) {
    _showSnackBar(
      context,
      context.l10n.ts(
        'No encontramos un centro de gestión para esta plataforma.',
      ),
    );
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showSnackBar(
      context,
      context.l10n.ts('No se pudo abrir la gestión de suscripción.'),
    );
  }
}

Future<void> _openPrivacyEmail(BuildContext context, UserProfile user) async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'privacidad@lorenaciente.app',
    queryParameters: {
      'subject': 'Solicitud sobre privacidad y datos',
      'body': _privacyShareText(user),
    },
  );

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showSnackBar(
      context,
      context.l10n.ts('No se pudo abrir el correo de privacidad.'),
    );
  }
}

Future<void> _openSupportEmail(BuildContext context, AppBootstrap data) async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'soporte@lorenaciente.app',
    queryParameters: {
      'subject': 'Soporte Lo Renaciente',
      'body': _supportShareText(data),
    },
  );

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showSnackBar(
      context,
      context.l10n.ts('No se pudo abrir el correo de soporte.'),
    );
  }
}

Future<void> _shareText(
  BuildContext context,
  String text, {
  required String successMessage,
}) async {
  await SharePlus.instance.share(ShareParams(text: text));
  if (context.mounted) {
    _showSnackBar(context, successMessage);
  }
}

Future<void> _copyText(
  BuildContext context,
  String text, {
  required String successMessage,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    _showSnackBar(context, successMessage);
  }
}

Uri? _subscriptionManagementUri(SubscriptionData subscription) {
  switch (subscription.platform) {
    case 'ios':
      return Uri.parse('https://apps.apple.com/account/subscriptions');
    case 'android':
      return Uri.parse(
        'https://play.google.com/store/account/subscriptions',
      );
    case 'web':
      return Uri.parse('https://www.lorenaciente.app/suscripcion');
    default:
      return null;
  }
}

String _subscriptionShareText(AppBootstrap data, Plan currentPlan) {
  final plans = data.plans
      .map(
        (plan) => '${plan.name}: '
            '${plan.priceMonthly == 0 ? 'Gratis' : '${plan.currency} ${plan.priceMonthly.toStringAsFixed(2)}/mes'}'
            ' · ${plan.features.take(3).join(', ')}',
      )
      .join('\n');

  return 'Suscripción actual\n'
      '${data.subscription.planName} · ${data.subscription.status}\n'
      'Plataforma: ${data.subscription.platform}\n'
      'Facturación: ${data.subscription.billingProvider}\n'
      'Plan activo en la app: ${currentPlan.name}\n\n'
      'Comparativa rápida\n$plans';
}

String _privacyShareText(UserProfile user) {
  final natal = user.natalChart;
  return 'Privacidad y datos\n'
      'Nombre: ${displayUserName(user)}\n'
      'Email: ${user.email.isEmpty ? 'No registrado' : user.email}\n'
      'Ubicación: ${user.location.isEmpty ? 'No registrada' : user.location}\n'
      'Zona horaria: ${user.timezone}\n'
      'Nacimiento: ${natal.birthDate} ${natal.birthTimeUnknown ? '(hora desconocida)' : natal.birthTime}\n'
      'Lugar: ${natal.city}, ${natal.country}\n'
      'Focos: ${user.preferences.focusAreas.join(', ')}';
}

String _supportShareText(AppBootstrap data) {
  return 'Diagnóstico Lo Renaciente\n'
      'Usuarios activos: ${data.admin.activeUsers}\n'
      'Suscriptores premium: ${data.admin.premiumSubscribers}\n'
      'Reservas del mes: ${data.admin.monthlyBookings}\n'
      'Especialistas activos: ${data.admin.activeSpecialists}\n'
      'Incidencias abiertas: ${data.admin.openIncidents}\n'
      'Plan actual: ${data.subscription.planName} · ${data.subscription.status}';
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
