-- ============================================================
-- SCHEMA FIX — Tambah kolom yang belum ada
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- Tambah kolom baru ke tabel yang sudah ada (aman jika sudah ada)
ALTER TABLE programs ADD COLUMN IF NOT EXISTS deskripsi_panjang TEXT;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS harga INTEGER DEFAULT 0;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS durasi TEXT DEFAULT 'Self-paced';
ALTER TABLE programs ADD COLUMN IF NOT EXISTS level TEXT DEFAULT 'Pemula';

ALTER TABLE blog ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE alumni ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS bukti_url TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS catatan TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMPTZ;

-- Buat tabel baru jika belum ada
CREATE TABLE IF NOT EXISTS media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL,
  tipe TEXT,
  url TEXT NOT NULL,
  storage_path TEXT,
  ukuran INTEGER,
  deskripsi TEXT,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  invoice_no TEXT UNIQUE NOT NULL,
  program_id UUID,
  program_judul TEXT NOT NULL,
  program_harga INTEGER DEFAULT 0,
  nama TEXT NOT NULL,
  email TEXT NOT NULL,
  whatsapp TEXT NOT NULL,
  kota TEXT,
  jenis_usaha TEXT,
  status TEXT DEFAULT 'pending',
  bukti_url TEXT,
  catatan TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS blog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  konten TEXT,
  ringkasan TEXT,
  thumbnail TEXT DEFAULT '📰',
  thumbnail_url TEXT,
  kategori TEXT DEFAULT 'Tips UMKM',
  penulis TEXT DEFAULT 'Tim UMKM Penggerak',
  views INTEGER DEFAULT 0,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL,
  usaha TEXT,
  kota TEXT,
  foto_emoji TEXT DEFAULT '🧑‍💼',
  foto_url TEXT,
  warna_bg TEXT DEFAULT '#EFF6FF',
  pencapaian TEXT,
  program_diikuti TEXT,
  omzet_sebelum TEXT,
  omzet_sesudah TEXT,
  aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS untuk tabel baru
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni ENABLE ROW LEVEL SECURITY;

-- Drop & recreate policies (aman diulang)
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname, tablename FROM pg_policies
    WHERE tablename IN ('media','orders','blog','alumni')
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.tablename;
  END LOOP;
END $$;

CREATE POLICY "pub_sel_blog"   ON blog   FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_alumni" ON alumni FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_media"  ON media  FOR SELECT USING (aktif=true);
CREATE POLICY "pub_ins_orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "pub_sel_orders" ON orders FOR SELECT USING (true);
CREATE POLICY "pub_upd_orders" ON orders FOR UPDATE USING (true);
CREATE POLICY "adm_blog"   ON blog   FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_alumni" ON alumni FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_media"  ON media  FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_orders" ON orders FOR ALL USING (auth.role()='authenticated');

-- Storage bucket untuk media
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT DO NOTHING;

DROP POLICY IF EXISTS "pub_read_media"   ON storage.objects;
DROP POLICY IF EXISTS "pub_upload_media" ON storage.objects;
DROP POLICY IF EXISTS "adm_media_all"   ON storage.objects;
CREATE POLICY "pub_read_media"   ON storage.objects FOR SELECT USING (bucket_id='media');
CREATE POLICY "pub_upload_media" ON storage.objects FOR INSERT WITH CHECK (bucket_id='media');
CREATE POLICY "adm_media_all"    ON storage.objects FOR ALL USING (bucket_id='media' AND auth.role()='authenticated');

