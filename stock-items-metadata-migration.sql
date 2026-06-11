-- ============================================================
--  Stock items: add metadata jsonb column for per-item identifiers
--  Run this ONCE in Supabase -> SQL Editor.
--
--  metadata stores category-specific fields:
--    GPS    -> { "imei": "..." }
--    SIM-*  -> { "primary": "...", "secondary": "..." }
--    SENSOR -> { "sensorNo": "...", "macId": "..." }
--    Other  -> {}  (no extra fields)
-- ============================================================

alter table public.stock_items
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create index if not exists stock_items_metadata_gin_idx
  on public.stock_items using gin (metadata);
