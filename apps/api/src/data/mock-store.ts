import { randomUUID } from "node:crypto";

import { buildDailyHomeContent } from "./home-daily.js";
import { buildTarotCardImagePath } from "./tarot-images.js";

export type SessionMode = "chat" | "audio" | "video";
export type AccountType = "client" | "specialist";
export type BookingStatus =
  | "confirmed"
  | "pending_payment"
  | "completed"
  | "cancelled";

export interface Money {
  amount: number;
  currency: string;
}

export interface Plan {
  id: string;
  name: string;
  tier: "free" | "premium";
  priceMonthly: number;
  currency: string;
  isPopular: boolean;
  features: string[];
  sessionMessageLimit: number | null;
  consultationAccess: string[];
}

export interface NatalChart {
  subjectName: string;
  birthDate: string;
  birthTime: string;
  birthTimeUnknown: boolean;
  city: string;
  state: string;
  country: string;
  timeZoneId: string;
  utcOffset: string;
  latitude: number | null;
  longitude: number | null;
}

export interface UserPreferences {
  focusAreas: string[];
  preferredSessionModes: SessionMode[];
  receivesPush: boolean;
}

export interface UserProfile {
  id: string;
  firstName: string;
  lastName: string;
  nickname: string;
  email: string;
  avatarUrl: string;
  location: string;
  timezone: string;
  zodiacSign: string;
  planId: string;
  accountType: AccountType;
  specialistProfileId?: string;
  natalChart: NatalChart;
  preferences: UserPreferences;
}

export interface DailyCard {
  title: string;
  cardName: string;
  message: string;
  ritual: string;
  imageUrl: string;
}

export interface AstrologicalEnergy {
  title: string;
  summary: string;
  advice: string;
  intensity: string;
}

export interface QuickAction {
  id: string;
  label: string;
  description: string;
  type: "content" | "booking" | "subscription" | "profile";
}

export interface ServiceOffer {
  id: string;
  name: string;
  category: string;
  description: string;
  durationMinutes: number;
  price: Money;
  deliveryModes: SessionMode[];
  premiumIncluded: boolean;
  specialistIds: string[];
}

export interface Specialist {
  id: string;
  name: string;
  headline: string;
  specialties: string[];
  bio: string;
  yearsExperience: number;
  sessionModes: SessionMode[];
  languages: string[];
  rating: number;
  reviewCount: number;
  featured: boolean;
  nextAvailableAt: string;
}

export interface CourseLesson {
  id: string;
  title: string;
  format: string;
  durationMinutes: number;
  prompt: string;
}

export interface CourseModule {
  id: string;
  title: string;
  summary: string;
  durationMinutes: number;
  lessons: CourseLesson[];
}

export interface Course {
  id: string;
  title: string;
  subtitle: string;
  category: string;
  level: string;
  premium: boolean;
  featured: boolean;
  removable: boolean;
  estimatedHours: number;
  moduleCount: number;
  lessonCount: number;
  progressPercent: number;
  streakDays: number;
  hook: string;
  description: string;
  outcomes: string[];
  modules: CourseModule[];
}

export interface Booking {
  id: string;
  userId: string;
  serviceId: string;
  serviceName: string;
  specialistId: string;
  specialistName: string;
  scheduledAt: string;
  mode: SessionMode;
  status: BookingStatus;
  price: Money;
  notes: string;
}

export type ShopOrderStatus = "pending" | "confirmed" | "preparing" | "shipped";

export interface ShopProduct {
  id: string;
  name: string;
  category: string;
  shortDescription: string;
  description: string;
  price: Money;
  imageUrl: string;
  artwork: string;
  badge: string;
  featured: boolean;
  stockLabel: string;
  tags: string[];
}

export interface CreateShopProductInput {
  name?: string;
  category?: string;
  shortDescription?: string;
  description?: string;
  price?: Partial<Money>;
  imageUrl?: string;
  artwork?: string;
  badge?: string;
  featured?: boolean;
  stockLabel?: string;
  tags?: string[];
}

export interface UpdateShopProductInput {
  name?: string;
  category?: string;
  shortDescription?: string;
  description?: string;
  price?: Partial<Money>;
  imageUrl?: string;
  artwork?: string;
  badge?: string;
  featured?: boolean;
  stockLabel?: string;
  tags?: string[];
}

export interface UpdateShopOrderStatusInput {
  status?: ShopOrderStatus;
}

export interface ShopOrderItem {
  productId: string;
  productName: string;
  category: string;
  quantity: number;
  imageUrl: string;
  unitPrice: Money;
  lineTotal: Money;
}

export interface ShopOrder {
  id: string;
  userId: string;
  orderCode: string;
  status: ShopOrderStatus;
  createdAt: string;
  deliveryAddress: string;
  notes: string;
  subtotal: Money;
  shipping: Money;
  total: Money;
  itemCount: number;
  items: ShopOrderItem[];
}

export interface ShopData {
  title: string;
  subtitle: string;
  featuredNote: string;
  supportNote: string;
  currency: string;
  products: ShopProduct[];
  orders: ShopOrder[];
}

export interface Subscription {
  planId: string;
  planName: string;
  status: "active" | "inactive" | "trial";
  renewsAt: string | null;
  platform: "ios" | "android" | "web";
  billingProvider: "app_store" | "play_store" | "mercado_pago";
  entitlements: string[];
}

export interface PaymentsConfig {
  consultationProvider: string;
  premiumProvider: string;
  supportedMethods: string[];
  notes: string[];
}

export interface AdminSummary {
  activeUsers: number;
  premiumSubscribers: number;
  monthlyBookings: number;
  activeSpecialists: number;
  openIncidents: number;
}

export interface BookingSummary {
  id: string;
  specialistName: string;
  serviceName: string;
  scheduledAt: string;
  status: BookingStatus;
}

export interface HomePayload {
  welcomeTitle: string;
  welcomeSubtitle: string;
  cardOfTheDay: DailyCard;
  astrologicalEnergy: AstrologicalEnergy;
  quickActions: QuickAction[];
  upcomingBooking: BookingSummary | null;
  featuredMessage: string;
}

export interface AppBootstrap {
  app: {
    name: string;
    tagline: string;
    market: string;
    timezone: string;
  };
  user: UserProfile;
  home: HomePayload;
  plans: Plan[];
  subscription: Subscription;
  payments: PaymentsConfig;
  services: ServiceOffer[];
  specialists: Specialist[];
  courses: Course[];
  shop: ShopData;
  bookings: Booking[];
  admin: AdminSummary;
}

export interface CreateBookingInput {
  specialistId?: string;
  serviceId?: string;
  scheduledAt?: string;
  mode?: SessionMode;
  notes?: string;
}

export interface UpdateBookingInput {
  scheduledAt?: string;
  mode?: SessionMode;
  notes?: string;
  status?: BookingStatus;
  cancellationReason?: string;
  rescheduleReason?: string;
}

export interface UpdateUserProfileInput {
  firstName?: string;
  lastName?: string;
  nickname?: string;
  email?: string;
  avatarUrl?: string;
  location?: string;
  zodiacSign?: string;
  accountType?: AccountType;
  specialistProfileId?: string;
  natalChart?: Partial<NatalChart>;
  preferences?: Partial<UserPreferences>;
}

export interface CreateShopOrderItemInput {
  productId?: string;
  quantity?: number;
}

export interface CreateShopOrderInput {
  items?: CreateShopOrderItemInput[];
  deliveryAddress?: string;
  notes?: string;
}

export interface PhoneAuthStartInput {
  countryCode?: string;
  dialCode?: string;
  nationalNumber?: string;
}

export interface PhoneAuthStartResult {
  phoneNumber: string;
  expiresInSeconds: number;
  resendInSeconds: number;
  debugCode: string;
}

export interface PhoneAuthVerifyInput {
  phoneNumber?: string;
  code?: string;
}

export interface CompletePhoneProfileInput {
  firstName?: string;
  lastName?: string;
  email?: string;
  location?: string;
  accountType?: AccountType;
  subjectName?: string;
  birthDate?: string;
  birthTime?: string;
  birthTimeUnknown?: boolean;
  city?: string;
  state?: string;
  country?: string;
  timeZoneId?: string;
  utcOffset?: string;
  latitude?: number;
  longitude?: number;
  zodiacSign?: string;
}

export interface UpdateServiceOfferInput {
  price?: Partial<Money>;
  durationMinutes?: number;
}

