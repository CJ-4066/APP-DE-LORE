import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/branding/renaciente_logo.dart';
import '../../core/i18n/app_i18n.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/mystic_ui.dart';
import '../../models/app_models.dart';
import '../../models/astro_models.dart';
import '../profile/account_center_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.data,
    required this.onRefresh,
    required this.onOpenAstralChart,
    required this.onOpenNumerology,
    required this.onLoadAstroOverview,
  });

  final AppBootstrap data;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onOpenAstralChart;
  final Future<void> Function() onOpenNumerology;
  final Future<AstroOverviewData> Function(AstroRequestInput input)
      onLoadAstroOverview;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AstroOverviewData? _astroOverview;
  String? _astroError;
  bool _isAstroLoading = false;
  String _loadedSignature = '';
  final PageController _discoverModulesController = PageController(
    viewportFraction: 0.84,
  );
  int _discoverModulesIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAstroOverview(force: true);
  }

  @override
  void dispose() {
    _discoverModulesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousSignature = _astroProfileSignature(oldWidget.data.user);
    final currentSignature = _astroProfileSignature(widget.data.user);
    if (previousSignature != currentSignature) {
      _loadAstroOverview(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final l10n = context.l10n;
    final hasSubscriptionCenter = _hasSubscriptionCenter(data);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppPalette.shellGradientTop,
            AppPalette.shellGradientMid,
            AppPalette.shellGradientBottom,
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _HomeAstroCard(
                user: data.user,
                overview: _astroOverview,
                isLoading: _isAstroLoading,
                errorMessage: _astroError,
                planLabel: hasSubscriptionCenter
                    ? l10n.tr(
                        'homePlanChip',
                        {'plan': data.subscription.planName},
                      )
                    : null,
                onPlanTap: hasSubscriptionCenter
                    ? () => _openSubscription(context)
                    : null,
                onOpenAstralChart: widget.onOpenAstralChart,
              ),
              const SizedBox(height: 24),
              _DiscoverDaySection(
                title: l10n.tr('homeDiscoverTitle'),
                subtitle: l10n.tr('homeDiscoverSubtitle'),
                controller: _discoverModulesController,
                currentIndex: _discoverModulesIndex,
                onPageChanged: (index) {
                  setState(() {
                    _discoverModulesIndex = index;
                  });
                },
                astralTitle: l10n.tr('astralChart'),
                astralCaption: l10n.tr('homeAstralPanelCaption'),
                numerologyTitle: l10n.tr('homeNumerologyTitle'),
                numerologyCaption: l10n.tr('homeNumerologyPanelCaption'),
                transitCaption: _buildTransitModuleCaption(
                  overview: _astroOverview,
                  isLoading: _isAstroLoading,
                  errorMessage: _astroError,
                ),
                onOpenAstralChart: widget.onOpenAstralChart,
                onOpenNumerology: widget.onOpenNumerology,
                onOpenTodayTransitHub: _openTodayTransitHub,
              ),
              if (hasSubscriptionCenter) ...[
                const SizedBox(height: 24),
                _PlanStrip(
                  planName: data.subscription.planName,
                  status: data.subscription.status,
                  renewsAt: data.subscription.renewsAt,
                  entitlements: data.subscription.entitlements,
                  onTap: () => _openSubscription(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSubscriptionCenter(AppBootstrap bootstrap) {
    return bootstrap.plans.isNotEmpty &&
        bootstrap.subscription.planName.trim().isNotEmpty &&
        bootstrap.subscription.platform.trim().isNotEmpty;
  }

  Future<void> _refreshHome() async {
    await widget.onRefresh();
    await _loadAstroOverview(force: true);
  }

  Future<void> _loadAstroOverview({bool force = false}) async {
    final user = widget.data.user;
    final signature = _astroProfileSignature(user);

    if (!_canLoadAstroOverview(user)) {
      if (!mounted) {
        return;
      }

      setState(() {
        _astroOverview = null;
        _astroError = null;
        _isAstroLoading = false;
        _loadedSignature = '';
      });
      return;
    }

    if (!force &&
        (_isAstroLoading ||
            (_loadedSignature == signature && _astroOverview != null))) {
      return;
    }

    setState(() {
      _isAstroLoading = true;
      _astroError = null;
    });

    try {
      final overview = await widget.onLoadAstroOverview(
        _buildAstroRequest(user),
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _astroOverview = overview;
        _astroError = null;
        _isAstroLoading = false;
        _loadedSignature = signature;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _astroOverview = null;
        _astroError = error.toString().replaceFirst('Exception: ', '');
        _isAstroLoading = false;
        _loadedSignature = '';
      });
    }
  }

  AstroRequestInput _buildAstroRequest(UserProfile user) {
    final natal = user.natalChart;
    return AstroRequestInput(
      subjectName: natal.subjectName.trim().isEmpty
          ? user.firstName.trim().isEmpty
              ? null
              : user.firstName.trim()
          : natal.subjectName.trim(),
      birthDate: natal.birthDate.trim(),
      birthTime: natal.birthTimeUnknown ? '' : natal.birthTime.trim(),
      birthTimeUnknown: natal.birthTimeUnknown,
      utcOffset: natal.utcOffset.trim(),
      timeZoneId: natal.timeZoneId.trim().isEmpty ? null : natal.timeZoneId,
      latitude: natal.latitude!,
      longitude: natal.longitude!,
      locationLabel: _buildLocationLabel(user),
      houseSystem: 'placidus',
    );
  }

  String _buildLocationLabel(UserProfile user) {
    final natal = user.natalChart;
    final label = [
      natal.city.trim(),
      natal.state.trim(),
      natal.country.trim(),
    ].where((item) => item.isNotEmpty).join(', ');

    if (label.isNotEmpty) {
      return label;
    }

    return user.location.trim();
  }

  Future<void> _openTodayTransitHub() async {
    final items = _buildTodayTransitItems(_astroOverview, context.l10n);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _TodayTransitOverviewScreen(
          overview: _astroOverview,
          isLoading: _isAstroLoading,
          errorMessage: _astroError,
          items: items,
          onOpenAstralChart: widget.onOpenAstralChart,
        ),
      ),
    );
  }

  Future<void> _openSubscription(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SubscriptionOverviewScreen(data: widget.data),
      ),
    );
  }
}

