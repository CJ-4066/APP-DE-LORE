import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/cache/app_settings_cache.dart';
import '../core/cache/bootstrap_cache.dart';
import '../core/cache/seed_bootstrap_loader.dart';
import '../core/cache/session_cache.dart';
import '../core/config/app_config.dart';
import '../core/data/birth_place_catalog.dart';
import '../core/i18n/app_i18n.dart';
import '../core/network/api_client.dart';
import '../features/auth/phone_countries.dart';
import '../models/app_models.dart';
import '../models/astro_models.dart';
import '../models/auth_models.dart';
import '../models/booking_models.dart';
import '../models/chat_models.dart';
import '../models/numerology_models.dart';
import '../models/profile_models.dart';
import '../models/shop_models.dart';

enum AppStage {
  restoring,
  phoneEntry,
  otpEntry,
  profileEntry,
  loadingHome,
  home,
}

class AppController extends ChangeNotifier with WidgetsBindingObserver {
  AppController({
    ApiClient? apiClient,
  })  : _apiClient = apiClient ?? ApiClient(baseUrl: AppConfig.apiBaseUrl),
        _selectedCountry = resolveDefaultCountry(
          PlatformDispatcher.instance.locale.countryCode,
        ),
        _locale = AppLocalizations.resolveSupportedLocale(
          PlatformDispatcher.instance.locale,
        ) {
    debugPrint(
        'AppController initialized with API base URL: ${_apiClient.baseUrl}');
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(_restorePersistedState);
  }

  final ApiClient _apiClient;
  final AppSettingsCache _appSettingsCache = AppSettingsCache();
  final BootstrapCache _bootstrapCache = BootstrapCache();
  final SeedBootstrapLoader _seedBootstrapLoader = SeedBootstrapLoader();
  final SessionCache _sessionCache = SessionCache();

  PhoneCountry _selectedCountry;
  Locale _locale;
  AppStage _stage = AppStage.restoring;
  AppBootstrap? _bootstrap;
  PhoneAuthStartResult? _challenge;
  PhoneAuthSession? _session;
  String? _authErrorMessage;
  String? _homeErrorMessage;
  bool _isBusy = false;
  int _currentIndex = 0;
  Timer? _dailyRefreshTimer;

  PhoneCountry get selectedCountry => _selectedCountry;
  Locale get locale => _locale;
  AppStage get stage => _stage;
  AppBootstrap? get bootstrap => _bootstrap;
  PhoneAuthStartResult? get challenge => _challenge;
  PhoneAuthSession? get session => _session;
  String? get authErrorMessage => _authErrorMessage;
  String? get homeErrorMessage => _homeErrorMessage;
  bool get isBusy => _isBusy;
  int get currentIndex => _currentIndex;

  Future<void> setLocale(Locale locale) async {
    final resolved = AppLocalizations.resolveSupportedLocale(locale);
    if (_locale == resolved) {
      return;
    }

    _locale = resolved;
    await _appSettingsCache.writeLocale(_locale);
    notifyListeners();
  }

  void selectCountry(PhoneCountry country) {
    if (_selectedCountry == country) {
      return;
    }

    _selectedCountry = country;
    notifyListeners();
  }

  void setCurrentIndex(int value) {
    if (_currentIndex == value) {
      return;
    }

    _currentIndex = value;
    notifyListeners();
  }

  void goBackToPhoneEntry() {
    _authErrorMessage = null;
    _challenge = null;
    _stage = AppStage.phoneEntry;
    notifyListeners();
  }

  Future<void> signOut() async {
    final currentSession = _session;
    if (currentSession != null) {
      try {
        await _apiClient.logout(accessToken: currentSession.accessToken);
      } catch (_) {
        // Logout should still succeed locally even if the network is unavailable.
      }
    }

    await _clearPersistedState();
    _session = null;
    _bootstrap = null;
    _challenge = null;
    _authErrorMessage = null;
    _homeErrorMessage = null;
    _currentIndex = 0;
    _stage = AppStage.phoneEntry;
    notifyListeners();
  }

