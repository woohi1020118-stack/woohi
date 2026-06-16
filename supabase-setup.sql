-- =============================================
-- 우히 Supabase 전체 스키마 (IF NOT EXISTS 안전)
-- Supabase SQL Editor에서 전체 실행
-- =============================================

-- songs
CREATE TABLE IF NOT EXISTS public.songs (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist     TEXT NOT NULL,
  title      TEXT NOT NULL,
  genre      TEXT DEFAULT 'etc',
  level      INT DEFAULT 0,
  memo       TEXT DEFAULT '',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS sort_order INT DEFAULT 0;
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Public read songs"  ON public.songs FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Auth insert songs"  ON public.songs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Auth update songs"  ON public.songs FOR UPDATE TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "Auth delete songs"  ON public.songs FOR DELETE TO authenticated USING (true);

-- schedules
CREATE TABLE IF NOT EXISTS public.schedules (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date        DATE NOT NULL UNIQUE,
  status      TEXT DEFAULT 'normal',
  slot1_title TEXT,
  slot2_title TEXT,
  slot1_time  TEXT DEFAULT '11:30',
  slot2_time  TEXT DEFAULT '19:00',
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.schedules ADD COLUMN IF NOT EXISTS slot1_time TEXT DEFAULT '11:30';
ALTER TABLE public.schedules ADD COLUMN IF NOT EXISTS slot2_time TEXT DEFAULT '19:00';
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "Public read schedules"  ON public.schedules FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Auth insert schedules"  ON public.schedules FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "Auth update schedules"  ON public.schedules FOR UPDATE TO authenticated USING (true);
CREATE POLICY IF NOT EXISTS "Auth delete schedules"  ON public.schedules FOR DELETE TO authenticated USING (true);

-- overlay_state
CREATE TABLE IF NOT EXISTS public.overlay_state (
  id          INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  song_title  TEXT DEFAULT '',
  song_artist TEXT DEFAULT '',
  is_visible  BOOLEAN DEFAULT FALSE,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO public.overlay_state (id, song_title, song_artist, is_visible)
VALUES (1, '', '', false) ON CONFLICT (id) DO NOTHING;
ALTER TABLE public.overlay_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "overlay_read"   ON public.overlay_state FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "overlay_all"    ON public.overlay_state FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- upbo_task_types
CREATE TABLE IF NOT EXISTS public.upbo_task_types (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  category   TEXT DEFAULT 'normal',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.upbo_task_types ADD COLUMN IF NOT EXISTS sort_order INT DEFAULT 0;
ALTER TABLE public.upbo_task_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public read task_types" ON public.upbo_task_types FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "auth all task_types"    ON public.upbo_task_types FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- upbo_members
CREATE TABLE IF NOT EXISTS public.upbo_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT NOT NULL,
  user_id    TEXT,
  memo       TEXT,
  is_hidden  BOOLEAN DEFAULT FALSE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.upbo_members ADD COLUMN IF NOT EXISTS sort_order INT DEFAULT 0;
ALTER TABLE public.upbo_members ADD COLUMN IF NOT EXISTS is_hidden  BOOLEAN DEFAULT FALSE;
ALTER TABLE public.upbo_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public read members" ON public.upbo_members FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "auth all members"    ON public.upbo_members FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- upbo_tasks
CREATE TABLE IF NOT EXISTS public.upbo_tasks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id  UUID REFERENCES public.upbo_members(id) ON DELETE CASCADE,
  type_id    UUID REFERENCES public.upbo_task_types(id) ON DELETE CASCADE,
  quantity   INT DEFAULT 1,
  memo       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.upbo_tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public read tasks" ON public.upbo_tasks FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "auth all tasks"    ON public.upbo_tasks FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- upbo_inquiries
CREATE TABLE IF NOT EXISTS public.upbo_inquiries (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT,
  content    TEXT,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.upbo_inquiries ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;
ALTER TABLE public.upbo_inquiries ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public insert inquiries" ON public.upbo_inquiries FOR INSERT WITH CHECK (true);
CREATE POLICY IF NOT EXISTS "auth all inquiries"      ON public.upbo_inquiries FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- upbo_settings
CREATE TABLE IF NOT EXISTS public.upbo_settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);
ALTER TABLE public.upbo_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public read settings" ON public.upbo_settings FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "auth all settings"    ON public.upbo_settings FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- dress_items
CREATE TABLE IF NOT EXISTS public.dress_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category    TEXT NOT NULL DEFAULT 'hair',
  name        TEXT NOT NULL,
  description TEXT DEFAULT '',
  image_key   TEXT DEFAULT '',
  image_url   TEXT DEFAULT '',
  badges      JSONB DEFAULT '[]',
  is_event    BOOLEAN DEFAULT FALSE,
  glow_color  TEXT DEFAULT '#1599f0',
  sort_order  INT DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_dress_items_category ON public.dress_items(category);
ALTER TABLE public.dress_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY IF NOT EXISTS "public read dress" ON public.dress_items FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "auth all dress"    ON public.dress_items FOR ALL TO authenticated USING (true) WITH CHECK (true);
