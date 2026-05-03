-- ============================================================
-- UMKM PENGGERAK — SETUP LENGKAP (Jalankan ini saja)
-- Aman diulang, tidak akan hapus data yang sudah ada
-- ============================================================

-- STEP 1: Tambah kolom yang mungkin belum ada di tabel lama
ALTER TABLE programs ADD COLUMN IF NOT EXISTS deskripsi_panjang TEXT;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS harga INTEGER DEFAULT 0;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS durasi TEXT DEFAULT 'Self-paced';
ALTER TABLE programs ADD COLUMN IF NOT EXISTS level TEXT DEFAULT 'Pemula';

-- STEP 2: Buat tabel baru (IF NOT EXISTS = aman jika sudah ada)
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

-- STEP 3: Aktifkan RLS
ALTER TABLE blog     ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni   ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders   ENABLE ROW LEVEL SECURITY;
ALTER TABLE media    ENABLE ROW LEVEL SECURITY;

-- STEP 4: Hapus policy lama lalu buat ulang (aman diulang)
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT policyname, tablename FROM pg_policies
    WHERE tablename IN (
      'programs','mentors','testimonials','site_settings',
      'pendaftar','blog','alumni','orders','media'
    )
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- Public bisa baca konten aktif
CREATE POLICY "pub_programs"     ON programs     FOR SELECT USING (aktif=true);
CREATE POLICY "pub_mentors"      ON mentors      FOR SELECT USING (aktif=true);
CREATE POLICY "pub_testimonials" ON testimonials FOR SELECT USING (aktif=true);
CREATE POLICY "pub_blog"         ON blog         FOR SELECT USING (aktif=true);
CREATE POLICY "pub_alumni"       ON alumni       FOR SELECT USING (aktif=true);
CREATE POLICY "pub_settings"     ON site_settings FOR SELECT USING (true);
CREATE POLICY "pub_media"        ON media        FOR SELECT USING (aktif=true);

-- Public bisa insert (form pendaftaran & order)
CREATE POLICY "pub_ins_pendaftar" ON pendaftar FOR INSERT WITH CHECK (true);
CREATE POLICY "pub_ins_orders"    ON orders    FOR INSERT WITH CHECK (true);
CREATE POLICY "pub_sel_orders"    ON orders    FOR SELECT USING (true);
CREATE POLICY "pub_upd_orders"    ON orders    FOR UPDATE USING (true);

-- Admin bisa semua
CREATE POLICY "adm_programs"     ON programs     FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_mentors"      ON mentors      FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_testimonials" ON testimonials FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_blog"         ON blog         FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_alumni"       ON alumni       FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_orders"       ON orders       FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_media"        ON media        FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_settings"     ON site_settings FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_pendaftar"    ON pendaftar    FOR SELECT USING (auth.role()='authenticated');

-- STEP 5: Storage bucket untuk upload foto/video
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT DO NOTHING;

DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies WHERE tablename='objects' AND policyname IN ('pub_read_media','pub_upload_media','adm_media_all')
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON storage.objects'; END LOOP;
END $$;
CREATE POLICY "pub_read_media"   ON storage.objects FOR SELECT USING (bucket_id='media');
CREATE POLICY "pub_upload_media" ON storage.objects FOR INSERT WITH CHECK (bucket_id='media');
CREATE POLICY "adm_media_all"    ON storage.objects FOR ALL  USING (bucket_id='media' AND auth.role()='authenticated');

-- STEP 6: Seed data awal (hanya jika tabel kosong)