export interface PhoneAuthSessionPayload {
  accessToken: string;
  refreshToken: string;
  phoneNumber: string;
  profileCompleted: boolean;
  user: UserProfile;
}

interface PhoneAuthIdentity {
  userId: string;
  phoneNumber: string;
  countryCode: string;
  dialCode: string;
  profileCompleted: boolean;
}

interface PhoneVerificationRecord {
  phoneNumber: string;
  code: string;
  countryCode: string;
  dialCode: string;
  expiresAt: number;
  attemptsRemaining: number;
}

interface PhoneAuthSessionRecord {
  accessToken: string;
  refreshToken: string;
  userId: string;
  phoneNumber: string;
  expiresAt: number;
}

const plans: Plan[] = [
  {
    id: "free",
    name: "Free",
    tier: "free",
    priceMonthly: 0,
    currency: "USD",
    isPopular: false,
    features: [
      "Carta del día",
      "Energía astrológica básica",
      "Agenda limitada",
      "Chat con límite mensual",
    ],
    sessionMessageLimit: 20,
    consultationAccess: ["tarot", "astrología"],
  },
  {
    id: "premium",
    name: "Premium",
    tier: "premium",
    priceMonthly: 14.99,
    currency: "USD",
    isPopular: true,
    features: [
      "Lectura diaria ampliada",
      "Astrología personalizada",
      "Cursos premium",
      "Chat ilimitado",
      "Acceso a especialistas avanzados",
    ],
    sessionMessageLimit: null,
    consultationAccess: [
      "tarot",
      "astrología",
      "numerología",
      "reiki",
      "diseños humanos",
      "feng shui",
    ],
  },
];

