alter table shop_product_overrides
  add column if not exists specialist_id text not null default 'spec-amaya',
  add column if not exists specialist_name text not null default 'Amaya Rivas',
  add column if not exists store_id text not null default 'store-spec-amaya',
  add column if not exists store_name text not null default 'Tienda de Amaya Rivas',
  add column if not exists stock_quantity integer not null default 9,
  add column if not exists made_to_order boolean not null default false;

update shop_product_overrides
set specialist_id = 'spec-amaya'
where trim(specialist_id) = '';

update shop_product_overrides
set specialist_name = 'Amaya Rivas'
where trim(specialist_name) = '';

update shop_product_overrides
set store_id = 'store-' || specialist_id
where trim(store_id) = ''
  and trim(specialist_id) <> '';

update shop_product_overrides
set store_name = 'Tienda de ' || specialist_name
where trim(store_name) = ''
  and trim(specialist_name) <> '';

update shop_product_overrides
set made_to_order = position('pedido' in lower(stock_label)) > 0;

update shop_product_overrides
set stock_quantity = case
  when made_to_order then 0
  when position('agotado' in lower(stock_label)) > 0 then 0
  when position('pocas' in lower(stock_label)) > 0 then 3
  when position('ultim' in lower(stock_label)) > 0 then 3
  when position('nueva' in lower(stock_label)) > 0 then 7
  else 9
end;

create index if not exists shop_product_overrides_specialist_id_idx
  on shop_product_overrides (specialist_id, category, featured);

alter table shop_orders
  add column if not exists specialist_id text not null default 'spec-amaya',
  add column if not exists specialist_name text not null default 'Amaya Rivas',
  add column if not exists store_id text not null default 'store-spec-amaya',
  add column if not exists store_name text not null default 'Tienda de Amaya Rivas';

update shop_orders
set specialist_id = 'spec-amaya'
where trim(specialist_id) = '';

update shop_orders
set specialist_name = 'Amaya Rivas'
where trim(specialist_name) = '';

update shop_orders
set store_id = 'store-' || specialist_id
where trim(store_id) = ''
  and trim(specialist_id) <> '';

update shop_orders
set store_name = 'Tienda de ' || specialist_name
where trim(store_name) = ''
  and trim(specialist_name) <> '';

create index if not exists shop_orders_specialist_id_created_at_idx
  on shop_orders (specialist_id, created_at desc);
