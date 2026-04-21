# AI Refactor Phase 1

## Hedef

Uygulamadaki dağınık AI çağrılarını tek omurgaya toplamak, kullanıcıya görünmeyen anahtar yönetimini başlatmak ve onboarding / reflection kişiselleştirmesini daha sistemli hale getirmek.

## Tamamlananlar

- Ortak AI sözleşmesi eklendi:
  - `app/lib/src/ai/ai_contracts.dart`
- Adaptif soru motoru eklendi:
  - `app/lib/src/ai/adaptive_follow_up_service.dart`
- Reflection raporu ve onboarding mirror üretimi için orkestratöre yeni girişler eklendi:
  - `generatePsycheAnchor(...)`
  - `generateReflectionReport(...)`
- Onboarding 8. bölüm soru üretimi yeni servise bağlanmaya başladı.
- Reflection raporu artık controller üzerinden orkestratörden geliyor.
- API anahtarları için `dart-define` tabanlı gizli yapılandırma desteği eklendi.
- Eski `llm_service.dart` içindeki gömülü Gemini anahtarı temizlendi.

## Devam Edenler

- `llm_service.dart` dosyasının tamamen devreden çıkarılması
- 8. bölümde LLM tabanlı soru yeniden yazımı
- Reflection raporunda AI/yerel mod farkının UI’da daha açık gösterilmesi
- Günlük kullanım ve etkileşim akışlarının aynı tek AI kapısına bağlanması

## Sonraki Adımlar

1. `llm_service.dart` kullanımını tamamen kaldır
2. `generateAdaptiveFollowUps(...)` akışını async hale getir ve LLM rewrite ekle
3. Reflection / daily / interaction için ortak `AiEnvelope` görünürlüğünü UI’ya taşı
4. Release build’de developer AI panelini tamamen kaldır
5. `dart-define` / backend proxy stratejisinden biriyle gerçek gizli anahtar akışını netleştir
