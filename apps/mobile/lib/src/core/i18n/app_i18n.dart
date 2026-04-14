import 'package:flutter/material.dart';

class AppLanguageOption {
  const AppLanguageOption({
    required this.locale,
    required this.label,
    required this.nativeLabel,
  });

  final Locale locale;
  final String label;
  final String nativeLabel;
}

const supportedAppLanguages = <AppLanguageOption>[
  AppLanguageOption(
    locale: Locale('es'),
    label: 'Spanish',
    nativeLabel: 'Español',
  ),
  AppLanguageOption(
    locale: Locale('en'),
    label: 'English',
    nativeLabel: 'English',
  ),
  AppLanguageOption(
    locale: Locale('pt'),
    label: 'Portuguese',
    nativeLabel: 'Português',
  ),
  AppLanguageOption(
    locale: Locale('fr'),
    label: 'French',
    nativeLabel: 'Français',
  ),
  AppLanguageOption(
    locale: Locale('it'),
    label: 'Italian',
    nativeLabel: 'Italiano',
  ),
  AppLanguageOption(
    locale: Locale('de'),
    label: 'German',
    nativeLabel: 'Deutsch',
  ),
];

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt'),
    Locale('fr'),
    Locale('it'),
    Locale('de'),
  ];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(value != null, 'AppLocalizations not found in context.');
    return value!;
  }

  static AppLocalizations forLocale(Locale locale) {
    return AppLocalizations(resolveSupportedLocale(locale));
  }

  static Locale resolveSupportedLocale(Locale locale) {
    return supportedLocales.firstWhere(
      (item) => item.languageCode == locale.languageCode,
      orElse: () => const Locale('es'),
    );
  }

  static AppLanguageOption languageOptionForLocale(Locale locale) {
    final resolved = resolveSupportedLocale(locale);
    return supportedAppLanguages.firstWhere(
      (item) => item.locale.languageCode == resolved.languageCode,
      orElse: () => supportedAppLanguages.first,
    );
  }

  String tr(String key, [Map<String, String> params = const {}]) {
    final bundle =
        _localizedValues[locale.languageCode] ?? _localizedValues['es']!;
    var value = bundle[key] ?? _localizedValues['es']![key] ?? key;
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (item) => item.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.forLocale(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

const _localizedValues = <String, Map<String, String>>{
  'es': {
    'loadingRestoringTitle': 'Restaurando tu espacio',
    'loadingRestoringSubtitle':
        'Recuperando tu sesión, perfil y configuración guardada.',
    'loadingPreparingAccessTitle': 'Preparando acceso',
    'loadingPreparingAccessSubtitle':
        'Reconstruyendo el flujo de verificación.',
    'loadingPreparingSpaceTitle': 'Preparando tu espacio',
    'loadingPreparingSpaceSubtitle':
        'Estamos cargando tus datos, agenda y contenido personalizado.',
    'loadingRetry': 'Reintentar',
    'loadingAppTitle': 'Cargando Lo Renaciente',
    'loadingAppSubtitle': 'Ajustando tu experiencia personalizada.',
    'navHome': 'Inicio',
    'navTarot': 'Tarot',
    'navShop': 'Shop',
    'navCourses': 'Biblioteca',
    'navBookings': 'Citas',
    'navProfile': 'Perfil',
    'authPhoneTitle': 'Ingresa tu teléfono',
    'authPhoneSubtitle':
        'Selecciona tu país, escribe tu número y te enviaremos un código de seguridad por SMS.',
    'country': 'País',
    'phoneNumber': 'Número de teléfono',
    'sendCode': 'Enviar código',
    'authOtpTitle': 'Verifica tu código',
    'authOtpSubtitle':
        'Ingresa el código enviado a {phone}. En desarrollo te mostramos el OTP real para avanzar rápido.',
    'demoCode': 'Código demo',
    'securityCode': 'Código de seguridad',
    'verifyCode': 'Verificar código',
    'changeNumber': 'Cambiar número',
    'profileTitle': 'Perfil',
    'currentPlan': 'Plan actual: {plan}',
    'email': 'Correo',
    'noEmail': 'Sin correo registrado',
    'location': 'Ubicación',
    'noLocation': 'Sin ubicación registrada',
    'natalData': 'Datos natales',
    'utcOffset': 'UTC offset: {offset}',
    'coords': 'Coordenadas: {lat}, {lng}',
    'editProfile': 'Editar perfil',
    'guestModeTitle': 'Modo invitado',
    'guestModeSubtitle':
        'La app abrió con contenido local porque la API no está disponible. Ingresa con tu teléfono para recuperar tu cuenta cuando la conexión vuelva.',
    'guestModeAction': 'Ingresar con teléfono',
    'astralChart': 'Carta astral',
    'preferences': 'Preferencias',
    'subscription': 'Suscripción',
    'status': 'Estado: {status}',
    'billing': 'Facturación: {provider}',
    'renewsOn': 'Renueva el {date}',
    'payments': 'Monetización y pagos',
    'consultations': 'Consultas: {provider}',
    'premium': 'Premium: {provider}',
    'manageSubscription': 'Gestionar suscripción',
    'privacyData': 'Privacidad y datos',
    'support': 'Soporte',
    'activeUsers': 'Usuarios activos: {count}',
    'language': 'Idioma',
    'languageDescription': 'Cambia el idioma visible de la app.',
    'chooseLanguage': 'Elegir idioma',
    'homePlanChip': 'Plan {plan}',
    'ritual': 'Ritual: {ritual}',
    'intensity': 'Intensidad {value}',
    'homeAstralTitle': 'Carta Astral',
    'homeAstralDescription':
        'Genera tu carta con Sol, Luna, Ascendente, casas, aspectos, tránsitos y revoluciones sobre el motor propio de Lo Renaciente.',
    'natalReady': 'Datos natales listos',
    'completeNatalData': 'Completar datos natales',
    'missingUtc': 'Falta UTC offset',
    'openAstralChart': 'Abrir carta astral',
    'homeNumerologyTitle': 'Numerología',
    'homeNumerologyDescription':
        'Calcula sendero de vida, expresión, alma, personalidad, pináculos, desafíos y ciclos personales.',
    'lifePath': 'Sendero de vida',
    'personalYear': 'Año personal',
    'birthName': 'Nombre natal',
    'openNumerology': 'Abrir numerología',
    'homeTarotTitle': 'Portal Tarot',
    'homeTarotDescription':
        'Entra a tu espacio de tarot con carta del día, lecturas, especialistas, biblioteca y ritual recomendado.',
    'cardOfDay': 'Carta del día',
    'readings': 'Lecturas',
    'specialists': 'Especialistas',
    'openTarot': 'Abrir tarot',
    'quickAccess': 'Accesos rápidos',
    'nextSession': 'Próxima consulta',
    'view': 'Ver',
    'subscriptionStatus': 'Estado de suscripción',
    'subscriptionActive': 'Tu plan {plan} está activo y renueva el {date}.',
    'subscriptionInactive':
        'Estás en {plan}. Puedes desbloquear biblioteca, chat y especialistas avanzados.',
    'productArchitecture': 'Nota de arquitectura del producto',
    'homeDiscoverTitle': 'Descubre tu día',
    'homeDiscoverSubtitle':
        'Elige lo que quieres ver hoy y ve directo a lo importante.',
    'homeAstralPanelCaption': 'Tríada, tránsitos y rueda natal.',
    'homeNumerologyPanelCaption': 'Ciclos, sendero y radar del momento.',
    'homeDailyPulseTitle': 'Lo que marca tu día',
    'homeDailyPulseSubtitle':
        'Mira tu carta del día y la energía del momento en una sola vista.',
    'homeNextSessionSubtitle': 'El seguimiento completo se hace desde Agenda.',
    'homeAstroRadarLabel': 'Radar astral',
    'homeAstroReadyTitle': 'Tu tríada y el cielo de hoy',
    'homeAstroFallbackTitle': 'Inicio orientado a tu contexto real',
    'homeAstralOverviewFallback':
        'Aquí puedes ver Sol, Luna, Ascendente y el tránsito más activo apenas tu carta esté completa.',
    'homeAstralLoading': 'Leyendo tu carta y los tránsitos del momento.',
    'completeAstralChart': 'Completar carta astral',
    'astroTransitActive': 'Tránsito activo',
    'astroUpcomingEclipse': 'Eclipse a seguir',
    'astroFallbackErrorTitle': 'No pude leer tu cielo actual',
    'astroFallbackReadyTitle': 'Tu radar astral está listo para activarse',
    'astroFallbackCompleteTitle': 'Completa tu tríada personal',
    'astroFallbackErrorBody':
        'Hubo un problema al calcular tránsitos y eclipses. Puedes reabrir tu carta para refrescar el cálculo.',
    'astroFallbackPartialBody':
        'Con tus datos actuales puedo darte contexto parcial, pero la hora exacta mejora mucho la lectura de ascendente y tránsitos.',
    'astroFallbackCompleteBody':
        'Agrega fecha, hora y lugar de nacimiento para ver tu Sol, Luna, Ascendente, tránsito activo y eclipse cercano en esta pantalla.',
    'arcanaOfDay': 'Arcano de hoy',
    'tarotTapCardHint': 'Toca la carta para verla completa y leer tu mensaje.',
    'tarotHeroSummary':
        'Lectura breve del día, una acción concreta y acceso rápido para profundizar sin ruido.',
    'tarotHeroMessageTitle': 'Mensaje central',
    'tarotHeroActionTitle': 'Movimiento sugerido',
    'tarotReadingsCount': '{count} lecturas',
    'tarotSpecialistsCount': '{count} especialistas',
    'tarotCoursesCount': '{count} cursos',
    'tarotScheduleReading': 'Reservar lectura',
    'tarotOpenSpread': 'Tirada completa diaria',
    'tarotDailySpreadScreenSubtitle':
        'Tres cartas para leer el día por capas, con un recorrido más visual y una interpretación que cambia al deslizar.',
    'tarotDailySpreadScreenHint':
        'Desliza a izquierda o derecha para hacer girar las cartas y actualizar la lectura debajo.',
    'tarotCombinedReadingTitle': 'Lectura conjunta',
    'tarotDailySequenceTitle': 'Secuencia del día',
    'tarotCardOfCount': 'Carta {current} de {total}',
    'tarotOpenCardDetail': 'Ver detalle completo',
    'tarotOverviewNextReading': 'Próxima lectura',
    'tarotSuggestedSpecialists': 'Especialistas sugeridos',
    'tarotRecommendedCourses': 'Cursos recomendados',
    'tarotDoSpread': 'Hacer tirada',
    'tarotDrawAgain': 'Tirar de nuevo',
    'tarotNoSpreadTitle': 'Todavía no tiraste las cartas',
    'tarotNoSpreadSubtitle':
        'Haz la tirada para ver tres posiciones claras y una acción práctica.',
    'tarotNoReadingsTitle': 'No hay lecturas cargadas',
    'tarotNoReadingsSubtitle':
        'Cuando el catálogo de tarot esté disponible aparecerá aquí.',
    'tarotWhoGuidesYou': 'Quién te acompaña',
    'tarotTodayRitual': 'Ritual de hoy',
    'tarotRitualAnchor':
        'Usa la energía de {card} como ancla antes de una lectura o una decisión importante.',
    'tarotRitualStepBreathe': 'Respira 3 veces',
    'tarotRitualStepQuestion': 'Formula una pregunta',
    'tarotRitualStepIntuition': 'Anota una intuición',
    'tarotBookGuidedReading': 'Reservar lectura guiada',
    'tarotMenuOverview': 'Panorama',
    'tarotMenuSpread': 'Tirada',
    'tarotMenuReadings': 'Lecturas',
    'tarotMenuRitual': 'Ritual',
    'tarotBook': 'Reservar',
    'tarotMovement': 'Movimiento: {value}',
    'tarotGentleKey': 'Clave amable: {value}',
    'tarotGentleInterpretation': 'Interpretación amable',
    'tarotMoreAboutCard': 'Más sobre esta carta',
    'tarotWhatAsksToday': 'Lo que te pide hoy',
    'tarotWhatAvoidToday': 'Lo que conviene evitar',
    'tarotGuidingQuestion': 'Pregunta guía',
    'tarotRefreshAtMidnight': 'Se renueva a las 00:00',
    'tapToOpen': 'Toca para abrir',
    'tarotDailyReadingTitle': 'Lectura diaria',
    'tarotDailyReadingSubtitle':
        'Una tirada breve para ordenar el tono del día y aterrizarlo en una acción.',
    'tarotDailyReadingPrompt':
        'Respira, piensa en tu prioridad de hoy y deja que tres cartas bajen el mensaje.',
    'tarotPosRelease': 'Lo que sueltas',
    'tarotPosDayPulse': 'Pulso del día',
    'tarotPosConsciousAction': 'Acción consciente',
    'tarotClarityTitle': 'Claridad',
    'tarotClaritySubtitle':
        'Ideal cuando hay ruido mental y necesitas ordenar una decisión.',
    'tarotClarityPrompt':
        'Formula una sola pregunta y deja que la tirada te muestre raíz, nudo y salida.',
    'tarotPosRoot': 'Raíz',
    'tarotPosCurrentKnot': 'Nudo actual',
    'tarotPosNextStep': 'Siguiente paso',
    'tarotBondsTitle': 'Vínculos',
    'tarotBondsSubtitle':
        'Para revisar deseo, reciprocidad y el gesto más honesto.',
    'tarotBondsPrompt':
        'Piensa en el vínculo que te mueve hoy y mira qué está pidiendo de ti.',
    'tarotPosFeeling': 'Lo que sientes',
    'tarotPosActivated': 'Lo que se activa',
    'tarotPosHealthyMovement': 'Movimiento sano',
    'tarotWorkMoneyTitle': 'Trabajo y dinero',
    'tarotWorkMoneySubtitle':
        'Enfoca la tirada en timing, dirección y decisiones concretas.',
    'tarotWorkMoneyPrompt':
        'Baja la consulta a una sola prioridad y usa la lectura para decidir con menos dispersión.',
    'tarotPosAvailableEnergy': 'Energía disponible',
    'tarotPosRisk': 'Riesgo',
    'tarotPosSmartBet': 'Apuesta inteligente',
  },
  'en': {
    'loadingRestoringTitle': 'Restoring your space',
    'loadingRestoringSubtitle':
        'Recovering your session, profile, and saved settings.',
    'loadingPreparingAccessTitle': 'Preparing access',
    'loadingPreparingAccessSubtitle': 'Rebuilding the verification flow.',
    'loadingPreparingSpaceTitle': 'Preparing your space',
    'loadingPreparingSpaceSubtitle':
        'We are loading your data, bookings, and personalized content.',
    'loadingRetry': 'Retry',
    'loadingAppTitle': 'Loading Lo Renaciente',
    'loadingAppSubtitle': 'Adjusting your personalized experience.',
    'navHome': 'Home',
    'navTarot': 'Tarot',
    'navShop': 'Shop',
    'navCourses': 'Library',
    'navBookings': 'Appointments',
    'navProfile': 'Profile',
    'authPhoneTitle': 'Enter your phone',
    'authPhoneSubtitle':
        'Select your country, type your number, and we will send you a security code by SMS.',
    'country': 'Country',
    'phoneNumber': 'Phone number',
    'sendCode': 'Send code',
    'authOtpTitle': 'Verify your code',
    'authOtpSubtitle':
        'Enter the code sent to {phone}. In development we show the real OTP so you can move faster.',
    'demoCode': 'Demo code',
    'securityCode': 'Security code',
    'verifyCode': 'Verify code',
    'changeNumber': 'Change number',
    'profileTitle': 'Profile',
    'currentPlan': 'Current plan: {plan}',
    'email': 'Email',
    'noEmail': 'No email registered',
    'location': 'Location',
    'noLocation': 'No location registered',
    'natalData': 'Natal data',
    'utcOffset': 'UTC offset: {offset}',
    'coords': 'Coordinates: {lat}, {lng}',
    'editProfile': 'Edit profile',
    'astralChart': 'Astral chart',
    'preferences': 'Preferences',
    'subscription': 'Subscription',
    'status': 'Status: {status}',
    'billing': 'Billing: {provider}',
    'renewsOn': 'Renews on {date}',
    'payments': 'Monetization and payments',
    'consultations': 'Consultations: {provider}',
    'premium': 'Premium: {provider}',
    'manageSubscription': 'Manage subscription',
    'privacyData': 'Privacy and data',
    'support': 'Support',
    'activeUsers': 'Active users: {count}',
    'language': 'Language',
    'languageDescription': 'Change the visible language of the app.',
    'chooseLanguage': 'Choose language',
    'homePlanChip': 'Plan {plan}',
    'ritual': 'Ritual: {ritual}',
    'intensity': 'Intensity {value}',
    'homeAstralTitle': 'Astral Chart',
    'homeAstralDescription':
        'Generate your chart with Sun, Moon, Ascendant, houses, aspects, transits, and returns on Lo Renaciente’s own engine.',
    'natalReady': 'Natal data ready',
    'completeNatalData': 'Complete natal data',
    'missingUtc': 'UTC offset missing',
    'openAstralChart': 'Open astral chart',
    'homeNumerologyTitle': 'Numerology',
    'homeNumerologyDescription':
        'Calculate life path, expression, soul urge, personality, pinnacles, challenges, and personal cycles.',
    'lifePath': 'Life path',
    'personalYear': 'Personal year',
    'birthName': 'Birth name',
    'openNumerology': 'Open numerology',
    'homeTarotTitle': 'Tarot Portal',
    'homeTarotDescription':
        'Enter your tarot space with card of the day, readings, specialists, courses, and recommended ritual.',
    'cardOfDay': 'Card of the day',
    'readings': 'Readings',
    'specialists': 'Specialists',
    'openTarot': 'Open tarot',
    'quickAccess': 'Quick access',
    'nextSession': 'Next session',
    'view': 'View',
    'subscriptionStatus': 'Subscription status',
    'subscriptionActive': 'Your {plan} plan is active and renews on {date}.',
    'subscriptionInactive':
        'You are on {plan}. You can unlock courses, chat, and advanced specialists.',
    'productArchitecture': 'Product architecture note',
    'homeDiscoverTitle': 'Discover your day',
    'homeDiscoverSubtitle':
        'Choose what you want to see today and jump straight to what matters.',
    'homeAstralPanelCaption': 'Triad, transits, and natal wheel.',
    'homeNumerologyPanelCaption':
        'Cycles, life path, and the radar of the moment.',
    'homeDailyPulseTitle': 'What shapes your day',
    'homeDailyPulseSubtitle':
        'See your card of the day and the current energy in one place.',
    'homeNextSessionSubtitle': 'Full follow-up happens from Bookings.',
    'homeAstroRadarLabel': 'Astral radar',
    'homeAstroReadyTitle': 'Your triad and today’s sky',
    'homeAstroFallbackTitle': 'A start guided by your real context',
    'homeAstralOverviewFallback':
        'Here you can see your Sun, Moon, Ascendant, and the strongest transit as soon as your chart is complete.',
    'homeAstralLoading': 'Reading your chart and current transits.',
    'completeAstralChart': 'Complete astral chart',
    'astroTransitActive': 'Active transit',
    'astroUpcomingEclipse': 'Upcoming eclipse',
    'astroFallbackErrorTitle': 'I could not read your current sky',
    'astroFallbackReadyTitle': 'Your astral radar is ready to activate',
    'astroFallbackCompleteTitle': 'Complete your personal triad',
    'astroFallbackErrorBody':
        'There was a problem calculating transits and eclipses. You can reopen your chart to refresh the calculation.',
    'astroFallbackPartialBody':
        'With your current data I can give you partial context, but the exact birth time greatly improves the ascendant and transit reading.',
    'astroFallbackCompleteBody':
        'Add your birth date, time, and place to see your Sun, Moon, Ascendant, active transit, and nearby eclipse on this screen.',
    'arcanaOfDay': 'Today’s arcana',
    'tarotTapCardHint':
        'Tap the card to view it in full and read your message.',
    'tarotHeroSummary':
        'A short reading for today, one concrete action, and quick access to go deeper without the noise.',
    'tarotHeroMessageTitle': 'Core message',
    'tarotHeroActionTitle': 'Suggested move',
    'tarotReadingsCount': '{count} readings',
    'tarotSpecialistsCount': '{count} specialists',
    'tarotCoursesCount': '{count} courses',
    'tarotScheduleReading': 'Book reading',
    'tarotOpenSpread': 'Full daily spread',
    'tarotDailySpreadScreenSubtitle':
        'Three cards to read the day in layers, with a more visual journey and an interpretation that changes as you swipe.',
    'tarotDailySpreadScreenHint':
        'Swipe left or right to rotate the cards and update the reading below.',
    'tarotCombinedReadingTitle': 'Combined reading',
    'tarotDailySequenceTitle': 'Today\'s sequence',
    'tarotCardOfCount': 'Card {current} of {total}',
    'tarotOpenCardDetail': 'View full detail',
    'tarotOverviewNextReading': 'Next reading',
    'tarotSuggestedSpecialists': 'Suggested specialists',
    'tarotRecommendedCourses': 'Recommended courses',
    'tarotDoSpread': 'Draw spread',
    'tarotDrawAgain': 'Draw again',
    'tarotNoSpreadTitle': 'You have not drawn the cards yet',
    'tarotNoSpreadSubtitle':
        'Draw the spread to reveal three clear positions and one practical action.',
    'tarotNoReadingsTitle': 'No readings loaded',
    'tarotNoReadingsSubtitle':
        'When the tarot catalog is available, it will appear here.',
    'tarotWhoGuidesYou': 'Who guides you',
    'tarotTodayRitual': 'Today’s ritual',
    'tarotRitualAnchor':
        'Use the energy of {card} as an anchor before a reading or an important decision.',
    'tarotRitualStepBreathe': 'Breathe 3 times',
    'tarotRitualStepQuestion': 'Shape one question',
    'tarotRitualStepIntuition': 'Write down one intuition',
    'tarotBookGuidedReading': 'Book guided reading',
    'tarotMenuOverview': 'Overview',
    'tarotMenuSpread': 'Spread',
    'tarotMenuReadings': 'Readings',
    'tarotMenuRitual': 'Ritual',
    'tarotBook': 'Book',
    'tarotMovement': 'Movement: {value}',
    'tarotGentleKey': 'Gentle key: {value}',
    'tarotGentleInterpretation': 'Gentle interpretation',
    'tarotMoreAboutCard': 'More about this card',
    'tarotWhatAsksToday': 'What it asks of you today',
    'tarotWhatAvoidToday': 'What to avoid today',
    'tarotGuidingQuestion': 'Guiding question',
    'tarotRefreshAtMidnight': 'Refreshes at 00:00',
    'tapToOpen': 'Tap to open',
    'tarotDailyReadingTitle': 'Daily reading',
    'tarotDailyReadingSubtitle':
        'A short spread to organize the tone of the day and ground it in action.',
    'tarotDailyReadingPrompt':
        'Breathe, think about your priority today, and let three cards bring the message down.',
    'tarotPosRelease': 'What you release',
    'tarotPosDayPulse': 'Pulse of the day',
    'tarotPosConsciousAction': 'Conscious action',
    'tarotClarityTitle': 'Clarity',
    'tarotClaritySubtitle':
        'Ideal when there is mental noise and you need to organize a decision.',
    'tarotClarityPrompt':
        'Ask one clear question and let the spread show you root, knot, and way forward.',
    'tarotPosRoot': 'Root',
    'tarotPosCurrentKnot': 'Current knot',
    'tarotPosNextStep': 'Next step',
    'tarotBondsTitle': 'Relationships',
    'tarotBondsSubtitle':
        'To review desire, reciprocity, and the most honest gesture.',
    'tarotBondsPrompt':
        'Think about the bond moving you today and see what it is asking from you.',
    'tarotPosFeeling': 'What you feel',
    'tarotPosActivated': 'What is activated',
    'tarotPosHealthyMovement': 'Healthy movement',
    'tarotWorkMoneyTitle': 'Work and money',
    'tarotWorkMoneySubtitle':
        'Focus the spread on timing, direction, and concrete decisions.',
    'tarotWorkMoneyPrompt':
        'Reduce the question to one priority and use the reading to decide with less dispersion.',
    'tarotPosAvailableEnergy': 'Available energy',
    'tarotPosRisk': 'Risk',
    'tarotPosSmartBet': 'Smart bet',
  },
  'pt': {
    'loadingRestoringTitle': 'Restaurando seu espaço',
    'loadingRestoringSubtitle':
        'Recuperando sua sessão, perfil e configurações salvas.',
    'loadingPreparingAccessTitle': 'Preparando acesso',
    'loadingPreparingAccessSubtitle': 'Reconstruindo o fluxo de verificação.',
    'loadingPreparingSpaceTitle': 'Preparando seu espaço',
    'loadingPreparingSpaceSubtitle':
        'Estamos carregando seus dados, agenda e conteúdo personalizado.',
    'loadingRetry': 'Tentar novamente',
    'loadingAppTitle': 'Carregando Lo Renaciente',
    'loadingAppSubtitle': 'Ajustando sua experiência personalizada.',
    'navHome': 'Início',
    'navTarot': 'Tarô',
    'navShop': 'Shop',
    'navCourses': 'Biblioteca',
    'navBookings': 'Consultas',
    'navProfile': 'Perfil',
    'authPhoneTitle': 'Digite seu telefone',
    'authPhoneSubtitle':
        'Selecione seu país, escreva seu número e enviaremos um código de segurança por SMS.',
    'country': 'País',
    'phoneNumber': 'Número de telefone',
    'sendCode': 'Enviar código',
    'authOtpTitle': 'Verifique seu código',
    'authOtpSubtitle':
        'Digite o código enviado para {phone}. Em desenvolvimento mostramos o OTP real para avançar mais rápido.',
    'demoCode': 'Código demo',
    'securityCode': 'Código de segurança',
    'verifyCode': 'Verificar código',
    'changeNumber': 'Trocar número',
    'profileTitle': 'Perfil',
    'currentPlan': 'Plano atual: {plan}',
    'email': 'Email',
    'noEmail': 'Sem email registrado',
    'location': 'Localização',
    'noLocation': 'Sem localização registrada',
    'natalData': 'Dados natais',
    'utcOffset': 'UTC offset: {offset}',
    'coords': 'Coordenadas: {lat}, {lng}',
    'editProfile': 'Editar perfil',
    'astralChart': 'Mapa astral',
    'preferences': 'Preferências',
    'subscription': 'Assinatura',
    'status': 'Status: {status}',
    'billing': 'Cobrança: {provider}',
    'renewsOn': 'Renova em {date}',
    'payments': 'Monetização e pagamentos',
    'consultations': 'Consultas: {provider}',
    'premium': 'Premium: {provider}',
    'manageSubscription': 'Gerenciar assinatura',
    'privacyData': 'Privacidade e dados',
    'support': 'Suporte',
    'activeUsers': 'Usuários ativos: {count}',
    'language': 'Idioma',
    'languageDescription': 'Altere o idioma visível do app.',
    'chooseLanguage': 'Escolher idioma',
    'homePlanChip': 'Plano {plan}',
    'ritual': 'Ritual: {ritual}',
    'intensity': 'Intensidade {value}',
    'homeAstralTitle': 'Mapa Astral',
    'homeAstralDescription':
        'Gere seu mapa com Sol, Lua, Ascendente, casas, aspectos, trânsitos e revoluções no motor próprio do Lo Renaciente.',
    'natalReady': 'Dados natais prontos',
    'completeNatalData': 'Completar dados natais',
    'missingUtc': 'Falta UTC offset',
    'openAstralChart': 'Abrir mapa astral',
    'homeNumerologyTitle': 'Numerologia',
    'homeNumerologyDescription':
        'Calcule caminho de vida, expressão, alma, personalidade, pináculos, desafios e ciclos pessoais.',
    'lifePath': 'Caminho de vida',
    'personalYear': 'Ano pessoal',
    'birthName': 'Nome natal',
    'openNumerology': 'Abrir numerologia',
    'homeTarotTitle': 'Portal Tarô',
    'homeTarotDescription':
        'Entre no seu espaço de tarô com carta do dia, leituras, especialistas, biblioteca e ritual recomendado.',
    'cardOfDay': 'Carta do dia',
    'readings': 'Leituras',
    'specialists': 'Especialistas',
    'openTarot': 'Abrir tarô',
    'quickAccess': 'Acessos rápidos',
    'nextSession': 'Próxima consulta',
    'view': 'Ver',
    'subscriptionStatus': 'Status da assinatura',
    'subscriptionActive': 'Seu plano {plan} está ativo e renova em {date}.',
    'subscriptionInactive':
        'Você está no plano {plan}. Pode desbloquear biblioteca, chat e especialistas avançados.',
    'productArchitecture': 'Nota de arquitetura do produto',
    'homeDiscoverTitle': 'Descubra seu dia',
    'homeDiscoverSubtitle':
        'Escolha o que quer ver hoje e vá direto ao que importa.',
    'homeAstralPanelCaption': 'Tríade, trânsitos e roda natal.',
    'homeNumerologyPanelCaption': 'Ciclos, caminho de vida e radar do momento.',
    'homeDailyPulseTitle': 'O que marca seu dia',
    'homeDailyPulseSubtitle':
        'Veja sua carta do dia e a energia do momento em uma só visão.',
    'homeNextSessionSubtitle':
        'O acompanhamento completo acontece pela Agenda.',
    'homeAstroRadarLabel': 'Radar astral',
    'homeAstroReadyTitle': 'Sua tríade e o céu de hoje',
    'homeAstroFallbackTitle': 'Início guiado pelo seu contexto real',
    'homeAstralOverviewFallback':
        'Aqui você pode ver Sol, Lua, Ascendente e o trânsito mais ativo assim que seu mapa estiver completo.',
    'homeAstralLoading': 'Lendo seu mapa e os trânsitos do momento.',
    'completeAstralChart': 'Completar mapa astral',
    'astroTransitActive': 'Trânsito ativo',
    'astroUpcomingEclipse': 'Eclipse a acompanhar',
    'astroFallbackErrorTitle': 'Não consegui ler seu céu atual',
    'astroFallbackReadyTitle': 'Seu radar astral está pronto para ativar',
    'astroFallbackCompleteTitle': 'Complete sua tríade pessoal',
    'astroFallbackErrorBody':
        'Houve um problema ao calcular trânsitos e eclipses. Você pode reabrir seu mapa para atualizar o cálculo.',
    'astroFallbackPartialBody':
        'Com seus dados atuais posso dar um contexto parcial, mas a hora exata melhora muito a leitura do ascendente e dos trânsitos.',
    'astroFallbackCompleteBody':
        'Adicione data, hora e local de nascimento para ver Sol, Lua, Ascendente, trânsito ativo e eclipse próximo nesta tela.',
    'arcanaOfDay': 'Arcano do dia',
    'tarotTapCardHint': 'Toque na carta para vê-la inteira e ler sua mensagem.',
    'tarotHeroSummary':
        'Leitura breve do dia, uma ação concreta e acesso rápido para aprofundar sem ruído.',
    'tarotHeroMessageTitle': 'Mensagem central',
    'tarotHeroActionTitle': 'Movimento sugerido',
    'tarotReadingsCount': '{count} leituras',
    'tarotSpecialistsCount': '{count} especialistas',
    'tarotCoursesCount': '{count} cursos',
    'tarotScheduleReading': 'Reservar leitura',
    'tarotOpenSpread': 'Tiragem completa diária',
    'tarotDailySpreadScreenSubtitle':
        'Três cartas para ler o dia em camadas, com um percurso mais visual e uma interpretação que muda ao deslizar.',
    'tarotDailySpreadScreenHint':
        'Deslize para a esquerda ou direita para girar as cartas e atualizar a leitura abaixo.',
    'tarotCombinedReadingTitle': 'Leitura conjunta',
    'tarotDailySequenceTitle': 'Sequência do dia',
    'tarotCardOfCount': 'Carta {current} de {total}',
    'tarotOpenCardDetail': 'Ver detalhe completo',
    'tarotOverviewNextReading': 'Próxima leitura',
    'tarotSuggestedSpecialists': 'Especialistas sugeridos',
    'tarotRecommendedCourses': 'Cursos recomendados',
    'tarotDoSpread': 'Fazer tiragem',
    'tarotDrawAgain': 'Tirar novamente',
    'tarotNoSpreadTitle': 'Você ainda não tirou as cartas',
    'tarotNoSpreadSubtitle':
        'Faça a tiragem para ver três posições claras e uma ação prática.',
    'tarotNoReadingsTitle': 'Não há leituras carregadas',
    'tarotNoReadingsSubtitle':
        'Quando o catálogo de tarô estiver disponível, ele aparecerá aqui.',
    'tarotWhoGuidesYou': 'Quem acompanha você',
    'tarotTodayRitual': 'Ritual de hoje',
    'tarotRitualAnchor':
        'Use a energia de {card} como âncora antes de uma leitura ou de uma decisão importante.',
    'tarotRitualStepBreathe': 'Respire 3 vezes',
    'tarotRitualStepQuestion': 'Formule uma pergunta',
    'tarotRitualStepIntuition': 'Anote uma intuição',
    'tarotBookGuidedReading': 'Reservar leitura guiada',
    'tarotMenuOverview': 'Panorama',
    'tarotMenuSpread': 'Tiragem',
    'tarotMenuReadings': 'Leituras',
    'tarotMenuRitual': 'Ritual',
    'tarotBook': 'Reservar',
    'tarotMovement': 'Movimento: {value}',
    'tarotGentleKey': 'Chave gentil: {value}',
    'tarotGentleInterpretation': 'Interpretação gentil',
    'tarotMoreAboutCard': 'Mais sobre esta carta',
    'tarotWhatAsksToday': 'O que ela pede hoje',
    'tarotWhatAvoidToday': 'O que convém evitar',
    'tarotGuidingQuestion': 'Pergunta-guia',
    'tarotRefreshAtMidnight': 'Renova às 00:00',
    'tapToOpen': 'Toque para abrir',
    'tarotDailyReadingTitle': 'Leitura diária',
    'tarotDailyReadingSubtitle':
        'Uma tiragem breve para organizar o tom do dia e levá-lo para uma ação.',
    'tarotDailyReadingPrompt':
        'Respire, pense na sua prioridade de hoje e deixe que três cartas tragam a mensagem.',
    'tarotPosRelease': 'O que você solta',
    'tarotPosDayPulse': 'Pulso do dia',
    'tarotPosConsciousAction': 'Ação consciente',
    'tarotClarityTitle': 'Clareza',
    'tarotClaritySubtitle':
        'Ideal quando há ruído mental e você precisa organizar uma decisão.',
    'tarotClarityPrompt':
        'Formule uma única pergunta e deixe que a tiragem mostre raiz, nó e saída.',
    'tarotPosRoot': 'Raiz',
    'tarotPosCurrentKnot': 'Nó atual',
    'tarotPosNextStep': 'Próximo passo',
    'tarotBondsTitle': 'Vínculos',
    'tarotBondsSubtitle':
        'Para revisar desejo, reciprocidade e o gesto mais honesto.',
    'tarotBondsPrompt':
        'Pense no vínculo que mexe com você hoje e veja o que ele está pedindo.',
    'tarotPosFeeling': 'O que você sente',
    'tarotPosActivated': 'O que se ativa',
    'tarotPosHealthyMovement': 'Movimento saudável',
    'tarotWorkMoneyTitle': 'Trabalho e dinheiro',
    'tarotWorkMoneySubtitle':
        'Foque a tiragem em timing, direção e decisões concretas.',
    'tarotWorkMoneyPrompt':
        'Reduza a consulta a uma única prioridade e use a leitura para decidir com menos dispersão.',
    'tarotPosAvailableEnergy': 'Energia disponível',
    'tarotPosRisk': 'Risco',
    'tarotPosSmartBet': 'Aposta inteligente',
  },
  'fr': {
    'loadingRestoringTitle': 'Restauration de votre espace',
    'loadingRestoringSubtitle':
        'Récupération de votre session, profil et paramètres enregistrés.',
    'loadingPreparingAccessTitle': 'Préparation de l’accès',
    'loadingPreparingAccessSubtitle': 'Reconstruction du flux de vérification.',
    'loadingPreparingSpaceTitle': 'Préparation de votre espace',
    'loadingPreparingSpaceSubtitle':
        'Chargement de vos données, rendez-vous et contenu personnalisé.',
    'loadingRetry': 'Réessayer',
    'loadingAppTitle': 'Chargement de Lo Renaciente',
    'loadingAppSubtitle': 'Ajustement de votre expérience personnalisée.',
    'navHome': 'Accueil',
    'navTarot': 'Tarot',
    'navShop': 'Shop',
    'navCourses': 'Bibliothèque',
    'navBookings': 'Rendez-vous',
    'navProfile': 'Profil',
    'authPhoneTitle': 'Entrez votre téléphone',
    'authPhoneSubtitle':
        'Sélectionnez votre pays, saisissez votre numéro et nous vous enverrons un code de sécurité par SMS.',
    'country': 'Pays',
    'phoneNumber': 'Numéro de téléphone',
    'sendCode': 'Envoyer le code',
    'authOtpTitle': 'Vérifiez votre code',
    'authOtpSubtitle':
        'Entrez le code envoyé à {phone}. En développement, nous affichons le vrai OTP pour avancer plus vite.',
    'demoCode': 'Code démo',
    'securityCode': 'Code de sécurité',
    'verifyCode': 'Vérifier le code',
    'changeNumber': 'Changer de numéro',
    'profileTitle': 'Profil',
    'currentPlan': 'Plan actuel : {plan}',
    'email': 'Email',
    'noEmail': 'Aucun email enregistré',
    'location': 'Emplacement',
    'noLocation': 'Aucun emplacement enregistré',
    'natalData': 'Données natales',
    'utcOffset': 'Décalage UTC : {offset}',
    'coords': 'Coord. : {lat}, {lng}',
    'editProfile': 'Modifier le profil',
    'astralChart': 'Carte astrale',
    'preferences': 'Préférences',
    'subscription': 'Abonnement',
    'status': 'Statut : {status}',
    'billing': 'Facturation : {provider}',
    'renewsOn': 'Renouvelle le {date}',
    'payments': 'Monétisation et paiements',
    'consultations': 'Consultations : {provider}',
    'premium': 'Premium : {provider}',
    'manageSubscription': 'Gérer l’abonnement',
    'privacyData': 'Confidentialité et données',
    'support': 'Support',
    'activeUsers': 'Utilisateurs actifs : {count}',
    'language': 'Langue',
    'languageDescription': 'Changez la langue visible de l’application.',
    'chooseLanguage': 'Choisir la langue',
    'homePlanChip': 'Plan {plan}',
    'ritual': 'Rituel : {ritual}',
    'intensity': 'Intensité {value}',
    'homeAstralTitle': 'Carte Astrale',
    'homeAstralDescription':
        'Générez votre carte avec Soleil, Lune, Ascendant, maisons, aspects, transits et révolutions sur le moteur propre de Lo Renaciente.',
    'natalReady': 'Données natales prêtes',
    'completeNatalData': 'Compléter les données natales',
    'missingUtc': 'Décalage UTC manquant',
    'openAstralChart': 'Ouvrir la carte astrale',
    'homeNumerologyTitle': 'Numérologie',
    'homeNumerologyDescription':
        'Calculez chemin de vie, expression, âme, personnalité, pinacles, défis et cycles personnels.',
    'lifePath': 'Chemin de vie',
    'personalYear': 'Année personnelle',
    'birthName': 'Nom natal',
    'openNumerology': 'Ouvrir la numérologie',
    'homeTarotTitle': 'Portail Tarot',
    'homeTarotDescription':
        'Entrez dans votre espace tarot avec carte du jour, lectures, spécialistes, bibliothèque et rituel recommandé.',
    'cardOfDay': 'Carte du jour',
    'readings': 'Lectures',
    'specialists': 'Spécialistes',
    'openTarot': 'Ouvrir le tarot',
    'quickAccess': 'Accès rapides',
    'nextSession': 'Prochaine consultation',
    'view': 'Voir',
    'subscriptionStatus': 'État de l’abonnement',
    'subscriptionActive':
        'Votre plan {plan} est actif et se renouvelle le {date}.',
    'subscriptionInactive':
        'Vous êtes sur {plan}. Vous pouvez débloquer bibliothèque, chat et spécialistes avancés.',
    'productArchitecture': 'Note d’architecture du produit',
    'homeDiscoverTitle': 'Découvrez votre journée',
    'homeDiscoverSubtitle':
        'Choisissez ce que vous voulez voir aujourd’hui et allez droit à l’essentiel.',
    'homeAstralPanelCaption': 'Triade, transits et roue natale.',
    'homeNumerologyPanelCaption': 'Cycles, chemin de vie et radar du moment.',
    'homeDailyPulseTitle': 'Ce qui marque votre journée',
    'homeDailyPulseSubtitle':
        'Voyez votre carte du jour et l’énergie du moment au même endroit.',
    'homeNextSessionSubtitle': 'Le suivi complet se fait depuis l’Agenda.',
    'homeAstroRadarLabel': 'Radar astral',
    'homeAstroReadyTitle': 'Votre triade et le ciel du jour',
    'homeAstroFallbackTitle': 'Un départ ancré dans votre contexte réel',
    'homeAstralOverviewFallback':
        'Ici, vous pourrez voir Soleil, Lune, Ascendant et le transit le plus actif dès que votre carte sera complète.',
    'homeAstralLoading': 'Lecture de votre carte et des transits du moment.',
    'completeAstralChart': 'Compléter la carte astrale',
    'astroTransitActive': 'Transit actif',
    'astroUpcomingEclipse': 'Éclipse à suivre',
    'astroFallbackErrorTitle': 'Je n’ai pas pu lire votre ciel actuel',
    'astroFallbackReadyTitle': 'Votre radar astral est prêt à s’activer',
    'astroFallbackCompleteTitle': 'Complétez votre triade personnelle',
    'astroFallbackErrorBody':
        'Un problème est survenu lors du calcul des transits et des éclipses. Vous pouvez rouvrir votre carte pour relancer le calcul.',
    'astroFallbackPartialBody':
        'Avec vos données actuelles, je peux donner un contexte partiel, mais l’heure exacte améliore beaucoup la lecture de l’ascendant et des transits.',
    'astroFallbackCompleteBody':
        'Ajoutez date, heure et lieu de naissance pour voir votre Soleil, votre Lune, votre Ascendant, le transit actif et l’éclipse proche sur cet écran.',
    'arcanaOfDay': 'Arcane du jour',
    'tarotTapCardHint':
        'Touchez la carte pour la voir en entier et lire votre message.',
    'tarotHeroSummary':
        'Une lecture brève du jour, une action concrète et un accès rapide pour approfondir sans bruit.',
    'tarotHeroMessageTitle': 'Message central',
    'tarotHeroActionTitle': 'Mouvement suggéré',
    'tarotReadingsCount': '{count} lectures',
    'tarotSpecialistsCount': '{count} spécialistes',
    'tarotCoursesCount': '{count} cours',
    'tarotScheduleReading': 'Réserver une lecture',
    'tarotOpenSpread': 'Tirage quotidien complet',
    'tarotDailySpreadScreenSubtitle':
        'Trois cartes pour lire la journée par couches, avec un parcours plus visuel et une interprétation qui change au glissement.',
    'tarotDailySpreadScreenHint':
        'Glissez à gauche ou à droite pour faire tourner les cartes et mettre à jour la lecture en dessous.',
    'tarotCombinedReadingTitle': 'Lecture conjointe',
    'tarotDailySequenceTitle': 'Séquence du jour',
    'tarotCardOfCount': 'Carte {current} sur {total}',
    'tarotOpenCardDetail': 'Voir le détail complet',
    'tarotOverviewNextReading': 'Prochaine lecture',
    'tarotSuggestedSpecialists': 'Spécialistes suggérés',
    'tarotRecommendedCourses': 'Cours recommandés',
    'tarotDoSpread': 'Faire le tirage',
    'tarotDrawAgain': 'Tirer à nouveau',
    'tarotNoSpreadTitle': 'Vous n’avez pas encore tiré les cartes',
    'tarotNoSpreadSubtitle':
        'Faites le tirage pour voir trois positions claires et une action pratique.',
    'tarotNoReadingsTitle': 'Aucune lecture chargée',
    'tarotNoReadingsSubtitle':
        'Quand le catalogue tarot sera disponible, il apparaîtra ici.',
    'tarotWhoGuidesYou': 'Qui vous accompagne',
    'tarotTodayRitual': 'Rituel du jour',
    'tarotRitualAnchor':
        'Utilisez l’énergie de {card} comme ancre avant une lecture ou une décision importante.',
    'tarotRitualStepBreathe': 'Respirez 3 fois',
    'tarotRitualStepQuestion': 'Formulez une question',
    'tarotRitualStepIntuition': 'Notez une intuition',
    'tarotBookGuidedReading': 'Réserver une lecture guidée',
    'tarotMenuOverview': 'Panorama',
    'tarotMenuSpread': 'Tirage',
    'tarotMenuReadings': 'Lectures',
    'tarotMenuRitual': 'Rituel',
    'tarotBook': 'Réserver',
    'tarotMovement': 'Mouvement : {value}',
    'tarotGentleKey': 'Clé douce : {value}',
    'tarotGentleInterpretation': 'Interprétation douce',
    'tarotMoreAboutCard': 'Plus sur cette carte',
    'tarotWhatAsksToday': 'Ce qu’elle demande aujourd’hui',
    'tarotWhatAvoidToday': 'Ce qu’il vaut mieux éviter',
    'tarotGuidingQuestion': 'Question guide',
    'tarotRefreshAtMidnight': 'Se renouvelle à 00:00',
    'tapToOpen': 'Touchez pour ouvrir',
    'tarotDailyReadingTitle': 'Lecture quotidienne',
    'tarotDailyReadingSubtitle':
        'Un tirage bref pour ordonner le ton du jour et le traduire en action.',
    'tarotDailyReadingPrompt':
        'Respirez, pensez à votre priorité du jour et laissez trois cartes faire descendre le message.',
    'tarotPosRelease': 'Ce que vous lâchez',
    'tarotPosDayPulse': 'Pouls du jour',
    'tarotPosConsciousAction': 'Action consciente',
    'tarotClarityTitle': 'Clarté',
    'tarotClaritySubtitle':
        'Idéal quand le mental est bruyant et qu’il faut ordonner une décision.',
    'tarotClarityPrompt':
        'Formulez une seule question et laissez le tirage montrer racine, nœud et sortie.',
    'tarotPosRoot': 'Racine',
    'tarotPosCurrentKnot': 'Nœud actuel',
    'tarotPosNextStep': 'Étape suivante',
    'tarotBondsTitle': 'Liens',
    'tarotBondsSubtitle':
        'Pour revoir désir, réciprocité et geste le plus honnête.',
    'tarotBondsPrompt':
        'Pensez au lien qui vous traverse aujourd’hui et voyez ce qu’il vous demande.',
    'tarotPosFeeling': 'Ce que vous ressentez',
    'tarotPosActivated': 'Ce qui s’active',
    'tarotPosHealthyMovement': 'Mouvement sain',
    'tarotWorkMoneyTitle': 'Travail et argent',
    'tarotWorkMoneySubtitle':
        'Concentrez le tirage sur le timing, la direction et les décisions concrètes.',
    'tarotWorkMoneyPrompt':
        'Ramenez la question à une seule priorité et utilisez la lecture pour décider avec moins de dispersion.',
    'tarotPosAvailableEnergy': 'Énergie disponible',
    'tarotPosRisk': 'Risque',
    'tarotPosSmartBet': 'Pari intelligent',
  },
  'it': {
    'loadingRestoringTitle': 'Ripristino del tuo spazio',
    'loadingRestoringSubtitle':
        'Recupero della sessione, del profilo e delle impostazioni salvate.',
    'loadingPreparingAccessTitle': 'Preparazione dell’accesso',
    'loadingPreparingAccessSubtitle': 'Ricostruzione del flusso di verifica.',
    'loadingPreparingSpaceTitle': 'Preparazione del tuo spazio',
    'loadingPreparingSpaceSubtitle':
        'Stiamo caricando dati, agenda e contenuti personalizzati.',
    'loadingRetry': 'Riprova',
    'loadingAppTitle': 'Caricamento di Lo Renaciente',
    'loadingAppSubtitle': 'Stiamo adattando la tua esperienza personalizzata.',
    'navHome': 'Home',
    'navTarot': 'Tarocchi',
    'navShop': 'Shop',
    'navCourses': 'Biblioteca',
    'navBookings': 'Appuntamenti',
    'navProfile': 'Profilo',
    'authPhoneTitle': 'Inserisci il tuo telefono',
    'authPhoneSubtitle':
        'Seleziona il tuo paese, scrivi il numero e ti invieremo un codice di sicurezza via SMS.',
    'country': 'Paese',
    'phoneNumber': 'Numero di telefono',
    'sendCode': 'Invia codice',
    'authOtpTitle': 'Verifica il tuo codice',
    'authOtpSubtitle':
        'Inserisci il codice inviato a {phone}. In sviluppo mostriamo l’OTP reale per avanzare più velocemente.',
    'demoCode': 'Codice demo',
    'securityCode': 'Codice di sicurezza',
    'verifyCode': 'Verifica codice',
    'changeNumber': 'Cambia numero',
    'profileTitle': 'Profilo',
    'currentPlan': 'Piano attuale: {plan}',
    'email': 'Email',
    'noEmail': 'Nessuna email registrata',
    'location': 'Posizione',
    'noLocation': 'Nessuna posizione registrata',
    'natalData': 'Dati natali',
    'utcOffset': 'UTC offset: {offset}',
    'coords': 'Coord.: {lat}, {lng}',
    'editProfile': 'Modifica profilo',
    'astralChart': 'Carta astrale',
    'preferences': 'Preferenze',
    'subscription': 'Abbonamento',
    'status': 'Stato: {status}',
    'billing': 'Fatturazione: {provider}',
    'renewsOn': 'Rinnova il {date}',
    'payments': 'Monetizzazione e pagamenti',
    'consultations': 'Consulti: {provider}',
    'premium': 'Premium: {provider}',
    'manageSubscription': 'Gestisci abbonamento',
    'privacyData': 'Privacy e dati',
    'support': 'Supporto',
    'activeUsers': 'Utenti attivi: {count}',
    'language': 'Lingua',
    'languageDescription': 'Cambia la lingua visibile dell’app.',
    'chooseLanguage': 'Scegli lingua',
    'homePlanChip': 'Piano {plan}',
    'ritual': 'Rituale: {ritual}',
    'intensity': 'Intensità {value}',
    'homeAstralTitle': 'Carta Astrale',
    'homeAstralDescription':
        'Genera la tua carta con Sole, Luna, Ascendente, case, aspetti, transiti e rivoluzioni nel motore proprietario di Lo Renaciente.',
    'natalReady': 'Dati natali pronti',
    'completeNatalData': 'Completa dati natali',
    'missingUtc': 'Manca UTC offset',
    'openAstralChart': 'Apri carta astrale',
    'homeNumerologyTitle': 'Numerologia',
    'homeNumerologyDescription':
        'Calcola percorso di vita, espressione, anima, personalità, pinnacoli, sfide e cicli personali.',
    'lifePath': 'Percorso di vita',
    'personalYear': 'Anno personale',
    'birthName': 'Nome natale',
    'openNumerology': 'Apri numerologia',
    'homeTarotTitle': 'Portale Tarocchi',
    'homeTarotDescription':
        'Entra nel tuo spazio tarocchi con carta del giorno, letture, specialisti, biblioteca e rituale consigliato.',
    'cardOfDay': 'Carta del giorno',
    'readings': 'Letture',
    'specialists': 'Specialisti',
    'openTarot': 'Apri tarocchi',
    'quickAccess': 'Accessi rapidi',
    'nextSession': 'Prossima consulenza',
    'view': 'Vedi',
    'subscriptionStatus': 'Stato dell’abbonamento',
    'subscriptionActive':
        'Il tuo piano {plan} è attivo e si rinnova il {date}.',
    'subscriptionInactive':
        'Sei in {plan}. Puoi sbloccare biblioteca, chat e specialisti avanzati.',
    'productArchitecture': 'Nota di architettura del prodotto',
    'homeDiscoverTitle': 'Scopri la tua giornata',
    'homeDiscoverSubtitle':
        'Scegli cosa vuoi vedere oggi e vai dritto a ciò che conta.',
    'homeAstralPanelCaption': 'Triade, transiti e ruota natale.',
    'homeNumerologyPanelCaption':
        'Cicli, percorso di vita e radar del momento.',
    'homeDailyPulseTitle': 'Ciò che segna la tua giornata',
    'homeDailyPulseSubtitle':
        'Guarda la carta del giorno e l’energia del momento in un’unica vista.',
    'homeNextSessionSubtitle': 'Il monitoraggio completo avviene da Agenda.',
    'homeAstroRadarLabel': 'Radar astrale',
    'homeAstroReadyTitle': 'La tua triade e il cielo di oggi',
    'homeAstroFallbackTitle': 'Un inizio guidato dal tuo contesto reale',
    'homeAstralOverviewFallback':
        'Qui puoi vedere Sole, Luna, Ascendente e il transito più attivo appena la tua carta è completa.',
    'homeAstralLoading': 'Sto leggendo la tua carta e i transiti del momento.',
    'completeAstralChart': 'Completa carta astrale',
    'astroTransitActive': 'Transito attivo',
    'astroUpcomingEclipse': 'Eclissi da seguire',
    'astroFallbackErrorTitle':
        'Non sono riuscito a leggere il tuo cielo attuale',
    'astroFallbackReadyTitle': 'Il tuo radar astrale è pronto ad attivarsi',
    'astroFallbackCompleteTitle': 'Completa la tua triade personale',
    'astroFallbackErrorBody':
        'C’è stato un problema nel calcolo di transiti ed eclissi. Puoi riaprire la carta per aggiornare il calcolo.',
    'astroFallbackPartialBody':
        'Con i dati attuali posso offrirti un contesto parziale, ma l’ora esatta migliora molto la lettura di ascendente e transiti.',
    'astroFallbackCompleteBody':
        'Aggiungi data, ora e luogo di nascita per vedere Sole, Luna, Ascendente, transito attivo ed eclissi vicina in questa schermata.',
    'arcanaOfDay': 'Arcano del giorno',
    'tarotTapCardHint':
        'Tocca la carta per vederla completa e leggere il tuo messaggio.',
    'tarotHeroSummary':
        'Lettura breve del giorno, un’azione concreta e accesso rapido per approfondire senza rumore.',
    'tarotHeroMessageTitle': 'Messaggio centrale',
    'tarotHeroActionTitle': 'Movimento suggerito',
    'tarotReadingsCount': '{count} letture',
    'tarotSpecialistsCount': '{count} specialisti',
    'tarotCoursesCount': '{count} corsi',
    'tarotScheduleReading': 'Prenota lettura',
    'tarotOpenSpread': 'Stesa quotidiana completa',
    'tarotDailySpreadScreenSubtitle':
        'Tre carte per leggere la giornata per strati, con un percorso più visivo e un\'interpretazione che cambia mentre scorri.',
    'tarotDailySpreadScreenHint':
        'Scorri a sinistra o a destra per far ruotare le carte e aggiornare la lettura qui sotto.',
    'tarotCombinedReadingTitle': 'Lettura congiunta',
    'tarotDailySequenceTitle': 'Sequenza del giorno',
    'tarotCardOfCount': 'Carta {current} di {total}',
    'tarotOpenCardDetail': 'Vedi dettaglio completo',
    'tarotOverviewNextReading': 'Prossima lettura',
    'tarotSuggestedSpecialists': 'Specialisti consigliati',
    'tarotRecommendedCourses': 'Corsi consigliati',
    'tarotDoSpread': 'Fai la stesa',
    'tarotDrawAgain': 'Tira di nuovo',
    'tarotNoSpreadTitle': 'Non hai ancora tirato le carte',
    'tarotNoSpreadSubtitle':
        'Fai la stesa per vedere tre posizioni chiare e un’azione pratica.',
    'tarotNoReadingsTitle': 'Nessuna lettura caricata',
    'tarotNoReadingsSubtitle':
        'Quando il catalogo dei tarocchi sarà disponibile apparirà qui.',
    'tarotWhoGuidesYou': 'Chi ti accompagna',
    'tarotTodayRitual': 'Rituale di oggi',
    'tarotRitualAnchor':
        'Usa l’energia di {card} come ancora prima di una lettura o di una decisione importante.',
    'tarotRitualStepBreathe': 'Respira 3 volte',
    'tarotRitualStepQuestion': 'Formula una domanda',
    'tarotRitualStepIntuition': 'Annota un’intuizione',
    'tarotBookGuidedReading': 'Prenota lettura guidata',
    'tarotMenuOverview': 'Panoramica',
    'tarotMenuSpread': 'Stesa',
    'tarotMenuReadings': 'Letture',
    'tarotMenuRitual': 'Rituale',
    'tarotBook': 'Prenota',
    'tarotMovement': 'Movimento: {value}',
    'tarotGentleKey': 'Chiave gentile: {value}',
    'tarotGentleInterpretation': 'Interpretazione gentile',
    'tarotMoreAboutCard': 'Più su questa carta',
    'tarotWhatAsksToday': 'Ciò che chiede oggi',
    'tarotWhatAvoidToday': 'Ciò che conviene evitare',
    'tarotGuidingQuestion': 'Domanda guida',
    'tarotRefreshAtMidnight': 'Si rinnova alle 00:00',
    'tapToOpen': 'Tocca per aprire',
    'tarotDailyReadingTitle': 'Lettura quotidiana',
    'tarotDailyReadingSubtitle':
        'Una stesa breve per ordinare il tono della giornata e portarlo in un’azione.',
    'tarotDailyReadingPrompt':
        'Respira, pensa alla tua priorità di oggi e lascia che tre carte facciano scendere il messaggio.',
    'tarotPosRelease': 'Ciò che lasci andare',
    'tarotPosDayPulse': 'Polso del giorno',
    'tarotPosConsciousAction': 'Azione consapevole',
    'tarotClarityTitle': 'Chiarezza',
    'tarotClaritySubtitle':
        'Ideale quando c’è rumore mentale e hai bisogno di ordinare una decisione.',
    'tarotClarityPrompt':
        'Formula una sola domanda e lascia che la stesa mostri radice, nodo e uscita.',
    'tarotPosRoot': 'Radice',
    'tarotPosCurrentKnot': 'Nodo attuale',
    'tarotPosNextStep': 'Passo successivo',
    'tarotBondsTitle': 'Legami',
    'tarotBondsSubtitle':
        'Per rivedere desiderio, reciprocità e il gesto più onesto.',
    'tarotBondsPrompt':
        'Pensa al legame che oggi ti muove e guarda cosa ti sta chiedendo.',
    'tarotPosFeeling': 'Ciò che senti',
    'tarotPosActivated': 'Ciò che si attiva',
    'tarotPosHealthyMovement': 'Movimento sano',
    'tarotWorkMoneyTitle': 'Lavoro e denaro',
    'tarotWorkMoneySubtitle':
        'Concentra la stesa su timing, direzione e decisioni concrete.',
    'tarotWorkMoneyPrompt':
        'Riduci la domanda a una sola priorità e usa la lettura per decidere con meno dispersione.',
    'tarotPosAvailableEnergy': 'Energia disponibile',
    'tarotPosRisk': 'Rischio',
    'tarotPosSmartBet': 'Scommessa intelligente',
  },
  'de': {
    'loadingRestoringTitle': 'Dein Bereich wird wiederhergestellt',
    'loadingRestoringSubtitle':
        'Sitzung, Profil und gespeicherte Einstellungen werden geladen.',
    'loadingPreparingAccessTitle': 'Zugang wird vorbereitet',
    'loadingPreparingAccessSubtitle':
        'Der Verifizierungsablauf wird neu aufgebaut.',
    'loadingPreparingSpaceTitle': 'Dein Bereich wird vorbereitet',
    'loadingPreparingSpaceSubtitle':
        'Wir laden deine Daten, Termine und personalisierten Inhalte.',
    'loadingRetry': 'Erneut versuchen',
    'loadingAppTitle': 'Lo Renaciente wird geladen',
    'loadingAppSubtitle': 'Deine personalisierte Erfahrung wird angepasst.',
    'navHome': 'Start',
    'navTarot': 'Tarot',
    'navShop': 'Shop',
    'navCourses': 'Bibliothek',
    'navBookings': 'Termine',
    'navProfile': 'Profil',
    'authPhoneTitle': 'Telefon eingeben',
    'authPhoneSubtitle':
        'Wähle dein Land, gib deine Nummer ein und wir senden dir einen Sicherheitscode per SMS.',
    'country': 'Land',
    'phoneNumber': 'Telefonnummer',
    'sendCode': 'Code senden',
    'authOtpTitle': 'Code bestätigen',
    'authOtpSubtitle':
        'Gib den an {phone} gesendeten Code ein. In der Entwicklung zeigen wir das echte OTP, damit du schneller weiterkommst.',
    'demoCode': 'Demo-Code',
    'securityCode': 'Sicherheitscode',
    'verifyCode': 'Code bestätigen',
    'changeNumber': 'Nummer ändern',
    'profileTitle': 'Profil',
    'currentPlan': 'Aktueller Plan: {plan}',
    'email': 'E-Mail',
    'noEmail': 'Keine E-Mail registriert',
    'location': 'Standort',
    'noLocation': 'Kein Standort registriert',
    'natalData': 'Geburtsdaten',
    'utcOffset': 'UTC-Offset: {offset}',
    'coords': 'Koord.: {lat}, {lng}',
    'editProfile': 'Profil bearbeiten',
    'astralChart': 'Geburtshoroskop',
    'preferences': 'Einstellungen',
    'subscription': 'Abo',
    'status': 'Status: {status}',
    'billing': 'Abrechnung: {provider}',
    'renewsOn': 'Verlängert am {date}',
    'payments': 'Monetarisierung und Zahlungen',
    'consultations': 'Beratungen: {provider}',
    'premium': 'Premium: {provider}',
    'manageSubscription': 'Abo verwalten',
    'privacyData': 'Datenschutz und Daten',
    'support': 'Support',
    'activeUsers': 'Aktive Nutzer: {count}',
    'language': 'Sprache',
    'languageDescription': 'Ändere die sichtbare Sprache der App.',
    'chooseLanguage': 'Sprache wählen',
    'homePlanChip': 'Plan {plan}',
    'ritual': 'Ritual: {ritual}',
    'intensity': 'Intensität {value}',
    'homeAstralTitle': 'Horoskop',
    'homeAstralDescription':
        'Erstelle dein Horoskop mit Sonne, Mond, Aszendent, Häusern, Aspekten, Transiten und Wiederkehr auf der eigenen Engine von Lo Renaciente.',
    'natalReady': 'Geburtsdaten vollständig',
    'completeNatalData': 'Geburtsdaten ergänzen',
    'missingUtc': 'UTC-Offset fehlt',
    'openAstralChart': 'Horoskop öffnen',
    'homeNumerologyTitle': 'Numerologie',
    'homeNumerologyDescription':
        'Berechne Lebensweg, Ausdruck, Seele, Persönlichkeit, Gipfel, Herausforderungen und persönliche Zyklen.',
    'lifePath': 'Lebensweg',
    'personalYear': 'Persönliches Jahr',
    'birthName': 'Geburtsname',
    'openNumerology': 'Numerologie öffnen',
    'homeTarotTitle': 'Tarot-Portal',
    'homeTarotDescription':
        'Betritt deinen Tarot-Bereich mit Tageskarte, Legungen, Spezialisten, Bibliothek und empfohlenem Ritual.',
    'cardOfDay': 'Tageskarte',
    'readings': 'Legungen',
    'specialists': 'Spezialisten',
    'openTarot': 'Tarot öffnen',
    'quickAccess': 'Schnellzugriff',
    'nextSession': 'Nächste Beratung',
    'view': 'Ansehen',
    'subscriptionStatus': 'Abo-Status',
    'subscriptionActive':
        'Dein Plan {plan} ist aktiv und verlängert sich am {date}.',
    'subscriptionInactive':
        'Du nutzt {plan}. Du kannst Bibliothek, Chat und erweiterte Spezialisten freischalten.',
    'productArchitecture': 'Hinweis zur Produktarchitektur',
    'homeDiscoverTitle': 'Entdecke deinen Tag',
    'homeDiscoverSubtitle':
        'Wähle, was du heute sehen möchtest, und gehe direkt zum Wesentlichen.',
    'homeAstralPanelCaption': 'Triade, Transite und Geburtshoroskop-Rad.',
    'homeNumerologyPanelCaption':
        'Zyklen, Lebensweg und Radar des Augenblicks.',
    'homeDailyPulseTitle': 'Was deinen Tag prägt',
    'homeDailyPulseSubtitle':
        'Sieh deine Tageskarte und die aktuelle Energie an einem Ort.',
    'homeNextSessionSubtitle':
        'Die vollständige Nachverfolgung läuft über Termine.',
    'homeAstroRadarLabel': 'Astralradar',
    'homeAstroReadyTitle': 'Deine Triade und der Himmel von heute',
    'homeAstroFallbackTitle': 'Ein Start aus deinem echten Kontext heraus',
    'homeAstralOverviewFallback':
        'Hier kannst du Sonne, Mond, Aszendent und den aktivsten Transit sehen, sobald dein Horoskop vollständig ist.',
    'homeAstralLoading':
        'Dein Horoskop und die aktuellen Transite werden gelesen.',
    'completeAstralChart': 'Horoskop vervollständigen',
    'astroTransitActive': 'Aktiver Transit',
    'astroUpcomingEclipse': 'Bevorstehende Finsternis',
    'astroFallbackErrorTitle': 'Ich konnte deinen aktuellen Himmel nicht lesen',
    'astroFallbackReadyTitle': 'Dein Astralradar ist bereit zur Aktivierung',
    'astroFallbackCompleteTitle': 'Vervollständige deine persönliche Triade',
    'astroFallbackErrorBody':
        'Beim Berechnen von Transiten und Finsternissen ist ein Problem aufgetreten. Du kannst dein Horoskop erneut öffnen, um die Berechnung zu aktualisieren.',
    'astroFallbackPartialBody':
        'Mit deinen aktuellen Daten kann ich einen teilweisen Kontext geben, aber die genaue Geburtszeit verbessert die Deutung von Aszendent und Transiten deutlich.',
    'astroFallbackCompleteBody':
        'Füge Geburtsdatum, -zeit und -ort hinzu, um Sonne, Mond, Aszendent, aktiven Transit und nahe Finsternis auf diesem Bildschirm zu sehen.',
    'arcanaOfDay': 'Arkanum des Tages',
    'tarotTapCardHint':
        'Tippe auf die Karte, um sie vollständig zu sehen und deine Botschaft zu lesen.',
    'tarotHeroSummary':
        'Eine kurze Lesung für den Tag, eine konkrete Handlung und schneller Zugang, um ohne unnötiges Rauschen tiefer zu gehen.',
    'tarotHeroMessageTitle': 'Kernbotschaft',
    'tarotHeroActionTitle': 'Empfohlener Schritt',
    'tarotReadingsCount': '{count} Legungen',
    'tarotSpecialistsCount': '{count} Spezialisten',
    'tarotCoursesCount': '{count} Kurse',
    'tarotScheduleReading': 'Lesung buchen',
    'tarotOpenSpread': 'Komplette Tageslegung',
    'tarotDailySpreadScreenSubtitle':
        'Drei Karten, um den Tag in Schichten zu lesen, mit einem visuelleren Verlauf und einer Deutung, die sich beim Wischen verändert.',
    'tarotDailySpreadScreenHint':
        'Wische nach links oder rechts, um die Karten rotieren zu lassen und die Deutung darunter zu aktualisieren.',
    'tarotCombinedReadingTitle': 'Gemeinsame Deutung',
    'tarotDailySequenceTitle': 'Abfolge des Tages',
    'tarotCardOfCount': 'Karte {current} von {total}',
    'tarotOpenCardDetail': 'Volles Detail ansehen',
    'tarotOverviewNextReading': 'Nächste Lesung',
    'tarotSuggestedSpecialists': 'Empfohlene Spezialisten',
    'tarotRecommendedCourses': 'Empfohlene Kurse',
    'tarotDoSpread': 'Legung ziehen',
    'tarotDrawAgain': 'Erneut ziehen',
    'tarotNoSpreadTitle': 'Du hast die Karten noch nicht gezogen',
    'tarotNoSpreadSubtitle':
        'Ziehe die Legung, um drei klare Positionen und eine praktische Handlung zu sehen.',
    'tarotNoReadingsTitle': 'Keine Lesungen geladen',
    'tarotNoReadingsSubtitle':
        'Sobald der Tarot-Katalog verfügbar ist, erscheint er hier.',
    'tarotWhoGuidesYou': 'Wer dich begleitet',
    'tarotTodayRitual': 'Ritual des Tages',
    'tarotRitualAnchor':
        'Nutze die Energie von {card} als Anker vor einer Lesung oder einer wichtigen Entscheidung.',
    'tarotRitualStepBreathe': '3-mal atmen',
    'tarotRitualStepQuestion': 'Eine Frage formulieren',
    'tarotRitualStepIntuition': 'Eine Intuition notieren',
    'tarotBookGuidedReading': 'Geführte Lesung buchen',
    'tarotMenuOverview': 'Überblick',
    'tarotMenuSpread': 'Legung',
    'tarotMenuReadings': 'Lesungen',
    'tarotMenuRitual': 'Ritual',
    'tarotBook': 'Buchen',
    'tarotMovement': 'Bewegung: {value}',
    'tarotGentleKey': 'Sanfter Schlüssel: {value}',
    'tarotGentleInterpretation': 'Sanfte Deutung',
    'tarotMoreAboutCard': 'Mehr über diese Karte',
    'tarotWhatAsksToday': 'Was sie heute von dir verlangt',
    'tarotWhatAvoidToday': 'Was du besser vermeidest',
    'tarotGuidingQuestion': 'Leitfrage',
    'tarotRefreshAtMidnight': 'Erneuert sich um 00:00',
    'tapToOpen': 'Zum Öffnen tippen',
    'tarotDailyReadingTitle': 'Tageslesung',
    'tarotDailyReadingSubtitle':
        'Eine kurze Legung, um den Ton des Tages zu ordnen und in Handlung zu übersetzen.',
    'tarotDailyReadingPrompt':
        'Atme durch, denke an deine Priorität heute und lass drei Karten die Botschaft herunterbringen.',
    'tarotPosRelease': 'Was du loslässt',
    'tarotPosDayPulse': 'Puls des Tages',
    'tarotPosConsciousAction': 'Bewusste Handlung',
    'tarotClarityTitle': 'Klarheit',
    'tarotClaritySubtitle':
        'Ideal, wenn mentaler Lärm da ist und du eine Entscheidung ordnen musst.',
    'tarotClarityPrompt':
        'Stelle eine klare Frage und lass die Legung Wurzel, Knoten und nächsten Ausgang zeigen.',
    'tarotPosRoot': 'Wurzel',
    'tarotPosCurrentKnot': 'Aktueller Knoten',
    'tarotPosNextStep': 'Nächster Schritt',
    'tarotBondsTitle': 'Verbindungen',
    'tarotBondsSubtitle':
        'Um Wunsch, Gegenseitigkeit und die ehrlichste Geste zu prüfen.',
    'tarotBondsPrompt':
        'Denke an die Verbindung, die dich heute bewegt, und schau, was sie von dir verlangt.',
    'tarotPosFeeling': 'Was du fühlst',
    'tarotPosActivated': 'Was aktiviert wird',
    'tarotPosHealthyMovement': 'Gesunde Bewegung',
    'tarotWorkMoneyTitle': 'Arbeit und Geld',
    'tarotWorkMoneySubtitle':
        'Richte die Legung auf Timing, Richtung und konkrete Entscheidungen aus.',
    'tarotWorkMoneyPrompt':
        'Reduziere die Frage auf eine Priorität und nutze die Lesung, um mit weniger Zerstreuung zu entscheiden.',
    'tarotPosAvailableEnergy': 'Verfügbare Energie',
    'tarotPosRisk': 'Risiko',
    'tarotPosSmartBet': 'Kluger Einsatz',
  },
};
