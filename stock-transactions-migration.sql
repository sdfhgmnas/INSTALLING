-- ============================================================
--  Stock Transactions migration
--  Run this ONCE in Supabase -> SQL Editor after the
--  stock-items-migration has been applied.
--
--  Records every stock adjustment (receive or use), optionally
--  linked to an installation, so the Stock page can show
--  "Used in VEHICLE-X" and a full history per item.
-- ============================================================

create table if not exists public.stock_transactions (
  id uuid primary key default gen_random_uuid(),
  stock_item_id uuid not null references public.stock_items(id) on delete cascade,
  installation_id uuid references public.installations(id) on delete set null,
  vehicle_no text,                       -- denormalized so display works even if the install is later edited / deleted
  delta numeric not null,                -- + receive, - use
  resulting_quantity numeric,            -- snapshot of the stock_items.quantity right after this adjustment
  note text,
  created_by text,
  created_at timestamptz not null default now()
);

create index if not exists stock_tx_stock_item_idx
  on public.stock_transactions (stock_item_id, created_at desc);
create index if not exists stock_tx_installation_idx
  on public.stock_transactions (installation_id);
create index if not exists stock_tx_vehicle_no_idx
  on public.stock_transactions (vehicle_no);

alter table public.stock_transactions enable row level security;

do $$ begin
  create policy "stock_tx_select" on public.stock_transactions for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_tx_insert" on public.stock_transactions for insert with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_tx_update" on public.stock_transactions for update using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "stock_tx_delete" on public.stock_transactions for delete using (true);
exception when duplicate_object then null; end $$;
