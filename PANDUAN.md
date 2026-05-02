# 🚀 Panduan Deploy UMKM Penggerak Indonesia
**Frontend → Vercel | Backend/Database → Supabase**

---

## DAFTAR ISI
1. [Setup Supabase (Database)](#1-setup-supabase)
2. [Konfigurasi Website](#2-konfigurasi-website)
3. [Deploy ke Vercel](#3-deploy-ke-vercel)
4. [Cek Data Pendaftar](#4-cek-data)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Setup Supabase (Database) {#1-setup-supabase}

### A. Buat Akun & Project Supabase
1. Buka **https://supabase.com** → klik **Start your project**
2. Login dengan akun GitHub (gratis)
3. Klik **New Project**
4. Isi:
   - **Organization**: pilih atau buat baru
   - **Name**: `umkm-penggerak`
   - **Database Password**: buat password yang kuat (simpan!)
   - **Region**: pilih **Southeast Asia (Singapore)**
5. Klik **Create new project** → tunggu ~2 menit

### B. Buat Tabel `pendaftar`
1. Di dashboard Supabase, klik menu **SQL Editor** (ikon database di sidebar kiri)
2. Klik **New query**, tempel SQL berikut, lalu klik **Run**:

```sql
-- Buat tabel pendaftar
CREATE TABLE pendaftar (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        TEXT NOT NULL,
  whatsapp    TEXT NOT NULL,
  email       TEXT NOT NULL,
  jenis_usaha TEXT,
  kota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Aktifkan Row Level Security
ALTER TABLE pendaftar ENABLE ROW LEVEL SECURITY;

-- Izinkan siapa saja INSERT (pendaftaran publik)
CREATE POLICY "Allow public insert"
  ON pendaftar FOR INSERT
  WITH CHECK (true);

-- Hanya admin (authenticated) yang bisa SELECT
CREATE POLICY "Allow admin select"
  ON pendaftar FOR SELECT
  USING (auth.role() = 'authenticated');
```

3. Pastikan muncul pesan **"Success. No rows returned"**

### C. Ambil API Keys
1. Klik menu **Project Settings** (ikon gear) → **API**
2. Catat dua nilai ini:
   - **Project URL** → contoh: `https://abcdefghij.supabase.co`
   - **anon / public key** → string panjang dimulai `eyJ...`

---

## 2. Konfigurasi Website {#2-konfigurasi-website}

Buka file **`index.html`**, cari baris ini (sekitar baris 560):

```javascript
const SUPABASE_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Ganti dengan nilai yang Anda catat tadi:

```javascript
const SUPABASE_URL = 'https://abcdefghij.supabase.co';   // ← ganti ini
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6...'; // ← dan ini
```

**Simpan file.**

> 💡 **Tips keamanan**: `anon key` aman dipakai di frontend karena sudah dibatasi oleh Row Level Security (RLS) yang kita buat di langkah sebelumnya.

---

## 3. Deploy ke Vercel {#3-deploy-ke-vercel}

### Metode A: Drag & Drop (Paling Mudah — 2 Menit)
1. Buka **https://vercel.com** → Login / Sign Up (gratis)
2. Di dashboard Vercel, klik tombol **Add New → Project**
3. Pilih tab **"Or upload files"** (di bagian bawah halaman)
4. **Drag & drop** seluruh folder `umkm-penggerak` ke area upload
5. Vercel otomatis mendeteksi sebagai static site
6. Klik **Deploy**
7. Tunggu ~30 detik → website Anda **LIVE!** 🎉

URL otomatis: `https://umkm-penggerak-xxx.vercel.app`

---

### Metode B: Via GitHub (Rekomendasi untuk Update Mudah)

**Langkah 1 — Upload ke GitHub:**
1. Buka **https://github.com** → Login → klik **New repository**
2. Nama repo: `umkm-penggerak` → centang **Public** → klik **Create**
3. Di halaman repo baru, klik **uploading an existing file**
4. Upload file `index.html` dan `vercel.json`
5. Klik **Commit changes**

**Langkah 2 — Connect ke Vercel:**
1. Buka **https://vercel.com** → **Add New → Project**
2. Klik **Import Git Repository** → pilih repo `umkm-penggerak`
3. Biarkan semua setting default → klik **Deploy**
4. Selesai! Setiap push ke GitHub akan **auto-deploy** otomatis ✅

**Langkah 3 — Custom Domain (Opsional):**
1. Di Vercel dashboard → pilih project → menu **Settings → Domains**
2. Tambahkan domain Anda, misal: `umkmpenggera.id`
3. Ikuti instruksi untuk update DNS di domain registrar Anda

---

## 4. Cek Data Pendaftar {#4-cek-data}

### Lihat di Supabase Dashboard
1. Buka **https://supabase.com** → project Anda
2. Klik menu **Table Editor** → pilih tabel **pendaftar**
3. Semua data pendaftaran akan muncul di sini secara real-time

### Export ke Excel/CSV
1. Di Table Editor, klik tombol **Export** (pojok kanan atas)
2. Pilih format **CSV** → download otomatis

### Query Lanjutan (SQL Editor)
```sql
-- Lihat semua pendaftar terbaru
SELECT * FROM pendaftar ORDER BY created_at DESC;

-- Hitung per jenis usaha
SELECT jenis_usaha, COUNT(*) as total 
FROM pendaftar 
GROUP BY jenis_usaha 
ORDER BY total DESC;

-- Pendaftar minggu ini
SELECT * FROM pendaftar 
WHERE created_at >= NOW() - INTERVAL '7 days';
```

---

## 5. Troubleshooting {#5-troubleshooting}

| Masalah | Solusi |
|---------|--------|
| Form muncul error "Failed to fetch" | Pastikan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` sudah diisi dengan benar |
| Data tidak masuk ke tabel | Cek di Supabase → SQL Editor → jalankan `SELECT * FROM pendaftar` |
| Website tidak bisa dibuka | Di Vercel dashboard → cek tab **Deployments** → lihat log error |
| Form tidak bisa submit | Buka DevTools browser (F12) → tab Console → lihat pesan error |
| Ingin reset tabel | Di SQL Editor jalankan: `TRUNCATE TABLE pendaftar;` |

---

## STRUKTUR FILE

```
umkm-penggerak/
├── index.html        ← Website utama (edit konten di sini)
├── vercel.json       ← Konfigurasi Vercel (jangan diubah)
└── PANDUAN.md        ← File panduan ini
```

---

## KUSTOMISASI KONTEN

| Yang ingin diubah | Lokasi di index.html |
|-------------------|----------------------|
| Nama & logo | Cari teks "UMKM Penggerak" |
| Warna merah brand | Cari `--red: #E30613` di bagian `:root` |
| Statistik hero (10K+, 250+, dst) | Cari bagian `hero-stats` |
| Program pelatihan | Cari komentar `<!-- PROGRAMS -->` |
| Data mentor | Cari komentar `<!-- MENTORS -->` |
| Testimoni | Cari komentar `<!-- TESTIMONIALS -->` |

---

**© 2025 UMKM Penggerak Indonesia**
Dibuat dengan ❤️ untuk UMKM Indonesia yang lebih maju.
