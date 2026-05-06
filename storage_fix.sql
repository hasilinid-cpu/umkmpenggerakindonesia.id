-- ============================================================
-- FIX STORAGE BUCKET & MEDIA TABLE
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- 1. Pastikan bucket 'media' ada dan PUBLIC
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'media', 'media', true,
  52428800,  -- 50MB
  ARRAY['image/jpeg','image/png','image/gif','image/webp','image/svg+xml','video/mp4','video/quicktime','video/webm','video/avi']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 52428800;

-- 2. Hapus semua policy storage lama
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies WHERE tablename='objects' AND schemaname='storage'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON storage.objects'; END LOOP;
END $$;

-- 3. Buat policy storage yang benar
-- Siapapun bisa LIHAT (SELECT) file di bucket media
CREATE POLICY "media_public_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'media');

-- Siapapun bisa UPLOAD (INSERT) ke bucket media
CREATE POLICY "media_public_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'media');

-- Hanya authenticated yang bisa hapus
CREATE POLICY "media_auth_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'media' AND auth.role() = 'authenticated');

-- Admin bisa semua
CREATE POLICY "media_auth_all"
  ON storage.objects FOR ALL
  USING (bucket_id = 'media' AND auth.role() = 'authenticated');

-- 4. Pastikan tabel media ada dengan struktur benar
CREATE TABLE IF NOT EXISTS media (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama         TEXT NOT NULL,
  tipe         TEXT CHECK (tipe IN ('image','video')),
  url          TEXT NOT NULL,
  storage_path TEXT,
  ukuran       INTEGER,
  deskripsi    TEXT,
  aktif        BOOLEAN DEFAULT true,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE media ENABLE ROW LEVEL SECURITY;

DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies WHERE tablename='media'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON media'; END LOOP;
END $$;

CREATE POLICY "media_public_read"  ON media FOR SELECT USING (aktif = true);
CREATE POLICY "media_public_ins"   ON media FOR INSERT WITH CHECK (true);
CREATE POLICY "media_auth_all"     ON media FOR ALL   USING (auth.role() = 'authenticated');

SELECT 'Storage fix selesai! Bucket media sudah public.' AS status;
