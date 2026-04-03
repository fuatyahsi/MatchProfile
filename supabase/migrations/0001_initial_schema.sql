create extension if not exists pgcrypto;

create type public.session_status as enum (
  'created',
  'recording',
  'transcribing',
  'awaiting_structured_input',
  'awaiting_clarification',
  'analyzing',
  'awaiting_user_validation',
  'finalized',
  'archived',
  'manual_review_required',
  'failed'
);

create type public.confidence_label as enum (
  'Yüksek Kanıt',
  'Orta Kanıt',
  'Düşük Kanıt',
  'Veri Eksik',
  'Kullanıcı Yorumu Ağırlıklı',
  'Geçmiş Örüntü Benzerliği'
);

create type public.validation_type as enum (
  'dogru',
  'eksik',
  'yanlis',
  'veri_yetersiz'
);

create type public.notification_job_type as enum (
  'checkin_day_7',
  'checkin_day_14'
);

create type public.notification_job_status as enum (
  'scheduled',
  'sent',
  'cancelled',
  'failed'
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  display_name text,
  relationship_goal text,
  pacing_preference text,
  clarity_expectation text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.relationship_values (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  value_key text not null,
  importance_rank int,
  created_at timestamptz not null default now()
);

create table if not exists public.dealbreakers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text not null,
  severity text,
  created_at timestamptz not null default now()
);

create table if not exists public.bias_flags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  flag_key text not null,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.safety_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  preference_key text not null,
  preference_value jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  session_status public.session_status not null default 'created',
  session_title text,
  date_context jsonb not null default '{}'::jsonb,
  date_time timestamptz,
  raw_transcript text,
  cleaned_summary text,
  audio_status text,
  audio_retention_policy text,
  audio_storage_path text,
  final_report jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.structured_responses (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  follow_up_offer text,
  future_plan_signal text,
  payment_signal text,
  comfort_level text,
  clarity_level text,
  physical_boundary_issue boolean,
  response_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.extracted_signals (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  signal_type text not null,
  title text not null,
  explanation text not null,
  evidence_source text not null,
  evidence_text text not null,
  confidence_label public.confidence_label not null,
  linked_session_id uuid references public.sessions(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.uncertainty_flags (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  missing_data_point text,
  ambiguity_reason text,
  emotional_bias_risk text,
  insufficient_evidence_flag boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.user_validations (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  signal_id uuid not null references public.extracted_signals(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  validation_type public.validation_type not null,
  user_comment text,
  revised_weight numeric(5,2),
  created_at timestamptz not null default now()
);

create table if not exists public.outcomes (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  follow_up_status text,
  consistency_result text,
  user_choice_outcome text,
  counterpart_behavior_outcome text,
  unresolved_flag boolean not null default false,
  submitted_at timestamptz not null default now()
);

create table if not exists public.memory_patterns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  pattern_strength text not null,
  related_sessions uuid[] not null default '{}',
  pattern_type text not null,
  activation_level text not null,
  pattern_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.safety_events (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  escalation_flag boolean not null default false,
  risk_category text,
  response_mode text,
  notes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.prompt_versions (
  id uuid primary key default gen_random_uuid(),
  version_key text not null unique,
  prompt_family text not null,
  schema_version text not null,
  status text not null,
  prompt_body text,
  created_at timestamptz not null default now()
);

create table if not exists public.analysis_runs (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  prompt_version_id uuid references public.prompt_versions(id) on delete set null,
  schema_version text not null,
  provider_name text not null,
  model_name text not null,
  run_status text not null,
  latency_ms int,
  retry_count int not null default 0,
  contract_valid boolean not null default false,
  failure_reason text,
  raw_output_json jsonb,
  normalized_output_json jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.notification_jobs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  session_id uuid not null references public.sessions(id) on delete cascade,
  job_type public.notification_job_type not null,
  scheduled_for timestamptz not null,
  sent_at timestamptz,
  job_status public.notification_job_status not null default 'scheduled',
  created_at timestamptz not null default now()
);

create table if not exists public.policy_acceptances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  policy_type text not null,
  policy_version text not null,
  accepted_at timestamptz not null default now()
);

create table if not exists public.deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  request_scope text not null,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  request_status text not null
);

create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_type text not null,
  actor_id uuid,
  action_type text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists sessions_user_created_at_idx
  on public.sessions(user_id, created_at desc);

create index if not exists analysis_runs_session_created_at_idx
  on public.analysis_runs(session_id, created_at desc);

create index if not exists notification_jobs_user_status_schedule_idx
  on public.notification_jobs(user_id, job_status, scheduled_for);

create index if not exists user_validations_session_signal_idx
  on public.user_validations(session_id, signal_id);

create index if not exists safety_events_user_created_at_idx
  on public.safety_events(user_id, created_at desc);
