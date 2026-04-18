import { useEffect, useState } from "react";

import "./App.css";

type HealthResponse = {
  status: string;
  timestamp: string;
};

type BootstrapResponse = {
  app: {
    name: string;
    tagline: string;
    market: string;
    timezone: string;
  };
  home: {
    welcomeTitle: string;
    welcomeSubtitle: string;
    featuredMessage: string;
    cardOfTheDay: {
      title: string;
      cardName: string;
      message: string;
      ritual: string;
      imageUrl: string;
    };
    upcomingBooking: null | {
      specialistName: string;
      serviceName: string;
      scheduledAt: string;
      status: string;
    };
  };
  services: Array<{
    id: string;
    name: string;
    category: string;
    description: string;
    durationMinutes: number;
    price: {
      amount: number;
      currency: string;
    };
  }>;
  specialists: Array<{
    id: string;
    name: string;
    headline: string;
    specialties: string[];
    featured: boolean;
    nextAvailableAt: string;
  }>;
  plans: Array<{
    id: string;
    name: string;
    tier: string;
    priceMonthly: number;
    currency: string;
    features: string[];
  }>;
  bookings: Array<{
    id: string;
    serviceName: string;
    specialistName: string;
    scheduledAt: string;
    status: string;
    mode: string;
  }>;
};

const guestBootstrap: BootstrapResponse = {
  app: {
    name: "Lo Renaciente",
    tagline: "Autoconocimiento, guía y consultas en un mismo lugar.",
    market: "Perú / Latam",
    timezone: "America/Lima",
  },
  home: {
    welcomeTitle: "Hola, visitante",
    welcomeSubtitle: "Explora tarot, astrología, agenda y contenido premium desde la experiencia web.",
    featuredMessage: "La experiencia web ya puede mostrar oferta, especialistas y agenda base aunque todavía no haya sesión iniciada.",
    cardOfTheDay: {
      title: "Carta del día",
      cardName: "La Estrella",
      message: "Hoy conviene bajar el ruido, volver a tu centro y avanzar con una decisión pequeña pero muy clara.",
      ritual: "Escribe una intención breve antes de abrir tu jornada.",
      imageUrl: "",
    },
    upcomingBooking: {
      specialistName: "Amaya Rivas",
      serviceName: "Lectura de tarot terapéutico",
      scheduledAt: "2026-04-24T19:00:00-05:00",
      status: "confirmed",
    },
  },
  services: [
    {
      id: "service-tarot",
      name: "Lectura de tarot terapéutico",
      category: "Tarot",
      description: "Sesión enfocada en claridad emocional, decisiones y cierres de ciclo.",
      durationMinutes: 45,
      price: {
        amount: 32,
        currency: "USD",
      },
    },
    {
      id: "service-astro",
      name: "Astrología natal personalizada",
      category: "Astrología",
      description: "Lectura de carta natal con foco en identidad, relaciones y timing.",
      durationMinutes: 60,
      price: {
        amount: 48,
        currency: "USD",
      },
    },
    {
      id: "service-numerologia",
      name: "Consulta de numerología",
      category: "Numerología",
      description: "Interpretación de ciclos, talentos y aprendizajes por vibración numérica.",
      durationMinutes: 40,
      price: {
        amount: 29,
        currency: "USD",
      },
    },
  ],
  specialists: [
    {
      id: "spec-amaya",
      name: "Amaya Rivas",
      headline: "Tarot terapéutico y lectura intuitiva",
      specialties: ["Tarot", "Procesos emocionales", "Rituales de cierre"],
      featured: true,
      nextAvailableAt: "2026-04-24T19:00:00-05:00",
    },
    {
      id: "spec-elian",
      name: "Elian Duarte",
      headline: "Astrología natal, sinastría y ciclos",
      specialties: ["Astrología natal", "Sinastría", "Revolución solar"],
      featured: true,
      nextAvailableAt: "2026-04-26T18:30:00-05:00",
    },
  ],
  plans: [
    {
      id: "free",
      name: "Free",
      tier: "free",
      priceMonthly: 0,
      currency: "USD",
      features: [
        "Carta del día",
        "Energía astrológica básica",
        "Agenda limitada",
        "Chat con límite mensual",
      ],
    },
    {
      id: "premium",
      name: "Premium",
      tier: "premium",
      priceMonthly: 14.99,
      currency: "USD",
      features: [
        "Cursos premium",
        "Biblioteca completa",
        "Más sesiones por mes",
        "Acceso anticipado a contenidos",
      ],
    },
  ],
  bookings: [
    {
      id: "booking-guest-1",
      serviceName: "Lectura de tarot terapéutico",
      specialistName: "Amaya Rivas",
      scheduledAt: "2026-04-24T19:00:00-05:00",
      status: "confirmed",
      mode: "video",
    },
  ],
};

