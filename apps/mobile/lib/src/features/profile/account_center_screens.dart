import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Suscripción'),
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
                  hasPremiumNow ? 'Centro de suscripción' : 'Centro Premium',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  hasPremiumNow
                      ? 'Tu plan está activo. Desde aquí puedes revisar beneficios, comparar planes y saltar a la gestión de tu plataforma.'
                      : 'Aquí comparas planes, entiendes qué desbloquea Premium y saltas al centro de compra o gestión de tu plataforma.',
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
                    _HeroTag(label: 'Plan ${data.subscription.planName}'),
                    _HeroTag(
                      label: hasPremiumNow
                          ? 'Premium activo'
                          : 'Upgrade disponible',
                    ),
                    _HeroTag(
                      label: premiumPlan.priceMonthly == 0
                          ? 'Gratis'
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
                            ? 'Gestionar en plataforma'
                            : 'Ir a Premium',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareText(
                        context,
                        _subscriptionShareText(data, currentPlan),
                        successMessage:
                            'Resumen de planes listo para compartir.',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Estado actual',
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
                Text('Plataforma: ${data.subscription.platform}'),
                const SizedBox(height: 4),
                Text('Facturación: ${data.subscription.billingProvider}'),
                if (data.subscription.renewsAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      'Renueva: ${formatSchedule(data.subscription.renewsAt!)}'),
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
                        hasPremiumNow ? 'Gestionar renovación' : 'Ver upgrade',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _shareText(
                        context,
                        _subscriptionShareText(data, currentPlan),
                        successMessage:
                            'Resumen de planes listo para compartir.',
                      ),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir planes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Planes disponibles',
            child: Column(
              children: data.plans
                  .map(
                    (plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PlanCard(
                        plan: plan,
                        isCurrent: plan.id == currentPlan.id,
                        actionLabel: plan.id == currentPlan.id
                            ? 'Gestionar'
                            : plan.id == 'premium'
                                ? 'Elegir Premium'
                                : 'Ver alternativa',
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
            title: 'Pagos y métodos',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consultas: ${data.payments.consultationProvider}'),
                const SizedBox(height: 4),
                Text('Premium: ${data.payments.premiumProvider}'),
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
    final natal = user.natalChart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y datos'),
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
                label: const Text('Editar perfil'),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareText(
                  context,
                  _privacyShareText(user),
                  successMessage: 'Resumen de privacidad listo para compartir.',
                ),
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Exportar resumen'),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyText(
                  context,
                  _privacyShareText(user),
                  successMessage: 'Resumen copiado al portapapeles.',
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openPrivacyEmail(context, user),
                icon: const Icon(Icons.mail_outline),
                label: const Text('Solicitar revisión'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Datos visibles en tu cuenta',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${displayUserName(user)}'),
                if (user.nickname.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Apodo: @${user.nickname.trim()}'),
                ],
                const SizedBox(height: 4),
                Text(
                    'Email: ${user.email.isEmpty ? 'No registrado' : user.email}'),
                const SizedBox(height: 4),
                Text(
                    'Ubicación: ${user.location.isEmpty ? 'No registrada' : user.location}'),
                const SizedBox(height: 4),
                Text('Zona horaria: ${user.timezone}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Datos natales guardados',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${natal.birthDate}'),
                const SizedBox(height: 4),
                Text(
                  'Hora: ${natal.birthTimeUnknown ? 'Desconocida' : natal.birthTime}',
                ),
                const SizedBox(height: 4),
                Text('Lugar: ${natal.city}, ${natal.state}, ${natal.country}'),
                if (natal.timeZoneId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Zona IANA: ${natal.timeZoneId}'),
                ],
                if (natal.utcOffset.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('UTC: ${natal.utcOffset}'),
                ],
                if (natal.latitude != null && natal.longitude != null) ...[
                  const SizedBox(height: 4),
                  Text('Coordenadas: ${natal.latitude}, ${natal.longitude}'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Preferencias guardadas',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Áreas de foco: ${user.preferences.focusAreas.isEmpty ? 'Ninguna' : user.preferences.focusAreas.join(', ')}',
                ),
                const SizedBox(height: 4),
                Text(
                  'Modos preferidos: ${user.preferences.preferredSessionModes.isEmpty ? 'Ninguno' : user.preferences.preferredSessionModes.join(', ')}',
                ),
                const SizedBox(height: 4),
                Text(
                    'Push activadas: ${user.preferences.receivesPush ? 'Sí' : 'No'}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Estado actual',
            child: Text(
              'Desde aquí ya puedes revisar qué datos están visibles, copiar o exportar un resumen y enviar una solicitud de revisión si necesitas ajustar algo.',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte'),
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
                label: const Text('Escribir a soporte'),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareText(
                  context,
                  _supportShareText(data),
                  successMessage: 'Diagnóstico listo para compartir.',
                ),
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartir diagnóstico'),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyText(
                  context,
                  _supportShareText(data),
                  successMessage: 'Diagnóstico copiado al portapapeles.',
                ),
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Canales disponibles',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• Correo directo a soporte desde esta pantalla'),
                const SizedBox(height: 6),
                const Text(
                    '• Copia y comparte un diagnóstico resumido de tu cuenta'),
                const SizedBox(height: 6),
                Text(
                  '• Estado operativo: ${data.admin.openIncidents} incidencias abiertas en este momento',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: 'Estado operativo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuarios activos: ${data.admin.activeUsers}'),
                const SizedBox(height: 4),
                Text('Suscriptores premium: ${data.admin.premiumSubscribers}'),
                const SizedBox(height: 4),
                Text('Reservas del mes: ${data.admin.monthlyBookings}'),
                const SizedBox(height: 4),
                Text('Especialistas activos: ${data.admin.activeSpecialists}'),
                const SizedBox(height: 4),
                Text('Incidencias abiertas: ${data.admin.openIncidents}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _InfoSection(
            title: 'Qué puedes gestionar desde aquí',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Reportar problemas de navegación, pagos o acceso'),
                SizedBox(height: 6),
                Text(
                    '• Compartir contexto técnico mínimo para acelerar la respuesta'),
                SizedBox(height: 6),
                Text('• Escalar temas de privacidad, suscripción o reservas'),
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
                  child: const Text(
                    'Actual',
                    style: TextStyle(
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
                ? 'Gratis'
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
    'Ese plan no requiere gestión extra desde la app en este momento.',
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
      'No encontramos un centro de gestión para esta plataforma.',
    );
    return;
  }

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showSnackBar(context, 'No se pudo abrir la gestión de suscripción.');
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
    _showSnackBar(context, 'No se pudo abrir el correo de privacidad.');
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
    _showSnackBar(context, 'No se pudo abrir el correo de soporte.');
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
