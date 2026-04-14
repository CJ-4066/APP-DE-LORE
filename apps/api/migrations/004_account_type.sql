alter table users
  add column if not exists account_type text not null default 'client';

update users
set account_type = 'specialist'
where id in (
  select user_id
  from user_roles
  where role = 'specialist' or role = 'admin'
);