const services: ServiceOffer[] = [
  {
    id: "service-tarot",
    name: "Lectura de tarot terapéutico",
    category: "Tarot",
    description:
      "Sesión enfocada en claridad emocional, decisiones y cierres de ciclo.",
    durationMinutes: 45,
    price: { amount: 32, currency: "USD" },
    deliveryModes: ["chat", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-amaya", "spec-lorena"],
  },
  {
    id: "service-tarot-love",
    name: "Tirada de vínculos y amor",
    category: "Tarot",
    description:
      "Lectura enfocada en relaciones, dinámicas afectivas y claridad vincular.",
    durationMinutes: 40,
    price: { amount: 30, currency: "USD" },
    deliveryModes: ["chat", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-amaya", "spec-lucia"],
  },
  {
    id: "service-tarot-cycle",
    name: "Tirada de ciclo y decisiones",
    category: "Tarot",
    description:
      "Sesión para ordenar procesos, cierres, aperturas y decisiones de corto plazo.",
    durationMinutes: 50,
    price: { amount: 36, currency: "USD" },
    deliveryModes: ["audio", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-lucia"],
  },
  {
    id: "service-astro",
    name: "Astrología natal personalizada",
    category: "Astrología",
    description:
      "Lectura de carta natal con foco en identidad, relaciones y timing.",
    durationMinutes: 60,
    price: { amount: 48, currency: "USD" },
    deliveryModes: ["audio", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-elian"],
  },
  {
    id: "service-numerologia",
    name: "Consulta de numerología",
    category: "Numerología",
    description:
      "Interpretación de ciclos, talentos y aprendizajes por vibración numérica.",
    durationMinutes: 40,
    price: { amount: 29, currency: "USD" },
    deliveryModes: ["chat", "audio"],
    premiumIncluded: false,
    specialistIds: ["spec-mila", "spec-lorena"],
  },
  {
    id: "service-numerologia-mapa",
    name: "Mapa numerológico personal",
    category: "Numerología",
    description:
      "Lectura de sendero de vida, expresión, alma, personalidad, desafíos y pináculos.",
    durationMinutes: 60,
    price: { amount: 42, currency: "USD" },
    deliveryModes: ["audio", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-mila", "spec-noa"],
  },
  {
    id: "service-numerologia-year",
    name: "Año personal y ciclos",
    category: "Numerología",
    description:
      "Sesión centrada en año personal, mes personal, timing y decisiones del periodo.",
    durationMinutes: 35,
    price: { amount: 26, currency: "USD" },
    deliveryModes: ["chat", "audio"],
    premiumIncluded: false,
    specialistIds: ["spec-mila", "spec-noa"],
  },
  {
    id: "service-numerologia-compat",
    name: "Compatibilidad numerológica",
    category: "Numerología",
    description:
      "Análisis de afinidades, tensiones y acuerdos entre dos perfiles numerológicos.",
    durationMinutes: 50,
    price: { amount: 38, currency: "USD" },
    deliveryModes: ["audio", "video"],
    premiumIncluded: false,
    specialistIds: ["spec-noa"],
  },
  {
    id: "service-campus",
    name: "Campus de cursos guiados",
    category: "Contenido",
    description:
      "Acceso continuo a rutas de aprendizaje, prácticas guiadas y material accionable.",
    durationMinutes: 0,
    price: { amount: 0, currency: "USD" },
    deliveryModes: ["chat"],
    premiumIncluded: true,
    specialistIds: [],
  },
];

const specialists: Specialist[] = [
  {
    id: "spec-amaya",
    name: "Amaya Rivas",
    headline: "Tarot terapéutico y lectura intuitiva",
    specialties: ["Tarot", "Procesos emocionales", "Rituales de cierre"],
    bio: "Acompaña procesos de cambio con tarot, escucha activa y trabajo simbólico.",
    yearsExperience: 8,
    sessionModes: ["chat", "video"],
    languages: ["es", "pt"],
    rating: 4.9,
    reviewCount: 128,
    featured: true,
    nextAvailableAt: "2026-03-24T19:00:00-03:00",
  },
  {
    id: "spec-elian",
    name: "Elian Duarte",
    headline: "Astrología natal, sinastría y ciclos",
    specialties: ["Astrología natal", "Sinastría", "Revolución solar"],
    bio: "Trabaja con mapa natal y tránsitos para ordenar decisiones y tiempos.",
    yearsExperience: 11,
    sessionModes: ["audio", "video"],
    languages: ["es", "en"],
    rating: 4.8,
    reviewCount: 96,
    featured: true,
    nextAvailableAt: "2026-03-28T18:30:00-03:00",
  },
  {
    id: "spec-lucia",
    name: "Lucía Beltrán",
    headline: "Tarot evolutivo, vínculos y elecciones",
    specialties: ["Tarot", "Vínculos", "Tarot de Marsella"],
    bio: "Integra tarot simbólico con preguntas concretas para ordenar decisiones y vínculos.",
    yearsExperience: 9,
    sessionModes: ["audio", "video"],
    languages: ["es"],
    rating: 4.9,
    reviewCount: 84,
    featured: true,
    nextAvailableAt: "2026-03-25T20:00:00-03:00",
  },
  {
    id: "spec-lorena",
    name: "Lorena Domínguez",
    headline: "Tarot intuitivo, numerología y claridad de decisiones",
    specialties: ["Tarot", "Numerología", "Lectura simbólica"],
    bio: "Combina tarot, numerología y lectura simbólica para orientar decisiones sin ruido.",
    yearsExperience: 7,
    sessionModes: ["chat", "video"],
    languages: ["es"],
    rating: 4.8,
    reviewCount: 74,
    featured: true,
    nextAvailableAt: "2026-03-29T18:00:00-03:00",
  },
  {
    id: "spec-mila",
    name: "Mila Ortega",
    headline: "Numerología aplicada a relaciones y propósito",
    specialties: ["Numerología", "Compatibilidad", "Ciclos personales"],
    bio: "Ayuda a leer patrones vitales desde la numerología contemporánea.",
    yearsExperience: 6,
    sessionModes: ["chat", "audio"],
    languages: ["es"],
    rating: 4.7,
    reviewCount: 61,
    featured: false,
    nextAvailableAt: "2026-03-26T17:00:00-03:00",
  },
  {
    id: "spec-noa",
    name: "Noa Ferrer",
    headline: "Numerología pitagórica, ciclos y lectura de nombre",
    specialties: [
      "Numerología pitagórica",
      "Año personal",
      "Lectura de nombre natal",
    ],
    bio: "Trabaja con números nucleares, periodos, pináculos y compatibilidad.",
    yearsExperience: 7,
    sessionModes: ["audio", "video"],
    languages: ["es", "en"],
    rating: 4.8,
    reviewCount: 47,
    featured: true,
    nextAvailableAt: "2026-03-27T18:00:00-03:00",
  },
];

const courses: Course[] = [
  {
    id: "course-tarot-sin-ruido",
    title: "Tarot sin ruido",
    subtitle: "Intuición, símbolo y decisiones sin respuestas literales",
    category: "Tarot",
    level: "Inicial",
    premium: false,
    featured: true,
    removable: true,
    estimatedHours: 3.5,
    moduleCount: 4,
    lessonCount: 12,
    progressPercent: 28,
    streakDays: 4,
    hook: "Una ruta corta, elegante y muy práctica para que el tarot deje de sentirse confuso y empiece a darte claridad accionable.",
    description:
      "Este curso cambia la lógica de 'decir el futuro' por lectura simbólica, foco emocional y pequeñas decisiones concretas después de cada tirada.",
    outcomes: [
      "Aprender a formular preguntas que abren lectura útil.",
      "Leer arcanos sin depender de palabras clave rígidas.",
      "Cerrar cada tirada con una acción observable en tu semana.",
    ],
    modules: [
      {
        id: "course-tarot-sin-ruido-m1",
        title: "Bajar el ruido mental",
        summary:
          "Cómo entrar al tarot sin ansiedad por acertar y sin buscar respuestas literales.",
        durationMinutes: 48,
        lessons: [
          {
            id: "course-tarot-sin-ruido-m1-l1",
            title: "La pregunta que abre símbolo",
            format: "video",
            durationMinutes: 11,
            prompt:
              "Reescribe una pregunta cerrada como una pregunta de claridad.",
          },
          {
            id: "course-tarot-sin-ruido-m1-l2",
            title: "Intención antes de barajar",
            format: "audio",
            durationMinutes: 9,
            prompt:
              "Detecta si estás entrando desde ansiedad, curiosidad o decisión.",
          },
          {
            id: "course-tarot-sin-ruido-m1-l3",
            title: "La carta como espejo",
            format: "práctica",
            durationMinutes: 28,
            prompt:
              "Haz una lectura de una sola carta y anota tres reflejos del momento.",
          },
        ],
      },
      {
        id: "course-tarot-sin-ruido-m2",
        title: "Arcanos que sí cambian una decisión",
        summary:
          "Aprende a distinguir energía de fondo, advertencia y oportunidad.",
        durationMinutes: 56,
        lessons: [
          {
            id: "course-tarot-sin-ruido-m2-l1",
            title: "Mayores como bisagra",
            format: "video",
            durationMinutes: 14,
            prompt:
              "Ubica en qué área de tu vida ya se siente un cambio de etapa.",
          },
          {
            id: "course-tarot-sin-ruido-m2-l2",
            title: "Menores como clima real",
            format: "lectura",
            durationMinutes: 16,
            prompt:
              "Relaciona palo, número y contexto actual sin memorizar recetas.",
          },
          {
            id: "course-tarot-sin-ruido-m2-l3",
            title: "Integracion express",
            format: "práctica",
            durationMinutes: 26,
            prompt:
              "Resume una tirada en una frase de acción para las próximas 48 horas.",
          },
        ],
      },
      {
        id: "course-tarot-sin-ruido-m3",
        title: "Tirada de claridad",
        summary:
          "Una estructura simple de tres cartas para decisiones afectivas, laborales o creativas.",
        durationMinutes: 62,
        lessons: [
          {
            id: "course-tarot-sin-ruido-m3-l1",
            title: "Antes de la tirada",
            format: "audio",
            durationMinutes: 10,
            prompt:
              "Define que necesitas entender hoy y que no necesitas controlar.",
          },
          {
            id: "course-tarot-sin-ruido-m3-l2",
            title: "Presente, tension y salida",
            format: "video",
            durationMinutes: 18,
            prompt:
              "Aplica la estructura completa con un asunto real de tu semana.",
          },
          {
            id: "course-tarot-sin-ruido-m3-l3",
            title: "Chequeo de realidad",
            format: "práctica",
            durationMinutes: 34,
            prompt: "Convierte el mensaje final en una decisión verificable.",
          },
        ],
      },
      {
        id: "course-tarot-sin-ruido-m4",
        title: "Cierre y ritual mínimo",
        summary:
          "Salir de la lectura con dirección, no con dependencia del mazo.",
        durationMinutes: 44,
        lessons: [
          {
            id: "course-tarot-sin-ruido-m4-l1",
            title: "Ritual de cierre de 5 minutos",
            format: "audio",
            durationMinutes: 8,
            prompt: "Cierra energía y registra la acción elegida.",
          },
          {
            id: "course-tarot-sin-ruido-m4-l2",
            title: "Bitácora para no depender",
            format: "lectura",
            durationMinutes: 12,
            prompt:
              "Crea una bitácora con fecha, símbolos, acción y resultado.",
          },
          {
            id: "course-tarot-sin-ruido-m4-l3",
            title: "Sprint de integración",
            format: "práctica",
            durationMinutes: 24,
            prompt:
              "Sostiene siete días de lectura corta sin repetir la misma pregunta.",
          },
        ],
      },
    ],
  },
  {
    id: "course-arquitectura-del-destino",
    title: "Arquitectura del destino",
    subtitle: "Astrología y numerología para leer tu año sin improvisar",
    category: "Astro + Numerología",
    level: "Intermedio",
    premium: true,
    featured: false,
    removable: true,
    estimatedHours: 5.2,
    moduleCount: 5,
    lessonCount: 15,
    progressPercent: 8,
    streakDays: 1,
    hook: "Una experiencia con ritmo de serie corta: entiendes tus ciclos, reconoces tus ventanas y sales con mapa de acción trimestral.",
    description:
      "Cruza sendero de vida, año personal, Sol, Luna y tránsitos clave para pasar de intuición suelta a estrategia personal con timing.",
    outcomes: [
      "Ubicar tu tema rector del año con astrología y numerología.",
      "Detectar meses de avance, corrección y repliegue.",
      "Construir un tablero de decisiones por trimestre.",
    ],
    modules: [
      {
        id: "course-arquitectura-del-destino-m1",
        title: "Tu mapa rector",
        summary:
          "Junta Sol, Luna, Ascendente y sendero de vida para encontrar el patrón de fondo.",
        durationMinutes: 58,
        lessons: [
          {
            id: "course-arquitectura-del-destino-m1-l1",
            title: "Sol, Luna y Ascendente en lenguaje humano",
            format: "video",
            durationMinutes: 18,
            prompt:
              "Describe tu energía base, necesidad emocional y forma de entrar al mundo.",
          },
          {
            id: "course-arquitectura-del-destino-m1-l2",
            title: "Sendero de vida como columna",
            format: "lectura",
            durationMinutes: 12,
            prompt:
              "Relaciona tu número central con decisiones repetidas en tu historia.",
          },
          {
            id: "course-arquitectura-del-destino-m1-l3",
            title: "Síntesis del patrón",
            format: "práctica",
            durationMinutes: 28,
            prompt: "Redacta una frase directriz para tu año actual.",
          },
        ],
      },
      {
        id: "course-arquitectura-del-destino-m2",
        title: "Año personal y tránsitos",
        summary:
          "Cruza timing numerológico con el cielo para detectar presión, expansión y limpieza.",
        durationMinutes: 64,
        lessons: [
          {
            id: "course-arquitectura-del-destino-m2-l1",
            title: "Leer el año personal",
            format: "video",
            durationMinutes: 16,
            prompt:
              "Identifica el verbo central del año: sembrar, ordenar, exponer o cerrar.",
          },
          {
            id: "course-arquitectura-del-destino-m2-l2",
            title: "Tránsitos que activan decisión",
            format: "audio",
            durationMinutes: 14,
            prompt:
              "Anota qué áreas se mueven cuando el cielo acelera tu mapa natal.",
          },
          {
            id: "course-arquitectura-del-destino-m2-l3",
            title: "Cruce estrategico",
            format: "práctica",
            durationMinutes: 34,
            prompt:
              "Marca tus próximas tres ventanas de acción y una ventana de pausa.",
          },
        ],
      },
      {
        id: "course-arquitectura-del-destino-m3",
        title: "Trabajo, dinero y estructura",
        summary:
          "Cómo ordenar foco profesional, energía y recursos sin sobrecargarte.",
        durationMinutes: 52,
        lessons: [
          {
            id: "course-arquitectura-del-destino-m3-l1",
            title: "La casa profesional y tus números de expresión",
            format: "video",
            durationMinutes: 17,
            prompt:
              "Detecta dónde tu talento pide más visibilidad o más sistema.",
          },
          {
            id: "course-arquitectura-del-destino-m3-l2",
            title: "Prioridades del trimestre",
            format: "práctica",
            durationMinutes: 35,
            prompt:
              "Convierte tu lectura en tres decisiones concretas para ingresos y foco.",
          },
        ],
      },
      {
        id: "course-arquitectura-del-destino-m4",
        title: "Vínculos y energía relacional",
        summary:
          "Relaciona necesidades emocionales, compatibilidades y límites sanos.",
        durationMinutes: 49,
        lessons: [
          {
            id: "course-arquitectura-del-destino-m4-l1",
            title: "Tu forma de vincular",
            format: "audio",
            durationMinutes: 15,
            prompt:
              "Observa qué patrón repites cuando buscas seguridad o cercanía.",
          },
          {
            id: "course-arquitectura-del-destino-m4-l2",
            title: "Meses sensibles y meses de expansión",
            format: "lectura",
            durationMinutes: 14,
            prompt:
              "Distingue cuándo empujar y cuándo cuidar energía afectiva.",
          },
          {
            id: "course-arquitectura-del-destino-m4-l3",
            title: "Mapa de conversaciones clave",
            format: "práctica",
            durationMinutes: 20,
            prompt:
              "Programa una conversación necesaria en una ventana favorable.",
          },
        ],
      },
      {
        id: "course-arquitectura-del-destino-m5",
        title: "Cierre con tablero anual",
        summary:
          "Arma un tablero liviano para sostener el aprendizaje sin perderte en teoria.",
        durationMinutes: 41,
        lessons: [
          {
            id: "course-arquitectura-del-destino-m5-l1",
            title: "Checklist de tu año",
            format: "práctica",
            durationMinutes: 21,
            prompt: "Resume prioridades, riesgos y rituales de mantenimiento.",
          },
          {
            id: "course-arquitectura-del-destino-m5-l2",
            title: "Ritmo de seguimiento",
            format: "audio",
            durationMinutes: 20,
            prompt:
              "Define un sistema semanal para revisar tu mapa sin obsesionarte.",
          },
        ],
      },
    ],
  },
];

let currentUser: UserProfile = {
  id: "user-mark",
  firstName: "Mark",
  lastName: "Lore",
  nickname: "mark",
  email: "mark@example.com",
  avatarUrl: "",
  location: "Lima, Perú",
  timezone: "America/Lima",
  zodiacSign: "Sagitario",
  planId: "free",
  accountType: "specialist",
  specialistProfileId: "spec-amaya",
  natalChart: {
    subjectName: "Mark",
    birthDate: "2000-11-28",
    birthTime: "01:40",
    birthTimeUnknown: false,
    city: "Lima",
    state: "Lima",
    country: "Perú",
    timeZoneId: "America/Lima",
    utcOffset: "-05:00",
    latitude: -12.0464,
    longitude: -77.0428,
  },
  preferences: {
    focusAreas: ["claridad", "propósito", "vínculos"],
    preferredSessionModes: ["chat", "video"],
    receivesPush: true,
  },
};

let bookings: Booking[] = [
  {
    id: "booking-1",
    userId: currentUser.id,
    serviceId: "service-tarot",
    serviceName: "Lectura de tarot terapéutico",
    specialistId: "spec-amaya",
    specialistName: "Amaya Rivas",
    scheduledAt: "2026-03-24T19:00:00-03:00",
    mode: "video",
    status: "confirmed",
    price: { amount: 32, currency: "USD" },
    notes: "Quiero trabajar claridad sobre una decisión profesional.",
  },
  {
    id: "booking-2",
    userId: currentUser.id,
    serviceId: "service-astro",
    serviceName: "Astrología natal personalizada",
    specialistId: "spec-elian",
    specialistName: "Elian Duarte",
    scheduledAt: "2026-03-28T18:30:00-03:00",
    mode: "audio",
    status: "pending_payment",
    price: { amount: 48, currency: "USD" },
    notes: "Revisar tránsitos y energía del trimestre.",
  },
];

const usersById = new Map<string, UserProfile>([[currentUser.id, currentUser]]);
const phoneAuthIdentitiesByPhone = new Map<string, PhoneAuthIdentity>([
  [
    "+59891111111",
    {
      userId: currentUser.id,
      phoneNumber: "+59891111111",
      countryCode: "UY",
      dialCode: "+598",
      profileCompleted: true,
    },
  ],
]);
const verificationRecordsByPhone = new Map<string, PhoneVerificationRecord>();
const authSessionsByAccessToken = new Map<string, PhoneAuthSessionRecord>();

const paymentsConfig: PaymentsConfig = {
  consultationProvider: "Mercado Pago",
  premiumProvider: "Apple In-App Purchase / Google Play Billing",
  supportedMethods: [
    "Tarjetas crédito/débito",
    "Transferencias",
    "Pago en efectivo habilitado por Mercado Pago",
    "Suscripcion mensual o anual en stores",
  ],
  notes: [
    "Premium y contenido digital se gestionan por billing de tienda.",
    "Consultas 1:1 pueden evaluarse con Mercado Pago segun el flujo final.",
  ],
};

const adminSummary: AdminSummary = {
  activeUsers: 324,
  premiumSubscribers: 81,
  monthlyBookings: 146,
  activeSpecialists: 7,
  openIncidents: 2,
};

const shopProducts: ShopProduct[] = [
  {
    id: "shop-vela-luna-nueva",
    name: "Vela ritual Luna Nueva",
    category: "Velas",
    shortDescription: "Cera vegetal con notas de mirra y jazmín.",
    description:
      "Vela pensada para aperturas, intenciones y limpiezas suaves del espacio.",
    price: { amount: 18, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/d/db/Ritual-_Candles.jpg",
    artwork: "candle-moon",
    badge: "Ritual inicial",
    featured: true,
    stockLabel: "Disponible",
    tags: ["cera vegetal", "intención", "altar"],
  },
  {
    id: "shop-vela-proteccion",
    name: "Vela Protección Obsidiana",
    category: "Velas",
    shortDescription: "Blend oscuro para cierres y contención energética.",
    description:
      "Ideal para rituales de protección, límites y cierres de ciclo con humo suave.",
    price: { amount: 21, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/f/f5/Candle_black.jpg",
    artwork: "candle-obsidian",
    badge: "Protección",
    featured: false,
    stockLabel: "Pocas unidades",
    tags: ["obsidiana", "protección", "limpieza"],
  },
  {
    id: "shop-cuadro-carta-dorada",
    name: "Cuadro carta natal dorada",
    category: "Cuadros",
    shortDescription: "Impresión premium con mapa natal en foil.",
    description:
      "Tu carta natal en composición vertical con acentos dorados y datos de nacimiento.",
    price: { amount: 64, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/0/03/Astrological_birth_chart_for_1st_Duke_of_Albemarle_Wellcome_L0040335.jpg",
    artwork: "natal-gold",
    badge: "Personalizable",
    featured: true,
    stockLabel: "Hecho a pedido",
    tags: ["carta natal", "foil", "decoración"],
  },
  {
    id: "shop-cuadro-carta-nocturna",
    name: "Cuadro carta natal nocturna",
    category: "Cuadros",
    shortDescription: "Lámina azul profundo con constelaciones y casas.",
    description:
      "Versión en paleta noche con círculos zodiacales y espacio para dedicatoria.",
    price: { amount: 58, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/b/b5/12_star_charts_of_the_signs_of_the_Zodiac_by_John_Bevis.jpg",
    artwork: "natal-night",
    badge: "Edición estudio",
    featured: false,
    stockLabel: "Disponible",
    tags: ["constelaciones", "hogar", "regalo"],
  },
  {
    id: "shop-estatua-triple-luna",
    name: "Estatua Triple Luna",
    category: "Estatuas",
    shortDescription: "Figura resina marfil para altar o biblioteca.",
    description:
      "Pieza decorativa inspirada en la triple luna para espacios de práctica y contemplación.",
    price: { amount: 46, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/b/bd/Moon_Statue.jpg",
    artwork: "statue-moon",
    badge: "Altar",
    featured: false,
    stockLabel: "Disponible",
    tags: ["resina", "altar", "luna"],
  },
  {
    id: "shop-estatua-buda-lunar",
    name: "Estatua Buda lunar",
    category: "Estatuas",
    shortDescription: "Figura pequeña para meditación y calma visual.",
    description:
      "Acabado piedra suave para rincones de lectura, meditación y descanso.",
    price: { amount: 39, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/3/34/Dhyana_buddha_statue_in_Amaravathi.jpg",
    artwork: "statue-buddha",
    badge: "Calma",
    featured: false,
    stockLabel: "Disponible",
    tags: ["meditación", "hogar", "serenidad"],
  },
  {
    id: "shop-simbolo-flor-vida",
    name: "Símbolo Flor de la Vida",
    category: "Símbolos",
    shortDescription: "Placa metálica para pared o altar.",
    description:
      "Símbolo geométrico en acabado dorado mate para armonizar el espacio.",
    price: { amount: 27, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/f/f4/Flower_of_life_black.png",
    artwork: "symbol-flower",
    badge: "Geometría sagrada",
    featured: false,
    stockLabel: "Disponible",
    tags: ["geometría", "armonía", "pared"],
  },
  {
    id: "shop-simbolo-pentagrama",
    name: "Pentagrama ceremonial",
    category: "Símbolos",
    shortDescription: "Pieza de altar en madera oscura y latón.",
    description:
      "Símbolo para mesa ritual, prácticas de enfoque e intención consciente.",
    price: { amount: 24, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/8/87/Steel_pentagram_01.jpg",
    artwork: "symbol-pentacle",
    badge: "Mesa ritual",
    featured: false,
    stockLabel: "Disponible",
    tags: ["latón", "altar", "foco"],
  },
  {
    id: "shop-tarot-rider-waite",
    name: "Tarot Rider Waite lino",
    category: "Tarot",
    shortDescription: "Mazo clásico con acabado mate texturizado.",
    description:
      "Versión suave al tacto, ideal para práctica diaria y lecturas guiadas.",
    price: { amount: 33, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/3/3e/Rider-Waite_Major_Arcana_full.png",
    artwork: "tarot-rider",
    badge: "Clásico",
    featured: true,
    stockLabel: "Disponible",
    tags: ["78 cartas", "clásico", "aprendizaje"],
  },
  {
    id: "shop-tarot-marsella",
    name: "Tarot de Marsella restaurado",
    category: "Tarot",
    shortDescription: "Paleta restaurada con guía breve incluida.",
    description:
      "Mazo enfocado en lectura simbólica tradicional con colores renovados.",
    price: { amount: 37, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/3/3f/Tarot_De_Marseille.jpg",
    artwork: "tarot-marsella",
    badge: "Marsella",
    featured: true,
    stockLabel: "Disponible",
    tags: ["tradicional", "restaurado", "guía"],
  },
  {
    id: "shop-tarot-thoth-pocket",
    name: "Tarot Thoth pocket",
    category: "Tarot",
    shortDescription: "Formato compacto para lecturas de viaje.",
    description:
      "Mazo reducido con impresión nítida y estuche rígido para llevar contigo.",
    price: { amount: 29, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/f/fb/Thoth_Tarot_Cards_in_the_Museum_of_Witchcraft_and_Magic.jpg",
    artwork: "tarot-thoth",
    badge: "Pocket",
    featured: false,
    stockLabel: "Disponible",
    tags: ["viaje", "compacto", "estuche"],
  },
  {
    id: "shop-tarot-lunar-oracle",
    name: "Tarot Lunar Vision",
    category: "Tarot",
    shortDescription: "Mazo ilustrado con tono místico contemporáneo.",
    description:
      "Ideal para lecturas intuitivas, journaling y trabajo con fases lunares.",
    price: { amount: 41, currency: "USD" },
    imageUrl:
      "https://upload.wikimedia.org/wikipedia/commons/8/83/Tarot_cards_-_3_card_spread_with_candles.jpg",
    artwork: "tarot-lunar",
    badge: "Edición visual",
    featured: false,
    stockLabel: "Nueva llegada",
    tags: ["luna", "intuición", "journaling"],
  },
];

const shopOrdersByUserId = new Map<string, ShopOrder[]>([
  [
    currentUser.id,
    [
      {
        id: "order-seed-1",
        userId: currentUser.id,
        orderCode: "LR-2026-041",
        status: "confirmed",
        createdAt: "2026-03-18T16:40:00-05:00",
        deliveryAddress: "Miraflores, Lima, Perú",
        notes: "Entrega en portería.",
        subtotal: { amount: 51, currency: "USD" },
        shipping: { amount: 0, currency: "USD" },
        total: { amount: 51, currency: "USD" },
        itemCount: 2,
        items: [
          {
            productId: "shop-vela-luna-nueva",
            productName: "Vela ritual Luna Nueva",
            category: "Velas",
            quantity: 1,
            imageUrl: "",
            unitPrice: { amount: 18, currency: "USD" },
            lineTotal: { amount: 18, currency: "USD" },
          },
          {
            productId: "shop-tarot-rider-waite",
            productName: "Tarot Rider Waite lino",
            category: "Tarot",
            quantity: 1,
            imageUrl: buildTarotCardImagePath("La Fuerza") ?? "",
            unitPrice: { amount: 33, currency: "USD" },
            lineTotal: { amount: 33, currency: "USD" },
          },
        ],
      },
    ],
  ],
]);

function getUserById(userId?: string): UserProfile {
  if (userId && usersById.has(userId)) {
    return usersById.get(userId)!;
  }

  return currentUser;
}

function setCurrentUser(user: UserProfile) {
  currentUser = user;
  usersById.set(user.id, user);
}

function getPhoneIdentityByUserId(userId: string): PhoneAuthIdentity | null {
  for (const identity of phoneAuthIdentitiesByPhone.values()) {
    if (identity.userId === userId) {
      return identity;
    }
  }

  return null;
}

function createOpaqueToken(): string {
  return `${randomUUID()}${randomUUID()}`.replaceAll("-", "");
}

function generateMockOtpCode(): string {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function normalizeDialCode(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 1 || digits.length > 4) {
    throw new Error("Selecciona un prefijo internacional válido.");
  }

  return `+${digits}`;
}

function normalizeNationalNumber(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 6 || digits.length > 12) {
    throw new Error("Ingresa un número de teléfono válido.");
  }

  return digits;
}

function normalizeFullPhoneNumber(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 8 || digits.length > 15) {
    throw new Error("El número de teléfono no es válido.");
  }

  return `+${digits}`;
}

function inferZodiacSign(birthDate?: string): string {
  const normalizedBirthDate = normalizeBirthDateInput(birthDate);
  const match = normalizedBirthDate.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) {
    return "";
  }

  const month = Number(match[2]);
  const day = Number(match[3]);

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) {
    return "Aries";
  }
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) {
    return "Tauro";
  }
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) {
    return "Geminis";
  }
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) {
    return "Cancer";
  }
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) {
    return "Leo";
  }
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) {
    return "Virgo";
  }
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) {
    return "Libra";
  }
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) {
    return "Escorpio";
  }
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) {
    return "Sagitario";
  }
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) {
    return "Capricornio";
  }
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) {
    return "Acuario";
  }
  if ((month === 2 && day >= 19) || (month === 3 && day <= 20)) {
    return "Piscis";
  }

  return "";
}

function normalizeBirthDateInput(value?: string): string {
  const raw = (value ?? "").trim();
  const isoMatch = raw.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (isoMatch) {
    return raw;
  }

  const dayFirstMatch = raw.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (dayFirstMatch) {
    return `${dayFirstMatch[3]}-${dayFirstMatch[2]}-${dayFirstMatch[1]}`;
  }

  return raw;
}

function getCurrentPlan(userId?: string): Plan {
  const user = getUserById(userId);
  return plans.find((plan) => plan.id === user.planId) ?? plans[0];
}

function resolveShopOwnerId(userId?: string): string {
  return userId?.trim() || currentUser.id;
}

function getUserLocationFallback(userId?: string): string {
  const ownerId = resolveShopOwnerId(userId);
  return usersById.get(ownerId)?.location?.trim() || currentUser.location;
}

function cloneMoney(value: Money): Money {
  return {
    amount: value.amount,
    currency: value.currency,
  };
}

function buildOrderCode(orderCount: number): string {
  const year = new Date().getFullYear();
  return `LR-${year}-${String(orderCount + 41).padStart(3, "0")}`;
}

function slugifyShopValue(value: string): string {
  return (
    value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 48) || "producto"
  );
}

function inferShopArtwork(category: string): string {
  const normalized = category.toLowerCase();
  if (normalized.includes("vela")) {
    return "candle-moon";
  }
  if (normalized.includes("cuadro") || normalized.includes("carta")) {
    return "natal-gold";
  }
  if (normalized.includes("estatua") || normalized.includes("figura")) {
    return "statue-moon";
  }
  if (normalized.includes("simbolo") || normalized.includes("símbolo")) {
    return "symbol-flower";
  }
  if (normalized.includes("tarot") || normalized.includes("mazo")) {
    return "tarot-rider";
  }

  return "shop-default";
}

function normalizeShopTags(tags?: string[]): string[] {
  const normalized = (tags ?? [])
    .map((tag) => tag.trim())
    .filter((tag) => tag.length > 0);

  return normalized.length > 0 ? normalized.slice(0, 6) : ["nuevo"];
}

function isShopOrderStatus(value: unknown): value is ShopOrderStatus {
  return (
    value === "pending" ||
    value === "confirmed" ||
    value === "preparing" ||
    value === "shipped"
  );
}

function getUpcomingBooking(userId?: string): Booking | null {
  const ordered = getBookings(userId).filter(
    (booking) =>
      booking.status === "confirmed" || booking.status === "pending_payment",
  );

  return ordered[0] ?? null;
}

function buildPhoneAuthSessionPayload(
  session: PhoneAuthSessionRecord,
): PhoneAuthSessionPayload {
  const user = getUserById(session.userId);
  const identity = phoneAuthIdentitiesByPhone.get(session.phoneNumber);

  if (!identity) {
    throw new Error("No se encontró la identidad del teléfono autenticado.");
  }

  return {
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
    phoneNumber: session.phoneNumber,
    profileCompleted: identity.profileCompleted,
    user,
  };
}

function buildPendingPhoneAuthUser(phoneNumber: string): UserProfile {
  const suffix = phoneNumber.replace(/\D/g, "").slice(-4);

  return {
    id: randomUUID(),
    firstName: "",
    lastName: "",
    nickname: suffix.length === 0 ? "" : `user${suffix}`,
    email: "",
    avatarUrl: "",
    location: "",
    timezone: "America/Lima",
    zodiacSign: "",
    planId: "free",
    accountType: "client",
    specialistProfileId: "",
    natalChart: {
      subjectName: "",
      birthDate: "",
      birthTime: "",
      birthTimeUnknown: true,
      city: "",
      state: "",
      country: "",
      timeZoneId: "",
      utcOffset: "",
      latitude: null,
      longitude: null,
    },
    preferences: {
      focusAreas: [],
      preferredSessionModes: ["chat"],
      receivesPush: true,
    },
  };
}

export function getHomePayload(userId?: string): HomePayload {
  const user = getUserById(userId);
  const upcoming = getUpcomingBooking(user.id);
  const firstName = user.firstName.trim();
  const { cardOfTheDay, astrologicalEnergy } = buildDailyHomeContent(
    user.timezone,
  );

  return {
    welcomeTitle: firstName.length === 0 ? "Hola" : `Hola, ${firstName}`,
    welcomeSubtitle:
      "Tu espacio diario para tarot, astrología, consultas y contenido guiado.",
    cardOfTheDay,
    astrologicalEnergy,
    quickActions: [
      {
        id: "quick-numerology",
        label: "Numerología",
        description: "Perfil, ciclos y nombre natal",
        type: "content",
      },
      {
        id: "quick-premium",
        label: "Ver Premium",
        description: "Plan, beneficios y estado actual",
        type: "subscription",
      },
      {
        id: "quick-profile",
        label: "Completar perfil astral",
        description: "Fecha, hora y lugar de nacimiento",
        type: "profile",
      },
    ],
    upcomingBooking: upcoming
      ? {
          id: upcoming.id,
          specialistName: upcoming.specialistName,
          serviceName: upcoming.serviceName,
          scheduledAt: upcoming.scheduledAt,
          status: upcoming.status,
        }
      : null,
    featuredMessage:
      "La mejor primera versión prioriza agenda, contenido diario y una navegación clara por módulo.",
  };
}

export function getPlans(): Plan[] {
  return plans;
}

export function getServices(): ServiceOffer[] {
  return services;
}

export function updateServiceOffer(
  serviceId: string,
  input: UpdateServiceOfferInput,
): ServiceOffer {
  const index = services.findIndex((item) => item.id === serviceId);
  if (index < 0) {
    throw new Error("El servicio no existe.");
  }

  const existing = services[index];
  const amount =
    input.price?.amount === undefined
      ? existing.price.amount
      : Number(input.price.amount);
  if (!Number.isFinite(amount) || amount < 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const durationMinutes =
    input.durationMinutes === undefined
      ? existing.durationMinutes
      : Math.max(0, Math.round(Number(input.durationMinutes)));

  const updated: ServiceOffer = {
    ...existing,
    durationMinutes,
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || existing.price.currency,
    },
  };

  services[index] = updated;
  return updated;
}

export function getSpecialists(): Specialist[] {
  return specialists;
}

export function getCourses(): Course[] {
  return courses;
}

export function getShopOrders(userId?: string): ShopOrder[] {
  const ownerId = resolveShopOwnerId(userId);
  const items = shopOrdersByUserId.get(ownerId) ?? [];

  return [...items].sort((left, right) =>
    right.createdAt.localeCompare(left.createdAt),
  );
}

export function getShopData(userId?: string): ShopData {
  return {
    title: "Shop Renaciente",
    subtitle:
      "Una selección cuidada de productos para acompañar tu espacio y tu práctica.",
    featuredNote:
      "Este catálogo inicial es seed y sirve para validar interés, ticket promedio y familias de producto.",
    supportNote:
      "Las órdenes se generan dentro de la app y quedan listas para pago o coordinación manual.",
    currency: "USD",
    products: shopProducts,
    orders: getShopOrders(userId),
  };
}

export function createShopProduct(input: CreateShopProductInput): ShopProduct {
  const name = input.name?.trim() ?? "";
  const category = input.category?.trim() ?? "";
  const amount = Number(input.price?.amount ?? 0);

  if (name.length < 3) {
    throw new Error("Ingresa un nombre de producto válido.");
  }
  if (category.length < 3) {
    throw new Error("Ingresa una categoría válida.");
  }
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const product: ShopProduct = {
    id: `shop-${slugifyShopValue(name)}-${randomUUID().slice(0, 8)}`,
    name,
    category,
    shortDescription:
      input.shortDescription?.trim() ||
      input.description?.trim() ||
      "Producto agregado desde administración.",
    description:
      input.description?.trim() ||
      input.shortDescription?.trim() ||
      "Producto agregado desde administración de tienda.",
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || "USD",
    },
    imageUrl: input.imageUrl?.trim() ?? "",
    artwork: input.artwork?.trim() || inferShopArtwork(category),
    badge: input.badge?.trim() || "Nuevo",
    featured: input.featured ?? false,
    stockLabel: input.stockLabel?.trim() || "Disponible",
    tags: normalizeShopTags(input.tags),
  };

  shopProducts.unshift(product);
  return product;
}

