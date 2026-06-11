-- ============================================================
--  Deletion audit log: every delete operation (with reason)
--  is recorded here so admin can review all destructive
--  actions performed by any user.
--  Run this ONCE in Supabase -> SQL Editor.
-- ============================================================

create table if not exists public.deletion_log (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,             -- 'installation' | 'maintenance' | 'stock_item' | 'sim' | 'category' | 'supplier'
  entity_id text,                        -- original ID of the deleted row
  entity_label text,                     -- short human label, e.g. "VEHICLE-MP17ZL1066 · 867530..."
  reason text,
  deleted_by text,
  snapshot jsonb,                        -- full original data for forensics
  deleted_at timestamptz not null default now()
);

create index if not exists deletion_log_at_idx on public.deletion_log (deleted_at desc);
create index if not exists deletion_log_type_idx on public.deletion_log (entity_type);

alter table public.deletion_log enable row level security;

do $$ begin
  create policy "del_log_select" on public.deletion_log for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "del_log_insert" on public.deletion_log for insert with check (true);
exception when duplicate_object then null; end $$;
-- No update/delete policies — audit log is immutable.
