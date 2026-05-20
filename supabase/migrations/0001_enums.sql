-- 0001_enums.sql
-- User roles across the system
CREATE TYPE user_role AS ENUM ('owner', 'admin', 'user');

-- Notification activity types
CREATE TYPE notification_type AS ENUM (
  'new_assignment',   -- User created a new project
  'update_log',       -- User added OR edited a cash entry
  'structural_alert', -- User deleted a cash entry
  'archived'          -- User deleted a project
);