export function updateShopProduct(
  productId: string,
  input: UpdateShopProductInput,
): ShopProduct {
  const index = shopProducts.findIndex((item) => item.id === productId);
  if (index < 0) {
    throw new Error("El producto no existe.");
  }

  const existing = shopProducts[index];
  const amount =
    input.price?.amount === undefined
      ? existing.price.amount
      : Number(input.price.amount);

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const category = input.category?.trim() || existing.category;
  const updated: ShopProduct = {
    ...existing,
    name: input.name?.trim() || existing.name,
    category,
    shortDescription:
      input.shortDescription?.trim() || existing.shortDescription,
    description: input.description?.trim() || existing.description,
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || existing.price.currency,
    },
    imageUrl: input.imageUrl?.trim() ?? existing.imageUrl,
    artwork:
      input.artwork?.trim() || existing.artwork || inferShopArtwork(category),
    badge: input.badge?.trim() || existing.badge,
    featured: input.featured ?? existing.featured,
    stockLabel: input.stockLabel?.trim() || existing.stockLabel,
    tags:
      input.tags === undefined ? existing.tags : normalizeShopTags(input.tags),
  };

  shopProducts[index] = updated;
  return updated;
}

export function updateShopOrderStatus(
  orderId: string,
  input: UpdateShopOrderStatusInput,
  userId?: string,
): ShopOrder {
  const status = input.status;
  if (!isShopOrderStatus(status)) {
    throw new Error("Selecciona un estado de orden válido.");
  }

  const ownerId = resolveShopOwnerId(userId);
  const orders = shopOrdersByUserId.get(ownerId) ?? [];
  const index = orders.findIndex((item) => item.id === orderId);
  if (index < 0) {
    throw new Error("La orden no existe.");
  }

  const updated: ShopOrder = {
    ...orders[index],
    status,
  };

  orders[index] = updated;
  shopOrdersByUserId.set(ownerId, [...orders]);
  return updated;
}

