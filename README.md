# RecipeBox

Aplikasi mobile Flutter untuk mencari resep makanan dan menyimpan resep favorit
beserta catatan memasak dan rating pribadi. Katalog resep diambil dari **REST API
TheMealDB**, sedangkan data personal (favorit, catatan, rating) disimpan di
**database Supabase**.

## Identitas

| | |
|---|---|
| Nama | Ketut Rona Dino |
| NIM | 2415051108 |
| Kelas | Pemrograman Mobile |
| Mata kuliah | Pemrograman Mobile – Project UTS |
| Repository | [https://github.com/ketutronadino-wq/UTS_2415051108_Ketut-Rona-Dino.git](https://github.com/ketutronadino-wq/UTS_2415051108_Ketut-Rona-Dino.git) |

## Fitur

- Dashboard: ringkasan jumlah resep & favorit, pencarian cepat, kategori, rekomendasi resep
- Daftar resep dari REST API (list di layar sempit, grid di layar lebar) dengan pull-to-refresh
- Pencarian resep berdasarkan nama dan filter berdasarkan kategori
- Detail resep: gambar, bahan, instruksi, layout 2 kolom di layar lebar
- **Create** – simpan resep ke favorit lewat form (catatan + rating) dengan validasi
- **Read** – daftar resep favorit dari database
- **Update** – edit catatan dan rating
- **Delete** – hapus favorit dengan dialog konfirmasi
- Loading, error (dengan tombol "Coba Lagi"), dan empty state di setiap daftar
- SnackBar / AlertDialog sebagai umpan balik operasi penting
- Navigasi adaptif: NavigationBar (compact) dan NavigationRail (wide)

## Tech Stack

- Flutter & Dart (Material 3)
- Provider + ChangeNotifier (state management)
- `http` (REST API), `supabase_flutter` (database)

## REST API

[TheMealDB](https://www.themealdb.com/api.php) – `GET https://www.themealdb.com/api/json/v1/1/search.php?s=a`
Response JSON dikonversi menjadi `RecipeModel`.

## Backend / Database

Supabase (PostgreSQL), tabel `saved_recipes`:

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid (PK) | primary key |
| recipe_id | text | id resep dari TheMealDB |
| title | text | nama resep |
| category | text | kategori resep |
| note | text | catatan pengguna |
| rating | int | 0–5 |
| created_at | timestamptz | waktu dibuat |

Skrip pembuatan tabel dan RLS ada di [`supabase_setup.sql`](supabase_setup.sql).
Aplikasi hanya memakai **anon key**; `service_role` key tidak pernah dipakai maupun di-commit.

## Arsitektur