class _HomeAstroCard extends StatelessWidget {
  const _HomeAstroCard({
    required this.user,
    required this.overview,
    required this.isLoading,
    required this.errorMessage,
    required this.planLabel,
    required this.onPlanTap,
    required this.onOpenAstralChart,
  });

  final UserProfile user;
  final AstroOverviewData? overview;
  final bool isLoading;
  final String? errorMessage;
  final String? planLabel;
  final VoidCallback? onPlanTap;
  final Future<void> Function() onOpenAstralChart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final eclipse = overview == null
        ? null
        : _pickRelevantEclipse(overview!.events.eclipses);
    final canShowAstro = overview != null;

    return Container(
      padding: const EdgeInsets.all(18),
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
            color: AppPalette.indigo.withValues(alpha: 0.26),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -14,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('homeAstroRadarLabel'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          canShowAstro
                              ? l10n.tr('homeAstroReadyTitle')
                              : l10n.tr('homeAstroFallbackTitle'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          canShowAstro
                              ? _buildTriadSummary(overview!)
                              : l10n.tr('homeAstralOverviewFallback'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.34,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const RenacienteAnimatedLogoMark(
                    size: 76,
                    accentColor: AppPalette.butterflyInk,
                    wingInsetColor: AppPalette.orchid,
                    glowColor: AppPalette.roseQuartz,
                    surfaceColor: AppPalette.candleGlow,
                  ),
                ],
              ),
              if (planLabel != null) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: onPlanTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.moonIvory,
                      foregroundColor: AppPalette.butterflyInk,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(planLabel!),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppPalette.flameGold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.tr('homeAstralLoading'),
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (canShowAstro) ...[
                _AstroContextPanel(
                  transitMessage: _buildTransitSummary(overview!),
                  transitDetail: _buildTransitMeta(overview!),
                  eclipseMessage: eclipse?.label,
                  eclipseDetail:
                      eclipse == null ? null : _buildEclipseMeta(eclipse),
                  onOpenAstralChart: onOpenAstralChart,
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _buildAstroFallbackTitle(l10n, user, errorMessage),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _buildAstroFallbackBody(l10n, user, errorMessage),
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () => onOpenAstralChart(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.moonIvory,
                          foregroundColor: AppPalette.butterflyInk,
                        ),
                        child: Text(l10n.tr('completeAstralChart')),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AstroContextPanel extends StatelessWidget {
  const _AstroContextPanel({
    required this.transitMessage,
    required this.transitDetail,
    required this.eclipseMessage,
    required this.eclipseDetail,
    required this.onOpenAstralChart,
  });

  final String transitMessage;
  final String transitDetail;
  final String? eclipseMessage;
  final String? eclipseDetail;
  final Future<void> Function() onOpenAstralChart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AstroContextLine(
            label: l10n.tr('astroTransitActive'),
            message: transitMessage,
            detail: transitDetail,
          ),
          if (eclipseMessage != null && eclipseMessage!.trim().isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0x26FFFFFF),
              ),
            ),
            _AstroContextLine(
              label: l10n.tr('astroUpcomingEclipse'),
              message: eclipseMessage!,
              detail: eclipseDetail ?? '',
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onOpenAstralChart(),
              style: TextButton.styleFrom(
                foregroundColor: AppPalette.moonIvory,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.tr('openAstralChart')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AstroContextLine extends StatelessWidget {
  const _AstroContextLine({
    required this.label,
    required this.message,
    required this.detail,
  });

  final String label;
  final String message;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
        ),
        if (detail.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}

class _TodayTransitPanel extends StatelessWidget {
  const _TodayTransitPanel({
    required this.overview,
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onItemTap,
    required this.onOpenAstralChart,
  });

  final AstroOverviewData? overview;
  final bool isLoading;
  final String? errorMessage;
  final List<_HomeTransitItem> items;
  final ValueChanged<_HomeTransitItem> onItemTap;
  final Future<void> Function() onOpenAstralChart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isLoading) {
      return _TransitStateCard(
        title: l10n.ts('Leyendo el cielo de hoy'),
        subtitle: l10n.ts(
          'Estoy calculando los tránsitos y la ventana activa del día.',
        ),
      );
    }

    if (overview == null) {
      return _TransitStateCard(
        title: l10n.ts('Faltan datos para mostrar tránsitos'),
        subtitle: errorMessage?.trim().isNotEmpty == true
            ? errorMessage!
            : l10n.ts(
                'Completa tu carta astral para que Inicio muestre el movimiento real del día.',
              ),
        actionLabel: l10n.ts('Abrir carta astral'),
        onAction: onOpenAstralChart,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7DDD0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF184A56).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF4F7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.ts('Actualizado con tu carta y el cielo del momento'),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF184A56),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TransitListTile(
                item: item,
                onTap: () => onItemTap(item),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onOpenAstralChart(),
              icon: const Icon(Icons.auto_awesome_outlined),
              label: Text(l10n.ts('Ver detalle astral')),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitStateCard extends StatelessWidget {
  const _TransitStateCard({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7DDD0)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E676E),
                  height: 1.4,
                ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => onAction?.call(),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransitListTile extends StatelessWidget {
  const _TransitListTile({
    required this.item,
    required this.onTap,
  });

  final _HomeTransitItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF4),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0E3D4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2328),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF5E676E),
                            height: 1.4,
                          ),
                    ),
                    if (item.detail.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.detail,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFF7C675B),
                                ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Toca para profundizar',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: item.accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: item.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTransitItem {
  const _HomeTransitItem({
    required this.title,
    required this.message,
    required this.detail,
    required this.summary,
    required this.highlights,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String message;
  final String detail;
  final String summary;
  final List<String> highlights;
  final IconData icon;
  final Color accent;
}

Future<void> _showTransitDetailSheet({
  required BuildContext context,
  required _HomeTransitItem item,
  required Future<void> Function() onOpenAstralChart,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFFFFCF8),
    builder: (sheetContext) {
      return _TransitDetailSheet(
        item: item,
        onOpenAstralChart: () async {
          Navigator.of(sheetContext).pop();
          await onOpenAstralChart();
        },
      );
    },
  );
}

class _TransitDetailSheet extends StatelessWidget {
  const _TransitDetailSheet({
    required this.item,
    required this.onOpenAstralChart,
  });

  final _HomeTransitItem item;
  final Future<void> Function() onOpenAstralChart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1B2328),
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF4E5A61),
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.detail.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoChip(label: item.detail),
          ],
          const SizedBox(height: 18),
          Text(
            'Resumen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            item.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E676E),
                  height: 1.45,
                ),
          ),
          if (item.highlights.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Claves rápidas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            ...item.highlights.map(
              (highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: item.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        highlight,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF4E5A61),
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onOpenAstralChart,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: Text(context.l10n.ts('Ver carta astral completa')),
          ),
        ],
      ),
    );
  }
}

