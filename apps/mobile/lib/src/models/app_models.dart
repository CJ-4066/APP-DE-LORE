class AppBootstrap {
  AppBootstrap({
    required this.app,
    required this.user,
    required this.home,
    required this.plans,
    required this.subscription,
    required this.payments,
    required this.services,
    required this.specialists,
    required this.courses,
    required this.shop,
    required this.bookings,
    required this.admin,
  });

  final AppMeta app;
  final UserProfile user;
  final HomeData home;
  final List<Plan> plans;
  final SubscriptionData subscription;
  final PaymentsConfig payments;
  final List<ServiceOffer> services;
  final List<Specialist> specialists;
  final List<Course> courses;
  final ShopData shop;
  final List<Booking> bookings;
  final AdminSummary admin;

  factory AppBootstrap.fromJson(Map<String, dynamic> json) {
    return AppBootstrap(
      app: AppMeta.fromJson(json['app'] as Map<String, dynamic>),
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
      home: HomeData.fromJson(json['home'] as Map<String, dynamic>),
      plans: _mapList(json['plans'], Plan.fromJson),
      subscription: SubscriptionData.fromJson(
        json['subscription'] as Map<String, dynamic>,
      ),
      payments: PaymentsConfig.fromJson(
        json['payments'] as Map<String, dynamic>,
      ),
      services: _mapList(json['services'], ServiceOffer.fromJson),
      specialists: _mapList(json['specialists'], Specialist.fromJson),
      courses: _parseCourses(json),
      shop: ShopData.fromJson(
        json['shop'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      bookings: _mapList(json['bookings'], Booking.fromJson),
      admin: AdminSummary.fromJson(json['admin'] as Map<String, dynamic>),
    );
  }
}

class AppMeta {
  AppMeta({
    required this.name,
    required this.tagline,
    required this.market,
    required this.timezone,
  });

  final String name;
  final String tagline;
  final String market;
  final String timezone;

  factory AppMeta.fromJson(Map<String, dynamic> json) {
    return AppMeta(
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      market: json['market'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
    );
  }
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nickname,
    required this.email,
    required this.avatarUrl,
    required this.location,
    required this.timezone,
    required this.zodiacSign,
    required this.planId,
    required this.accountType,
    required this.natalChart,
    required this.preferences,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String nickname;
  final String email;
  final String avatarUrl;
  final String location;
  final String timezone;
  final String zodiacSign;
  final String planId;
  final String accountType;
  final NatalChart natalChart;
  final UserPreferences preferences;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      zodiacSign: json['zodiacSign'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      accountType: json['accountType'] as String? ?? 'client',
      natalChart:
          NatalChart.fromJson(json['natalChart'] as Map<String, dynamic>),
      preferences: UserPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'email': email,
      'avatarUrl': avatarUrl,
      'location': location,
      'timezone': timezone,
      'zodiacSign': zodiacSign,
      'planId': planId,
      'accountType': accountType,
      'natalChart': natalChart.toJson(),
      'preferences': preferences.toJson(),
    };
  }
}

class NatalChart {
  NatalChart({
    required this.subjectName,
    required this.birthDate,
    required this.birthTime,
    required this.birthTimeUnknown,
    required this.city,
    required this.state,
    required this.country,
    required this.timeZoneId,
    required this.utcOffset,
    required this.latitude,
    required this.longitude,
  });

  final String subjectName;
  final String birthDate;
  final String birthTime;
  final bool birthTimeUnknown;
  final String city;
  final String state;
  final String country;
  final String timeZoneId;
  final String utcOffset;
  final double? latitude;
  final double? longitude;

  factory NatalChart.fromJson(Map<String, dynamic> json) {
    return NatalChart(
      subjectName: json['subjectName'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      birthTime: json['birthTime'] as String? ?? '',
      birthTimeUnknown: json['birthTimeUnknown'] as bool? ?? false,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      timeZoneId: json['timeZoneId'] as String? ?? '',
      utcOffset: json['utcOffset'] as String? ?? '',
      latitude: _asNullableDouble(json['latitude']),
      longitude: _asNullableDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'birthTimeUnknown': birthTimeUnknown,
      'city': city,
      'state': state,
      'country': country,
      'timeZoneId': timeZoneId,
      'utcOffset': utcOffset,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UserPreferences {
  UserPreferences({
    required this.focusAreas,
    required this.preferredSessionModes,
    required this.receivesPush,
  });

  final List<String> focusAreas;
  final List<String> preferredSessionModes;
  final bool receivesPush;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      focusAreas: _stringList(json['focusAreas']),
      preferredSessionModes: _stringList(json['preferredSessionModes']),
      receivesPush: json['receivesPush'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focusAreas': focusAreas,
      'preferredSessionModes': preferredSessionModes,
      'receivesPush': receivesPush,
    };
  }
}

class HomeData {
  HomeData({
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.cardOfTheDay,
    required this.astrologicalEnergy,
    required this.quickActions,
    required this.upcomingBooking,
    required this.featuredMessage,
  });

  final String welcomeTitle;
  final String welcomeSubtitle;
  final DailyCard cardOfTheDay;
  final AstrologicalEnergy astrologicalEnergy;
  final List<QuickAction> quickActions;
  final BookingSummary? upcomingBooking;
  final String featuredMessage;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      welcomeTitle: json['welcomeTitle'] as String? ?? '',
      welcomeSubtitle: json['welcomeSubtitle'] as String? ?? '',
      cardOfTheDay: DailyCard.fromJson(
        json['cardOfTheDay'] as Map<String, dynamic>,
      ),
      astrologicalEnergy: AstrologicalEnergy.fromJson(
        json['astrologicalEnergy'] as Map<String, dynamic>,
      ),
      quickActions: _mapList(json['quickActions'], QuickAction.fromJson),
      upcomingBooking: json['upcomingBooking'] == null
          ? null
          : BookingSummary.fromJson(
              json['upcomingBooking'] as Map<String, dynamic>,
            ),
      featuredMessage: json['featuredMessage'] as String? ?? '',
    );
  }
}

class DailyCard {
  DailyCard({
    required this.title,
    required this.cardName,
    required this.message,
    required this.ritual,
    required this.imageUrl,
  });

  final String title;
  final String cardName;
  final String message;
  final String ritual;
  final String imageUrl;

  factory DailyCard.fromJson(Map<String, dynamic> json) {
    return DailyCard(
      title: json['title'] as String? ?? '',
      cardName: json['cardName'] as String? ?? '',
      message: json['message'] as String? ?? '',
      ritual: json['ritual'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

class AstrologicalEnergy {
  AstrologicalEnergy({
    required this.title,
    required this.summary,
    required this.advice,
    required this.intensity,
  });

  final String title;
  final String summary;
  final String advice;
  final String intensity;

  factory AstrologicalEnergy.fromJson(Map<String, dynamic> json) {
    return AstrologicalEnergy(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      advice: json['advice'] as String? ?? '',
      intensity: json['intensity'] as String? ?? '',
    );
  }
}

class QuickAction {
  QuickAction({
    required this.id,
    required this.label,
    required this.description,
    required this.type,
  });

  final String id;
  final String label;
  final String description;
  final String type;

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }
}

class BookingSummary {
  BookingSummary({
    required this.id,
    required this.specialistName,
    required this.serviceName,
    required this.scheduledAt,
    required this.status,
  });

  final String id;
  final String specialistName;
  final String serviceName;
  final String scheduledAt;
  final String status;

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    return BookingSummary(
      id: json['id'] as String? ?? '',
      specialistName: json['specialistName'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      scheduledAt: json['scheduledAt'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class Plan {
  Plan({
    required this.id,
    required this.name,
    required this.tier,
    required this.priceMonthly,
    required this.currency,
    required this.isPopular,
    required this.features,
    required this.sessionMessageLimit,
    required this.consultationAccess,
  });

  final String id;
  final String name;
  final String tier;
  final double priceMonthly;
  final String currency;
  final bool isPopular;
  final List<String> features;
  final int? sessionMessageLimit;
  final List<String> consultationAccess;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tier: json['tier'] as String? ?? '',
      priceMonthly: (json['priceMonthly'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ?? false,
      features: _stringList(json['features']),
      sessionMessageLimit: json['sessionMessageLimit'] as int?,
      consultationAccess: _stringList(json['consultationAccess']),
    );
  }
}

class SubscriptionData {
  SubscriptionData({
    required this.planId,
    required this.planName,
    required this.status,
    required this.renewsAt,
    required this.platform,
    required this.billingProvider,
    required this.entitlements,
  });

  final String planId;
  final String planName;
  final String status;
  final String? renewsAt;
  final String platform;
  final String billingProvider;
  final List<String> entitlements;

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      renewsAt: json['renewsAt'] as String?,
      platform: json['platform'] as String? ?? '',
      billingProvider: json['billingProvider'] as String? ?? '',
      entitlements: _stringList(json['entitlements']),
    );
  }
}

class PaymentsConfig {
  PaymentsConfig({
    required this.consultationProvider,
    required this.premiumProvider,
    required this.supportedMethods,
    required this.notes,
  });

  final String consultationProvider;
  final String premiumProvider;
  final List<String> supportedMethods;
  final List<String> notes;

  factory PaymentsConfig.fromJson(Map<String, dynamic> json) {
    return PaymentsConfig(
      consultationProvider: json['consultationProvider'] as String? ?? '',
      premiumProvider: json['premiumProvider'] as String? ?? '',
      supportedMethods: _stringList(json['supportedMethods']),
      notes: _stringList(json['notes']),
    );
  }
}

class ServiceOffer {
  ServiceOffer({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.price,
    required this.deliveryModes,
    required this.premiumIncluded,
    required this.specialistIds,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final int durationMinutes;
  final Money price;
  final List<String> deliveryModes;
  final bool premiumIncluded;
  final List<String> specialistIds;

  factory ServiceOffer.fromJson(Map<String, dynamic> json) {
    return ServiceOffer(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      price: Money.fromJson(json['price'] as Map<String, dynamic>),
      deliveryModes: _stringList(json['deliveryModes']),
      premiumIncluded: json['premiumIncluded'] as bool? ?? false,
      specialistIds: _stringList(json['specialistIds']),
    );
  }
}

class UpdateServiceOfferInput {
  UpdateServiceOfferInput({
    this.priceAmount,
    this.durationMinutes,
  });

  final double? priceAmount;
  final int? durationMinutes;

  Map<String, dynamic> toJson() {
    return {
      if (priceAmount != null)
        'price': {
          'amount': priceAmount,
          'currency': 'USD',
        },
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    };
  }
}

class Specialist {
  Specialist({
    required this.id,
    required this.name,
    required this.headline,
    required this.specialties,
    required this.bio,
    required this.yearsExperience,
    required this.sessionModes,
    required this.languages,
    required this.rating,
    required this.reviewCount,
    required this.featured,
    required this.nextAvailableAt,
  });

  final String id;
  final String name;
  final String headline;
  final List<String> specialties;
  final String bio;
  final int yearsExperience;
  final List<String> sessionModes;
  final List<String> languages;
  final double rating;
  final int reviewCount;
  final bool featured;
  final String nextAvailableAt;

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      specialties: _stringList(json['specialties']),
      bio: json['bio'] as String? ?? '',
      yearsExperience: json['yearsExperience'] as int? ?? 0,
      sessionModes: _stringList(json['sessionModes']),
      languages: _stringList(json['languages']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      featured: json['featured'] as bool? ?? false,
      nextAvailableAt: json['nextAvailableAt'] as String? ?? '',
    );
  }
}

class Course {
  Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.level,
    required this.premium,
    required this.featured,
    required this.removable,
    required this.estimatedHours,
    required this.moduleCount,
    required this.lessonCount,
    required this.progressPercent,
    required this.streakDays,
    required this.hook,
    required this.description,
    required this.outcomes,
    required this.modules,
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String level;
  final bool premium;
  final bool featured;
  final bool removable;
  final double estimatedHours;
  final int moduleCount;
  final int lessonCount;
  final int progressPercent;
  final int streakDays;
  final String hook;
  final String description;
  final List<String> outcomes;
  final List<CourseModule> modules;

  factory Course.fromJson(Map<String, dynamic> json) {
    final modules = _mapList(json['modules'], CourseModule.fromJson);
    final derivedLessonCount = modules.fold<int>(
      0,
      (sum, module) => sum + module.lessons.length,
    );

    return Course(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String? ?? '',
      level: json['level'] as String? ?? '',
      premium: json['premium'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      removable: json['removable'] as bool? ?? false,
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0,
      moduleCount: json['moduleCount'] as int? ?? modules.length,
      lessonCount: json['lessonCount'] as int? ?? derivedLessonCount,
      progressPercent: json['progressPercent'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      hook: json['hook'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outcomes: _stringList(json['outcomes']),
      modules: modules,
    );
  }
}

class CourseModule {
  CourseModule({
    required this.id,
    required this.title,
    required this.summary,
    required this.durationMinutes,
    required this.lessons,
  });

  final String id;
  final String title;
  final String summary;
  final int durationMinutes;
  final List<CourseLesson> lessons;

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      lessons: _mapList(json['lessons'], CourseLesson.fromJson),
    );
  }
}

class CourseLesson {
  CourseLesson({
    required this.id,
    required this.title,
    required this.format,
    required this.durationMinutes,
    required this.prompt,
  });

  final String id;
  final String title;
  final String format;
  final int durationMinutes;
  final String prompt;

  factory CourseLesson.fromJson(Map<String, dynamic> json) {
    return CourseLesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      format: json['format'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      prompt: json['prompt'] as String? ?? '',
    );
  }
}

class Booking {
  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.specialistId,
    required this.specialistName,
    required this.scheduledAt,
    required this.mode,
    required this.status,
    required this.price,
    required this.notes,
  });

  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String specialistId;
  final String specialistName;
  final String scheduledAt;
  final String mode;
  final String status;
  final Money price;
  final String notes;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      serviceName: json['serviceName'] as String? ?? '',
      specialistId: json['specialistId'] as String? ?? '',
      specialistName: json['specialistName'] as String? ?? '',
      scheduledAt: json['scheduledAt'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      price: Money.fromJson(json['price'] as Map<String, dynamic>),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class ShopData {
  ShopData({
    required this.title,
    required this.subtitle,
    required this.featuredNote,
    required this.supportNote,
    required this.currency,
    required this.products,
    required this.orders,
  });

  final String title;
  final String subtitle;
  final String featuredNote;
  final String supportNote;
  final String currency;
  final List<ShopProduct> products;
  final List<ShopOrder> orders;

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      featuredNote: json['featuredNote'] as String? ?? '',
      supportNote: json['supportNote'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      products: _mapList(json['products'], ShopProduct.fromJson),
      orders: _mapList(json['orders'], ShopOrder.fromJson),
    );
  }
}

class ShopProduct {
  ShopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.artwork,
    required this.badge,
    required this.featured,
    required this.stockLabel,
    required this.tags,
  });

  final String id;
  final String name;
  final String category;
  final String shortDescription;
  final String description;
  final Money price;
  final String imageUrl;
  final String artwork;
  final String badge;
  final bool featured;
  final String stockLabel;
  final List<String> tags;

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: Money.fromJson(json['price'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String? ?? '',
      artwork: json['artwork'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      featured: json['featured'] as bool? ?? false,
      stockLabel: json['stockLabel'] as String? ?? '',
      tags: _stringList(json['tags']),
    );
  }
}

class ShopOrder {
  ShopOrder({
    required this.id,
    required this.userId,
    required this.orderCode,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    required this.notes,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.itemCount,
    required this.items,
  });

  final String id;
  final String userId;
  final String orderCode;
  final String status;
  final String createdAt;
  final String deliveryAddress;
  final String notes;
  final Money subtotal;
  final Money shipping;
  final Money total;
  final int itemCount;
  final List<ShopOrderItem> items;

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    return ShopOrder(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      orderCode: json['orderCode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      subtotal: Money.fromJson(json['subtotal'] as Map<String, dynamic>),
      shipping: Money.fromJson(json['shipping'] as Map<String, dynamic>),
      total: Money.fromJson(json['total'] as Map<String, dynamic>),
      itemCount: json['itemCount'] as int? ?? 0,
      items: _mapList(json['items'], ShopOrderItem.fromJson),
    );
  }
}

class ShopOrderItem {
  ShopOrderItem({
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.imageUrl,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String productId;
  final String productName;
  final String category;
  final int quantity;
  final String imageUrl;
  final Money unitPrice;
  final Money lineTotal;

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      unitPrice: Money.fromJson(json['unitPrice'] as Map<String, dynamic>),
      lineTotal: Money.fromJson(json['lineTotal'] as Map<String, dynamic>),
    );
  }
}

class Money {
  Money({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
    );
  }
}

class AdminSummary {
  AdminSummary({
    required this.activeUsers,
    required this.premiumSubscribers,
    required this.monthlyBookings,
    required this.activeSpecialists,
    required this.openIncidents,
  });

  final int activeUsers;
  final int premiumSubscribers;
  final int monthlyBookings;
  final int activeSpecialists;
  final int openIncidents;

  factory AdminSummary.fromJson(Map<String, dynamic> json) {
    return AdminSummary(
      activeUsers: json['activeUsers'] as int? ?? 0,
      premiumSubscribers: json['premiumSubscribers'] as int? ?? 0,
      monthlyBookings: json['monthlyBookings'] as int? ?? 0,
      activeSpecialists: json['activeSpecialists'] as int? ?? 0,
      openIncidents: json['openIncidents'] as int? ?? 0,
    );
  }
}

List<T> _mapList<T>(
  Object? raw,
  T Function(Map<String, dynamic> json) factory,
) {
  final list = raw as List<dynamic>? ?? const [];
  return list.map((item) => factory(item as Map<String, dynamic>)).toList();
}

List<String> _stringList(Object? raw) {
  final list = raw as List<dynamic>? ?? const [];
  return list.map((item) => item as String).toList();
}

List<Course> _parseCourses(Map<String, dynamic> json) {
  final rawCourses = json['courses'];
  if (rawCourses is List<dynamic>) {
    return rawCourses
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  final rawLibrary = json['library'] as List<dynamic>? ?? const [];
  return rawLibrary.map((item) {
    final entry = item as Map<String, dynamic>;
    final title = entry['title'] as String? ?? 'Curso breve';
    final category = entry['category'] as String? ?? 'General';
    final excerpt = entry['excerpt'] as String? ?? '';
    final readingTimeMinutes = entry['readingTimeMinutes'] as int? ?? 8;

    return Course(
      id: entry['id'] as String? ?? title.toLowerCase(),
      title: title,
      subtitle: 'Ruta express para no perder continuidad',
      category: category,
      level: 'Express',
      premium: entry['premium'] as bool? ?? false,
      featured: false,
      removable: true,
      estimatedHours:
          ((readingTimeMinutes / 60).clamp(0.5, 2.0) as num).toDouble(),
      moduleCount: 1,
      lessonCount: 1,
      progressPercent: 0,
      streakDays: 0,
      hook: excerpt,
      description: excerpt,
      outcomes: [
        'Transformar una lectura heredada en una práctica accionable.',
      ],
      modules: [
        CourseModule(
          id: '${entry['id'] ?? 'legacy'}-module',
          title: 'Transición desde contenido guardado',
          summary: 'Migración automática de la biblioteca anterior.',
          durationMinutes: readingTimeMinutes,
          lessons: [
            CourseLesson(
              id: '${entry['id'] ?? 'legacy'}-lesson',
              title: title,
              format: 'Lectura',
              durationMinutes: readingTimeMinutes,
              prompt: excerpt,
            ),
          ],
        ),
      ],
    );
  }).toList();
}

double? _asNullableDouble(Object? raw) {
  if (raw == null) {
    return null;
  }

  if (raw is num) {
    return raw.toDouble();
  }

  return double.tryParse(raw.toString());
}
