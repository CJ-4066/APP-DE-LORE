create table if not exists users (
  id text primary key,
  first_name text not null default '',
  last_name text not null default '',
  nickname text not null default '',
  email text not null default '',
  avatar_url text not null default '',
  location text not null default '',
  timezone text not null default 'America/Lima',
  zodiac_sign text not null default '',
  plan_id text not null default 'free',
  subject_name text not null default '',
  birth_date text not null default '',
  birth_time text not null default '',
  birth_time_unknown boolean not null default false,
  city text not null default '',
  state text not null default '',
  country text not null default '',
  time_zone_id text not null default '',
  utc_offset text not null default '',
  latitude double precision,
  longitude double precision,
  focus_areas jsonb not null default '[]'::jsonb,
  preferred_session_modes jsonb not null default '[]'::jsonb,
  receives_push boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists phone_auth_identities (
  phone_number text primary key,
  user_id text not null references users(id) on delete cascade,
  country_code text not null default '',
  dial_code text not null default '',
  profile_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

create table if not exists phone_verification_codes (
  phone_number text primary key,
  code text not null,
  country_code text not null default '',
  dial_code text not null default '',
  expires_at timestamptz not null,
  attempts_remaining integer not null,
  created_at timestamptz not null default now()
);

create table if not exists auth_sessions (
  access_token text primary key,
  refresh_token text not null unique,
  user_id text not null references users(id) on delete cascade,
  phone_number text not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists auth_sessions_user_id_idx
  on auth_sessions (user_id);

create index if not exists auth_sessions_expires_at_idx
  on auth_sessions (expires_at);

create table if not exists bookings (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  service_id text not null,
  service_name text not null,
  specialist_id text not null,
  specialist_name text not null,
  scheduled_at timestamptz not null,
  mode text not null,
  status text not null,
  price_amount numeric(10, 2) not null,
  price_currency text not null,
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists bookings_user_id_idx
  on bookings (user_id);

create index if not exists bookings_scheduled_at_idx
  on bookings (scheduled_at);

create table if not exists specialist_availability (
  id text primary key,
  specialist_id text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  mode text not null,
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists specialist_availability_specialist_id_idx
  on specialist_availability (specialist_id, starts_at);

create table if not exists push_devices (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  platform text not null,
  push_token text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists chat_threads (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  specialist_id text not null,
  booking_id text,
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists chat_messages (
  id text primary key,
  thread_id text not null references chat_threads(id) on delete cascade,
  author_type text not null,
  author_id text not null,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists chat_messages_thread_id_idx
  on chat_messages (thread_id, created_at);

create table if not exists audit_logs (
  id text primary key,
  actor_type text not null,
  actor_id text not null,
  event_type text not null,
  entity_type text not null,
  entity_id text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

insert into users (
  id,
  first_name,
  last_name,
  nickname,
  email,
  avatar_url,
  location,
  timezone,
  zodiac_sign,
  plan_id,
  subject_name,
  birth_date,
  birth_time,
  birth_time_unknown,
  city,
  state,
  country,
  time_zone_id,
  utc_offset,
  latitude,
  longitude,
  focus_areas,
  preferred_session_modes,
  receives_push
) values (
  'user-mark',
  'Mark',
  'Lore',
  'mark',
  'mark@example.com',
  '',
  'Lima, Peru',
  'America/Lima',
  'Sagitario',
  'free',
  'Mark',
  '2000-11-28',
  '01:40',
  false,
  'Lima',
  'Lima',
  'Peru',
  'America/Lima',
  '-05:00',
  -12.0464,
  -77.0428,
  '["claridad", "proposito", "vinculos"]'::jsonb,
  '["chat", "video"]'::jsonb,
  true
) on conflict (id) do nothing;

insert into phone_auth_identities (
  phone_number,
  user_id,
  country_code,
  dial_code,
  profile_completed
) values (
  '+59891111111',
  'user-mark',
  'UY',
  '+598',
  true
) on conflict (phone_number) do nothing;

insert into bookings (
  id,
  user_id,
  service_id,
  service_name,
  specialist_id,
  specialist_name,
  scheduled_at,
  mode,
  status,
  price_amount,
  price_currency,
  notes
) values
(
  'booking-1',
  'user-mark',
  'service-tarot',
  'Lectura de tarot terapeutico',
  'spec-amaya',
  'Amaya Rivas',
  '2026-03-24T22:00:00Z',
  'video',
  'confirmed',
  32.00,
  'USD',
  'Quiero trabajar claridad sobre una decision profesional.'
),
(
  'booking-2',
  'user-mark',
  'service-astro',
  'Astrologia natal personalizada',
  'spec-elian',
  'Elian Duarte',
  '2026-03-28T21:30:00Z',
  'audio',
  'pending_payment',
  48.00,
  'USD',
  'Revisar transitos y energia del trimestre.'
)
on conflict (id) do nothing;