class _TodayTransitOverviewScreen extends StatelessWidget {
  const _TodayTransitOverviewScreen({
    required this.overview,
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onOpenAstralChart,
  });

  final AstroOverviewData? overview;
  final bool isLoading;
  final String? errorMessage;
  final List<_HomeTransitItem> items;
  final Future<void> Function() onOpenAstralChart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: Text(l10n.ts('Tránsitos de hoy')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            l10n.ts(
              'Aquí vive la lectura completa del movimiento activo del día sobre tu carta natal y tu cielo actual.',
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5E676E),
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 16),
          _TodayTransitPanel(
            overview: overview,
            isLoading: isLoading,
            errorMessage: errorMessage,
            items: items,
            onItemTap: (item) => _showTransitDetailSheet(
              context: context,
              item: item,
              onOpenAstralChart: onOpenAstralChart,
            ),
            onOpenAstralChart: onOpenAstralChart,
          ),
        ],
      ),
    );
  }
}

bool _canLoadAstroOverview(UserProfile user) {
  final natal = user.natalChart;
  final hasBirthDate = natal.birthDate.trim().isNotEmpty;
  final hasBirthTime =
      natal.birthTimeUnknown || natal.birthTime.trim().isNotEmpty;
  final hasOffset = natal.utcOffset.trim().isNotEmpty;
  final hasCoordinates = natal.latitude != null && natal.longitude != null;
  final hasLocation = [
    natal.city.trim(),
    natal.state.trim(),
    natal.country.trim(),
    user.location.trim(),
  ].any((item) => item.isNotEmpty);

  return hasBirthDate &&
      hasBirthTime &&
      hasOffset &&
      hasCoordinates &&
      hasLocation;
}

String _astroProfileSignature(UserProfile user) {
  final natal = user.natalChart;
  return [
    user.id,
    natal.subjectName,
    natal.birthDate,
    natal.birthTime,
    natal.birthTimeUnknown.toString(),
    natal.city,
    natal.state,
    natal.country,
    natal.timeZoneId,
    natal.utcOffset,
    natal.latitude?.toString() ?? '',
    natal.longitude?.toString() ?? '',
  ].join('|');
}

String _buildTriadSummary(AstroOverviewData overview) {
  final bigThree = overview.natalChart.bigThree;
  return 'Sol en ${bigThree.sun.sign} · Luna en ${bigThree.moon.sign} · Ascendente en ${bigThree.ascendant.sign}.';
}

