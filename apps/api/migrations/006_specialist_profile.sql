alter table users
  add column if not exists specialist_profile_id text not null default '';

update users
set specialist_profile_id = 'spec-amaya'
where id = 'user-mark'
  and specialist_profile_id = '';
