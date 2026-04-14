create table if not exists user_roles (
  user_id text not null references users(id) on delete cascade,
  role text not null,
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

create table if not exists user_subscriptions (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  plan_id text not null,
  status text not null,
  platform text not null,
  billing_provider text not null,
  started_at timestamptz not null default now(),
  renews_at timestamptz,
  cancelled_at timestamptz,
  cancel_reason text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_subscriptions_user_id_idx
  on user_subscriptions (user_id, created_at desc);

create table if not exists payment_transactions (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  kind text not null,
  plan_id text,
  booking_id text,
  amount numeric(10, 2) not null,
  currency text not null,
  provider text not null,
  platform text not null,
  method text not null,
  status text not null default 'pending',
  reference_code text not null unique,
  approval_code text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now(),
  confirmed_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint payment_transactions_target_check check (
    (plan_id is not null and booking_id is null) or
    (plan_id is null and booking_id is not null)
  )
);

create index if not exists payment_transactions_user_id_idx
  on payment_transactions (user_id, created_at desc);

create index if not exists payment_transactions_status_idx
  on payment_transactions (status, kind);

insert into user_roles (
  user_id,
  role
) values (
  'user-mark',
  'admin'
) on conflict (user_id, role) do nothing;
