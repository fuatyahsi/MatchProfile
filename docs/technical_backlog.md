# MatchProfile Technical Backlog

Bu backlog, [build_ready.txt](C:\Users\user\Desktop\MatchProfile\build_ready.txt) içindeki `v4.1` blueprint'i delivery planına çevirir.

## Milestone 0 — Release Readiness

### MP-001 Project foundation
- Priority: P0
- Output: `app/` Flutter client, `supabase/` schema, `docs/` planning assets
- Acceptance criteria:
- Android ve iOS build hedefleri olan Flutter uygulama iskeleti çalışır.
- Repo yapısı mobil app, backend schema ve docs katmanlarını ayırır.

### MP-002 Canonical insight contract
- Priority: P0
- Output: `insight_report_v1` domain modeli ve validation kuralları
- Acceptance criteria:
- App yalnızca canonical contract render eder.
- Unknown veya invalid payload kullanıcıya gösterilmez.

### MP-003 Prompt/version observability
- Priority: P0
- Output: `analysis_runs`, `prompt_versions`, audit yaklaşımı
- Acceptance criteria:
- Her analiz çalışması provider, model, schema version ve prompt version ile izlenebilir.

### MP-004 Safety and compliance baseline
- Priority: P0
- Output: 18+ gate, policy acceptance tracking, deletion request flow
- Acceptance criteria:
- Kullanıcı onboarding öncesi yaş beyanı ve politika kabulü verir.
- Deletion ve retention davranışı UI ve schema tarafında temsil edilir.

### MP-005 Notification and check-in scheduler
- Priority: P0
- Output: 7/14 gün check-in job modeli
- Acceptance criteria:
- Session finalize olduğunda iki check-in job'u planlanabilir.
- Manuel outcome gelirse bekleyen job iptal edilebilir.

## Milestone 1 — MVP Beta App

### MP-101 Welcome and onboarding flow
- Priority: P0
- Output: welcome, calibration, values, dealbreakers, bias flags, safety preferences
- Acceptance criteria:
- Kullanıcı tek oturumda onboarding'i tamamlayabilir.
- Zorunlu alanlar boş geçilemez.

### MP-102 Dashboard / Netlik Özeti
- Priority: P0
- Output: son oturum özeti, bekleyen check-in'ler, CTA
- Acceptance criteria:
- Dashboard skorsuz çalışır.
- Kullanıcı yeni reflection başlatabilir ve history'ye gidebilir.

### MP-103 Reflection session flow
- Priority: P0
- Output: debrief capture, structured form, clarification questions
- Acceptance criteria:
- Session lifecycle `created -> recording -> awaiting_structured_input -> awaiting_clarification -> analyzing` akışını destekler.
- MVP'de ses kaydı yerine placeholder/manual transcript ile de ilerlenebilir.

### MP-104 Insight screen
- Priority: P0
- Output: positive signals, caution signals, uncertainty, missing data, next step
- Acceptance criteria:
- Her signal confidence label ve evidence ile görünür.
- Safety escalation varsa standart insight görünümü geri plana çekilir.

### MP-105 Validation step
- Priority: P0
- Output: kullanıcı `doğru / eksik / yanlış / veri yetersiz` feedback'i verir
- Acceptance criteria:
- Her signal için validation tutulabilir.
- Sonuç final save öncesi kaydedilir.

### MP-106 Journal and history
- Priority: P0
- Output: geçmiş reflections ve outcome etiketleri
- Acceptance criteria:
- History ikili başarı/başarısız etiketi kullanmaz.
- Kullanıcı geçmiş session kartlarını ve outcome durumlarını görür.

### MP-107 Privacy and settings
- Priority: P0
- Output: retention explanation, delete session, delete account request, legal docs entry points
- Acceptance criteria:
- Kullanıcı veri yaşam döngüsünü anlayabilir.
- Delete aksiyonları audit edilmeye hazır durumdadır.

## Milestone 2 — Backend and Data

### MP-201 Supabase schema v1
- Priority: P0
- Output: initial migration with auth-linked tables
- Acceptance criteria:
- Core profile, session, signal, validation, outcome, safety ve audit tabloları tanımlanır.
- RLS stratejisi belgelenir.

### MP-202 Session orchestration API
- Priority: P1
- Output: session create/update/finalize service contracts
- Acceptance criteria:
- Client belirli state geçişleri dışında illegal transition yapamaz.

### MP-203 Analysis pipeline adapter
- Priority: P1
- Output: STT adapter + LLM adapter + contract validator
- Acceptance criteria:
- Raw transcript, structured form ve memory context tek analysis request'e dönüşür.
- Invalid contract retry edilir, sonra manual review_required durumuna düşer.

### MP-204 Memory update pipeline
- Priority: P1
- Output: structured memory, vector memory, rule memory hooks
- Acceptance criteria:
- Validation sonucu pattern ağırlıklarını etkileyebilir.

### MP-205 Push notification delivery
- Priority: P1
- Output: job runner, send tracking, cancellation path
- Acceptance criteria:
- 7/14 gün check-in push'ları stateful biçimde yönetilir.

## Milestone 3 — Quality, Safety, Launch

### MP-301 Widget and flow tests
- Priority: P0
- Output: smoke tests for onboarding, dashboard, reflection flow
- Acceptance criteria:
- Kritik ekran rotaları testlerle korunur.

### MP-302 Store readiness
- Priority: P0
- Output: bundle identifiers, signing, privacy labels, screenshots, store descriptions
- Acceptance criteria:
- iOS App Store Connect ve Google Play Console checklist'i tamamlanmış olur.

### MP-303 Analytics and guardrails
- Priority: P1
- Output: PDV, dispute rate, latency, STT success, deletion SLA metrics
- Acceptance criteria:
- Product ve ops metrikleri aynı event modeli üzerinden izlenebilir.

### MP-304 Beta operations
- Priority: P1
- Output: first 30 sessions manual quality review, false negative safety review
- Acceptance criteria:
- Faz 1 çıkış kriterleri ölçülebilir hale gelir.

## Dependency Order

1. MP-001 → MP-002 → MP-201
2. MP-101 → MP-102 → MP-103 → MP-104 → MP-105 → MP-106
3. MP-004 → MP-107 → MP-302
4. MP-003 + MP-203 + MP-301 paralel ilerleyebilir
5. MP-205, MP-106 ve MP-201 tamamlanmadan check-in MVP bitmiş sayılmaz

## Immediate Build Sprint

- P0 now: MP-001, MP-002, MP-101, MP-102, MP-103, MP-104, MP-105, MP-106, MP-107, MP-201, MP-301
- P1 next: MP-203, MP-204, MP-205, MP-303, MP-304
- P2 later: monetization, pattern lab expansion, live consent-based mode
