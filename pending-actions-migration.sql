-- ============================================================
--  Pending Actions + Secondary SIM migration
--  Run this ONCE in Supabase -> SQL Editor before using the
--  new pending-actions workflow and secondary SIM feature.
-- ============================================================

-- Per-repair follow-up tasks (SIM update / deactivation,
-- device server update, vendor flow, sensor/device repair lifecycle).
-- Stored as a JSON array of { id, type, stage, updatedAt, updatedBy, history }.
alter table public.maintenance_records
  add column if not exists tasks jsonb not null default '[]'::jsonb;

-- Admin-managed backup / secondary SIM for an installation.
-- Akash enters the primary SIM at install; admin can add the
-- secondary SIM later, shown below the primary in the admin view.
alter table public.installations
  add column if not exists secondary_sim text;

-- Optional: speed up "pending action" scans if the table grows large.
create index if not exists maintenance_records_tasks_idx
  on public.maintenance_records using gin (tasks);
