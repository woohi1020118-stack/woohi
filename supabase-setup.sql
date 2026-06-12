-- songs 테이블 생성
create table if not exists public.songs (
  id       uuid primary key default gen_random_uuid(),
  artist   text not null,
  title    text not null,
  genre    text default 'etc',   -- kpop | jpop | pop | indie | folk | etc
  level    int  default 0,       -- 0~5 숙련도
  memo     text default '',
  created_at timestamptz default now()
);

-- RLS 활성화
alter table public.songs enable row level security;

-- 공개 읽기 (노래책 페이지에서 사용)
create policy "Public read songs"
  on public.songs for select
  using (true);

-- 인증된 사용자만 추가/수정/삭제 (admin 페이지에서 사용)
create policy "Auth insert songs"
  on public.songs for insert
  to authenticated
  with check (true);

create policy "Auth update songs"
  on public.songs for update
  to authenticated
  using (true);

create policy "Auth delete songs"
  on public.songs for delete
  to authenticated
  using (true);

-- schedules 테이블 (방송 일정 특이사항)
create table if not exists public.schedules (
  id         uuid primary key default gen_random_uuid(),
  date       date not null unique,           -- 날짜 (YYYY-MM-DD)
  status     text default 'normal',          -- normal | holiday | special
  slot1_title text,                          -- 1부 방송 내용
  slot2_title text,                          -- 2부 방송 내용
  note       text,                           -- 메모 / 휴방 사유
  created_at timestamptz default now()
);

alter table public.schedules enable row level security;

create policy "Public read schedules"
  on public.schedules for select using (true);

create policy "Auth insert schedules"
  on public.schedules for insert to authenticated with check (true);

create policy "Auth update schedules"
  on public.schedules for update to authenticated using (true);

create policy "Auth delete schedules"
  on public.schedules for delete to authenticated using (true);

-- schedules 테이블에 시간 컬럼 추가
alter table public.schedules
  add column if not exists slot1_time text default '11:30',
  add column if not exists slot2_time text default '19:00';

-- overlay_state 테이블
CREATE TABLE IF NOT EXISTS public.overlay_state (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  song_title TEXT DEFAULT '',
  song_artist TEXT DEFAULT '',
  is_visible BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
INSERT INTO public.overlay_state (id, song_title, song_artist, is_visible)
VALUES (1, '', '', false) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.overlay_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "overlay_read" ON public.overlay_state FOR SELECT USING (true);
CREATE POLICY "overlay_update" ON public.overlay_state FOR UPDATE TO authenticated USING (true);
CREATE POLICY "overlay_insert" ON public.overlay_state FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "overlay_upsert" ON public.overlay_state FOR ALL TO authenticated USING (true);

-- 업보 테이블들
CREATE TABLE IF NOT EXISTS public.upbo_task_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text DEFAULT 'normal', -- normal | event
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.upbo_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname text NOT NULL,
  user_id text,
  memo text,
  is_hidden boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.upbo_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id uuid REFERENCES public.upbo_members(id) ON DELETE CASCADE,
  type_id uuid REFERENCES public.upbo_task_types(id) ON DELETE CASCADE,
  quantity int DEFAULT 1,
  memo text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.upbo_inquiries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname text,
  content text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.upbo_settings (
  key text PRIMARY KEY,
  value text
);

-- RLS
ALTER TABLE public.upbo_task_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read task_types" ON public.upbo_task_types FOR SELECT USING (true);
CREATE POLICY "public read members" ON public.upbo_members FOR SELECT USING (true);
CREATE POLICY "public read tasks" ON public.upbo_tasks FOR SELECT USING (true);
CREATE POLICY "public read settings" ON public.upbo_settings FOR SELECT USING (true);
CREATE POLICY "public insert inquiries" ON public.upbo_inquiries FOR INSERT WITH CHECK (true);

CREATE POLICY "auth all task_types" ON public.upbo_task_types FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all members" ON public.upbo_members FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all tasks" ON public.upbo_tasks FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all settings" ON public.upbo_settings FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth read inquiries" ON public.upbo_inquiries FOR SELECT TO authenticated USING (true);

-- ─────────────────────────────────────────────
-- dress_items (옷장 / 방셀 리스트)
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.dress_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category    TEXT NOT NULL DEFAULT 'hair', -- hair | outfit | etc
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
CREATE POLICY "public read dress" ON public.dress_items FOR SELECT USING (true);
CREATE POLICY "auth all dress"    ON public.dress_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);