List<_HomeTransitItem> _buildTodayTransitItems(
  AstroOverviewData? overview,
  AppLocalizations l10n,
) {
  if (overview == null) {
    return const <_HomeTransitItem>[];
  }

  final items = <_HomeTransitItem>[
    _HomeTransitItem(
      title: l10n.ts('Pulso principal'),
      message: _buildTransitSummary(overview),
      detail: _buildTransitMeta(overview),
      summary: _buildTransitPulseSummary(overview),
      highlights: _buildTransitPulseHighlights(overview),
      icon: Icons.auto_awesome_rounded,
      accent: const Color(0xFF184A56),
    ),
  ];

  final aspects = overview.transits.aspectsToNatal.take(3).toList();
  for (var index = 0; index < aspects.length; index++) {
    final aspect = aspects[index];
    items.add(
      _HomeTransitItem(
        title: _buildAspectTitle(aspect, index),
        message:
            '${_translateAstroLabel(aspect.left)} en ${_translateAspectType(aspect.type)} con ${_translateAstroLabel(aspect.right)}',
        detail:
            'Orb ${aspect.orb.toStringAsFixed(1)}° · precisión ${aspect.precision}',
        summary: _buildAspectSummary(
          aspect,
          activeWindow: overview.transits.activeWindow,
        ),
        highlights: _buildAspectHighlights(
          aspect,
          activeWindow: overview.transits.activeWindow,
        ),
        icon: Icons.track_changes_rounded,
        accent: const Color(0xFF6B4C3A),
      ),
    );
  }

  final phase = _pickRelevantMoonPhase(overview.events.moonPhases);
  if (phase != null) {
    items.add(
      _HomeTransitItem(
        title: l10n.ts('Fase lunar cercana'),
        message: phase.label,
        detail: formatSchedule(phase.startsAt),
        summary: _buildMoonPhaseSummary(phase),
        highlights: _buildMoonPhaseHighlights(phase),
        icon: Icons.dark_mode_outlined,
        accent: const Color(0xFF5C7A72),
      ),
    );
  }

  return items;
}

String _buildTransitSummary(AstroOverviewData overview) {
  final highlights = overview.transits.highlights;
  if (highlights.isNotEmpty) {
    return highlights.first;
  }

  final aspects = overview.transits.aspectsToNatal;
  if (aspects.isNotEmpty) {
    final aspect = aspects.first;
    return '${_translateAstroLabel(aspect.left)} en ${_translateAspectType(aspect.type)} con ${_translateAstroLabel(aspect.right)}';
  }

  return 'Tu cielo está estable; hoy conviene mirar matices más que urgencias.';
}

String _buildTransitMeta(AstroOverviewData overview) {
  final activeWindow = overview.transits.activeWindow;
  if (activeWindow != null &&
      activeWindow.startsAt.trim().isNotEmpty &&
      activeWindow.endsAt.trim().isNotEmpty) {
    return formatTransitWindow(
      activeWindow.startsAt,
      activeWindow.endsAt,
    );
  }

  final aspects = overview.transits.aspectsToNatal;
  if (aspects.isEmpty) {
    return 'Se calcula con tus datos natales y el cielo actual.';
  }

  final aspect = aspects.first;
  final orb = aspect.orb.toStringAsFixed(1);
  return 'Aspecto natal: ${_translateAstroLabel(aspect.left)} y ${_translateAstroLabel(aspect.right)} · orb $orb°';
}

String _buildTransitModuleCaption({
  required AstroOverviewData? overview,
  required bool isLoading,
  required String? errorMessage,
}) {
  if (isLoading) {
    return 'Cargando el pulso principal, los aspectos activos y la fase lunar del día.';
  }
  if (overview != null) {
    return _buildTransitSummary(overview);
  }
  if (errorMessage != null && errorMessage.trim().isNotEmpty) {
    return errorMessage;
  }

  return 'Abre esta vista para ver pulso principal, tránsitos activos, fase lunar y resúmenes rápidos.';
}

String _buildTransitPulseSummary(AstroOverviewData overview) {
  final parts = <String>[];
  final highlights = overview.transits.highlights;
  if (highlights.isNotEmpty) {
    parts.add(highlights.first);
  }

  final activeWindow = overview.transits.activeWindow;
  if (activeWindow != null) {
    parts.add(
      '${_translateAstroLabel(activeWindow.transitLabel)} está marcando tu ${_translateAstroLabel(activeWindow.natalLabel)} natal en ${_translateAspectType(activeWindow.type)}.',
    );
  }

  if (parts.isEmpty) {
    parts.add(
      'Hoy la lectura cruza tu carta natal con el cielo actual para mostrar qué energía tiene más peso en tu día.',
    );
  }

  return parts.join(' ');
}

List<String> _buildTransitPulseHighlights(AstroOverviewData overview) {
  final entries = <String>[];
  final activeWindow = overview.transits.activeWindow;
  if (activeWindow != null) {
    entries.add(
      'Ventana activa: ${formatTransitWindow(activeWindow.startsAt, activeWindow.endsAt)}.',
    );
  }

  final firstAspect = overview.transits.aspectsToNatal.firstOrNull;
  if (firstAspect != null) {
    entries.add(
      'Aspecto dominante: ${_translateAstroLabel(firstAspect.left)} en ${_translateAspectType(firstAspect.type)} con ${_translateAstroLabel(firstAspect.right)}.',
    );
  }

  entries.add('Base natal: ${_buildTriadSummary(overview)}');
  entries.add(
    'Cálculo hecho para ${formatSchedule(overview.transits.targetDateUtc)}.',
  );
  return entries;
}

