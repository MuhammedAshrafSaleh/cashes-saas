-- 0006_storage_policies.sql
-- Storage RLS policies for the three buckets.
-- Buckets were created manually in the Supabase dashboard:
--   company-logos  → public
--   user-avatars   → public
--   receipt-images → private

-- ─────────────────────────────────────────────
-- receipt-images (private)
-- Path convention: {company_id}/{user_id}/{entry_id}.jpg
-- ─────────────────────────────────────────────

-- Owner upload to their own user folder (folder index 2, 0-based)
CREATE POLICY "receipt_user_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'receipt-images'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

-- Read: own user OR owner role OR same-company admin
CREATE POLICY "receipt_user_read" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'receipt-images'
    AND (
      (storage.foldername(name))[2] = auth.uid()::text
      OR auth_role() = 'owner'
      OR (
        auth_role() = 'admin'
        AND (storage.foldername(name))[1] = auth_company_id()::text
      )
    )
  );

-- Delete: own user only (pg_cron uses service_role which bypasses RLS)
CREATE POLICY "receipt_user_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'receipt-images'
    AND (storage.foldername(name))[2] = auth.uid()::text
  );

-- ─────────────────────────────────────────────
-- company-logos (public bucket — read is open; restrict writes to owner)
-- Path convention: {company_id}.jpg
-- ─────────────────────────────────────────────
CREATE POLICY "logo_owner_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

CREATE POLICY "logo_owner_modify" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

CREATE POLICY "logo_owner_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'company-logos'
    AND auth_role() = 'owner'
  );

-- ─────────────────────────────────────────────
-- user-avatars (public bucket — read is open; restrict writes to own user)
-- Path convention: {user_id}.jpg
-- ─────────────────────────────────────────────
CREATE POLICY "avatar_self_write" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );

CREATE POLICY "avatar_self_modify" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );

CREATE POLICY "avatar_self_delete" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'user-avatars'
    AND storage.filename(name) LIKE auth.uid()::text || '.%'
  );
