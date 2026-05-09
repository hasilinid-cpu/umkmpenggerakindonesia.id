-- ============================================================
-- PATCH v5 — Jalankan ini SAJA di Supabase SQL Editor
-- Aman diulang berkali-kali
-- ============================================================

-- 1. Tambah kolom yang kurang
ALTER TABLE media        ADD COLUMN IF NOT EXISTS section TEXT DEFAULT 'galeri';
ALTER TABLE mentors      ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE testimonials ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE alumni       ADD COLUMN IF NOT EXISTS foto_url TEXT;
ALTER TABLE blog         ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE programs     ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;

-- 2. Update semua record lama agar section = 'galeri'
UPDATE media SET section = 'galeri' WHERE section IS NULL;

-- 3. Index cepat
CREATE INDEX IF NOT EXISTS idx_media_section ON media(section);
CREATE INDEX IF NOT EXISTS idx_media_aktif ON media(aktif);

-- 4. Fix storage bucket — pastikan PUBLIC
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('media', 'media', true, 52428800)
ON CONFLICT (id) DO UPDATE SET public = true, file_size_limit = 52428800;

-- 5. Drop semua policy storage lama & buat ulang
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies
    WHERE tablename = 'objects' AND schemaname = 'storage'
  LOOP
    EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON storage.objects';
  END LOOP;
END $$;

CREATE POLICY "allow_public_read"   ON storage.objects FOR SELECT USING (bucket_id = 'media');
CREATE POLICY "allow_public_upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'media');
CREATE POLICY "allow_auth_manage"   ON storage.objects FOR ALL
  USING (bucket_id = 'media' AND auth.role() = 'authenticated');

-- 6. Fix RLS media table
DO $$ DECLARE r RECORD;
BEGIN
  FOR r IN SELECT policyname FROM pg_policies WHERE tablename = 'media'
  LOOP EXECUTE 'DROP POLICY IF EXISTS "' || r.policyname || '" ON media'; END LOOP;
END $$;

CREATE POLICY "media_public_read"  ON media FOR SELECT USING (aktif = true);
CREATE POLICY "media_public_write" ON media FOR INSERT WITH CHECK (true);
CREATE POLICY "media_auth_all"     ON media FOR ALL USING (auth.role() = 'authenticated');

SELECT 'Patch v5 berhasil! Semua kolom dan storage sudah siap.' AS status;
