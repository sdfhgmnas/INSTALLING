-- ============================================================
--  SIM Database migration
--  Run this ONCE in Supabase -> SQL Editor before using the
--  new standalone SIM database / SIM Upload workflow.
--
--  Model:
--    A "SIM" is a single physical card with two numbers:
--      - primary_number    (typically 13-digit, the displayed SIM no.)
--      - secondary_number  (typically 19-20 digit, the ICCID printed on the card)
--    Akash enters the secondary number in the field; the app looks up
--    the primary from this table automatically.
-- ============================================================

create table if not exists public.sims (
  id uuid primary key default gen_random_uuid(),
  primary_number text,
  secondary_number text not null unique,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sims_primary_number_idx
  on public.sims (primary_number);

alter table public.sims enable row level security;

-- Permissive policies that match the existing project's posture
-- (public read/write via anon key). Tighten later when adding Supabase Auth.
do $$ begin
  create policy "sims_select" on public.sims for select using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "sims_insert" on public.sims for insert with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "sims_update" on public.sims for update using (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "sims_delete" on public.sims for delete using (true);
exception when duplicate_object then null; end $$;
