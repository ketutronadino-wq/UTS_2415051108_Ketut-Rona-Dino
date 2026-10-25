# UTS Pemrograman Mobile - RecipeBox

## Deskripsi Project
RecipeBox adalah aplikasi mobile berbasis Flutter yang dirancang untuk mencari resep makanan dari seluruh dunia. Aplikasi ini mengintegrasikan REST API untuk mengambil katalog resep dan menggunakan database backend untuk menyimpan resep favorit beserta catatan dan rating pribadi pengguna.

## Identitas Mahasiswa
*   **Nama:** Ketut Rona Dino
*   **NIM:** 241051108
*   **Kelas:** Pemrograman Berbasis Mobile
*   **Tema Project:** Food & Recipe Explorer

## Fitur Utama
1.  **Home Dashboard:** Menampilkan sambutan dan navigasi cepat ke daftar resep.
2.  **Explore Recipes (REST API):** Menampilkan daftar resep dari API (TheMealDB) dengan layout responsif (List/Grid) dan fitur pencarian (Search).
3.  **Recipe Detail:** Menampilkan detail instruksi memasak dan gambar dari API. Terdapat passing data antar screen.
4.  **Saved Favorites (Database CRUD):** Menyimpan resep ke database Supabase. Pengguna dapat melihat daftar favorit, mengedit catatan (Update), dan menghapusnya (Delete dengan konfirmasi dialog).
5.  **Profile:** Menampilkan informasi pengembang aplikasi.

## Tech Stack & Arsitektur
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider + ChangeNotifier
*   **HTTP Client:** `http` package
*   **Database Client:** `supabase_flutter`
*   **Arsitektur:** 
    `UI (Screens/Widgets)` → `State (Providers)` → `Repository` → `Service (API/Supabase)`

## REST API & Database
*   **REST API:** [TheMealDB API](https://www.themealdb.com/api.php) (Endpoint: `search.php?s=a`)
*   **Backend/Database:** [Supabase](https://supabase.com/)
*   **Tabel Database:** `saved_recipes` (Field: `id`, `recipe_id`, `title`, `category`, `note`, `rating`, `created_at`)

## Struktur Folder
```text
lib/
 ┣ models/       # Model data (RecipeModel, SavedRecipeModel)
 ┣ services/     # Koneksi ke API dan Supabase
 ┣ repositories/ # Jembatan antara Provider dan Service
 ┣ providers/    # State Management (RecipeProvider)
 ┣ screens/      # Halaman UI (Home, List, Detail, Favorit, Edit, Profil)
 ┣ widgets/      # Komponen UI yang dapat digunakan ulang (CustomCard, EmptyState, dll)
 ┗ main.dart     # Entry point aplikasi