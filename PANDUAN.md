# 🚀 Panduan Lengkap UMKM Penggerak Indonesia
**Frontend → Vercel | Backend/Database → Supabase | CMS → admin.html**

---

## DAFTAR ISI
1. Setup Database Baru (Schema v2)
2. Cara Pakai Admin Panel CMS
3. Update & Deploy ke Vercel
4. Troubleshooting

---

## 1. Setup Database Baru (Schema v2)

> Jalankan ini SEKALI di Supabase SQL Editor untuk membuat semua tabel baru.

1. Buka https://supabase.com → project Anda
2. Klik SQL Editor → New query
3. Copy seluruh isi file schema.sql → paste → klik Run
4. Pastikan muncul "Success"

Tabel yang dibuat:
- programs      → data program/kelas pelatihan
- mentors       → data mentor
- testimonials  → data testimoni
- site_settings → pengaturan teks hero, statistik, dll
- pendaftar     → data pendaftar

---

## 2. Cara Pakai Admin Panel CMS

Buka Admin Panel:
→ https://domain-anda.vercel.app/admin.html

Buat Akun Admin di Supabase:
1. Supabase → Authentication → Users
2. Klik Add user → masukkan email & password
3. Gunakan email & password ini untuk login di admin.html

Fitur Admin Panel:
- Dashboard   : statistik jumlah data
- Program     : tambah/edit/hapus program pelatihan
- Mentor      : tambah/edit/hapus data mentor
- Testimoni   : tambah/edit/hapus + set featured
- Pengaturan  : edit teks hero, statistik, WhatsApp admin
- Pendaftar   : lihat semua pendaftar + export CSV

---

## 3. Deploy ke Vercel

Jika sudah connect GitHub ke Vercel:
→ Setiap push ke GitHub OTOMATIS deploy. Tidak perlu langkah tambahan.

File yang harus ada di GitHub:
  index.html   - Website utama
  admin.html   - CMS Admin Panel
  schema.sql   - SQL setup database
  vercel.json  - Konfigurasi Vercel
  PANDUAN.md   - Panduan ini

---

## 4. Troubleshooting

Program/mentor tidak muncul    → Jalankan schema.sql di Supabase SQL Editor
Admin tidak bisa login         → Buat user di Supabase → Authentication → Users
Data edit tidak muncul         → Refresh browser, tunggu ~5 detik
Failed to fetch di form        → Cek SUPABASE_URL dan ANON_KEY di index.html
Vercel tidak auto-deploy       → Cek Settings → Git di Vercel dashboard

---

TIPS:
- Urutan tampil: atur kolom "urutan" (angka kecil = tampil pertama)
- Sembunyikan konten: nonaktifkan toggle "aktif"
- Featured testimoni: aktifkan toggle featured → background merah
- Export pendaftar: menu Pendaftar → klik Export CSV

© 2025 UMKM Penggerak Indonesia
