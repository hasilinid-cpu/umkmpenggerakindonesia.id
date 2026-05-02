-- ============================================
-- UMKM PENGGERAK INDONESIA - DATABASE SCHEMA v2
-- AMAN dijalankan berulang (DROP IF EXISTS)
-- ============================================

-- 1. BUAT TABEL (jika belum ada)
CREATE TABLE IF NOT EXISTS programs (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul          TEXT NOT NULL,
  deskripsi      TEXT,
  kategori       TEXT,
  level          TEXT DEFAULT 'Pemula',
  tipe           TEXT DEFAULT 'Gratis',
  emoji          TEXT DEFAULT '📚',
  warna_bg       TEXT DEFAULT 'linear-gradient(135deg,#EEF3FD,#DBEAFE)',
  warna_cat      TEXT DEFAULT '#3B82F6',
  mentor_nama    TEXT,
  mentor_inisial TEXT DEFAULT 'M',
  peserta        INTEGER DEFAULT 0,
  urutan         INTEGER DEFAULT 0,
  aktif          BOOLEAN DEFAULT true,
  created_at     TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mentors (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama          TEXT NOT NULL,
  peran         TEXT,
  spesialisasi  TEXT,
  emoji         TEXT DEFAULT '👤',
  warna_avatar  TEXT DEFAULT 'linear-gradient(135deg,#60A5FA,#2563EB)',
  rating        TEXT DEFAULT '4.9',
  peserta       INTEGER DEFAULT 0,
  linkedin      TEXT,
  urutan        INTEGER DEFAULT 0,
  aktif         BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS testimonials (
  id         UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama       TEXT NOT NULL,
  peran      TEXT,
  isi        TEXT NOT NULL,
  emoji      TEXT DEFAULT '😊',
  bintang    INTEGER DEFAULT 5,
  featured   BOOLEAN DEFAULT false,
  aktif      BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS site_settings (
  key        TEXT PRIMARY KEY,
  value      TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pendaftar (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        TEXT NOT NULL,
  whatsapp    TEXT NOT NULL,
  email       TEXT NOT NULL,
  jenis_usaha TEXT,
  kota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. AKTIFKAN RLS
ALTER TABLE programs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentors      ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendaftar    ENABLE ROW LEVEL SECURITY;

-- 3. HAPUS POLICY LAMA (agar tidak error duplikat)
DROP POLICY IF EXISTS "Public read programs"       ON programs;
DROP POLICY IF EXISTS "Admin all programs"         ON programs;
DROP POLICY IF EXISTS "Public read mentors"        ON mentors;
DROP POLICY IF EXISTS "Admin all mentors"          ON mentors;
DROP POLICY IF EXISTS "Public read testimonials"   ON testimonials;
DROP POLICY IF EXISTS "Admin all testimonials"     ON testimonials;
DROP POLICY IF EXISTS "Public read settings"       ON site_settings;
DROP POLICY IF EXISTS "Admin all settings"         ON site_settings;
DROP POLICY IF EXISTS "Public insert pendaftar"    ON pendaftar;
DROP POLICY IF EXISTS "Allow public insert"        ON pendaftar;
DROP POLICY IF EXISTS "Admin read pendaftar"       ON pendaftar;
DROP POLICY IF EXISTS "Allow admin select"         ON pendaftar;

-- 4. BUAT POLICY BARU
CREATE POLICY "Public read programs"     ON programs     FOR SELECT USING (aktif = true);
CREATE POLICY "Admin all programs"       ON programs     FOR ALL    USING (auth.role() = 'authenticated');

CREATE POLICY "Public read mentors"      ON mentors      FOR SELECT USING (aktif = true);
CREATE POLICY "Admin all mentors"        ON mentors      FOR ALL    USING (auth.role() = 'authenticated');

CREATE POLICY "Public read testimonials" ON testimonials FOR SELECT USING (aktif = true);
CREATE POLICY "Admin all testimonials"   ON testimonials FOR ALL    USING (auth.role() = 'authenticated');

CREATE POLICY "Public read settings"     ON site_settings FOR SELECT USING (true);
CREATE POLICY "Admin all settings"       ON site_settings FOR ALL    USING (auth.role() = 'authenticated');

CREATE POLICY "Public insert pendaftar"  ON pendaftar    FOR INSERT WITH CHECK (true);
CREATE POLICY "Admin read pendaftar"     ON pendaftar    FOR SELECT USING (auth.role() = 'authenticated');

-- 5. DATA AWAL (hanya insert jika tabel masih kosong)
INSERT INTO programs (judul, deskripsi, kategori, tipe, emoji, warna_bg, warna_cat, mentor_nama, mentor_inisial, peserta, urutan)
SELECT * FROM (VALUES
  ('Strategi Marketing Digital untuk UMKM','Pelajari cara memasarkan produk secara digital','Strategi Bisnis','Gratis','📊','linear-gradient(135deg,#EEF3FD,#DBEAFE)','#3B82F6','Andi Pratama','A',2400,1),
  ('Kelola Keuangan UMKM Agar Bisnis Bertumbuh','Manajemen keuangan sederhana tapi efektif','Keuangan','Premium','💰','linear-gradient(135deg,#FFF7ED,#FED7AA)','#F97316','Rina Wijaya','R',1800,2),
  ('Bangun Brand Kuat Peningkat Penjualan','Cara membangun identitas brand yang kuat','Branding','Premium','🎨','linear-gradient(135deg,#FEF2F2,#FECACA)','#E30613','Denny Santoso','D',1300,3),
  ('Optimasi Operasional UMKM agar Efisien','Streamline operasional bisnis Anda','Operasional','Gratis','⚙️','linear-gradient(135deg,#F0FDF4,#DCFCE7)','#22C55E','Fitri Amelia','F',980,4),
  ('Inovasi Produk untuk UMKM Masa Depan','Kembangkan produk inovatif yang relevan','Inovasi','Premium','🚀','linear-gradient(135deg,#FAF5FF,#EDE9FE)','#8B5CF6','Yudha','Y',1100,5),
  ('Ekspansi ke Marketplace Nasional','Cara masuk dan berjualan di marketplace','Marketplace','Gratis','🛒','linear-gradient(135deg,#F0FFFE,#CCFBF1)','#0D9488','Andi Pratama','A',2100,6)
) AS v(judul,deskripsi,kategori,tipe,emoji,warna_bg,warna_cat,mentor_nama,mentor_inisial,peserta,urutan)
WHERE NOT EXISTS (SELECT 1 FROM programs LIMIT 1);

INSERT INTO mentors (nama, peran, spesialisasi, emoji, warna_avatar, rating, peserta, urutan)
SELECT * FROM (VALUES
  ('Andi Pratama','Digital Marketing Specialist','Strategi Bisnis','👨‍💼','linear-gradient(135deg,#60A5FA,#2563EB)','4.9',2400,1),
  ('Rina Wijaya','Financial Expert','Keuangan','👩‍💼','linear-gradient(135deg,#FB923C,#EA580C)','4.8',1800,2),
  ('Denny Santoso','Brand Consultant','Branding','👨‍🎨','linear-gradient(135deg,#F87171,#DC2626)','4.9',1300,3),
  ('Fitri Amelia','Business Coach','Operasional','👩‍🏫','linear-gradient(135deg,#4ADE80,#16A34A)','4.7',980,4)
) AS v(nama,peran,spesialisasi,emoji,warna_avatar,rating,peserta,urutan)
WHERE NOT EXISTS (SELECT 1 FROM mentors LIMIT 1);

INSERT INTO testimonials (nama, peran, isi, emoji, bintang, featured)
SELECT * FROM (VALUES
  ('Budi Setiawan','Pemilik Restoran, Bandung','Berkat UMKM Penggerak, omzet toko saya naik 3 kali lipat dalam 6 bulan. Programnya sangat praktis!','🧑‍🍳',5,true),
  ('Sari Andini','Pemilik Toko Online, Jakarta','Saya bisa ekspansi ke 3 marketplace hanya dalam 2 bulan setelah mengikuti program di sini. Luar biasa!','👩‍💻',5,false),
  ('Agus Hermawan','Petani & Pengusaha, Jawa Tengah','Mentor di sini langsung kasih solusi nyata untuk masalah bisnis saya. Worth it banget!','👨‍🌾',5,false)
) AS v(nama,peran,isi,emoji,bintang,featured)
WHERE NOT EXISTS (SELECT 1 FROM testimonials LIMIT 1);

INSERT INTO site_settings (key, value) VALUES
  ('stat_member',  '10K+'),
  ('stat_program', '250+'),
  ('stat_mentor',  '100+'),
  ('stat_umkm',    '5K+'),
  ('hero_desc',    'Platform edukasi, pendampingan, dan komunitas terbaik untuk memberdayakan UMKM Indonesia—naik kelas, berdaya saing, dan berdampak nyata.'),
  ('whatsapp_admin','6281234567890')
ON CONFLICT (key) DO NOTHING;
