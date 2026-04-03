# MatchProfile Database Schema v1

Backend hedefi: Supabase + PostgreSQL + pgvector

## Design Rules

- Tüm application tabloları `uuid` primary key kullanır.
- `auth.users(id)` ana kullanıcı kaynağıdır.
- `created_at` ve `updated_at` standarttır.
- `user_id` taşıyan her tabloda row-level security uygulanır.
- Ham provider çıktısı kullanıcıya gösterilmez; yalnızca normalize edilmiş contract saklanır ve render edilir.

## Core Tables

### profiles
- `id uuid pk`
- `user_id uuid unique fk auth.users`
- `display_name text`
- `relationship_goal text`
- `pacing_preference text`
- `clarity_expectation text`
- `created_at timestamptz`
- `updated_at timestamptz`

### relationship_values
- `id uuid pk`
- `user_id uuid fk`
- `value_key text`
- `importance_rank int`
- `created_at timestamptz`

### dealbreakers
- `id uuid pk`
- `user_id uuid fk`
- `label text`
- `severity text`
- `created_at timestamptz`

### bias_flags
- `id uuid pk`
- `user_id uuid fk`
- `flag_key text`
- `notes text`
- `created_at timestamptz`

### safety_preferences
- `id uuid pk`
- `user_id uuid fk`
- `preference_key text`
- `preference_value jsonb`
- `created_at timestamptz`
- `updated_at timestamptz`

### sessions
- `id uuid pk`
- `user_id uuid fk`
- `session_status text`
- `session_title text`
- `date_context jsonb`
- `date_time timestamptz`
- `raw_transcript text`
- `cleaned_summary text`
- `audio_status text`
- `audio_retention_policy text`
- `audio_storage_path text`
- `final_report jsonb`
- `created_at timestamptz`
- `updated_at timestamptz`

### structured_responses
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `follow_up_offer text`
- `future_plan_signal text`
- `payment_signal text`
- `comfort_level text`
- `clarity_level text`
- `physical_boundary_issue boolean`
- `response_payload jsonb`
- `created_at timestamptz`
- `updated_at timestamptz`

### extracted_signals
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `signal_type text`
- `title text`
- `explanation text`
- `evidence_source text`
- `evidence_text text`
- `confidence_label text`
- `linked_session_id uuid null`
- `created_at timestamptz`
- `updated_at timestamptz`

### uncertainty_flags
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `missing_data_point text`
- `ambiguity_reason text`
- `emotional_bias_risk text`
- `insufficient_evidence_flag boolean`
- `created_at timestamptz`

### user_validations
- `id uuid pk`
- `session_id uuid fk`
- `signal_id uuid fk extracted_signals`
- `user_id uuid fk`
- `validation_type text`
- `user_comment text`
- `revised_weight numeric`
- `created_at timestamptz`

### outcomes
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `follow_up_status text`
- `consistency_result text`
- `user_choice_outcome text`
- `counterpart_behavior_outcome text`
- `unresolved_flag boolean`
- `submitted_at timestamptz`

### memory_patterns
- `id uuid pk`
- `user_id uuid fk`
- `pattern_strength text`
- `related_sessions uuid[]`
- `pattern_type text`
- `activation_level text`
- `pattern_summary text`
- `created_at timestamptz`
- `updated_at timestamptz`

### safety_events
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `escalation_flag boolean`
- `risk_category text`
- `response_mode text`
- `notes jsonb`
- `created_at timestamptz`

## Operational Tables

### analysis_runs
- `id uuid pk`
- `session_id uuid fk`
- `user_id uuid fk`
- `prompt_version_id uuid fk`
- `schema_version text`
- `provider_name text`
- `model_name text`
- `run_status text`
- `latency_ms int`
- `retry_count int`
- `contract_valid boolean`
- `failure_reason text`
- `raw_output_json jsonb`
- `normalized_output_json jsonb`
- `created_at timestamptz`

### prompt_versions
- `id uuid pk`
- `version_key text unique`
- `prompt_family text`
- `schema_version text`
- `status text`
- `prompt_body text`
- `created_at timestamptz`

### notification_jobs
- `id uuid pk`
- `user_id uuid fk`
- `session_id uuid fk`
- `job_type text`
- `scheduled_for timestamptz`
- `sent_at timestamptz null`
- `job_status text`
- `created_at timestamptz`

### policy_acceptances
- `id uuid pk`
- `user_id uuid fk`
- `policy_type text`
- `policy_version text`
- `accepted_at timestamptz`

### deletion_requests
- `id uuid pk`
- `user_id uuid fk`
- `request_scope text`
- `requested_at timestamptz`
- `completed_at timestamptz null`
- `request_status text`

### audit_log
- `id uuid pk`
- `actor_type text`
- `actor_id uuid null`
- `action_type text`
- `entity_type text`
- `entity_id uuid null`
- `metadata jsonb`
- `created_at timestamptz`

## Recommended Enums

- `session_status`: `created`, `recording`, `transcribing`, `awaiting_structured_input`, `awaiting_clarification`, `analyzing`, `awaiting_user_validation`, `finalized`, `archived`, `manual_review_required`, `failed`
- `confidence_label`: `Yüksek Kanıt`, `Orta Kanıt`, `Düşük Kanıt`, `Veri Eksik`, `Kullanıcı Yorumu Ağırlıklı`, `Geçmiş Örüntü Benzerliği`
- `validation_type`: `dogru`, `eksik`, `yanlis`, `veri_yetersiz`
- `job_type`: `checkin_day_7`, `checkin_day_14`
- `job_status`: `scheduled`, `sent`, `cancelled`, `failed`

## Suggested Indexes

- `sessions(user_id, created_at desc)`
- `analysis_runs(session_id, created_at desc)`
- `notification_jobs(user_id, job_status, scheduled_for)`
- `user_validations(session_id, signal_id)`
- `safety_events(user_id, created_at desc)`

## RLS Rules

- Kullanıcı yalnızca kendi `user_id` kayıtlarını okuyabilir.
- Service role, analysis ve notification job güncellemelerinde bypass eder.
- `audit_log` son kullanıcı için read-only veya tamamen kapalı olabilir.