export function getBookings(userId?: string): Booking[] {
  const user = getUserById(userId);
  const specialistScope =
    user.accountType === "specialist" &&
    Boolean(user.specialistProfileId?.trim());

  return [...bookings]
    .filter((booking) => {
      if (specialistScope) {
        return booking.specialistId === user.specialistProfileId;
      }

      return booking.userId === user.id;
    })
    .sort((left, right) => left.scheduledAt.localeCompare(right.scheduledAt));
}

export function getProfile(userId?: string): UserProfile {
  return getUserById(userId);
}

export function setUserPlan(planId: string, userId?: string): UserProfile {
  const existingUser = getUserById(userId);
  const updatedUser = {
    ...existingUser,
    planId,
  };

  setCurrentUser(updatedUser);
  return updatedUser;
}

export function setBookingStatus(
  bookingId: string,
  status: BookingStatus,
  userId?: string,
): Booking {
  const user = getUserById(userId);
  const specialistScope =
    user.accountType === "specialist" &&
    Boolean(user.specialistProfileId?.trim());
  const bookingIndex = bookings.findIndex(
    (item) =>
      item.id === bookingId &&
      (specialistScope
        ? item.specialistId === user.specialistProfileId
        : item.userId === user.id),
  );

  if (bookingIndex < 0) {
    throw new Error("La reserva no existe.");
  }

  const booking = bookings[bookingIndex];
  if (booking.status === "cancelled") {
    throw new Error("La reserva ya fue cancelada.");
  }
  if (booking.status === "completed") {
    throw new Error("La reserva ya fue completada.");
  }
  if (booking.status === status) {
    return booking;
  }
  if (status === "confirmed" && booking.status !== "pending_payment") {
    throw new Error("La reserva ya no admite este pago.");
  }

  const updatedBooking: Booking = {
    ...booking,
    status,
  };

  bookings[bookingIndex] = updatedBooking;
  return updatedBooking;
}

