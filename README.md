# MatchProfile

MatchProfile, date sonrası karar netliği için tasarlanmış mobil bir reflection app'idir.

Bu repo şu anda MVP beta temelini içerir:

- Flutter mobile app shell
- onboarding / calibration flow
- reflection composer
- canonical `insight_report_v1` mantığına göre mock insight screen
- validation step
- journal / history
- privacy & settings
- Supabase schema taslağı ve migration başlangıcı
- teknik backlog, ekran kırılımı ve TODO planı

## Repo Yapısı

- `app/`: Flutter uygulaması
- `docs/`: ürün ve teslimat planlama dokümanları
- `supabase/`: veritabanı migration başlangıcı
- `build_ready.txt`: ürün blueprint kaynağı
- `TODO.md`: mevcut execution listesi

## Hızlı Başlangıç

```powershell
cd app
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat analyze
C:\flutter\bin\flutter.bat test -r expanded
```

## Mevcut Durum

Tamamlananlar:

- build-ready blueprint revizyonu
- teknik backlog
- ekran planı
- database schema planı
- Flutter app ilk dikey kesit
- widget smoke test

Sıradaki ana işler:

- Supabase entegrasyonu
- gerçek session persistence
- audio capture / STT pipeline
- App Store / Google Play release hazırlıkları
- CI ve GitHub workflow

## Dokümanlar

- [Teknik Backlog](docs/technical_backlog.md)
- [Screen Breakdown](docs/screens.md)
- [Database Schema](docs/database_schema.md)
- [Store Release Checklist](docs/store_release_checklist.md)

## Notlar

- Windows desktop run için Visual Studio C++ toolchain gerekir.
- Android emulator ve web smoke test için daha hazır durumda.
