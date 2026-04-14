create table if not exists file_assets (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  category text not null,
  original_name text not null,
  content_type text not null,
  byte_size bigint not null,
  storage_bucket text not null,
  object_key text not null unique,
  status text not null default 'pending_upload',
  upload_token text,
  upload_token_expires_at timestamptz,
  created_at timestamptz not null default now(),
  uploaded_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists file_assets_user_id_idx
  on file_assets (user_id, created_at desc);

create index if not exists file_assets_status_idx
  on file_assets (status, category);
