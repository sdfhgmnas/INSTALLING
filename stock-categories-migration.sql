-- ============================================================
--  Stock categories table + allow stock_transactions to survive
--  item deletion so we keep an audit trail of deletes.
--  Run this ONCE in Supabase -> SQL Editor.
-- ============================================================

-- 1. Categories table (admin-managed)
create table if not exists public.stock_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

-- Seed default categories (idempotent thanks to UNIQUE on name).
insert into public.stock_categories (name) values
  ('GPS'),
  ('SIM-AIRTEL'),
  ('SIM-JIO'),
  ('Sensor'),
  ('Roll'),
  ('Tape'),
  ('Drill'),
  ('Drill beat')
on conflict (name) do nothing;

alter table public.stock_categories enable row level security;

do $$ begin
  create policy "stock_cat_select" on public.stock_categories for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_cat_insert" on public.stock_categories for insert with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_cat_update" on public.stock_categories for update using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_cat_delete" on public.stock_categories for delete using (true);
exception when duplicate_object then null; end $$;

-- 2. Let stock_transactions outlive their stock_items so we keep
--    deletion remarks visible in the audit history.
alter table public.stock_transactions
  alter column stock_item_id drop not null;

alter table public.stock_transactions
  drop constraint if exists stock_transactions_stock_item_id_fkey;

alter table public.stock_transactions
  add constraint stock_transactions_stock_item_id_fkey
    foreign key (stock_item_id)
    references public.stock_items(id)
    on delete set null;

-- 3. Snapshot of the item name at transaction time so deleted items
--    are still identifiable in history views.
alter table public.stock_transactions
  add column if not exists item_name_snapshot text;