String _buildAspectTitle(AstroAspect aspect, int index) {
  final left = _translateAstroLabel(aspect.left);
  final right = _translateAstroLabel(aspect.right);
  if (left.trim().isEmpty || right.trim().isEmpty) {
    return 'Tránsito ${index + 1}';
  }

  return '$left sobre $right';
}

String _buildAspectSummary(
  AstroAspect aspect, {
  AstroTransitWindow? activeWindow,
}) {
  final left = _translateAstroLabel(aspect.left);
  final right = _translateAstroLabel(aspect.right);
  final emphasis = switch (aspect.type.trim().toLowerCase()) {
    'conjunction' =>
      '$left activa de forma directa tu $right natal. Este tipo de tránsito se nota más claro y pide usar esa energía con intención.',
    'opposition' =>
      '$left te muestra tu $right natal como espejo. Puede sentirse como contraste o tensión entre dos polos que hoy conviene balancear.',
    'square' =>
      '$left presiona tu $right natal y pide ajuste. Si aparece fricción, úsala para corregir hábitos, ritmo o límites.',
    'trine' =>
      '$left armoniza con tu $right natal. Hay más fluidez para avanzar, sostener conversaciones o tomar decisiones sin forzar.',
    'sextile' =>
      '$left abre una oportunidad con tu $right natal. La energía ayuda, pero responde mejor si tomas una acción concreta.',
    'quincunx' =>
      '$left desacomoda tu $right natal de forma sutil. Suele pedir recalibrar expectativas, horarios o pequeños hábitos.',
    _ =>
      '$left está activando tu $right natal y vale la pena observar cómo cambia tu manera de sentir, pensar o responder hoy.',
  };
  final intensity = switch (aspect.precision.trim().toLowerCase()) {
    'cerrado' =>
      ' Está bastante cerca de su punto fuerte, así que probablemente lo notes con claridad.',
    'moderado' =>
      ' Se siente activo, aunque todavía deja espacio para observar antes de reaccionar.',
    'amplio' =>
      ' Funciona más como clima de fondo que como detonante inmediato.',
    _ => '',
  };
  final activeNote = _matchesActiveWindow(activeWindow, aspect)
      ? ' Además, este parece ser el tránsito más activo de este momento.'
      : '';

  return '$emphasis$intensity$activeNote';
}

List<String> _buildAspectHighlights(
  AstroAspect aspect, {
  AstroTransitWindow? activeWindow,
}) {
  final entries = <String>[
    'Aspecto: ${_translateAspectType(aspect.type)}.',
    'Precisión ${aspect.precision} con orb de ${aspect.orb.toStringAsFixed(1)}° sobre un máximo de ${aspect.maxOrb.toStringAsFixed(1)}°.',
  ];
  if (_matchesActiveWindow(activeWindow, aspect)) {
    entries.add(
      'Ventana estimada: ${formatTransitWindow(activeWindow!.startsAt, activeWindow.endsAt)}.',
    );
  }
  entries.add(
    '${_translateAstroLabel(aspect.left)} toca el punto natal ${_translateAstroLabel(aspect.right)}.',
  );
  return entries;
}

bool _matchesActiveWindow(AstroTransitWindow? window, AstroAspect aspect) {
  if (window == null) {
    return false;
  }

  return window.type.trim().toLowerCase() == aspect.type.trim().toLowerCase() &&
      window.transitLabel.trim().toLowerCase() ==
          aspect.left.trim().toLowerCase() &&
      window.natalLabel.trim().toLowerCase() ==
          aspect.right.trim().toLowerCase();
}

String _buildMoonPhaseSummary(AstroEventItem phase) {
  final label = phase.label.trim().toLowerCase();
  if (label.contains('nueva')) {
    return 'La luna nueva abre un ciclo y favorece sembrar intención, ordenar prioridades y empezar con menos ruido.';
  }
  if (label.contains('llena')) {
    return 'La luna llena ilumina resultados y emociones. Suele mostrar con claridad qué ya maduró y qué pide cierre o exposición.';
  }
  if (label.contains('creciente')) {
    return 'El cuarto creciente empuja avance y decisión. Es una fase buena para sostener lo que ya empezó y mover lo pendiente.';
  }
  if (label.contains('menguante')) {
    return 'El cuarto menguante favorece limpiar, ajustar y soltar lo que ya no tiene fuerza real en tu proceso.';
  }

  return 'La fase lunar cercana funciona como telón de fondo del día y te da una pista del tono emocional y del ritmo disponible.';
}

List<String> _buildMoonPhaseHighlights(AstroEventItem phase) {
  final entries = <String>[
    'Momento exacto: ${formatSchedule(phase.startsAt)}.',
  ];
  if (phase.visibility.trim().isNotEmpty) {
    entries.add('Visibilidad: ${phase.visibility.trim()}.');
  }
  if (phase.sourceLabel.trim().isNotEmpty) {
    entries.add('Referencia astronómica: ${phase.sourceLabel.trim()}.');
  }
  return entries;
}