function resolveApiBaseUrl(): string {
  const envOverride = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim();
  if (envOverride) {
    return envOverride.replace(/\/+$/, "");
  }

  if (typeof window === "undefined") {
    return "http://127.0.0.1:4000";
  }

  const protocol = window.location.protocol === "https:" ? "https:" : "http:";
  const hostname = window.location.hostname === "0.0.0.0" ? "127.0.0.1" : window.location.hostname;
  return `${protocol}//${hostname}:4000`;
}

const apiBaseUrl = resolveApiBaseUrl();

function resolveAssetUrl(value: string | undefined): string {
  const trimmed = value?.trim() ?? "";
  if (!trimmed || trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
    return trimmed;
  }

  return new URL(trimmed, `${apiBaseUrl}/`).toString();
}

function formatSchedule(value: string): string {
  return new Intl.DateTimeFormat("es-PE", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

function formatMoney(amount: number, currency: string): string {
  return new Intl.NumberFormat("es-PE", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

function App() {
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [data, setData] = useState<BootstrapResponse | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [expandedCardImageUrl, setExpandedCardImageUrl] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const healthResponse = await fetch(`${apiBaseUrl}/health`);
        if (!healthResponse.ok) {
          throw new Error("La app web no pudo alcanzar la API local.");
        }

        const healthJson = (await healthResponse.json()) as HealthResponse;
        if (!cancelled) {
          setHealth(healthJson);
        }

        const bootstrapResponse = await fetch(`${apiBaseUrl}/api/bootstrap`);
        if (bootstrapResponse.status === 401) {
          if (!cancelled) {
            setData(guestBootstrap);
            setNotice(
              "La API local esta activa. Estas viendo el modo invitado de la web mientras conectamos el inicio de sesion en navegador.",
            );
            setError(null);
          }
          return;
        }

        if (!bootstrapResponse.ok) {
          throw new Error("La API local respondio, pero el bootstrap web fallo.");
        }

        const bootstrapJson = (await bootstrapResponse.json()) as BootstrapResponse;

        if (!cancelled) {
          setData(bootstrapJson);
          setNotice(null);
          setError(null);
        }
      } catch (loadError) {
        if (!cancelled) {
          setError(
            loadError instanceof Error
              ? loadError.message
              : "No se pudo cargar la app web.",
          );
          setNotice(null);
        }
      }
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, []);

  const featuredSpecialists = data?.specialists.filter((item) => item.featured) ?? [];
  const highlightedServices = data?.services.slice(0, 4) ?? [];
  const highlightedPlans = data?.plans.slice(0, 2) ?? [];
  const recentBookings = data?.bookings.slice(0, 3) ?? [];
  const dailyCardImageUrl = resolveAssetUrl(data?.home.cardOfTheDay.imageUrl);

  return (
    <main className="web-shell">
      <div className="ambient ambient-left" />
      <div className="ambient ambient-right" />

      <section className="hero-panel">
        <div className="hero-copy">
          <p className="eyebrow">Lo Renaciente Web</p>
          <h1>{data?.app.name ?? "Portal web conectado a la API"}</h1>
          <p className="hero-text">
            {data?.app.tagline ??
              "Base web separada para contenido, agenda y conversion premium sobre la misma API."}
          </p>
          <div className="hero-meta">
            <span>{data?.app.market ?? "Peru / Latam"}</span>
            <span>{data?.app.timezone ?? "America/Lima"}</span>
            <span className={`status-pill status-${health?.status ?? "loading"}`}>
              API {health?.status ?? "cargando"}
            </span>
          </div>
        </div>

        <div className="hero-card">
          <p className="card-label">{data?.home.cardOfTheDay.title ?? "Carta del dia"}</p>
          {dailyCardImageUrl ? (
            <button
              type="button"
              className="daily-card-image-button"
              onClick={() => setExpandedCardImageUrl(dailyCardImageUrl)}
            >
              <img
                className="daily-card-image"
                src={dailyCardImageUrl}
                alt={data?.home.cardOfTheDay.cardName ?? "Carta del dia"}
              />
            </button>
          ) : null}
          <h2>{data?.home.cardOfTheDay.cardName ?? "Carta del dia"}</h2>
          <p>
            {data?.home.cardOfTheDay.message ??
              "La carta del dia aparecera aqui cuando la API devuelva contenido."}
          </p>
          <p className="featured-copy">
            {data?.home.cardOfTheDay.ritual
              ? `Ritual: ${data.home.cardOfTheDay.ritual}`
              : data?.home.featuredMessage ??
                "Una app web separada debe vender claridad, ritmo y conversion."}
          </p>
          <dl>
            <div>
              <dt>Servicios</dt>
              <dd>{data?.services.length ?? 0}</dd>
            </div>
            <div>
              <dt>Especialistas</dt>
              <dd>{data?.specialists.length ?? 0}</dd>
            </div>
            <div>
              <dt>Reservas</dt>
              <dd>{data?.bookings.length ?? 0}</dd>
            </div>
          </dl>
        </div>
      </section>

      {error ? (
        <section className="message-panel error-panel">
          <h2>Conexion pendiente</h2>
          <p>{error}</p>
          <code>{apiBaseUrl}</code>
        </section>
      ) : null}

      {notice ? (
        <section className="message-panel">
          <h2>Modo invitado</h2>
          <p>{notice}</p>
          <code>{apiBaseUrl}</code>
        </section>
      ) : null}

      <section className="content-grid">
        <article className="panel spotlight-panel">
          <p className="section-kicker">Agenda web</p>
          <h2>Reservas visibles para adquisicion y seguimiento</h2>
          {data?.home.upcomingBooking ? (
            <div className="appointment-card">
              <strong>{data.home.upcomingBooking.serviceName}</strong>
              <span>{data.home.upcomingBooking.specialistName}</span>
              <span>{formatSchedule(data.home.upcomingBooking.scheduledAt)}</span>
              <span className="micro-chip">{data.home.upcomingBooking.status}</span>
            </div>
          ) : (
            <p className="muted-copy">Todavia no hay una reserva destacada en la respuesta bootstrap.</p>
          )}

          <div className="mini-list">
            {recentBookings.map((booking) => (
              <div key={booking.id} className="mini-list-row">
                <div>
                  <strong>{booking.serviceName}</strong>
                  <p>{booking.specialistName}</p>
                </div>
                <div className="mini-list-meta">
                  <span>{formatSchedule(booking.scheduledAt)}</span>
                  <span>{booking.mode}</span>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="panel">
          <p className="section-kicker">Oferta</p>
          <h2>Servicios listos para la capa web</h2>
          <div className="stack-list">
            {highlightedServices.map((service) => (
              <div key={service.id} className="stack-item">
                <div>
                  <strong>{service.name}</strong>
                  <p>{service.description}</p>
                </div>
                <div className="stack-aside">
                  <span>{service.category}</span>
                  <span>{service.durationMinutes} min</span>
                  <span>{formatMoney(service.price.amount, service.price.currency)}</span>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="panel">
          <p className="section-kicker">Equipo</p>
          <h2>Especialistas destacados</h2>
          <div className="stack-list">
            {featuredSpecialists.map((specialist) => (
              <div key={specialist.id} className="stack-item">
                <div>
                  <strong>{specialist.name}</strong>
                  <p>{specialist.headline}</p>
                </div>
                <div className="stack-aside">
                  <span>{specialist.specialties.slice(0, 2).join(" / ")}</span>
                  <span>{formatSchedule(specialist.nextAvailableAt)}</span>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="panel premium-panel">
          <p className="section-kicker">Monetizacion</p>
          <h2>Planes listos para venta web</h2>
          <div className="plan-grid">
            {highlightedPlans.map((plan) => (
              <div key={plan.id} className="plan-card">
                <span className="plan-tier">{plan.tier}</span>
                <strong>{plan.name}</strong>
                <p>{formatMoney(plan.priceMonthly, plan.currency)}/mes</p>
                <ul>
                  {plan.features.slice(0, 4).map((feature) => (
                    <li key={feature}>{feature}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </article>
      </section>

      {expandedCardImageUrl ? (
        <div
          className="card-lightbox"
          role="dialog"
          aria-modal="true"
          aria-label="Vista ampliada de la carta"
          onClick={() => setExpandedCardImageUrl(null)}
        >
          <button
            type="button"
            className="card-lightbox-close"
            onClick={() => setExpandedCardImageUrl(null)}
            aria-label="Cerrar carta"
          >
            Cerrar
          </button>
          <img
            className="card-lightbox-image"
            src={expandedCardImageUrl}
            alt={data?.home.cardOfTheDay.cardName ?? "Carta del dia"}
            onClick={(event) => event.stopPropagation()}
          />
        </div>
      ) : null}
    </main>
  );
}

export default App;
