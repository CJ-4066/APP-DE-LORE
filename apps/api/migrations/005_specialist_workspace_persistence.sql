create table if not exists service_offer_overrides (
  service_id text primary key,
  price_amount numeric(10, 2) not null,
  price_currency text not null default 'USD',
  duration_minutes integer not null,
  updated_at timestamptz not null default now()
);

create table if not exists shop_product_overrides (
  product_id text primary key,
  name text not null,
  category text not null,
  short_description text not null,
  description text not null,
  price_amount numeric(10, 2) not null,
  price_currency text not null default 'USD',
  image_url text not null default '',
  artwork text not null default '',
  badge text not null default '',
  featured boolean not null default false,
  stock_label text not null default 'Disponible',
  tags jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists shop_orders (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  order_code text not null,
  status text not null,
  created_at timestamptz not null default now(),
  delivery_address text not null default '',
  notes text not null default '',
  subtotal_amount numeric(10, 2) not null,
  subtotal_currency text not null default 'USD',
  shipping_amount numeric(10, 2) not null,
  shipping_currency text not null default 'USD',
  total_amount numeric(10, 2) not null,
  total_currency text not null default 'USD',
  item_count integer not null default 0,
  updated_at timestamptz not null default now()
);

create index if not exists shop_orders_user_id_created_at_idx
  on shop_orders (user_id, created_at desc);

create table if not exists shop_order_items (
  id text primary key,
  order_id text not null references shop_orders(id) on delete cascade,
  product_id text not null,
  product_name text not null,
  category text not null,
  quantity integer not null,
  image_url text not null default '',
  unit_price_amount numeric(10, 2) not null,
  unit_price_currency text not null default 'USD',
  line_total_amount numeric(10, 2) not null,
  line_total_currency text not null default 'USD',
  created_at timestamptz not null default now()
);

create index if not exists shop_order_items_order_id_idx
  on shop_order_items (order_id);
