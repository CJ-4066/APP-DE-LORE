import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/branding/renaciente_logo.dart';
import '../core/i18n/app_i18n.dart';
import '../core/theme/app_theme.dart';
import '../features/astro/astral_chart_screen.dart';
import '../features/auth/auth_screens.dart';
import '../features/bookings/bookings_screen.dart';
import '../features/bookings/schedule_booking_screen.dart';
import '../features/chat/community_chat_screen.dart';
import '../features/courses/courses_screen.dart';
import '../features/home/home_screen.dart';
import '../features/numerology/numerology_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/specialist/specialist_workspace_screen.dart';
import '../features/tarot/tarot_screen.dart';
import '../models/app_models.dart';
import '../state/app_controller.dart';

class LoRenacienteApp extends StatefulWidget {
  const LoRenacienteApp({super.key});

  @override
  State<LoRenacienteApp> createState() => _LoRenacienteAppState();
}

class _LoRenacienteAppState extends State<LoRenacienteApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.forLocale(_controller.locale);

    return MaterialApp(
      title: 'Lo Renaciente',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: _controller.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final bootstrap = _controller.bootstrap;

          if (bootstrap != null &&
              (_controller.stage == AppStage.restoring ||
                  _controller.stage == AppStage.loadingHome ||
                  _controller.stage == AppStage.home)) {
            return _AuthenticatedShell(
              controller: _controller,
              data: bootstrap,
            );
          }

          switch (_controller.stage) {
            case AppStage.restoring:
              return const _BootView();
            case AppStage.phoneEntry:
              return PhoneLoginScreen(
                selectedCountry: _controller.selectedCountry,
                onCountryChanged: _controller.selectCountry,
                onContinue: _controller.startPhoneAuth,
                isBusy: _controller.isBusy,
                errorMessage: _controller.authErrorMessage,
              );
            case AppStage.otpEntry:
              final challenge = _controller.challenge;
              if (challenge == null) {
                return _LoadingView(
                  title: strings.tr('loadingPreparingAccessTitle'),
                  subtitle: strings.tr('loadingPreparingAccessSubtitle'),
                );
              }

              return OtpVerificationScreen(
                phoneNumber: challenge.phoneNumber,
                debugCode: challenge.debugCode,
                onVerify: _controller.verifyPhoneCode,
                onBack: _controller.goBackToPhoneEntry,
                isBusy: _controller.isBusy,
                errorMessage: _controller.authErrorMessage,
              );
            case AppStage.profileEntry:
              final phoneNumber = _controller.session?.phoneNumber ??
                  _controller.challenge?.phoneNumber ??
                  '';
              return CompleteProfileScreen(
                phoneNumber: phoneNumber,
                initialProfile: _controller.session?.user,
                onSave: _controller.completeProfile,
                onSearchBirthPlaces: _controller.searchBirthPlaces,
                isBusy: _controller.isBusy,
                errorMessage: _controller.authErrorMessage,
              );
            case AppStage.loadingHome:
              return _LoadingView(
                title: strings.tr('loadingPreparingSpaceTitle'),
                subtitle: _controller.homeErrorMessage ??
                    strings.tr('loadingPreparingSpaceSubtitle'),
                actionLabel: _controller.homeErrorMessage == null
                    ? null
                    : strings.tr('loadingRetry'),
                onAction: _controller.homeErrorMessage == null
                    ? null
                    : _controller.retryHomeLoad,
              );
            case AppStage.home:
              if (bootstrap == null) {
                return _LoadingView(
                  title: strings.tr('loadingAppTitle'),
                  subtitle: strings.tr('loadingAppSubtitle'),
                );
              }

              return _AuthenticatedShell(
                controller: _controller,
                data: bootstrap,
              );
          }
        },
      ),
    );
  }
}

class _AuthenticatedShell extends StatelessWidget {
  const _AuthenticatedShell({
    required this.controller,
    required this.data,
  });

