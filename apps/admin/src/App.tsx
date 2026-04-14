import { useEffect, useState } from "react";

import "./App.css";

type HealthResponse = {
  status: string;
  dependencies: {
    database: { status: string };
    redis: { status: string };
    storage: { status: string };
  };
};

type AdminSummary = {
  activeUsers: number;
  premiumSubscribers: number;
  monthlyBookings: number;
  activeSpecialists: number;
  openIncidents: number;
  openChatThreads: number;
  registeredPushDevices: number;
  pendingPaymentBookings: number;
};

type AdminBooking = {
  id: string;
  userName: string;
  serviceName: string;
  specialistName: string;
  scheduledAt: string;
  status: string;
  mode: string;
};

type AdminUser = {
  id: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  planId: string;
  profileCompleted: boolean;
  createdAt: string;
};

type AdminChat = {
  totalThreads: number;
  openThreads: number;
  totalMessages: number;
  recentThreads: Array<{
    id: string;
    userName: string;
    specialistName: string;
    status: string;
    lastMessageAt: string | null;
    lastMessagePreview: string;
  }>;
};

const apiBaseUrl =
  (import.meta.env.VITE_API_BASE_URL as string | undefined)?.trim() ||
  "http://127.0.0.1:4000";
const adminTokenStorageKey = "lo_renaciente_admin_token";

function formatDate(value: string): string {
  return new Intl.DateTimeFormat("es-PE", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));
}