export function getCurrentSubscription(userId?: string): Subscription {
  const plan = getCurrentPlan(userId);

  return {
    planId: plan.id,
    planName: plan.name,
    status: plan.id === "premium" ? "active" : "inactive",
    renewsAt: plan.id === "premium" ? "2026-04-20T00:00:00-03:00" : null,
    platform: "ios",
    billingProvider: plan.id === "premium" ? "app_store" : "mercado_pago",
    entitlements: plan.features,
  };
}

export function getPaymentsConfig(): PaymentsConfig {
  return paymentsConfig;
}

export function getAdminSummary(): AdminSummary {
  return adminSummary;
}

export function createShopOrder(
  input: CreateShopOrderInput,
  userId?: string,
): ShopOrder {
  const ownerId = resolveShopOwnerId(userId);
  const requestedItems = input.items ?? [];
  if (requestedItems.length === 0) {
    throw new Error("Agrega al menos un producto al carrito.");
  }

  const items: ShopOrderItem[] = requestedItems.map((entry) => {
    const productId = entry.productId?.trim() ?? "";
    const quantity = Math.max(0, entry.quantity ?? 0);
    if (productId.length === 0 || quantity < 1) {
      throw new Error("El carrito contiene un producto inválido.");
    }

    const product = shopProducts.find((item) => item.id === productId);
    if (!product) {
      throw new Error("Uno de los productos ya no está disponible.");
    }

    return {
      productId: product.id,
      productName: product.name,
      category: product.category,
      quantity,
      imageUrl: product.imageUrl,
      unitPrice: cloneMoney(product.price),
      lineTotal: {
        amount: Number((product.price.amount * quantity).toFixed(2)),
        currency: product.price.currency,
      },
    };
  });

  const subtotalAmount = items.reduce(
    (sum, item) => sum + item.lineTotal.amount,
    0,
  );
  const shippingAmount = subtotalAmount >= 120 ? 0 : 9;
  const subtotal = {
    amount: Number(subtotalAmount.toFixed(2)),
    currency: "USD",
  };
  const shipping = { amount: shippingAmount, currency: "USD" };
  const total = {
    amount: Number((subtotal.amount + shipping.amount).toFixed(2)),
    currency: "USD",
  };
  const existingOrders = getShopOrders(ownerId);
  const order: ShopOrder = {
    id: randomUUID(),
    userId: ownerId,
    orderCode: buildOrderCode(existingOrders.length + 1),
    status: "pending",
    createdAt: new Date().toISOString(),
    deliveryAddress:
      (input.deliveryAddress?.trim().length ?? 0) > 0
        ? input.deliveryAddress!.trim()
        : getUserLocationFallback(ownerId),
    notes: input.notes?.trim() ?? "",
    subtotal,
    shipping,
    total,
    itemCount: items.reduce((sum, item) => sum + item.quantity, 0),
    items,
  };

  shopOrdersByUserId.set(ownerId, [order, ...existingOrders]);
  return order;
}