  final AppController controller;
  final AppBootstrap data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Future<void> openAstralChart() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AstralChartScreen(
            user: data.user,
            onSaveProfile: controller.updateProfile,
            onGenerate: controller.generateAstroOverview,
            onResolveUtcOffset: controller.resolveAstroUtcOffset,
            onSearchBirthPlaces: controller.searchBirthPlaces,
          ),
        ),
      );
    }

    Future<void> openBooking([String? initialServiceId]) async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ScheduleBookingScreen(
            data: data,
            initialServiceId: initialServiceId,
            onSave: controller.createBooking,
          ),
        ),
      );
    }

    Future<void> openNumerology() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NumerologyScreen(
            data: data,
            onRefresh: controller.refreshHome,
            onCreateBooking: openBooking,
            onLoadGuide: controller.loadNumerologyGuide,
            onGenerate: controller.generateNumerologyProfile,
          ),
        ),
      );
    }

    Future<void> openCommunityChat() async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CommunityChatScreen(
            onLoadMessages: controller.loadCommunityChat,
            onSendMessage: controller.sendCommunityChatMessage,
          ),
        ),
      );
    }

    final isSpecialist = data.user.accountType == 'specialist';
    final screens = isSpecialist
        ? [
            SpecialistWorkspaceScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onUpdateService: controller.updateServiceOffer,
              onUpdateBooking: controller.updateBooking,
              onOpenShop: () => controller.setCurrentIndex(1),
              onOpenCourses: () => controller.setCurrentIndex(2),
              onOpenCommunityChat: openCommunityChat,
            ),
            ShopScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onCreateOrder: controller.createShopOrder,
              onCreateProduct: controller.createShopProduct,
              onUpdateProduct: controller.updateShopProduct,
              onUpdateOrderStatus: controller.updateShopOrderStatus,
              canManageShop: true,
            ),
            CoursesScreen(
              data: data,
              onRefresh: controller.refreshHome,
            ),
            BookingsScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onCreateBooking: openBooking,
              onUpdateBooking: controller.updateBooking,
              onCancelBooking: controller.cancelBooking,
              onLoadCommunityChat: controller.loadCommunityChat,
              onSendCommunityChatMessage: controller.sendCommunityChatMessage,
            ),
            ProfileScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onOpenAstralChart: openAstralChart,
              currentLocale: controller.locale,
              onChangeLocale: controller.setLocale,
              onStartPhoneLogin: controller.goBackToPhoneEntry,
              onLogout: controller.signOut,
              onEditProfile: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfileScreen(
                      user: data.user,
                      onSave: controller.updateProfile,
                      onUploadAvatar: controller.uploadProfileAvatar,
                      onSearchBirthPlaces: controller.searchBirthPlaces,
                    ),
                  ),
                );
              },
            ),
          ]
        : [
            HomeScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onOpenAstralChart: openAstralChart,
              onOpenNumerology: openNumerology,
              onLoadAstroOverview: controller.generateAstroOverview,
            ),
            TarotScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onCreateBooking: openBooking,
            ),
            ShopScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onCreateOrder: controller.createShopOrder,
              onCreateProduct: controller.createShopProduct,
              onUpdateProduct: controller.updateShopProduct,
              onUpdateOrderStatus: controller.updateShopOrderStatus,
              canManageShop: false,
            ),
            CoursesScreen(
              data: data,
              onRefresh: controller.refreshHome,
            ),
            BookingsScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onCreateBooking: openBooking,
              onUpdateBooking: controller.updateBooking,
              onCancelBooking: controller.cancelBooking,
              onLoadCommunityChat: controller.loadCommunityChat,
              onSendCommunityChatMessage: controller.sendCommunityChatMessage,
            ),
            ProfileScreen(
              data: data,
              onRefresh: controller.refreshHome,
              onOpenAstralChart: openAstralChart,
              currentLocale: controller.locale,
              onChangeLocale: controller.setLocale,
              onStartPhoneLogin: controller.goBackToPhoneEntry,
              onLogout: controller.signOut,
              onEditProfile: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfileScreen(
                      user: data.user,
                      onSave: controller.updateProfile,
                      onUploadAvatar: controller.uploadProfileAvatar,
                      onSearchBirthPlaces: controller.searchBirthPlaces,
                    ),
                  ),
                );
              },
            ),
          ];
    final selectedIndex =
        controller.currentIndex.clamp(0, screens.length - 1).toInt();

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: controller.setCurrentIndex,
        destinations: isSpecialist
            ? [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(Icons.dashboard_customize),
                  label: 'Panel',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  selectedIcon: const Icon(Icons.shopping_bag),
                  label: l10n.tr('navShop'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_stories_outlined),
                  selectedIcon: const Icon(Icons.auto_stories),
                  label: l10n.tr('navCourses'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month),
                  label: l10n.tr('navBookings'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l10n.tr('navProfile'),
                ),
              ]
            : [
                NavigationDestination(
                  icon: const Icon(Icons.auto_awesome_outlined),
                  selectedIcon: const Icon(Icons.auto_awesome),
                  label: l10n.tr('navHome'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.style_outlined),
                  selectedIcon: const Icon(Icons.style),
                  label: l10n.tr('navTarot'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  selectedIcon: const Icon(Icons.shopping_bag),
                  label: l10n.tr('navShop'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_stories_outlined),
                  selectedIcon: const Icon(Icons.auto_stories),
                  label: l10n.tr('navCourses'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month),
                  label: l10n.tr('navBookings'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l10n.tr('navProfile'),
                ),
              ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF4E8),
              Color(0xFFF8E0C2),
              Color(0xFFFFFAF4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const RenacienteLogoLockup(
                      markSize: 74,
                      foregroundColor: Color(0xFF182127),
                      secondaryColor: Color(0xFF6B4C3A),
                      showTagline: true,
                      tagline: 'Autoconocimiento con forma clara',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF182127),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF5C7A72),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (actionLabel == null)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.8),
                      )
                    else
                      FilledButton(
                        onPressed: () async {
                          await onAction?.call();
                        },
                        child: Text(actionLabel!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootView extends StatelessWidget {
  const _BootView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF4E8),
              Color(0xFFF8E0C2),
              Color(0xFFFFFAF4),
            ],
          ),
        ),
        child: const SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RenacienteLogoLockup(
                  markSize: 74,
                  foregroundColor: Color(0xFF182127),
                  secondaryColor: Color(0xFF6B4C3A),
                  showTagline: true,
                  tagline: 'Autoconocimiento con forma clara',
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
