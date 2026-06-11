-- ============================================================
--  Suppliers + supplier on stock_items + maintenance_record_id
--  on stock_transactions.
--  Run this ONCE in Supabase -> SQL Editor.
-- ============================================================

-- 1. Suppliers table (admin-managed list)
create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

alter table public.suppliers enable row level security;

do $$ begin
  create policy "suppliers_select" on public.suppliers for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "suppliers_insert" on public.suppliers for insert with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "suppliers_update" on public.suppliers for update using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "suppliers_delete" on public.suppliers for delete using (true);
exception when duplicate_object then null; end $$;

-- 2. Stock items: supplier column
alter table public.stock_items
  add column if not exists supplier text;
create index if not exists stock_items_supplier_idx
  on public.stock_items (supplier);

-- 3. Stock transactions: link to maintenance_record so deleting a repair
--    can precisely restore the stock that was consumed by that repair.
alter table public.stock_transactions
  add column if not exists maintenance_record_id uuid
    references public.maintenance_records(id) on delete set null;
create index if not exists stock_tx_maint_idx
  on public.stock_transactions (maintenance_record_id);