export function getBootstrap(userId?: string): AppBootstrap {
  const user = getUserById(userId);
  const services =
    user.accountType === "specialist" &&
    Boolean(user.specialistProfileId?.trim())
      ? getServices().filter((service) =>
          service.specialistIds.includes(user.specialistProfileId ?? ""),
        )
      : getServices();

  return {
    app: {
      name: "Lo Renaciente",
      tagline: "Autoconocimiento, guía y consultas en un mismo lugar.",
      market: "Perú / Latam",
      timezone: user.timezone,
    },
    user,
    home: getHomePayload(user.id),
    plans: getPlans(),
    subscription: getCurrentSubscription(user.id),
    payments: getPaymentsConfig(),
    services: services,
    specialists: getSpecialists(),
    courses: getCourses(),
    shop: getShopData(user.id),
    bookings: getBookings(user.id),
    admin: getAdminSummary(),
  };
}

export function getUserIdForAccessToken(accessToken?: string): string | null {
  if (!accessToken) {
    return null;
  }

  const session = authSessionsByAccessToken.get(accessToken);
  if (!session || session.expiresAt < Date.now()) {
    if (session) {
      authSessionsByAccessToken.delete(accessToken);
    }

    return null;
  }

  return session.userId;
}

export function getPhoneAuthSession(
  accessToken: string,
): PhoneAuthSessionPayload {
  const session = authSessionsByAccessToken.get(accessToken);

  if (!session || session.expiresAt < Date.now()) {
    throw new Error("La sesión ya no es válida. Solicita un nuevo código.");
  }

  return buildPhoneAuthSessionPayload(session);
}

export function updateCurrentUser(
  input: UpdateUserProfileInput,
  userId?: string,
): UserProfile {
  const existingUser = getUserById(userId);
  const nextBirthDate = normalizeBirthDateInput(
    input.natalChart?.birthDate ?? existingUser.natalChart.birthDate,
  );
  const normalizedNatalChart = input.natalChart
    ? {
        ...input.natalChart,
        birthDate: normalizeBirthDateInput(input.natalChart.birthDate),
      }
    : undefined;
  const requestedZodiacSign = input.zodiacSign?.trim();
  const updatedUser: UserProfile = {
    ...existingUser,
    firstName: input.firstName ?? existingUser.firstName,
    lastName: input.lastName ?? existingUser.lastName,
    nickname: input.nickname ?? existingUser.nickname,
    email: input.email ?? existingUser.email,
    avatarUrl: input.avatarUrl ?? existingUser.avatarUrl,
    location: input.location ?? existingUser.location,
    accountType: input.accountType ?? existingUser.accountType,
    specialistProfileId:
      input.specialistProfileId ?? existingUser.specialistProfileId,
    timezone: input.natalChart?.timeZoneId?.trim() || existingUser.timezone,
    zodiacSign:
      requestedZodiacSign == null
        ? existingUser.zodiacSign
        : requestedZodiacSign.length === 0
          ? inferZodiacSign(nextBirthDate)
          : requestedZodiacSign,
    natalChart: {
      ...existingUser.natalChart,
      ...(normalizedNatalChart ?? {}),
    },
    preferences: {
      ...existingUser.preferences,
      ...(input.preferences ?? {}),
      preferredSessionModes:
        input.preferences?.preferredSessionModes ??
        existingUser.preferences.preferredSessionModes,
      focusAreas:
        input.preferences?.focusAreas ?? existingUser.preferences.focusAreas,
      receivesPush:
        input.preferences?.receivesPush ??
        existingUser.preferences.receivesPush,
    },
  };

  usersById.set(updatedUser.id, updatedUser);
  if (currentUser.id === updatedUser.id) {
    currentUser = updatedUser;
  }

  return updatedUser;
}