AstroEventItem? _pickRelevantEclipse(List<AstroEventItem> eclipses) {
  if (eclipses.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  final datedEvents = eclipses
      .map((item) {
        try {
          return MapEntry(item, DateTime.parse(item.startsAt).toLocal());
        } catch (_) {
          return null;
        }
      })
      .whereType<MapEntry<AstroEventItem, DateTime>>()
      .toList()
    ..sort((left, right) => left.value.compareTo(right.value));

  for (final event in datedEvents) {
    if (!event.value.isBefore(now)) {
      return event.key;
    }
  }

  return datedEvents.isNotEmpty ? datedEvents.last.key : eclipses.first;
}

AstroEventItem? _pickRelevantMoonPhase(List<AstroEventItem> phases) {
  if (phases.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  final datedEvents = phases
      .map((item) {
        try {
          return MapEntry(item, DateTime.parse(item.startsAt).toLocal());
        } catch (_) {
          return null;
        }
      })
      .whereType<MapEntry<AstroEventItem, DateTime>>()
      .toList()
    ..sort((left, right) => left.value.compareTo(right.value));

  for (final event in datedEvents) {
    if (!event.value.isBefore(now)) {
      return event.key;
    }
  }

  return datedEvents.isNotEmpty ? datedEvents.last.key : phases.first;
}

String _buildEclipseMeta(AstroEventItem event) {
  final visibility = event.visibility.trim();
  if (visibility.isEmpty) {
    return formatSchedule(event.startsAt);
  }

  return '${formatSchedule(event.startsAt)} · $visibility';
}

String _buildAstroFallbackTitle(
  AppLocalizations l10n,
  UserProfile user,
  String? errorMessage,
) {
  if (errorMessage != null && errorMessage.trim().isNotEmpty) {
    return l10n.tr('astroFallbackErrorTitle');
  }

  if (_canLoadAstroOverview(user)) {
    return l10n.tr('astroFallbackReadyTitle');
  }

  return l10n.tr('astroFallbackCompleteTitle');
}

String _buildAstroFallbackBody(
  AppLocalizations l10n,
  UserProfile user,
  String? errorMessage,
) {
  if (errorMessage != null && errorMessage.trim().isNotEmpty) {
    return l10n.tr('astroFallbackErrorBody');
  }

  final natal = user.natalChart;
  if (natal.birthTimeUnknown) {
    return l10n.tr('astroFallbackPartialBody');
  }

  return l10n.tr('astroFallbackCompleteBody');
}

String _translateAspectType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'conjunction':
      return 'conjunción';
    case 'opposition':
      return 'oposición';
    case 'trine':
      return 'trígono';
    case 'square':
      return 'cuadratura';
    case 'sextile':
      return 'sextil';
    case 'quincunx':
      return 'quincuncio';
    default:
      return value.toLowerCase();
  }
}

String _translateAstroLabel(String value) {
  switch (value.trim().toLowerCase()) {
    case 'sun':
      return 'Sol';
    case 'moon':
      return 'Luna';
    case 'mercury':
      return 'Mercurio';
    case 'venus':
      return 'Venus';
    case 'mars':
      return 'Marte';
    case 'jupiter':
      return 'Júpiter';
    case 'saturn':
      return 'Saturno';
    case 'uranus':
      return 'Urano';
    case 'neptune':
      return 'Neptuno';
    case 'pluto':
      return 'Plutón';
    case 'ascendant':
      return 'Ascendente';
    case 'midheaven':
      return 'Medio Cielo';
    case 'north node':
      return 'Nodo norte';
    case 'south node':
      return 'Nodo sur';
    default:
      return value;
  }
}

class _DiscoverDaySection extends StatelessWidget {
  const _DiscoverDaySection({
    required this.title,
    required this.subtitle,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    required this.astralTitle,
    required this.astralCaption,
    required this.numerologyTitle,
    required this.numerologyCaption,
    required this.transitCaption,
    required this.onOpenAstralChart,
    required this.onOpenNumerology,
    required this.onOpenTodayTransitHub,
  });