-- Seed data blog (jika kosong)
INSERT INTO blog (judul, slug, konten, ringkasan, thumbnail, kategori, penulis)
SELECT * FROM (VALUES
  ('5 Strategi Marketing Digital Wajib untuk UMKM','5-strategi-marketing-digital',
   '<h2>1. Optimalkan Media Sosial</h2><p>Instagram, TikTok, dan Facebook bisa menjadi alat pemasaran gratis yang sangat powerful. Buat konten menarik, konsisten, dan relevan dengan target pasar Anda.</p><h2>2. Konten yang Konsisten</h2><p>Posting minimal 3-5 kali seminggu. Gunakan format video pendek, carousel, dan infografis untuk meningkatkan engagement.</p><h2>3. WhatsApp Business</h2><p>Fitur katalog produk, pesan otomatis, dan label pelanggan sangat berguna untuk UMKM skala apapun.</p><h2>4. Google My Business</h2><p>Gratis dan efektif untuk visibilitas di pencarian lokal Google. Tambahkan foto produk dan minta ulasan pelanggan.</p><h2>5. Iklan Berbayar Budget Kecil</h2><p>Mulai dari Rp 10.000/hari di Meta Ads sudah bisa menjangkau ribuan calon pelanggan yang ditarget tepat.</p>',
   'Temukan 5 strategi marketing digital terbukti yang bisa langsung diterapkan UMKM untuk meningkatkan penjualan.','📱','Marketing Digital','Andi Pratama'),
  ('Cara Membuat Laporan Keuangan Sederhana untuk UMKM','laporan-keuangan-sederhana',
   '<h2>Mengapa Laporan Keuangan Penting?</h2><p>Banyak UMKM gagal bukan karena produknya buruk, tapi karena tidak tahu kondisi keuangan bisnisnya. Laporan keuangan adalah kompas bisnis Anda.</p><h2>3 Laporan Keuangan Dasar</h2><p><strong>1. Laporan Laba Rugi</strong> — Mencatat semua pemasukan dan pengeluaran.</p><p><strong>2. Laporan Arus Kas</strong> — Mencatat aliran uang masuk dan keluar.</p><p><strong>3. Neraca</strong> — Gambaran aset, kewajiban, dan modal bisnis Anda.</p><h2>Tools Gratis</h2><p>Google Sheets, BukuWarung, atau BukuKas adalah pilihan bagus untuk UMKM pemula.</p>',
   'Pelajari cara membuat laporan keuangan sederhana yang bisa langsung diterapkan UMKM tanpa latar belakang akuntansi.','💰','Keuangan','Rina Wijaya'),
  ('Tips Membangun Brand UMKM yang Kuat','membangun-brand-umkm',
   '<h2>Brand Bukan Sekadar Logo</h2><p>Brand adalah keseluruhan pengalaman pelanggan saat berinteraksi dengan bisnis Anda — dari visual, komunikasi, hingga layanan purna jual.</p><h2>Elemen Brand yang Wajib Dimiliki</h2><p>Logo profesional, palet warna konsisten, tipografi tepat, tone of voice yang sesuai, dan packaging menarik.</p><h2>Konsistensi adalah Kunci</h2><p>Gunakan elemen brand yang sama di semua platform — website, media sosial, kemasan produk, hingga seragam karyawan.</p>',
   'Panduan lengkap membangun brand UMKM yang kuat, konsisten, dan mampu bersaing di pasar modern.','🎨','Branding','Denny Santoso')
) AS v(judul,slug,konten,ringkasan,thumbnail,kategori,penulis)
WHERE NOT EXISTS (SELECT 1 FROM blog LIMIT 1);

-- Seed data alumni (jika kosong)
INSERT INTO alumni (nama, usaha, kota, foto_emoji, warna_bg, pencapaian, program_diikuti, omzet_sebelum, omzet_sesudah)
SELECT * FROM (VALUES
  ('Budi Setiawan','Warung Makan Budi Jaya','Bandung','🧑‍🍳','#FFF0F0','Omzet naik 300% dalam 6 bulan setelah menerapkan strategi digital marketing','Marketing Digital','Rp 5 Juta/bln','Rp 20 Juta/bln'),
  ('Sari Andini','Toko Fashion Online','Jakarta','👩‍💻','#F0FFF4','Ekspansi ke 3 marketplace nasional dan merekrut 5 karyawan baru','Ekspansi Marketplace','Rp 8 Juta/bln','Rp 35 Juta/bln'),
  ('Agus Hermawan','Agribisnis Tani Maju','Jawa Tengah','👨‍🌾','#EFF6FF','Punya brand produk pertanian sendiri yang masuk supermarket lokal','Branding UMKM','Rp 3 Juta/bln','Rp 18 Juta/bln'),
  ('Dewi Kusuma','Kue Artisan Dewi','Surabaya','👩‍🍰','#FFFBEB','Produk masuk ke 5 kafe dan supermarket di Surabaya','Operasional & Branding','Rp 4 Juta/bln','Rp 25 Juta/bln'),
  ('Hendra Putra','Konveksi Putra Jaya','Bandung','👕','#FAF5FF','Berhasil ekspor perdana ke Malaysia dan Singapura','Marketing & Operasional','Rp 15 Juta/bln','Rp 60 Juta/bln'),
  ('Yuni Rahayu','Batik Yuni Collection','Yogyakarta','🎨','#F0FFFE','Meraih penghargaan UMKM Terbaik DIY 2024','Branding UMKM','Rp 6 Juta/bln','Rp 28 Juta/bln')
) AS v(nama,usaha,kota,foto_emoji,warna_bg,pencapaian,program_diikuti,omzet_sebelum,omzet_sesudah)
WHERE NOT EXISTS (SELECT 1 FROM alumni LIMIT 1);

-- Update site_settings jika belum ada key baru
INSERT INTO site_settings (key, value) VALUES
  ('bank_name','BCA'),
  ('bank_no','1234567890'),
  ('bank_atas_nama','UMKM Penggerak Indonesia'),
  ('email_admin','admin@umkmpenggerak.id')
ON CONFLICT (key) DO NOTHING;

-- Konfirmasi selesai
SELECT 'Schema fix berhasil! Semua tabel dan kolom sudah siap.' AS status;
