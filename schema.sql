-- ============================================
-- UMKM PENGGERAK INDONESIA - DATABASE SCHEMA
-- Jalankan di Supabase SQL Editor
-- ============================================

-- 1. TABEL PROGRAM / KELAS
CREATE TABLE IF NOT EXISTS programs (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul       TEXT NOT NULL,
  deskripsi   TEXT,
  kategori    TEXT,
  level       TEXT DEFAULT 'Pemula',
  tipe        TEXT DEFAULT 'Gratis', -- 'Gratis' | 'Premium'
  emoji       TEXT DEFAULT '📚',
  warna_bg    TEXT DEFAULT 'linear-gradient(135deg,#EEF3FD,#DBEAFE)',
  warna_cat   TEXT DEFAULT '#3B82F6',
  mentor_nama TEXT,
  mentor_inisial TEXT DEFAULT 'M',
  peserta     INTEGER DEFAULT 0,
  urutan      INTEGER DEFAULT 0,
  aktif       BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABEL MENTOR
CREATE TABLE IF NOT EXISTS mentors (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        TEXT NOT NULL,
  peran       TEXT,
  spesialisasi TEXT,
  emoji       TEXT DEFAULT '👤',
  warna_avatar TEXT DEFAULT 'linear-gradient(135deg,#60A5FA,#2563EB)',
  rating      TEXT DEFAULT '4.9',
  peserta     INTEGER DEFAULT 0,
  linkedin    TEXT,
  urutan      INTEGER DEFAULT 0,
  aktif       BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL TESTIMONI
CREATE TABLE IF NOT EXISTS testimonials (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        TEXT NOT NULL,
  peran       TEXT,
  isi         TEXT NOT NULL,
  emoji       TEXT DEFAULT '😊',
  bintang     INTEGER DEFAULT 5,
  featured    BOOLEAN DEFAULT false,
  aktif       BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL PENGATURAN SITE
CREATE TABLE IF NOT EXISTS site_settings (
  key         TEXT PRIMARY KEY,
  value       TEXT,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL PENDAFTAR (sudah ada, pastikan tidak duplikat)
CREATE TABLE IF NOT EXISTS pendaftar (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama        TEXT NOT NULL,
  whatsapp    TEXT NOT NULL,
  email       TEXT NOT NULL,
  jenis_usaha TEXT,
  kota        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentors ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendaftar ENABLE ROW LEVEL SECURITY;

-- Public bisa READ programs, mentors, testimonials
CREATE POLICY "Public read programs" ON programs FOR SELECT USING (aktif = true);
CREATE POLICY "Public read mentors" ON mentors FOR SELECT USING (aktif = true);
CREATE POLICY "Public read testimonials" ON testimonials FOR SELECT USING (aktif = true);
CREATE POLICY "Public read settings" ON site_settings FOR SELECT USING (true);

-- Public bisa INSERT pendaftar
CREATE POLICY "Public insert pendaftar" ON pendaftar FOR INSERT WITH CHECK (true);

-- Admin (authenticated) bisa semua operasi
CREATE POLICY "Admin all programs" ON programs FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin all mentors" ON mentors FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin all testimonials" ON testimonials FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin all settings" ON site_settings FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Admin read pendaftar" ON pendaftar FOR SELECT USING (auth.role() = 'authenticated');

-- ============================================
-- DATA AWAL (SEED)
-- ============================================

INSERT INTO programs (judul, deskripsi, kategori, tipe, emoji, warna_bg, warna_cat, mentor_nama, mentor_inisial, peserta, urutan) VALUES
('Strategi Marketing Digital untuk UMKM', 'Pelajari cara memasarkan produk secara digital dengan efektif', 'Strategi Bisnis', 'Gratis', '📊', 'linear-gradient(135deg,#EEF3FD,#DBEAFE)', '#3B82F6', 'Andi Pratama', 'A', 2400, 1),
('Kelola Keuangan UMKM Agar Bisnis Bertumbuh', 'Manajemen keuangan sederhana tapi efektif untuk UMKM', 'Keuangan', 'Premium', '💰', 'linear-gradient(135deg,#FFF7ED,#FED7AA)', '#F97316', 'Rina Wijaya', 'R', 1800, 2),
('Bangun Brand Kuat Peningkat Penjualan', 'Cara membangun identitas brand yang kuat dan dikenal', 'Branding', 'Premium', '🎨', 'linear-gradient(135deg,#FEF2F2,#FECACA)', '#E30613', 'Denny Santoso', 'D', 1300, 3),
('Optimasi Operasional UMKM agar Efisien', 'Streamline operasional bisnis Anda agar lebih hemat waktu', 'Operasional', 'Gratis', '⚙️', 'linear-gradient(135deg,#F0FDF4,#DCFCE7)', '#22C55E', 'Fitri Amelia', 'F', 980, 4),
('Inovasi Produk untuk UMKM Masa Depan', 'Kembangkan produk inovatif yang relevan dengan pasar', 'Inovasi', 'Premium', '🚀', 'linear-gradient(135deg,#FAF5FF,#EDE9FE)', '#8B5CF6', 'Yudha', 'Y', 1100, 5),
('Ekspansi ke Marketplace Nasional', 'Cara masuk dan berjualan di Tokopedia, Shopee, dan lainnya', 'Marketplace', 'Gratis', '🛒', 'linear-gradient(135deg,#F0FFFE,#CCFBF1)', '#0D9488', 'Andi Pratama', 'A', 2100, 6);

INSERT INTO mentors (nama, peran, spesialisasi, emoji, warna_avatar, rating, peserta, urutan) VALUES
('Andi Pratama', 'Digital Marketing Specialist', 'Strategi Bisnis', '👨‍💼', 'linear-gradient(135deg,#60A5FA,#2563EB)', '4.9', 2400, 1),
('Rina Wijaya', 'Financial Expert', 'Keuangan', '👩‍💼', 'linear-gradient(135deg,#FB923C,#EA580C)', '4.8', 1800, 2),
('Denny Santoso', 'Brand Consultant', 'Branding', '👨‍🎨', 'linear-gradient(135deg,#F87171,#DC2626)', '4.9', 1300, 3),
('Fitri Amelia', 'Business Coach', 'Operasional', '👩‍🏫', 'linear-gradient(135deg,#4ADE80,#16A34A)', '4.7', 980, 4);

INSERT INTO testimonials (nama, peran, isi, emoji, bintang, featured) VALUES
('Budi Setiawan', 'Pemilik Restoran, Bandung', 'Berkat UMKM Penggerak, omzet toko saya naik 3 kali lipat dalam 6 bulan. Programnya sangat praktis dan langsung bisa diterapkan!', '🧑‍🍳', 5, true),
('Sari Andini', 'Pemilik Toko Online, Jakarta', 'Saya bisa ekspansi ke 3 marketplace hanya dalam 2 bulan setelah mengikuti program di sini. Luar biasa!', '👩‍💻', 5, false),
('Agus Hermawan', 'Petani & Pengusaha, Jawa Tengah', 'Mentor di sini bukan cuma ngajari teori, tapi langsung kasih solusi nyata untuk masalah bisnis saya. Worth it banget!', '👨‍🌾', 5, false);

INSERT INTO site_settings (key, value) VALUES
('hero_title_1', 'Satu Gerakan,'),
('hero_title_2', 'Jutaan'),
('hero_title_3', 'Perubahan.'),
('hero_desc', 'Platform edukasi, pendampingan, dan komunitas terbaik untuk memberdayakan UMKM Indonesia—naik kelas, berdaya saing, dan berdampak nyata.'),
('stat_member', '10K+'),
('stat_program', '250+'),
('stat_mentor', '100+'),
('stat_umkm', '5K+'),
('whatsapp_admin', '6281234567890');
