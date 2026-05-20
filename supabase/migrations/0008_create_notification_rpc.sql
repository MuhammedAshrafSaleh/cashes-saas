-- 0008_create_notification_rpc.sql
-- Called from Flutter via supabase.rpc('create_notification', params: {...})
-- SECURITY DEFINER so the user policy INSERT check passes even though
-- the function reads from public.users directly.

CREATE OR REPLACE FUNCTION create_notification(
  p_type         notification_type,
  p_project_name TEXT,
  p_project_id   UUID    DEFAULT NULL,
  p_entry_name   TEXT    DEFAULT NULL,
  p_message_ar   TEXT    DEFAULT NULL,
  p_message_en   TEXT    DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_engineer_name TEXT;
  v_company_id    UUID;
  v_message       TEXT;
BEGIN
  -- Resolve caller's name and company from public.users
  SELECT full_name, company_id
  INTO v_engineer_name, v_company_id
  FROM public.users
  WHERE id = auth.uid();

  -- Build Arabic message: caller may override with p_message_ar
  v_message := COALESCE(p_message_ar, CASE p_type
    WHEN 'new_assignment'   THEN 'تم إنشاء مشروع جديد: '                          || p_project_name
    WHEN 'update_log'       THEN 'تم تعديل بند '   || COALESCE(p_entry_name, '') || ' في مشروع ' || p_project_name
    WHEN 'structural_alert' THEN 'تم حذف بند '     || COALESCE(p_entry_name, '') || ' من مشروع ' || p_project_name
    WHEN 'archived'         THEN 'تم حذف مشروع '                                  || p_project_name
    ELSE p_project_name
  END);

  INSERT INTO public.notifications (
    company_id,
    triggered_by,
    type,
    message,
    project_name,
    entry_name,
    engineer_name,
    project_id
  ) VALUES (
    v_company_id,
    auth.uid(),
    p_type,
    v_message,
    p_project_name,
    p_entry_name,
    v_engineer_name,
    p_project_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