export function startPhoneAuth(
  input: PhoneAuthStartInput,
): PhoneAuthStartResult {
  const countryCode = (input.countryCode ?? "").trim().toUpperCase();
  const dialCode = normalizeDialCode(input.dialCode);
  const nationalNumber = normalizeNationalNumber(input.nationalNumber);
  const phoneNumber = `${dialCode}${nationalNumber}`;
  const debugCode = generateMockOtpCode();

  verificationRecordsByPhone.set(phoneNumber, {
    phoneNumber,
    code: debugCode,
    countryCode,
    dialCode,
    expiresAt: Date.now() + 5 * 60 * 1000,
    attemptsRemaining: 3,
  });

  return {
    phoneNumber,
    expiresInSeconds: 300,
    resendInSeconds: 30,
    debugCode,
  };
}

export function verifyPhoneAuth(
  input: PhoneAuthVerifyInput,
): PhoneAuthSessionPayload {
  const phoneNumber = normalizeFullPhoneNumber(input.phoneNumber);
  const submittedCode = (input.code ?? "").trim();
  const verificationRecord = verificationRecordsByPhone.get(phoneNumber);

  if (!verificationRecord) {
    throw new Error("Primero solicita un código para ese teléfono.");
  }

  if (verificationRecord.expiresAt < Date.now()) {
    verificationRecordsByPhone.delete(phoneNumber);
    throw new Error("El código venció. Solicita uno nuevo.");
  }

  if (!/^\d{6}$/.test(submittedCode)) {
    throw new Error("Ingresa un código de 6 dígitos.");
  }

  if (verificationRecord.code !== submittedCode) {
    verificationRecord.attemptsRemaining -= 1;
    if (verificationRecord.attemptsRemaining <= 0) {
      verificationRecordsByPhone.delete(phoneNumber);
      throw new Error("Se agotaron los intentos. Solicita un nuevo código.");
    }

    throw new Error("El código ingresado no coincide.");
  }

  let identity = phoneAuthIdentitiesByPhone.get(phoneNumber);
  let user: UserProfile;

  if (!identity) {
    user = buildPendingPhoneAuthUser(phoneNumber);

    identity = {
      userId: user.id,
      phoneNumber,
      countryCode: verificationRecord.countryCode,
      dialCode: verificationRecord.dialCode,
      profileCompleted: false,
    };

    usersById.set(user.id, user);
    phoneAuthIdentitiesByPhone.set(phoneNumber, identity);
  } else {
    user = getUserById(identity.userId);
  }

  setCurrentUser(user);
  verificationRecordsByPhone.delete(phoneNumber);

  const session: PhoneAuthSessionRecord = {
    accessToken: createOpaqueToken(),
    refreshToken: createOpaqueToken(),
    userId: user.id,
    phoneNumber,
    expiresAt: Date.now() + 30 * 24 * 60 * 60 * 1000,
  };

  authSessionsByAccessToken.set(session.accessToken, session);
  return buildPhoneAuthSessionPayload(session);
}

export function completePhoneProfile(
  accessToken: string,
  input: CompletePhoneProfileInput,
): PhoneAuthSessionPayload {
  const session = authSessionsByAccessToken.get(accessToken);

  if (!session || session.expiresAt < Date.now()) {
    throw new Error(
      "La sesión ya no es válida. Vuelve a verificar tu teléfono.",
    );
  }

  const normalizedLocation =
    input.location?.trim() ||
    [input.city?.trim(), input.country?.trim()].filter(Boolean).join(", ");

  const user = updateCurrentUser(
    {
      firstName: input.firstName?.trim(),
      lastName: input.lastName?.trim(),
      email: input.email?.trim(),
      location: normalizedLocation,
      accountType: input.accountType ?? "client",
      specialistProfileId: "",
      zodiacSign: input.zodiacSign?.trim() || inferZodiacSign(input.birthDate),
      natalChart: {
        subjectName: input.subjectName?.trim(),
        birthDate: normalizeBirthDateInput(input.birthDate),
        birthTime: input.birthTime?.trim(),
        birthTimeUnknown: Boolean(input.birthTimeUnknown),
        city: input.city?.trim(),
        state: input.state?.trim() ?? "",
        country: input.country?.trim(),
        timeZoneId: input.timeZoneId?.trim() ?? "",
        utcOffset: input.utcOffset?.trim() ?? "",
        latitude: typeof input.latitude === "number" ? input.latitude : null,
        longitude: typeof input.longitude === "number" ? input.longitude : null,
      },
    },
    session.userId,
  );

  const identity = getPhoneIdentityByUserId(user.id);
  if (identity) {
    identity.profileCompleted = Boolean(
      user.firstName.trim() &&
      user.lastName.trim() &&
      user.natalChart.birthDate.trim() &&
      user.natalChart.city.trim() &&
      user.natalChart.country.trim() &&
      user.natalChart.timeZoneId.trim() &&
      user.natalChart.utcOffset.trim() &&
      user.natalChart.latitude !== null &&
      user.natalChart.longitude !== null,
    );
  }

  setCurrentUser(user);
  return buildPhoneAuthSessionPayload(session);
}

export function revokePhoneAuthSession(accessToken: string): void {
  authSessionsByAccessToken.delete(accessToken);
}

export function createBooking(
  input: CreateBookingInput,
  userId?: string,
): Booking {
  const user = getUserById(userId);

  if (
    !input.serviceId ||
    !input.specialistId ||
    !input.scheduledAt ||
    !input.mode
  ) {
    throw new Error("Faltan campos obligatorios para crear la reserva.");
  }

  const service = services.find((item) => item.id === input.serviceId);
  if (!service) {
    throw new Error("El servicio no existe.");
  }

  const specialist = specialists.find((item) => item.id === input.specialistId);
  if (!specialist) {
    throw new Error("El especialista no existe.");
  }

  if (!service.specialistIds.includes(specialist.id)) {
    throw new Error("El especialista no ofrece ese servicio.");
  }

  if (!service.deliveryModes.includes(input.mode)) {
    throw new Error("Ese servicio no admite el modo seleccionado.");
  }

  const booking: Booking = {
    id: randomUUID(),
    userId: user.id,
    serviceId: service.id,
    serviceName: service.name,
    specialistId: specialist.id,
    specialistName: specialist.name,
    scheduledAt: input.scheduledAt,
    mode: input.mode,
    status: service.price.amount > 0 ? "pending_payment" : "confirmed",
    price: service.price,
    notes: input.notes ?? "",
  };

  bookings = [booking, ...bookings];
  return booking;
}

export function updateBooking(
  bookingId: string,
  input: UpdateBookingInput,
  userId?: string,
): Booking {
  const user = getUserById(userId);
  const specialistScope =
    user.accountType === "specialist" &&
    Boolean(user.specialistProfileId?.trim());
  const bookingIndex = bookings.findIndex(
    (item) =>
      item.id === bookingId &&
      (specialistScope
        ? item.specialistId === user.specialistProfileId
        : item.userId === user.id),
  );

  if (bookingIndex < 0) {
    throw new Error("La reserva no existe.");
  }

  const booking = bookings[bookingIndex];
  if (booking.status === "cancelled") {
    throw new Error("La reserva ya fue cancelada.");
  }
  if (booking.status === "completed") {
    throw new Error("No se puede modificar una reserva completada.");
  }

  const service = services.find((item) => item.id === booking.serviceId);
  if (!service) {
    throw new Error("El servicio asociado ya no existe.");
  }

  if (input.mode && !service.deliveryModes.includes(input.mode)) {
    throw new Error("Ese servicio no admite el modo seleccionado.");
  }

  if (input.scheduledAt) {
    const parsedDate = new Date(input.scheduledAt);
    if (Number.isNaN(parsedDate.getTime())) {
      throw new Error("La nueva fecha es inválida.");
    }
    if (parsedDate.getTime() <= Date.now()) {
      throw new Error("La nueva fecha debe estar en el futuro.");
    }
  }

  const updatedBooking: Booking = {
    ...booking,
    scheduledAt: input.scheduledAt?.trim() || booking.scheduledAt,
    mode: input.mode ?? booking.mode,
    notes: input.notes ?? booking.notes,
    status: input.status ?? booking.status,
  };

  bookings[bookingIndex] = updatedBooking;
  return updatedBooking;
}