-- Blog
INSERT INTO blog (judul,slug,konten,ringkasan,thumbnail,kategori,penulis)
SELECT judul,slug,konten,ringkasan,thumbnail,kategori,penulis FROM (VALUES
  ('5 Strategi Marketing Digital Wajib untuk UMKM',
   '5-strategi-marketing-digital',
   '<h2>1. Optimalkan Media Sosial</h2><p>Instagram, TikTok, dan Facebook bisa menjadi alat pemasaran gratis yang sangat powerful. Buat konten menarik, konsisten, dan relevan dengan target pasar Anda.</p><h2>2. Konten yang Konsisten</h2><p>Posting minimal 3-5 kali seminggu. Gunakan format video pendek, carousel, dan infografis untuk engagement lebih tinggi.</p><h2>3. WhatsApp Business</h2><p>Fitur katalog produk, pesan otomatis, dan label pelanggan sangat berguna untuk UMKM skala apapun.</p><h2>4. Google My Business</h2><p>Gratis dan efektif untuk visibilitas di pencarian lokal Google. Tambahkan foto dan minta ulasan pelanggan.</p><h2>5. Iklan Berbayar Budget Kecil</h2><p>Mulai Rp 10.000/hari di Meta Ads sudah bisa menjangkau ribuan calon pelanggan potensial.</p>',
   'Temukan 5 strategi marketing digital terbukti yang bisa langsung diterapkan UMKM untuk meningkatkan penjualan.',
   '📱','Marketing Digital','Andi Pratama'),
  ('Cara Membuat Laporan Keuangan Sederhana untuk UMKM',
   'laporan-keuangan-sederhana',
   '<h2>Mengapa Laporan Keuangan Penting?</h2><p>Banyak UMKM gagal bukan karena produknya buruk, tapi karena tidak tahu kondisi keuangan bisnisnya sendiri.</p><h2>3 Laporan Keuangan Dasar</h2><p><strong>1. Laporan Laba Rugi</strong> — Mencatat semua pemasukan dan pengeluaran.</p><p><strong>2. Laporan Arus Kas</strong> — Mencatat aliran uang masuk dan keluar bisnis Anda.</p><p><strong>3. Neraca</strong> — Gambaran aset, kewajiban, dan modal bisnis.</p><h2>Tools Gratis</h2><p>Google Sheets, BukuWarung, atau BukuKas cocok untuk UMKM pemula.</p>',
   'Pelajari cara membuat laporan keuangan sederhana yang bisa langsung diterapkan tanpa latar belakang akuntansi.',
   '💰','Keuangan','Rina Wijaya'),
  ('Tips Membangun Brand UMKM yang Kuat dan Dikenal',
   'membangun-brand-umkm',
   '<h2>Brand Bukan Sekadar Logo</h2><p>Brand adalah keseluruhan pengalaman yang dirasakan pelanggan — dari visual, komunikasi, hingga layanan purna jual.</p><h2>Elemen Brand yang Wajib Dimiliki</h2><p>Logo profesional, palet warna konsisten, tipografi tepat, tone of voice sesuai karakter bisnis, dan packaging menarik.</p><h2>Konsistensi adalah Kunci</h2><p>Gunakan elemen brand yang sama di semua platform — website, media sosial, kemasan, hingga seragam karyawan.</p>',
   'Panduan membangun brand UMKM yang kuat, konsisten, dan mampu bersaing di pasar modern.',
   '🎨','Branding','Denny Santoso')
) AS t(judul,slug,konten,ringkasan,thumbnail,kategori,penulis)
WHERE NOT EXISTS (SELECT 1 FROM blog LIMIT 1);

-- Alumni
INSERT INTO alumni (nama,usaha,kota,foto_emoji,warna_bg,pencapaian,program_diikuti,omzet_sebelum,omzet_sesudah)
SELECT nama,usaha,kota,foto_emoji,warna_bg,pencapaian,program_diikuti,omzet_sebelum,omzet_sesudah FROM (VALUES
  ('Budi Setiawan','Warung Makan Budi Jaya','Bandung','🧑‍🍳','#FFF0F0','Omzet naik 300% dalam 6 bulan setelah menerapkan strategi digital','Marketing Digital','Rp 5 Juta/bln','Rp 20 Juta/bln'),
  ('Sari Andini','Toko Fashion Online Sari','Jakarta','👩‍💻','#F0FFF4','Ekspansi ke 3 marketplace nasional, rekrut 5 karyawan baru','Ekspansi Marketplace','Rp 8 Juta/bln','Rp 35 Juta/bln'),
  ('Agus Hermawan','Agribisnis Tani Maju','Jawa Tengah','👨‍🌾','#EFF6FF','Punya brand produk pertanian sendiri yang masuk supermarket lokal','Branding UMKM','Rp 3 Juta/bln','Rp 18 Juta/bln'),
  ('Dewi Kusuma','Kue Artisan Dewi','Surabaya','👩‍🍰','#FFFBEB','Produk masuk ke 5 kafe dan supermarket di Surabaya','Operasional & Branding','Rp 4 Juta/bln','Rp 25 Juta/bln'),
  ('Hendra Putra','Konveksi Putra Jaya','Bandung','👕','#FAF5FF','Berhasil ekspor perdana ke Malaysia dan Singapura','Marketing & Operasional','Rp 15 Juta/bln','Rp 60 Juta/bln'),
  ('Yuni Rahayu','Batik Yuni Collection','Yogyakarta','🎨','#F0FFFE','Meraih penghargaan UMKM Terbaik DIY 2024','Branding UMKM','Rp 6 Juta/bln','Rp 28 Juta/bln')
) AS t(nama,usaha,kota,foto_emoji,warna_bg,pencapaian,program_diikuti,omzet_sebelum,omzet_sesudah)
WHERE NOT EXISTS (SELECT 1 FROM alumni LIMIT 1);

-- Settings tambahan
INSERT INTO site_settings (key,value) VALUES
  ('bank_name','BCA'),
  ('bank_no','1234567890'),
  ('bank_atas_nama','UMKM Penggerak Indonesia'),
  ('email_admin','admin@umkmpenggerak.id')
ON CONFLICT (key) DO NOTHING;

-- Selesai
SELECT 'SETUP SELESAI! Semua tabel, kolom, policy, dan data awal sudah siap.' AS hasil;