function App() {
  const [adminToken, setAdminToken] = useState(
    () => window.localStorage.getItem(adminTokenStorageKey) ?? "",
  );
  const [health, setHealth] = useState<HealthResponse | null>(null);
  const [summary, setSummary] = useState<AdminSummary | null>(null);
  const [bookings, setBookings] = useState<AdminBooking[]>([]);
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [chat, setChat] = useState<AdminChat | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const adminHeaders =
          adminToken.trim().length > 0
            ? { authorization: `Bearer ${adminToken.trim()}` }
            : undefined;
        const [healthResponse, summaryResponse, bookingsResponse, usersResponse, chatResponse] =
          await Promise.all([
            fetch(`${apiBaseUrl}/health`),
            fetch(`${apiBaseUrl}/api/admin/summary`, { headers: adminHeaders }),
            fetch(`${apiBaseUrl}/api/admin/bookings?limit=6`, {
              headers: adminHeaders,
            }),
            fetch(`${apiBaseUrl}/api/admin/users?limit=6`, {
              headers: adminHeaders,
            }),
            fetch(`${apiBaseUrl}/api/admin/chat?limit=6`, {
              headers: adminHeaders,
            }),
          ]);

        if (
          !healthResponse.ok ||
          !summaryResponse.ok ||
          !bookingsResponse.ok ||
          !usersResponse.ok ||
          !chatResponse.ok
        ) {
          throw new Error("El panel admin no pudo cargar la API.");
        }

        const [healthJson, summaryJson, bookingsJson, usersJson, chatJson] = await Promise.all([
          healthResponse.json() as Promise<HealthResponse>,
          summaryResponse.json() as Promise<{ item: AdminSummary }>,
          bookingsResponse.json() as Promise<{ items: AdminBooking[] }>,
          usersResponse.json() as Promise<{ items: AdminUser[] }>,
          chatResponse.json() as Promise<{ item: AdminChat }>,
        ]);

        if (!cancelled) {
          setHealth(healthJson);
          setSummary(summaryJson.item);
          setBookings(bookingsJson.items);
          setUsers(usersJson.items);
          setChat(chatJson.item);
          setError(null);
        }
      } catch (loadError) {
        if (!cancelled) {
          setError(
            loadError instanceof Error
              ? loadError.message
              : "No se pudo cargar el panel admin.",
          );
        }
      }
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [adminToken]);

  function handleTokenChange(nextValue: string) {
    setAdminToken(nextValue);
    window.localStorage.setItem(adminTokenStorageKey, nextValue);
  }

  return (
    <main className="admin-shell">
      <section className="admin-hero">
        <div>
          <p className="eyebrow">Lo Renaciente Admin</p>
          <h1>Operacion, agenda y salud tecnica en una sola vista</h1>
          <p className="hero-copy">
            Base separada para soporte, monitoreo comercial, disponibilidad y supervision
            operativa sobre la misma API.
          </p>
          <div className="token-panel">
            <label htmlFor="admin-token">Bearer token admin</label>
            <textarea
              id="admin-token"
              value={adminToken}
              onChange={(event) => handleTokenChange(event.target.value)}
              placeholder="Pega aqui el access token de un usuario con rol admin"
              rows={3}
            />
            <p className="token-help">
              Usa el token del usuario admin para consultar `/api/admin/*`.
            </p>
          </div>
        </div>

        <div className="hero-status">
          <div className="status-card">
            <span>API</span>
            <strong>{health?.status ?? "cargando"}</strong>
          </div>
          <div className="status-card">
            <span>DB</span>
            <strong>{health?.dependencies.database.status ?? "..."}</strong>
          </div>
          <div className="status-card">
            <span>Redis</span>
            <strong>{health?.dependencies.redis.status ?? "..."}</strong>
          </div>
          <div className="status-card">
            <span>Storage</span>
            <strong>{health?.dependencies.storage.status ?? "..."}</strong>
          </div>
        </div>
      </section>

      {error ? (
        <section className="admin-panel admin-error">
          <h2>Conexion pendiente</h2>
          <p>{error}</p>
          <code>{apiBaseUrl}</code>
        </section>
      ) : null}

      <section className="metric-grid">
        <article className="metric-card">
          <span>Usuarios activos</span>
          <strong>{summary?.activeUsers ?? 0}</strong>
        </article>
        <article className="metric-card">
          <span>Premium</span>
          <strong>{summary?.premiumSubscribers ?? 0}</strong>
        </article>
        <article className="metric-card">
          <span>Reservas del mes</span>
          <strong>{summary?.monthlyBookings ?? 0}</strong>
        </article>
        <article className="metric-card">
          <span>Pagos pendientes</span>
          <strong>{summary?.pendingPaymentBookings ?? 0}</strong>
        </article>
        <article className="metric-card">
          <span>Chats abiertos</span>
          <strong>{summary?.openChatThreads ?? 0}</strong>
        </article>
        <article className="metric-card">
          <span>Push devices</span>
          <strong>{summary?.registeredPushDevices ?? 0}</strong>
        </article>
      </section>

      <section className="admin-grid">
        <article className="admin-panel">
          <div className="panel-head">
            <p className="eyebrow">Reservas</p>
            <h2>Ultimos movimientos</h2>
          </div>
          <div className="table-list">
            {bookings.map((booking) => (
              <div key={booking.id} className="table-row">
                <div>
                  <strong>{booking.serviceName}</strong>
                  <p>{booking.userName}</p>
                </div>
                <div>
                  <strong>{booking.specialistName}</strong>
                  <p>{formatDate(booking.scheduledAt)}</p>
                </div>
                <div className="align-right">
                  <strong>{booking.status}</strong>
                  <p>{booking.mode}</p>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="admin-panel">
          <div className="panel-head">
            <p className="eyebrow">Usuarios</p>
            <h2>Alta reciente</h2>
          </div>
          <div className="table-list">
            {users.map((user) => (
              <div key={user.id} className="table-row">
                <div>
                  <strong>{user.fullName || user.id}</strong>
                  <p>{user.email || "sin email"}</p>
                </div>
                <div>
                  <strong>{user.planId}</strong>
                  <p>{user.phoneNumber || "sin telefono"}</p>
                </div>
                <div className="align-right">
                  <strong>{user.profileCompleted ? "perfil completo" : "perfil pendiente"}</strong>
                  <p>{formatDate(user.createdAt)}</p>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="admin-panel admin-panel-wide">
          <div className="panel-head">
            <p className="eyebrow">Chat 1:1</p>
            <h2>Hilos recientes</h2>
          </div>
          <div className="chat-summary">
            <span>Total hilos: {chat?.totalThreads ?? 0}</span>
            <span>Abiertos: {chat?.openThreads ?? 0}</span>
            <span>Mensajes: {chat?.totalMessages ?? 0}</span>
          </div>
          <div className="table-list">
            {chat?.recentThreads.map((thread) => (
              <div key={thread.id} className="table-row">
                <div>
                  <strong>{thread.userName}</strong>
                  <p>{thread.specialistName}</p>
                </div>
                <div>
                  <strong>{thread.status}</strong>
                  <p>{thread.lastMessageAt ? formatDate(thread.lastMessageAt) : "sin mensajes"}</p>
                </div>
                <div className="align-right">
                  <strong>Preview</strong>
                  <p>{thread.lastMessagePreview || "sin contenido"}</p>
                </div>
              </div>
            )) ?? null}
          </div>
        </article>
      </section>
    </main>
  );
}

export default App;