  final String title;
  final String subtitle;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final String astralTitle;
  final String astralCaption;
  final String numerologyTitle;
  final String numerologyCaption;
  final String transitCaption;
  final Future<void> Function() onOpenAstralChart;
  final Future<void> Function() onOpenNumerology;
  final Future<void> Function() onOpenTodayTransitHub;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPalette.mistLilac,
            AppPalette.moonIvory,
            AppPalette.softLilac,
          ],
        ),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.royalViolet.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -8,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.flameGold.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            bottom: 42,
            left: -18,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.royalViolet.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withValues(
                              alpha: 0.72,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppPalette.borderSoft,
                            ),
                          ),
                          child: Text(
                            l10n.ts('Desliza entre tus accesos clave'),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppPalette.royalViolet,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppPalette.midnight,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppPalette.mutedLavender,
                                    height: 1.35,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 222,
                child: PageView(
                  controller: controller,
                  padEnds: false,
                  clipBehavior: Clip.none,
                  onPageChanged: onPageChanged,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: _ModulePanel(
                        eyebrow: l10n.ts('Mapa natal'),
                        title: astralTitle,
                        caption: astralCaption,
                        glyphKind: MysticGlyphKind.astral,
                        motionVariant: _ModuleGlyphMotionVariant.astral,
                        accent: AppPalette.flameGold,
                        gradient: const [
                          AppPalette.midnight,
                          AppPalette.indigo,
                          AppPalette.royalViolet,
                        ],
                        onTap: onOpenAstralChart,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: _ModulePanel(
                        eyebrow: l10n.ts('Código personal'),
                        title: numerologyTitle,
                        caption: numerologyCaption,
                        glyphKind: MysticGlyphKind.numerology,
                        motionVariant: _ModuleGlyphMotionVariant.numerology,
                        accent: AppPalette.moonIvory,
                        gradient: const [
                          AppPalette.butterflyInk,
                          AppPalette.royalViolet,
                          AppPalette.orchid,
                        ],
                        onTap: onOpenNumerology,
                      ),
                    ),
                    _ModulePanel(
                      eyebrow: l10n.ts('Cielo activo'),
                      title: l10n.ts('Tránsitos de hoy'),
                      caption: transitCaption,
                      glyphKind: MysticGlyphKind.astral,
                      motionVariant: _ModuleGlyphMotionVariant.transit,
                      accent: AppPalette.moonIvory,
                      gradient: const [
                        AppPalette.midnight,
                        AppPalette.royalViolet,
                        AppPalette.berry,
                      ],
                      onTap: onOpenTodayTransitHub,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ts(
                        'Muévete de un lado a otro para cambiar de módulo.',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppPalette.mutedLavender,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _DiscoverModulesIndicator(
                    currentIndex: currentIndex,
                    total: 3,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModulePanel extends StatelessWidget {
  const _ModulePanel({
    required this.eyebrow,
    required this.title,
    required this.caption,
    required this.glyphKind,
    required this.motionVariant,
    required this.accent,
    required this.gradient,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String caption;
  final MysticGlyphKind glyphKind;
  final _ModuleGlyphMotionVariant motionVariant;
  final Color accent;
  final List<Color> gradient;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => onTap(),
        child: Container(
          constraints: const BoxConstraints(minHeight: 210),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -26,
                right: -18,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: -34,
                left: -12,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Text(
                            eyebrow,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _AnimatedModuleGlyph(
                        kind: glyphKind,
                        variant: motionVariant,
                        accent: accent,
                        foreground: AppPalette.moonIvory,
                        background: Colors.white.withValues(alpha: 0.14),
                        size: 54,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                          height: 1.38,
                        ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.ts('Toca para abrir'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ModuleGlyphMotionVariant {
  astral,
  numerology,
  transit,
}

class _AnimatedModuleGlyph extends StatefulWidget {
  const _AnimatedModuleGlyph({
    required this.kind,
    required this.variant,
    required this.accent,
    required this.foreground,
    required this.background,
    required this.size,
  });

  final MysticGlyphKind kind;
  final _ModuleGlyphMotionVariant variant;
  final Color accent;
  final Color foreground;
  final Color background;
  final double size;

  @override
  State<_AnimatedModuleGlyph> createState() => _AnimatedModuleGlyphState();
}

class _AnimatedModuleGlyphState extends State<_AnimatedModuleGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.size * 1.34;

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final phase = _controller.value * math.pi * 2;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ...switch (widget.variant) {
                _ModuleGlyphMotionVariant.astral => _buildAstralDecor(phase),
                _ModuleGlyphMotionVariant.numerology =>
                  _buildNumerologyDecor(phase),
                _ModuleGlyphMotionVariant.transit => _buildTransitDecor(phase),
              },
              _buildBadge(phase),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(double phase) {
    final floatY = switch (widget.variant) {
      _ModuleGlyphMotionVariant.astral => math.sin(phase * 1.1) * 2.4,
      _ModuleGlyphMotionVariant.numerology => math.sin(phase * 1.6) * 1.3,
      _ModuleGlyphMotionVariant.transit => math.sin(phase * 1.8) * 1.8,
    };

    final scale = switch (widget.variant) {
      _ModuleGlyphMotionVariant.astral => 1 + math.sin(phase * 1.2) * 0.02,
      _ModuleGlyphMotionVariant.numerology =>
        1 + (math.sin(phase * 2.0) + 1) * 0.028,
      _ModuleGlyphMotionVariant.transit => 1 + math.sin(phase * 1.4) * 0.018,
    };

    final rotation = switch (widget.variant) {
      _ModuleGlyphMotionVariant.astral => math.sin(phase * 0.7) * 0.06,
      _ModuleGlyphMotionVariant.numerology => math.sin(phase * 0.9) * 0.03,
      _ModuleGlyphMotionVariant.transit => math.sin(phase * 1.1) * 0.045,
    };

    return Transform.translate(
      offset: Offset(0, floatY),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: MysticGlyphBadge(
            kind: widget.kind,
            accent: widget.foreground,
            background: widget.background,
            size: widget.size,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAstralDecor(double phase) {
    final orbitA = phase;
    final orbitB = phase * 0.78 + math.pi * 0.2;
    final orbitC = -phase * 0.62 + math.pi * 0.95;
    final orbitD = phase * 1.18 + math.pi * 1.35;
    final orbitE = -phase * 0.92 + math.pi * 0.48;
    final outerRadius = widget.size * 0.45;
    final midRadius = widget.size * 0.36;
    final innerRadius = widget.size * 0.28;

    return [
      Container(
        width: widget.size * 1.18,
        height: widget.size * 1.18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.accent.withValues(alpha: 0.20),
            width: 1.2,
          ),
        ),
      ),
      Container(
        width: widget.size * 0.92,
        height: widget.size * 0.92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.accent.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
      ),
      _orbitDot(
        angle: orbitA,
        radius: outerRadius,
        size: widget.size * 0.12,
        color: widget.accent.withValues(alpha: 0.92),
      ),
      _orbitDot(
        angle: orbitB,
        radius: outerRadius,
        size: widget.size * 0.07,
        color: Colors.white.withValues(alpha: 0.64),
      ),
      _orbitDot(
        angle: orbitC,
        radius: midRadius,
        size: widget.size * 0.08,
        color: Colors.white.withValues(alpha: 0.78),
      ),
      _orbitDot(
        angle: orbitD,
        radius: midRadius,
        size: widget.size * 0.06,
        color: widget.accent.withValues(alpha: 0.58),
      ),
      _orbitDot(
        angle: orbitE,
        radius: innerRadius,
        size: widget.size * 0.045,
        color: Colors.white.withValues(alpha: 0.82),
      ),
    ];
  }

  List<Widget> _buildNumerologyDecor(double phase) {
    final ringOne = 0.92 + (math.sin(phase * 1.8) + 1) * 0.05;
    final ringTwo = 0.84 + (math.sin(phase * 1.8 + 0.7) + 1) * 0.045;

    return [
      Transform.scale(
        scale: ringOne,
        child: Container(
          width: widget.size * 1.18,
          height: widget.size * 1.18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.accent.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
        ),
      ),
      Transform.scale(
        scale: ringTwo,
        child: Container(
          width: widget.size * 0.94,
          height: widget.size * 0.94,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.accent.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
        ),
      ),
      _numberChip(
        label: '3',
        alignment: Alignment.topCenter,
        dx: math.sin(phase * 1.4) * 4,
        dy: math.cos(phase * 1.4) * 2,
      ),
      _numberChip(
        label: '6',
        alignment: Alignment.centerLeft,
        dx: math.cos(phase * 1.1) * 3,
        dy: math.sin(phase * 1.1) * 4,
      ),
      _numberChip(
        label: '9',
        alignment: Alignment.centerRight,
        dx: math.sin(phase * 1.25) * -3,
        dy: math.cos(phase * 1.25) * 4,
      ),
    ];
  }

  List<Widget> _buildTransitDecor(double phase) {
    return [
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.size),
          child: Stack(
            children: List.generate(3, (index) {
              final progress = (_controller.value + index * 0.24) % 1.0;
              final width = widget.size * (0.22 + index * 0.03);
              final left = -width + progress * widget.size * 1.5;
              final top = widget.size * (0.22 + index * 0.14) +
                  math.sin(progress * math.pi * 2 + index) * widget.size * 0.08;
              final opacity = 0.06 +
                  (1 - ((progress - 0.5).abs() * 2).clamp(0.0, 1.0)) * 0.22;

              return Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: -0.42,
                  child: Container(
                    width: width,
                    height: widget.size * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          widget.accent.withValues(alpha: 0),
                          widget.accent.withValues(alpha: opacity),
                          Colors.white.withValues(alpha: opacity * 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
      Container(
        width: widget.size * 1.08,
        height: widget.size * 1.08,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.accent.withValues(alpha: 0.10),
          ),
        ),
      ),
    ];
  }

  Widget _orbitDot({
    required double angle,
    required double radius,
    required double size,
    required Color color,
  }) {
    return Transform.translate(
      offset: Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.24),
              blurRadius: 8,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberChip({
    required String label,
    required Alignment alignment,
    required double dx,
    required double dy,
  }) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.accent.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: widget.foreground,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverModulesIndicator extends StatelessWidget {
  const _DiscoverModulesIndicator({
    required this.currentIndex,
    required this.total,
  });

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (index) {
          final selected = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 18 : 8,
            height: 8,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: selected ? AppPalette.royalViolet : AppPalette.border,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _PlanStrip extends StatelessWidget {
  const _PlanStrip({
    required this.planName,
    required this.status,
    required this.renewsAt,
    required this.entitlements,
    required this.onTap,
  });

  final String planName;
  final String status;
  final String? renewsAt;
  final List<String> entitlements;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final summary = status == 'active'
        ? renewsAt == null || renewsAt!.trim().isEmpty
            ? 'Activo'
            : 'Activo hasta ${formatSchedule(renewsAt!)}'
        : 'Sin beneficios activos';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppPalette.indigo,
                AppPalette.royalViolet,
                AppPalette.flameGold,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                planName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                summary,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              if (entitlements.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entitlements
                      .take(3)
                      .map(
                        (item) => _InfoChip(
                          label: item,
                          dark: true,
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.moonIvory,
                  foregroundColor: AppPalette.butterflyInk,
                ),
                child: Text(context.l10n.tr('manageSubscription')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    this.dark = false,
  });

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    const chipAccent = AppPalette.mutedLavender;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.12)
            : chipAccent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.18)
              : chipAccent.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: dark ? Colors.white : chipAccent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
