-- ============================================================
-- UMKM PENGGERAK INDONESIA — SCHEMA v4 (FULL + MEDIA UPLOAD)
-- Jalankan di Supabase SQL Editor — AMAN diulang
-- ============================================================

-- 1. BUAT SEMUA TABEL
CREATE TABLE IF NOT EXISTS programs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT NOT NULL, deskripsi TEXT, deskripsi_panjang TEXT,
  kategori TEXT, tipe TEXT DEFAULT 'Gratis', harga INTEGER DEFAULT 0,
  emoji TEXT DEFAULT '📚',
  warna_bg TEXT DEFAULT 'linear-gradient(135deg,#EEF3FD,#DBEAFE)',
  warna_cat TEXT DEFAULT '#3B82F6',
  mentor_nama TEXT, mentor_inisial TEXT DEFAULT 'M',
  peserta INTEGER DEFAULT 0, durasi TEXT DEFAULT 'Self-paced',
  level TEXT DEFAULT 'Pemula', urutan INTEGER DEFAULT 0,
  aktif BOOLEAN DEFAULT true, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS mentors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL, peran TEXT, spesialisasi TEXT,
  emoji TEXT DEFAULT '👤',
  warna_avatar TEXT DEFAULT 'linear-gradient(135deg,#60A5FA,#2563EB)',
  rating TEXT DEFAULT '4.9', peserta INTEGER DEFAULT 0,
  urutan INTEGER DEFAULT 0, aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS testimonials (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL, peran TEXT, isi TEXT NOT NULL,
  emoji TEXT DEFAULT '😊', bintang INTEGER DEFAULT 5,
  featured BOOLEAN DEFAULT false, aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS blog (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  judul TEXT NOT NULL, slug TEXT UNIQUE NOT NULL,
  konten TEXT, ringkasan TEXT,
  thumbnail TEXT DEFAULT '📰', thumbnail_url TEXT,
  kategori TEXT DEFAULT 'Tips UMKM',
  penulis TEXT DEFAULT 'Tim UMKM Penggerak',
  views INTEGER DEFAULT 0,
  aktif BOOLEAN DEFAULT true, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS alumni (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL, usaha TEXT, kota TEXT,
  foto_emoji TEXT DEFAULT '🧑‍💼', foto_url TEXT,
  warna_bg TEXT DEFAULT '#EFF6FF',
  pencapaian TEXT, program_diikuti TEXT,
  omzet_sebelum TEXT, omzet_sesudah TEXT,
  aktif BOOLEAN DEFAULT true, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  invoice_no TEXT UNIQUE NOT NULL,
  program_id UUID, program_judul TEXT NOT NULL, program_harga INTEGER DEFAULT 0,
  nama TEXT NOT NULL, email TEXT NOT NULL, whatsapp TEXT NOT NULL,
  kota TEXT, jenis_usaha TEXT,
  status TEXT DEFAULT 'pending',
  bukti_url TEXT, catatan TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(), confirmed_at TIMESTAMPTZ
);
CREATE TABLE IF NOT EXISTS media (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL, tipe TEXT, url TEXT NOT NULL,
  storage_path TEXT, ukuran INTEGER,
  deskripsi TEXT, aktif BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS site_settings (
  key TEXT PRIMARY KEY, value TEXT, updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS pendaftar (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL, whatsapp TEXT NOT NULL, email TEXT NOT NULL,
  jenis_usaha TEXT, kota TEXT, created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. RLS
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE mentors ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumni ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE pendaftar ENABLE ROW LEVEL SECURITY;

-- 3. DROP ALL OLD POLICIES
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname,tablename FROM pg_policies
    WHERE tablename IN ('programs','mentors','testimonials','blog','alumni','orders','media','site_settings','pendaftar')
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON ' || r.tablename; END LOOP;
END $$;

-- 4. POLICIES
CREATE POLICY "pub_sel_programs" ON programs FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_mentors" ON mentors FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_testimonials" ON testimonials FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_blog" ON blog FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_alumni" ON alumni FOR SELECT USING (aktif=true);
CREATE POLICY "pub_sel_settings" ON site_settings FOR SELECT USING (true);
CREATE POLICY "pub_sel_media" ON media FOR SELECT USING (aktif=true);
CREATE POLICY "pub_ins_pendaftar" ON pendaftar FOR INSERT WITH CHECK (true);
CREATE POLICY "pub_ins_orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "pub_sel_orders" ON orders FOR SELECT USING (true);
CREATE POLICY "pub_upd_orders" ON orders FOR UPDATE USING (true);
CREATE POLICY "adm_programs" ON programs FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_mentors" ON mentors FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_testimonials" ON testimonials FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_blog" ON blog FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_alumni" ON alumni FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_orders" ON orders FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_media" ON media FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_settings" ON site_settings FOR ALL USING (auth.role()='authenticated');
CREATE POLICY "adm_pendaftar" ON pendaftar FOR SELECT USING (auth.role()='authenticated');

-- 5. STORAGE BUCKET
INSERT INTO storage.buckets (id,name,public) VALUES ('media','media',true) ON CONFLICT DO NOTHING;
DROP POLICY IF EXISTS "pub_upload_media" ON storage.objects;
DROP POLICY IF EXISTS "pub_read_media" ON storage.objects;
CREATE POLICY "pub_read_media" ON storage.objects FOR SELECT USING (bucket_id='media');
CREATE POLICY "pub_upload_media" ON storage.objects FOR INSERT WITH CHECK (bucket_id='media');
CREATE POLICY "adm_media_all" ON storage.objects FOR ALL USING (bucket_id='media' AND auth.role()='authenticated');

-- 6. SEED DATA
INSERT INTO programs (judul,deskripsi,deskripsi_panjang,kategori,tipe,harga,emoji,warna_bg,warna_cat,mentor_nama,mentor_inisial,peserta,durasi,level,urutan) VALUES
('Strategi Marketing Digital untuk UMKM','Pelajari cara memasarkan produk secara digital dengan efektif dan terukur.','Program ini membahas strategi pemasaran digital mulai dari media sosial, iklan berbayar, SEO, hingga email marketing. Cocok untuk semua jenis UMKM yang ingin memperluas jangkauan pasar modern.','Marketing','Gratis',0,'📊','linear-gradient(135deg,#EEF3FD,#DBEAFE)','#3B82F6','Andi Pratama','A',2400,'8 Jam','Pemula',1),
('Kelola Keuangan UMKM Agar Bisnis Bertumbuh','Manajemen keuangan sederhana namun efektif untuk pertumbuhan bisnis Anda.','Pelajari cara membuat laporan keuangan sederhana, memisahkan keuangan pribadi dan bisnis, mengelola arus kas, hingga perencanaan modal usaha yang tepat.','Keuangan','Premium',299000,'💰','linear-gradient(135deg,#FFF7ED,#FED7AA)','#F97316','Rina Wijaya','R',1800,'12 Jam','Menengah',2),
('Bangun Brand Kuat Peningkat Penjualan','Cara membangun identitas brand yang kuat, konsisten, dan dikenal pasar.','Dari logo, warna, tone of voice, hingga strategi konten yang konsisten. Program ini memandu Anda membangun brand UMKM yang profesional dan meningkatkan kepercayaan pelanggan.','Branding','Premium',199000,'🎨','linear-gradient(135deg,#FEF2F2,#FECACA)','#E30613','Denny Santoso','D',1300,'10 Jam','Pemula',3),
('Optimasi Operasional UMKM agar Efisien','Streamline operasional bisnis untuk menghemat waktu dan biaya.','Pelajari sistem operasional yang efisien mulai dari manajemen stok, SOP produksi, hingga tools digital gratis untuk otomasi bisnis UMKM Anda.','Operasional','Gratis',0,'⚙️','linear-gradient(135deg,#F0FDF4,#DCFCE7)','#22C55E','Fitri Amelia','F',980,'6 Jam','Pemula',4),
('Ekspansi ke Marketplace Nasional','Strategi masuk dan berjualan di Tokopedia, Shopee, dan marketplace lainnya.','Panduan lengkap membuka toko online, optimasi listing produk, strategi promo, hingga cara mengelola pesanan massal di marketplace nasional.','Marketplace','Gratis',0,'🛒','linear-gradient(135deg,#F0FFFE,#CCFBF1)','#0D9488','Andi Pratama','A',2100,'8 Jam','Pemula',5),
('Inovasi Produk untuk UMKM Masa Depan','Kembangkan produk yang inovatif dan relevan dengan tren pasar.','Dari riset pasar, pengembangan produk baru, packaging menarik, hingga penetapan harga yang kompetitif. Jadikan produk Anda unggul di pasar nasional maupun internasional.','Inovasi','Premium',349000,'🚀','linear-gradient(135deg,#FAF5FF,#EDE9FE)','#8B5CF6','Yudha Prasetya','Y',1100,'14 Jam','Lanjutan',6)
ON CONFLICT DO NOTHING;

INSERT INTO mentors (nama,peran,spesialisasi,emoji,warna_avatar,rating,peserta,urutan) VALUES
('Andi Pratama','Digital Marketing Specialist','Marketing','👨‍💼','linear-gradient(135deg,#60A5FA,#2563EB)','4.9',4500,1),
('Rina Wijaya','Financial Expert & Business Advisor','Keuangan','👩‍💼','linear-gradient(135deg,#FB923C,#EA580C)','4.8',2800,2),
('Denny Santoso','Brand Consultant','Branding','👨‍🎨','linear-gradient(135deg,#F87171,#DC2626)','4.9',2300,3),
('Fitri Amelia','Business Coach & Trainer','Operasional','👩‍🏫','linear-gradient(135deg,#4ADE80,#16A34A)','4.7',1900,4)
ON CONFLICT DO NOTHING;

INSERT INTO testimonials (nama,peran,isi,emoji,bintang,featured) VALUES
('Budi Setiawan','Pemilik Restoran, Bandung','Berkat UMKM Penggerak, omzet restoran saya naik 3 kali lipat dalam 6 bulan. Programnya sangat praktis!','🧑‍🍳',5,true),
('Sari Andini','Pemilik Toko Online, Jakarta','Saya bisa ekspansi ke 3 marketplace hanya dalam 2 bulan. Mentor di sini benar-benar membantu step by step!','👩‍💻',5,false),
('Agus Hermawan','Petani & Pengusaha, Jawa Tengah','Dari petani biasa sekarang sudah punya brand produk pertanian sendiri yang dikenal luas. Terima kasih!','👨‍🌾',5,false)
ON CONFLICT DO NOTHING;

INSERT INTO blog (judul,slug,konten,ringkasan,thumbnail,kategori,penulis) VALUES
('5 Strategi Marketing Digital Wajib untuk UMKM','5-strategi-marketing-digital',
'<h2>1. Optimalkan Media Sosial</h2><p>Instagram, TikTok, dan Facebook bisa menjadi alat pemasaran gratis yang sangat powerful jika digunakan dengan strategi tepat. Buat konten yang menarik, konsisten, dan relevan dengan target pasar Anda.</p><h2>2. Buat Konten yang Konsisten</h2><p>Posting minimal 3-5 kali seminggu dengan konten yang bernilai. Gunakan format video pendek, carousel, dan infografis untuk meningkatkan engagement.</p><h2>3. Manfaatkan WhatsApp Business</h2><p>WhatsApp Business menyediakan fitur katalog produk, pesan otomatis, dan label pelanggan yang sangat berguna untuk UMKM skala kecil hingga menengah.</p><h2>4. Daftar di Google My Business</h2><p>Gratis dan sangat efektif untuk meningkatkan visibilitas bisnis Anda di pencarian lokal Google. Tambahkan foto produk dan minta pelanggan memberi ulasan.</p><h2>5. Mulai Iklan Berbayar dengan Budget Kecil</h2><p>Mulai dari Rp 10.000/hari di Meta Ads sudah bisa menjangkau ribuan calon pelanggan potensial yang ditarget dengan tepat.</p>',
'Temukan 5 strategi marketing digital terbukti yang bisa langsung diterapkan oleh pelaku UMKM untuk meningkatkan penjualan secara signifikan.','📱','Marketing Digital','Andi Pratama'),
('Cara Membuat Laporan Keuangan Sederhana untuk UMKM','laporan-keuangan-sederhana',
'<h2>Mengapa Laporan Keuangan Penting?</h2><p>Banyak UMKM gagal bukan karena produknya buruk, tapi karena tidak tahu kondisi keuangan bisnisnya. Laporan keuangan adalah kompas bisnis Anda.</p><h2>3 Laporan Keuangan Dasar</h2><p><strong>1. Laporan Laba Rugi</strong> — Mencatat semua pemasukan dan pengeluaran dalam periode tertentu untuk mengetahui apakah bisnis untung atau rugi.</p><p><strong>2. Laporan Arus Kas</strong> — Mencatat aliran uang masuk dan keluar. Ini sangat penting agar bisnis tidak kekurangan cash meski secara pembukuan untung.</p><p><strong>3. Neraca</strong> — Gambaran aset, kewajiban, dan modal bisnis Anda pada satu titik waktu tertentu.</p><h2>Tools Gratis yang Bisa Digunakan</h2><p>Google Sheets, BukuWarung, Jurnal.id, atau BukuKas adalah pilihan bagus untuk UMKM pemula yang belum siap menggunakan software akuntansi berbayar.</p>',
'Pelajari cara membuat laporan keuangan sederhana yang bisa langsung diterapkan UMKM tanpa latar belakang akuntansi.','💰','Keuangan','Rina Wijaya'),
('Tips Membangun Brand UMKM yang Kuat dan Dikenal','membangun-brand-umkm',
'<h2>Brand Bukan Sekadar Logo</h2><p>Banyak pelaku UMKM mengira brand hanya soal logo. Padahal brand adalah keseluruhan pengalaman yang dirasakan pelanggan saat berinteraksi dengan bisnis Anda — dari visual, komunikasi, hingga layanan.</p><h2>Elemen Brand yang Harus Dimiliki UMKM</h2><p>Logo profesional, palet warna konsisten, tipografi yang tepat, tone of voice yang sesuai karakter bisnis, dan packaging yang menarik perhatian di rak toko maupun marketplace.</p><h2>Konsistensi adalah Kunci Sukses Brand</h2><p>Gunakan elemen brand yang sama di semua platform — website, media sosial, kemasan produk, hingga seragam karyawan. Konsistensi membangun kepercayaan dan pengenalan merek yang kuat.</p><h2>Storytelling yang Menyentuh Hati</h2><p>Ceritakan kisah di balik bisnis Anda. Pelanggan lebih mudah terhubung dengan brand yang punya cerita autentik dan nilai yang mereka percayai.</p>',
'Panduan lengkap membangun brand UMKM yang kuat, konsisten, dan mampu bersaing di pasar modern yang semakin kompetitif.','🎨','Branding','Denny Santoso')
ON CONFLICT DO NOTHING;

INSERT INTO alumni (nama,usaha,kota,foto_emoji,warna_bg,pencapaian,program_diikuti,omzet_sebelum,omzet_sesudah) VALUES
('Budi Setiawan','Warung Makan Budi Jaya','Bandung','🧑‍🍳','#FFF0F0','Omzet naik 300% dalam 6 bulan setelah menerapkan strategi digital marketing','Marketing Digital','Rp 5 Juta/bln','Rp 20 Juta/bln'),
('Sari Andini','Toko Fashion Online Sari','Jakarta','👩‍💻','#F0FFF4','Berhasil ekspansi ke 3 marketplace nasional dan merekrut 5 karyawan baru','Ekspansi Marketplace','Rp 8 Juta/bln','Rp 35 Juta/bln'),
('Agus Hermawan','Agribisnis Tani Maju','Jawa Tengah','👨‍🌾','#EFF6FF','Punya brand produk pertanian sendiri yang kini masuk supermarket lokal','Branding UMKM','Rp 3 Juta/bln','Rp 18 Juta/bln'),
('Dewi Kusuma','Kue Artisan Dewi','Surabaya','👩‍🍰','#FFFBEB','Produk masuk ke 5 kafe dan supermarket lokal di Surabaya','Operasional & Branding','Rp 4 Juta/bln','Rp 25 Juta/bln'),
('Hendra Putra','Konveksi Putra Jaya','Bandung','👕','#FAF5FF','Berhasil ekspor perdana ke Malaysia dan Singapura','Marketing & Operasional','Rp 15 Juta/bln','Rp 60 Juta/bln'),
('Yuni Rahayu','Batik Yuni Collection','Yogyakarta','🎨','#F0FFFE','Meraih penghargaan UMKM Terbaik DIY 2024','Branding UMKM','Rp 6 Juta/bln','Rp 28 Juta/bln')
ON CONFLICT DO NOTHING;

INSERT INTO site_settings (key,value) VALUES
('stat_member','10K+'),('stat_program','250+'),('stat_mentor','100+'),('stat_umkm','5K+'),
('hero_desc','Platform edukasi, pendampingan, dan komunitas terbaik untuk memberdayakan UMKM Indonesia — naik kelas, berdaya saing, dan berdampak nyata.'),
('whatsapp_admin','6281234567890'),
('bank_name','BCA'),('bank_no','1234567890'),('bank_atas_nama','UMKM Penggerak Indonesia'),
('email_admin','admin@umkmpenggerak.id')
ON CONFLICT (key) DO NOTHING;
