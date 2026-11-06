-- Jalankan di Supabase Dashboard -> SQL Editor.
-- Jika tabel saved_recipes sudah ada dan aplikasi sudah berjalan, kamu cukup
-- memastikan bagian RLS (policy) di bawah sudah ada.

create table if not exists public.saved_recipes (
  id          uuid primary key default gen_random_uuid(),
  recipe_id   text not null,
  title       text not null,
  category    text,
  note        text default '',
  rating      int  default 0 check (rating between 0 and 5),
  created_at  timestamptz not null default now()
);

-- Aktifkan Row Level Security (WAJIB agar anon key aman dipakai di aplikasi)
alter table public.saved_recipes enable row level security;

-- Policy untuk demo UTS (tanpa login): anon boleh CRUD.
-- Catatan: tanpa autentikasi, semua pengguna aplikasi berbagi data yang sama.
drop policy if exists "anon select saved_recipes" on public.saved_recipes;
drop policy if exists "anon insert saved_recipes" on public.saved_recipes;
drop policy if exists "anon update saved_recipes" on public.saved_recipes;
drop policy if exists "anon delete saved_recipes" on public.saved_recipes;

create policy "anon select saved_recipes" on public.saved_recipes
  for select to anon using (true);

create policy "anon insert saved_recipes" on public.saved_recipes
  for insert to anon with check (true);

create policy "anon update saved_recipes" on public.saved_recipes
  for update to anon using (true) with check (true);

create policy "anon delete saved_recipes" on public.saved_recipes
  for delete to anon using (true);

-- (Opsional) cegah resep yang sama tersimpan dua kali di level database.
-- Jalankan hanya jika belum ada data ganda:
-- alter table public.saved_recipes
--   add constraint saved_recipes_recipe_id_key unique (recipe_id);