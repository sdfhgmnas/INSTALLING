-- ============================================================
--  Add task tracking to installations so install-level pending
--  actions (Update on GPS Portal, Check vehicle number) can be
--  generated and resolved like maintenance tasks.
--  Run this ONCE in Supabase -> SQL Editor.
-- ============================================================

alter table public.installations
  add column if not exists tasks jsonb;

-- Optional: backfill existing rows with empty tasks object so the app
-- knows they predate the feature (won't auto-create new tasks for them).
update public.installations set tasks = '{}'::jsonb where tasks is null;
