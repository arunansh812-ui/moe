-- Modern Education School: Supabase starter schema
-- Run in Supabase SQL Editor. Review policies with your database administrator before production.
create extension if not exists pgcrypto;

create type public.school_role as enum ('administrator','staff','nodal_officer','student');
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  user_id text unique,
  role public.school_role not null default 'student',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.staff_assignments (
  id uuid primary key default gen_random_uuid(),
  staff_id uuid not null references public.profiles(id) on delete cascade,
  designation text not null check (designation in ('subject_teacher','class_teacher','both','nodal_officer')),
  class_name text,
  section_name text,
  subjects text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table public.circulars (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  pdf_path text not null,
  published boolean not null default false,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.question_papers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  class_name text not null,
  section_name text not null,
  subject text not null,
  academic_session text,
  pdf_path text not null,
  uploaded_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.admission_applications (
  id uuid primary key default gen_random_uuid(),
  application_reference uuid not null unique default gen_random_uuid(),
  student_name text not null,
  father_name text not null,
  mother_name text not null,
  dob date not null,
  previous_class text,
  previous_percentage numeric(5,2) check (previous_percentage between 0 and 100),
  applying_for text not null,
  guardian_email text not null,
  photo_path text not null,
  status text not null default 'submitted' check (status in ('submitted','under_review','verified','not_eligible','exam_scheduled','completed')),
  reviewed boolean not null default false,
  exam_roll_number text unique,
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.admission_exam_documents (
  id uuid primary key default gen_random_uuid(),
  application_id uuid not null references public.admission_applications(id) on delete cascade,
  document_type text not null check (document_type in ('question_paper','marks_record','evaluated_answer_sheet')),
  file_path text not null,
  uploaded_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  student_id text not null unique,
  student_name text not null,
  roll_number text,
  class_name text not null,
  section_name text not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  attendance_date date not null,
  status text not null check (status in ('present','absent','leave')),
  marked_by uuid not null references public.profiles(id),
  unique(student_id,attendance_date)
);

create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  class_name text not null,
  assessment_name text not null,
  subject text not null,
  maximum_marks numeric(7,2) not null check (maximum_marks > 0),
  passing_marks numeric(7,2) not null check (passing_marks >= 0 and passing_marks <= maximum_marks),
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.examination_marks (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  assessment_id uuid not null references public.assessments(id) on delete cascade,
  marks numeric(7,2) not null check (marks >= 0),
  entered_by uuid not null references public.profiles(id),
  submitted_at timestamptz not null default now(),
  unique(student_id,assessment_id)
);

create table public.result_publications (
  id uuid primary key default gen_random_uuid(),
  class_name text not null,
  section_name text not null,
  assessment_name text not null,
  published boolean not null default false,
  published_by uuid references public.profiles(id),
  published_at timestamptz
);

-- Basic row-level security. Production policies should be further tightened and tested.
alter table public.profiles enable row level security;
alter table public.staff_assignments enable row level security;
alter table public.circulars enable row level security;
alter table public.question_papers enable row level security;
alter table public.admission_applications enable row level security;
alter table public.admission_exam_documents enable row level security;
alter table public.students enable row level security;
alter table public.attendance enable row level security;
alter table public.assessments enable row level security;
alter table public.examination_marks enable row level security;
alter table public.result_publications enable row level security;

-- Public can read only published circulars and academic papers.
create policy "public read published circulars" on public.circulars for select using (published = true);
create policy "public read question papers" on public.question_papers for select using (true);

-- Authenticated users can read their own profile.
create policy "read own profile" on public.profiles for select to authenticated using (id = auth.uid());

-- IMPORTANT: Do not expose admission_applications or private storage to anon/public users.
-- Admission submission and status checking must be implemented via Edge Functions
-- that validate input and reveal only the matching application status.
-- Nodal Officer-only application access and assignment checks must also be enforced
-- in server-side Edge Functions (never by trusting browser role fields).

-- Storage buckets to create in Supabase dashboard:
-- school-documents (public read for published circulars/question papers; uploads restricted)
-- admission-private (private; only trusted Edge Functions / authorized Nodal Officer access)
