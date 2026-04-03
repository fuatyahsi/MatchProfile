# MatchProfile Screen Breakdown

## App Structure

- Authless beta shell or authenticated shell
- Bottom navigation: `Dashboard`, `Journal`, `Settings`
- Primary action: `New Reflection`

## 1. Welcome
- Goal: ürünün ne yaptığını ve ne yapmadığını netleştirmek
- Components:
- headline: `Date sonrası daha net düşün`
- short explainer
- disclaimer chips: `Dating app değil`, `Nihai karar vermez`, `18+`
- CTA: `Başla`

## 2. Onboarding / Calibration
- Goal: kullanıcı anchor profilini toplamak
- Steps:
- relationship goal
- top 3 values
- dealbreakers
- pacing preference
- bias flags
- safety sensitivity
- policy acceptance
- State:
- form wizard
- local draft save
- completion summary

## 3. Dashboard / Netlik Özeti
- Goal: kullanıcının mevcut durumunu skorsuz göstermek
- Sections:
- latest reflection card
- pending 7/14 day check-ins
- repeated signal snapshot
- missing data prompt
- CTA `Yeni değerlendirme`

## 4. New Reflection Session
- Goal: yeni session başlatmak
- Components:
- session summary card
- date context inputs
- start debrief CTA

## 5. Voice Debrief
- Goal: serbest anlatım almak
- Components:
- timer
- record / pause / finish
- privacy reminder
- optional manual note field
- MVP note:
- ilk iterasyonda gerçek recording yerine demo transcript / text input fallback olabilir

## 6. Structured Form
- Goal: anlatımdaki boşlukları standartlaştırmak
- Fields:
- follow-up offer
- future plan signal
- comfort level
- clarity level
- payment signal
- physical boundary issue

## 7. Clarification Questions
- Goal: en fazla 3 netleştirme sorusuyla ambiguity azaltmak
- Components:
- one-question-per-card UI
- short answer input
- skip / answer actions

## 8. Insight Report
- Goal: canonical `insight_report_v1` render etmek
- Sections:
- summary
- positive signals
- caution signals
- uncertainty flags
- missing data points
- recommended questions
- next step
- confidence labels and evidence snippets

## 9. Safety Escalation View
- Goal: normal romantic değerlendirmeden güvenlik-first moda geçmek
- Sections:
- safety headline
- why this was escalated
- slow down / step back actions
- help resources block
- optional continue to insight

## 10. Validation Step
- Goal: kullanıcının raporu kalibre etmesi
- Components:
- per-signal feedback chips
- global prompt: `Neyi yanlış anladım?`
- finalize CTA

## 11. Final Reflection Save
- Goal: session'ı journala yazmak ve check-in planlamak
- Sections:
- saved confirmation
- next check-in preview
- view journal CTA

## 12. Journal / History
- Goal: geçmiş reflections ve outcome'ları görmek
- Components:
- filter chips
- session cards
- outcome labels
- detail drill-down

## 13. Check-ins
- Goal: 7. ve 14. gün outcome toplamak
- Components:
- yes/no/mixed status prompts
- consistency questions
- user choice outcome
- counterpart behavior outcome

## 14. Settings / Privacy
- Goal: güven ve veri kontrolü
- Sections:
- retention policy
- delete session
- request account deletion
- policy documents
- notification preferences

## Store-Facing Requirements

- iPhone small/large ve Android phone screenshots için en az şu ekranlar polish edilmeli:
- Welcome
- Onboarding
- Dashboard
- Insight Report
- Journal
- Privacy / Settings