  Future<void> startPhoneAuth(String rawPhoneNumber) async {
    final nationalNumber = _normalizeNationalNumber(rawPhoneNumber);
    if (nationalNumber == null) {
      _authErrorMessage = 'Ingresa un número de teléfono válido.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _authErrorMessage = null;

    try {
      debugPrint(
        'startPhoneAuth -> baseUrl=${_apiClient.baseUrl} country=${_selectedCountry.isoCode} dial=${_selectedCountry.dialCode} number=$nationalNumber',
      );
      final challenge = await _apiClient.startPhoneAuth(
        countryCode: _selectedCountry.isoCode,
        dialCode: _selectedCountry.dialCode,
        nationalNumber: nationalNumber,
      );

      debugPrint(
        'startPhoneAuth <- success phone=${challenge.phoneNumber} debugCode=${challenge.debugCode}',
      );
      _challenge = challenge;
      _stage = AppStage.otpEntry;
    } catch (error) {
      debugPrint('startPhoneAuth <- error ${_readErrorMessage(error)}');
      _authErrorMessage = _readErrorMessage(error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> verifyPhoneCode(String code) async {
    final pendingChallenge = _challenge;
    if (pendingChallenge == null) {
      _authErrorMessage = 'Primero solicita un código para continuar.';
      notifyListeners();
      return;
    }

    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedCode)) {
      _authErrorMessage = 'Ingresa el código de 6 dígitos.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _authErrorMessage = null;

    try {
      debugPrint(
        'verifyPhoneCode -> baseUrl=${_apiClient.baseUrl} phone=${pendingChallenge.phoneNumber}',
      );
      final session = _normalizeSession(
        await _apiClient.verifyPhoneAuth(
          phoneNumber: pendingChallenge.phoneNumber,
          code: normalizedCode,
        ),
      );

      debugPrint(
        'verifyPhoneCode <- success profileCompleted=${session.profileCompleted}',
      );
      _session = session;
      await _persistSession(session);
      if (session.profileCompleted) {
        await _loadHomeForSession();
      } else {
        _stage = AppStage.profileEntry;
      }
    } catch (error) {
      debugPrint('verifyPhoneCode <- error ${_readErrorMessage(error)}');
      _authErrorMessage = _readErrorMessage(error);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> completeProfile(CompletePhoneProfileInput input) async {
    final currentSession = _session;
    if (currentSession == null) {
      _authErrorMessage =
          'Tu sesión ya no está activa. Vuelve a verificar tu teléfono.';
      _stage = AppStage.phoneEntry;
      notifyListeners();
      return;
    }

    final firstName = input.firstName.trim();
    final lastName = input.lastName.trim();
    final city = input.city.trim();
    final country = input.country.trim();
    final birthDate = input.birthDate.trim();
    final birthTime = input.birthTime.trim();
    final utcOffset = input.utcOffset.trim();
    final latitude = input.latitude;
    final longitude = input.longitude;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        city.isEmpty ||
        country.isEmpty ||
        birthDate.isEmpty ||
        birthTime.isEmpty ||
        utcOffset.isEmpty) {
      _authErrorMessage =
          'Completa nombre, apellido, lugar natal, fecha, hora y coordenadas.';
      notifyListeners();
      return;
    }

    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      _authErrorMessage =
          'Selecciona un lugar natal válido para completar las coordenadas.';
      notifyListeners();
      return;
    }

    _setBusy(true);
    _authErrorMessage = null;

    try {
      _session = _normalizeSession(
        await _apiClient.completePhoneProfile(
          accessToken: currentSession.accessToken,
          input: CompletePhoneProfileInput(
            firstName: firstName,
            lastName: lastName,
            email: input.email.trim(),
            city: city,
            state: input.state.trim(),
            country: country,
            birthDate: birthDate,
            birthTime: birthTime,
            timeZoneId: input.timeZoneId.trim(),
            utcOffset: utcOffset,
            latitude: latitude,
            longitude: longitude,
            location: '${city.trim()}, ${country.trim()}',
            zodiacSign: input.zodiacSign.trim(),
          ),
        ),
      );
      await _persistSession(_session);

      await _loadHomeForSession();
    } catch (error) {
      _authErrorMessage = _readErrorMessage(error);
      _stage = AppStage.profileEntry;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> refreshHome() async {
    if (_session == null) {
      return;
    }

    try {
      final response = await _apiClient.fetchBootstrap(
        accessToken: _session!.accessToken,
      );
      _bootstrap = response.data;
      await _persistBootstrap(response.rawJson);
      _homeErrorMessage = null;
      notifyListeners();
    } catch (_) {
      // Preserve the existing view when a manual refresh fails.
    } finally {
      _scheduleDailyRefresh();
    }
  }

  Future<void> retryHomeLoad() async {
    await _loadHomeForSession();
  }

  Future<String?> updateProfile(UpdateProfileInput input) async {
    final currentSession = _session;
    if (currentSession == null) {
      return 'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.';
    }

    try {
      final updatedUser = await _apiClient.updateProfile(
        accessToken: currentSession.accessToken,
        input: input,
      );

      _session = _normalizeSession(
        PhoneAuthSession(
          accessToken: currentSession.accessToken,
          refreshToken: currentSession.refreshToken,
          phoneNumber: currentSession.phoneNumber,
          profileCompleted: _isRequiredProfileDataComplete(updatedUser),
          user: updatedUser,
        ),
      );
      await _persistSession(_session);

      final response = await _apiClient.fetchBootstrap(
        accessToken: currentSession.accessToken,
      );
      _bootstrap = response.data;
      await _persistBootstrap(response.rawJson);
      notifyListeners();

      return null;
    } catch (error) {
      return _readErrorMessage(error);
    }
  }

  Future<String> uploadProfileAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      return await _apiClient.uploadProfileAvatar(
        accessToken: currentSession.accessToken,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<String?> createBooking(CreateBookingInput input) async {
    final currentSession = _session;
    if (currentSession == null) {
      return 'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.';
    }

    try {
      final booking = await _apiClient.createBooking(
        accessToken: currentSession.accessToken,
        input: input,
      );
      _applyBookingSnapshot(booking);
      unawaited(refreshHome());

      return null;
    } catch (error) {
      return _readErrorMessage(error);
    }
  }

  Future<String?> updateBooking({
    required String bookingId,
    required UpdateBookingInput input,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return 'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.';
    }

    try {
      final booking = await _apiClient.updateBooking(
        accessToken: currentSession.accessToken,
        bookingId: bookingId,
        input: input,
      );
      _applyBookingSnapshot(booking);
      unawaited(refreshHome());

      return null;
    } catch (error) {
      return _readErrorMessage(error);
    }
  }

  Future<String?> cancelBooking(String bookingId) async {
    return updateBooking(
      bookingId: bookingId,
      input: UpdateBookingInput(status: 'cancelled'),
    );
  }

  Future<String?> updateServiceOffer({
    required String serviceId,
    required UpdateServiceOfferInput input,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      return 'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.';
    }

    try {
      final service = await _apiClient.updateServiceOffer(
        accessToken: currentSession.accessToken,
        serviceId: serviceId,
        input: input,
      );
      _applyServiceSnapshot(service);
      unawaited(refreshHome());

      return null;
    } catch (error) {
      return _readErrorMessage(error);
    }
  }

  Future<ShopOrder> createShopOrder(CreateShopOrderInput input) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      final order = await _apiClient.createShopOrder(
        accessToken: currentSession.accessToken,
        input: input,
      );
      _applyShopOrderSnapshot(order);
      unawaited(refreshHome());
      return order;
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<ShopProduct> createShopProduct(CreateShopProductInput input) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      final product = await _apiClient.createShopProduct(
        accessToken: currentSession.accessToken,
        input: input,
      );
      _applyShopProductSnapshot(product);
      unawaited(refreshHome());
      return product;
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<ShopProduct> updateShopProduct({
    required String productId,
    required UpdateShopProductInput input,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      final product = await _apiClient.updateShopProduct(
        accessToken: currentSession.accessToken,
        productId: productId,
        input: input,
      );
      _applyShopProductSnapshot(product);
      unawaited(refreshHome());
      return product;
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<ShopOrder> updateShopOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      final order = await _apiClient.updateShopOrderStatus(
        accessToken: currentSession.accessToken,
        orderId: orderId,
        input: UpdateShopOrderStatusInput(status: status),
      );
      _applyShopOrderSnapshot(order);
      unawaited(refreshHome());
      return order;
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<AstroOverviewData> generateAstroOverview(
    AstroRequestInput input,
  ) async {
    final natalFuture = _apiClient.fetchNatalChart(input: input);
    final transitsFuture = _apiClient.fetchAstroTransits(
      input: AstroRequestInput(
        subjectName: input.subjectName,
        birthDate: input.birthDate,
        birthTime: input.birthTime,
        birthTimeUnknown: input.birthTimeUnknown,
        utcOffset: input.utcOffset,
        timeZoneId: input.timeZoneId,
        selectedPlanets: input.selectedPlanets,
        nodeType: input.nodeType,
        lilithType: input.lilithType,
        arabicPartsMode: input.arabicPartsMode,
        technicalPoints: input.technicalPoints,
        latitude: input.latitude,
        longitude: input.longitude,
        locationLabel: input.locationLabel,
        houseSystem: input.houseSystem,
        targetDate: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    final returnsFuture = _apiClient.fetchAstroReturns(
      input: AstroRequestInput(
        subjectName: input.subjectName,
        birthDate: input.birthDate,
        birthTime: input.birthTime,
        birthTimeUnknown: input.birthTimeUnknown,
        utcOffset: input.utcOffset,
        timeZoneId: input.timeZoneId,
        selectedPlanets: input.selectedPlanets,
        nodeType: input.nodeType,
        lilithType: input.lilithType,
        arabicPartsMode: input.arabicPartsMode,
        technicalPoints: input.technicalPoints,
        latitude: input.latitude,
        longitude: input.longitude,
        locationLabel: input.locationLabel,
        houseSystem: input.houseSystem,
        from: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    final eventsFuture = _apiClient.fetchAstroEvents(
      latitude: input.latitude,
      longitude: input.longitude,
    );

    try {
      final results = await Future.wait<Object>([
        natalFuture,
        transitsFuture,
        returnsFuture,
        eventsFuture,
      ]);

      return AstroOverviewData(
        natalChart: results[0] as AstroNatalChartResult,
        transits: results[1] as AstroTransitsResult,
        returns: results[2] as AstroReturnsResult,
        events: results[3] as AstroEventsResult,
      );
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<AstroUtcOffsetResult> resolveAstroUtcOffset({
    required String birthDate,
    required String birthTime,
    required bool birthTimeUnknown,
    required String timeZoneId,
  }) async {
    try {
      return await _apiClient.fetchAstroUtcOffset(
        birthDate: birthDate,
        birthTime: birthTime,
        birthTimeUnknown: birthTimeUnknown,
        timeZoneId: timeZoneId,
      );
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<NumerologyGuideData> loadNumerologyGuide() async {
    try {
      return await _apiClient.fetchNumerologyGuide();
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<NumerologyProfileData> generateNumerologyProfile(
    NumerologyRequestInput input,
  ) async {
    try {
      return await _apiClient.fetchNumerologyProfile(input: input);
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<List<BirthPlaceOption>> searchBirthPlaces(String query) async {
    try {
      return await _apiClient.searchBirthPlaces(query: query);
    } catch (_) {
      return searchBirthPlaceCatalog(query);
    }
  }

  Future<List<CommunityChatMessage>> loadCommunityChat() async {
    try {
      return await _apiClient.fetchCommunityChat(
        accessToken: _session?.accessToken,
      );
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<List<CommunityChatMessage>> sendCommunityChatMessage(
    String body,
  ) async {
    final currentSession = _session;
    if (currentSession == null) {
      throw Exception(
        'Tu sesión ya no está activa. Vuelve a ingresar con tu teléfono.',
      );
    }

    try {
      return await _apiClient.sendCommunityChatMessage(
        accessToken: currentSession.accessToken,
        body: body,
      );
    } catch (error) {
      throw Exception(_readErrorMessage(error));
    }
  }

  Future<void> _loadHomeForSession() async {
    final currentSession = _session;
    if (currentSession == null) {
      _homeErrorMessage = 'No hay una sesión válida para cargar tu cuenta.';
      _stage = AppStage.phoneEntry;
      notifyListeners();
      return;
    }

    final hasFallback = _showHomeFallback(currentSession);
    if (!hasFallback) {
      _stage = AppStage.loadingHome;
      _homeErrorMessage = null;
      notifyListeners();
    }

    try {
      debugPrint(
        '_loadHomeForSession -> baseUrl=${_apiClient.baseUrl} accessTokenPresent=${currentSession.accessToken.isNotEmpty}',
      );
      final response = await _apiClient.fetchBootstrap(
        accessToken: currentSession.accessToken,
      );

      _bootstrap = response.data;
      await _persistBootstrap(response.rawJson);
      await _persistSession(currentSession);
      _currentIndex = 0;
      _stage = AppStage.home;
      _homeErrorMessage = null;
      _scheduleDailyRefresh();
      notifyListeners();
    } catch (error) {
      debugPrint('_loadHomeForSession <- error ${_readErrorMessage(error)}');
      if (!hasFallback) {
        _homeErrorMessage = _readErrorMessage(error);
        _stage = AppStage.loadingHome;
        notifyListeners();
      }
    }
  }

  Future<void> _restorePersistedState() async {
    try {
      final cachedLocale = await _appSettingsCache
          .readLocale()
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
      final cachedBootstrap = await _bootstrapCache
          .read()
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
      final cachedSession = await _sessionCache
          .read()
          .timeout(const Duration(seconds: 1), onTimeout: () => null);

      if (cachedLocale != null) {
        _locale = AppLocalizations.resolveSupportedLocale(cachedLocale);
      }

      if (cachedSession == null) {
        final publicBootstrap = await _loadPublicBootstrapFallback();
        if (publicBootstrap != null) {
          _bootstrap = publicBootstrap;
          _currentIndex = 0;
          _stage = AppStage.home;
          _homeErrorMessage = null;
          notifyListeners();
        } else {
          _stage = AppStage.phoneEntry;
          notifyListeners();
        }
        return;
      }

      _session = _normalizeSession(cachedSession);
      if (_session != null && !_session!.profileCompleted) {
        _bootstrap = null;
        _currentIndex = 0;
        _stage = AppStage.profileEntry;
        _homeErrorMessage = null;
        notifyListeners();
        return;
      }

      _bootstrap = _resolveStartupBootstrap(
        cachedSession: _session!,
        cachedBootstrap: cachedBootstrap?.data,
      );

      _stage = AppStage.home;
      _scheduleDailyRefresh();
      notifyListeners();

      try {
        final response = await _apiClient.fetchBootstrap(
          accessToken: _session!.accessToken,
        );
        _bootstrap = response.data;
        await _persistBootstrap(response.rawJson);
        await _persistSession(_session);
        _stage = AppStage.home;
        _homeErrorMessage = null;
        _scheduleDailyRefresh();
        notifyListeners();
      } catch (_) {
        if (_bootstrap != null) {
          _stage = AppStage.home;
          _homeErrorMessage = null;
          _scheduleDailyRefresh();
          notifyListeners();
          return;
        }

        await _clearPersistedState();
        _session = null;
        _stage = AppStage.phoneEntry;
        notifyListeners();
      }
    } catch (_) {
      await _clearPersistedState();
      _session = null;
      final publicBootstrap = await _loadPublicBootstrapFallback();
      if (publicBootstrap != null) {
        _bootstrap = publicBootstrap;
        _currentIndex = 0;
        _stage = AppStage.home;
        _homeErrorMessage = null;
      } else {
        _bootstrap = null;
        _stage = AppStage.phoneEntry;
      }
      notifyListeners();
    }
  }

  Future<AppBootstrap?> _loadPublicBootstrapFallback() async {
    try {
      final response =
          await _apiClient.fetchBootstrap().timeout(const Duration(seconds: 3));
      await _persistBootstrap(response.rawJson);
      return response.data;
    } catch (_) {
      final seedBootstrap = await _seedBootstrapLoader.load();
      if (seedBootstrap == null) {
        return null;
      }

      return _buildGuestBootstrap(seedBootstrap);
    }
  }

  AppBootstrap? _resolveStartupBootstrap({
    required PhoneAuthSession cachedSession,
    required AppBootstrap? cachedBootstrap,
  }) {
    final source = cachedBootstrap;
    if (source != null) {
      return _bootstrapWithSessionUser(source, cachedSession);
    }

    return _buildPlaceholderBootstrap(cachedSession);
  }

  bool _showHomeFallback(PhoneAuthSession session) {
    _bootstrap ??= _buildPlaceholderBootstrap(session);
    _currentIndex = 0;
    _stage = AppStage.home;
    _homeErrorMessage = null;
    _scheduleDailyRefresh();
    notifyListeners();
    return true;
  }

  AppBootstrap _bootstrapWithSessionUser(
    AppBootstrap source,
    PhoneAuthSession session,
  ) {
    final user = session.user;
    final trimmedFirstName = user.firstName.trim();
    final plan = _findPlanById(source.plans, user.planId);

    return AppBootstrap(
      app: source.app,
      user: user,
      home: HomeData(
        welcomeTitle: trimmedFirstName.isEmpty
            ? source.home.welcomeTitle
            : 'Hola, $trimmedFirstName',
        welcomeSubtitle: source.home.welcomeSubtitle,
        cardOfTheDay: source.home.cardOfTheDay,
        astrologicalEnergy: source.home.astrologicalEnergy,
        quickActions: source.home.quickActions,
        upcomingBooking: source.home.upcomingBooking,
        featuredMessage: source.home.featuredMessage,
      ),
      plans: source.plans,
      subscription: plan == null
          ? source.subscription
          : SubscriptionData(
              planId: plan.id,
              planName: plan.name,
              status: source.subscription.status,
              renewsAt: source.subscription.renewsAt,
              platform: source.subscription.platform,
              billingProvider: source.subscription.billingProvider,
              entitlements: plan.features,
            ),
      payments: source.payments,
      services: source.services,
      specialists: source.specialists,
      courses: source.courses,
      shop: source.shop,
      bookings: source.bookings,
      admin: source.admin,
    );
  }

  void _applyBookingSnapshot(Booking booking) {
    final currentBootstrap = _bootstrap;
    if (currentBootstrap == null) {
      return;
    }

    final nextBookings = [...currentBootstrap.bookings];
    final existingIndex =
        nextBookings.indexWhere((item) => item.id == booking.id);
    if (existingIndex >= 0) {
      nextBookings[existingIndex] = booking;
    } else {
      nextBookings.add(booking);
    }
    nextBookings
        .sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));

    _bootstrap = AppBootstrap(
      app: currentBootstrap.app,
      user: currentBootstrap.user,
      home: HomeData(
        welcomeTitle: currentBootstrap.home.welcomeTitle,
        welcomeSubtitle: currentBootstrap.home.welcomeSubtitle,
        cardOfTheDay: currentBootstrap.home.cardOfTheDay,
        astrologicalEnergy: currentBootstrap.home.astrologicalEnergy,
        quickActions: currentBootstrap.home.quickActions,
        upcomingBooking: _buildUpcomingBookingSummary(nextBookings),
        featuredMessage: currentBootstrap.home.featuredMessage,
      ),
      plans: currentBootstrap.plans,
      subscription: currentBootstrap.subscription,
      payments: currentBootstrap.payments,
      services: currentBootstrap.services,
      specialists: currentBootstrap.specialists,
      courses: currentBootstrap.courses,
      shop: currentBootstrap.shop,
      bookings: nextBookings,
      admin: currentBootstrap.admin,
    );
    notifyListeners();
  }

  void _applyShopOrderSnapshot(ShopOrder order) {
    final currentBootstrap = _bootstrap;
    if (currentBootstrap == null) {
      return;
    }

    final nextOrders = [...currentBootstrap.shop.orders];
    final existingIndex = nextOrders.indexWhere((item) => item.id == order.id);
    if (existingIndex >= 0) {
      nextOrders[existingIndex] = order;
    } else {
      nextOrders.insert(0, order);
    }
    nextOrders.sort((left, right) => right.createdAt.compareTo(left.createdAt));

    _bootstrap = AppBootstrap(
      app: currentBootstrap.app,
      user: currentBootstrap.user,
      home: currentBootstrap.home,
      plans: currentBootstrap.plans,
      subscription: currentBootstrap.subscription,
      payments: currentBootstrap.payments,
      services: currentBootstrap.services,
      specialists: currentBootstrap.specialists,
      courses: currentBootstrap.courses,
      shop: ShopData(
        title: currentBootstrap.shop.title,
        subtitle: currentBootstrap.shop.subtitle,
        featuredNote: currentBootstrap.shop.featuredNote,
        supportNote: currentBootstrap.shop.supportNote,
        currency: currentBootstrap.shop.currency,
        products: currentBootstrap.shop.products,
        orders: nextOrders,
      ),
      bookings: currentBootstrap.bookings,
      admin: currentBootstrap.admin,
    );
    notifyListeners();
  }

  void _applyShopProductSnapshot(ShopProduct product) {
    final currentBootstrap = _bootstrap;
    if (currentBootstrap == null) {
      return;
    }

    final nextProducts = [...currentBootstrap.shop.products];
    final existingIndex =
        nextProducts.indexWhere((item) => item.id == product.id);
    if (existingIndex >= 0) {
      nextProducts[existingIndex] = product;
    } else {
      nextProducts.insert(0, product);
    }

    _bootstrap = AppBootstrap(
      app: currentBootstrap.app,
      user: currentBootstrap.user,
      home: currentBootstrap.home,
      plans: currentBootstrap.plans,
      subscription: currentBootstrap.subscription,
      payments: currentBootstrap.payments,
      services: currentBootstrap.services,
      specialists: currentBootstrap.specialists,
      courses: currentBootstrap.courses,
      shop: ShopData(
        title: currentBootstrap.shop.title,
        subtitle: currentBootstrap.shop.subtitle,
        featuredNote: currentBootstrap.shop.featuredNote,
        supportNote: currentBootstrap.shop.supportNote,
        currency: currentBootstrap.shop.currency,
        products: nextProducts,
        orders: currentBootstrap.shop.orders,
      ),
      bookings: currentBootstrap.bookings,
      admin: currentBootstrap.admin,
    );
    notifyListeners();
  }

  void _applyServiceSnapshot(ServiceOffer service) {
    final currentBootstrap = _bootstrap;
    if (currentBootstrap == null) {
      return;
    }

    final nextServices = [...currentBootstrap.services];
    final existingIndex =
        nextServices.indexWhere((item) => item.id == service.id);
    if (existingIndex >= 0) {
      nextServices[existingIndex] = service;
    } else {
      nextServices.insert(0, service);
    }

    _bootstrap = AppBootstrap(
      app: currentBootstrap.app,
      user: currentBootstrap.user,
      home: currentBootstrap.home,
      plans: currentBootstrap.plans,
      subscription: currentBootstrap.subscription,
      payments: currentBootstrap.payments,
      services: nextServices,
      specialists: currentBootstrap.specialists,
      courses: currentBootstrap.courses,
      shop: currentBootstrap.shop,
      bookings: currentBootstrap.bookings,
      admin: currentBootstrap.admin,
    );
    notifyListeners();
  }

  BookingSummary? _buildUpcomingBookingSummary(List<Booking> bookings) {
    for (final booking in bookings) {
      if (booking.status == 'confirmed' ||
          booking.status == 'pending_payment') {
        return BookingSummary(
          id: booking.id,
          specialistName: booking.specialistName,
          serviceName: booking.serviceName,
          scheduledAt: booking.scheduledAt,
          status: booking.status,
        );
      }
    }

    return null;
  }

  AppBootstrap _buildPlaceholderBootstrap(PhoneAuthSession session) {
    final user = session.user;
    final trimmedFirstName = user.firstName.trim();
    final trimmedLastName = user.lastName.trim();
    final displayName = [trimmedFirstName, trimmedLastName]
        .where((item) => item.isNotEmpty)
        .join(' ');
    final planId = user.planId.trim().isEmpty ? 'free' : user.planId.trim();
    final planName = planId == 'premium' ? 'Premium' : 'Free';

    return AppBootstrap(
      app: AppMeta(
        name: 'Lo Renaciente',
        tagline: 'Autoconocimiento, guía y consultas en un mismo lugar.',
        market: 'Perú / Latam',
        timezone: user.timezone.trim().isEmpty ? 'America/Lima' : user.timezone,
      ),
      user: user,
      home: HomeData(
        welcomeTitle:
            trimmedFirstName.isEmpty ? 'Hola' : 'Hola, $trimmedFirstName',
        welcomeSubtitle:
            'Tu espacio está listo. Estamos sincronizando tus datos.',
        cardOfTheDay: DailyCard(
          title: 'Carta del día',
          cardName: 'La Fuerza',
          message:
              'Vuelve al centro, entra sin prisa y deja que la app termine de sincronizar.',
          ritual: 'Respira dos veces antes de abrir el siguiente módulo.',
          imageUrl: '',
        ),
        astrologicalEnergy: AstrologicalEnergy(
          title: 'Energía astrológica',
          summary:
              'La interfaz principal ya está disponible mientras completamos la actualización.',
          advice:
              'Puedes navegar ahora; el contenido se seguirá ajustando en segundo plano.',
          intensity: 'media',
        ),
        quickActions: [
          QuickAction(
            id: 'quick-profile',
            label: 'Perfil',
            description: 'Revisa tus datos base',
            type: 'profile',
          ),
          QuickAction(
            id: 'quick-astro',
            label: 'Carta astral',
            description: 'Abre tu espacio astral',
            type: 'content',
          ),
          QuickAction(
            id: 'quick-numerology',
            label: 'Numerología',
            description: 'Consulta tus ciclos',
            type: 'content',
          ),
        ],
        upcomingBooking: null,
        featuredMessage: displayName.isEmpty
            ? 'Cargando datos actualizados de tu cuenta.'
            : 'Cargando datos actualizados de $displayName.',
      ),
      plans: [
        Plan(
          id: 'free',
          name: 'Free',
          tier: 'free',
          priceMonthly: 0,
          currency: 'USD',
          isPopular: false,
          features: const [
            'Carta del día',
            'Agenda limitada',
          ],
          sessionMessageLimit: 20,
          consultationAccess: const ['tarot', 'astrología'],
        ),
        Plan(
          id: 'premium',
          name: 'Premium',
          tier: 'premium',
          priceMonthly: 14.99,
          currency: 'USD',
          isPopular: true,
          features: const [
            'Lectura diaria ampliada',
            'Astrología personalizada',
            'Chat ilimitado',
          ],
          sessionMessageLimit: null,
          consultationAccess: const [
            'tarot',
            'astrología',
            'numerología',
          ],
        ),
      ],
      subscription: SubscriptionData(
        planId: planId,
        planName: planName,
        status: 'active',
        renewsAt: null,
        platform: 'ios',
        billingProvider: 'Apple In-App Purchase',
        entitlements: planId == 'premium'
            ? const [
                'Lectura diaria ampliada',
                'Astrología personalizada',
                'Chat ilimitado',
              ]
            : const [
                'Carta del día',
                'Agenda limitada',
              ],
      ),
      payments: PaymentsConfig(
        consultationProvider: 'Mercado Pago',
        premiumProvider: 'Apple In-App Purchase',
        supportedMethods: const [
          'Tarjetas crédito/débito',
          'Suscripción mensual',
        ],
        notes: const [
          'Sincronizando tu configuración de pagos.',
        ],
      ),
      services: const [],
      specialists: const [],
      courses: const [],
      shop: ShopData(
        title: 'Shop Renaciente',
        subtitle:
            'Objetos rituales, mazos y piezas decorativas listos para sincronizar.',
        featuredNote:
            'Estamos preparando el catálogo inicial con artículos y órdenes.',
        supportNote:
            'El historial de compras aparecerá aquí cuando termine la sincronización.',
        currency: 'USD',
        products: const [],
        orders: const [],
      ),
      bookings: const [],
      admin: AdminSummary(
        activeUsers: 0,
        premiumSubscribers: 0,
        monthlyBookings: 0,
        activeSpecialists: 0,
        openIncidents: 0,
      ),
    );
  }

  AppBootstrap _buildGuestBootstrap(AppBootstrap source) {
    final freePlan = _findPlanById(source.plans, 'free');
    final guestPlanName =
        freePlan?.name.trim().isNotEmpty == true ? freePlan!.name : 'Free';
    final guestEntitlements = freePlan?.features ?? const <String>[];

    return AppBootstrap(
      app: source.app,
      user: UserProfile(
        id: '',
        firstName: '',
        lastName: '',
        nickname: 'invitado',
        email: '',
        avatarUrl: '',
        location: '',
        timezone: source.app.timezone,
        zodiacSign: '',
        planId: freePlan?.id ?? 'free',
        accountType: 'client',
        natalChart: NatalChart(
          subjectName: '',
          birthDate: '',
          birthTime: '',
          birthTimeUnknown: true,
          city: '',
          state: '',
          country: '',
          timeZoneId: source.app.timezone,
          utcOffset: '',
          latitude: null,
          longitude: null,
        ),
        preferences: UserPreferences(
          focusAreas: source.user.preferences.focusAreas,
          preferredSessionModes: source.user.preferences.preferredSessionModes,
          receivesPush: false,
        ),
      ),
      home: HomeData(
        welcomeTitle: 'Hola',
        welcomeSubtitle:
            'Explora Lo Renaciente mientras recuperamos la conexión con la API.',
        cardOfTheDay: source.home.cardOfTheDay,
        astrologicalEnergy: source.home.astrologicalEnergy,
        quickActions: source.home.quickActions,
        upcomingBooking: null,
        featuredMessage:
            'Modo local activo. Cuando la API vuelva a estar disponible, la app sincronizará tus datos.',
      ),
      plans: source.plans,
      subscription: SubscriptionData(
        planId: freePlan?.id ?? 'free',
        planName: guestPlanName,
        status: 'offline',
        renewsAt: null,
        platform: '',
        billingProvider: 'Sin conexión',
        entitlements: guestEntitlements,
      ),
      payments: source.payments,
      services: source.services,
      specialists: source.specialists,
      courses: source.courses,
      shop: ShopData(
        title: source.shop.title,
        subtitle: source.shop.subtitle,
        featuredNote: source.shop.featuredNote,
        supportNote: source.shop.supportNote,
        currency: source.shop.currency,
        products: source.shop.products,
        orders: const [],
      ),
      bookings: const [],
      admin: AdminSummary(
        activeUsers: 0,
        premiumSubscribers: 0,
        monthlyBookings: 0,
        activeSpecialists: source.specialists.length,
        openIncidents: 0,
      ),
    );
  }

  Plan? _findPlanById(List<Plan> plans, String planId) {
    for (final plan in plans) {
      if (plan.id == planId) {
        return plan;
      }
    }

    return null;
  }

  Future<void> _persistSession(PhoneAuthSession? session) async {
    if (session == null) {
      await _sessionCache.clear();
      return;
    }

    await _sessionCache.write(session);
  }

  Future<void> _persistBootstrap(String rawJson) async {
    await _bootstrapCache.write(rawJson);
  }

  Future<void> _clearPersistedState() async {
    _cancelDailyRefresh();
    await _sessionCache.clear();
    await _bootstrapCache.clear();
  }

  void _scheduleDailyRefresh() {
    _dailyRefreshTimer?.cancel();

    if (_session == null || _bootstrap == null || _stage != AppStage.home) {
      return;
    }

    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now) + const Duration(seconds: 1);

    _dailyRefreshTimer = Timer(delay, () {
      if (_session == null || _stage != AppStage.home) {
        return;
      }

      unawaited(refreshHome());
    });
  }

  void _cancelDailyRefresh() {
    _dailyRefreshTimer?.cancel();
    _dailyRefreshTimer = null;
  }

  void _setBusy(bool value) {
    if (_isBusy == value) {
      return;
    }

    _isBusy = value;
    notifyListeners();
  }

  PhoneAuthSession _normalizeSession(PhoneAuthSession session) {
    final profileCompleted = _isRequiredProfileDataComplete(session.user);
    if (session.profileCompleted == profileCompleted) {
      return session;
    }

    return PhoneAuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      phoneNumber: session.phoneNumber,
      profileCompleted: profileCompleted,
      user: session.user,
    );
  }

  bool _isRequiredProfileDataComplete(UserProfile user) {
    return user.firstName.trim().isNotEmpty &&
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

  String? _normalizeNationalNumber(String rawValue) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6 || digits.length > 12) {
      return null;
    }

    return digits;
  }

  String _readErrorMessage(Object error) {
    final rawMessage = error.toString().trim();
    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.substring('Exception: '.length);
    }

    return rawMessage;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _stage == AppStage.home &&
        _session != null) {
      unawaited(refreshHome());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelDailyRefresh();
    _apiClient.dispose();
    super.dispose();
  }
}
