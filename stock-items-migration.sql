-- ============================================================
--  Stock Inventory migration
--  Run this ONCE in Supabase -> SQL Editor before using the
--  Stock page.
--
--  Tracks equipment, spares, consumables: GPS devices, brackets,
--  cables, sensors, antennas, batteries, tools, etc. with quantity,
--  unit, optional cost-per-unit, and optional low-stock threshold.
-- ============================================================

create table if not exists public.stock_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,
  quantity numeric not null default 0,
  unit text not null default 'pcs',
  cost_per_unit numeric,
  low_stock_threshold numeric,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists stock_items_name_idx on public.stock_items (name);
create index if not exists stock_items_category_idx on public.stock_items (category);

alter table public.stock_items enable row level security;

do $$ begin
  create policy "stock_items_select" on public.stock_items for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_items_insert" on public.stock_items for insert with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_items_update" on public.stock_items for update using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_items_delete" on public.stock_items for delete using (true);
exception when duplicate_object then null; end $$;
