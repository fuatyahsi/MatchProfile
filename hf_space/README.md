---
title: Match Profile
emoji: 🧠
colorFrom: yellow
colorTo: blue
sdk: docker
app_port: 7860
pinned: false
---

# MatchProfile HF Space LLM

Bu klasor, mobil uygulamanin kendi LLM backend'ine baglanmasi icin minimal HF Space servisidir.

## MVP stratejisi

- Varsayilan model: `Qwen/Qwen2.5-0.5B-Instruct`
- Bir sonraki makul deneme: `Qwen/Qwen2.5-1.5B-Instruct`
- Hedef mimari: GPU Space uzerinde `Qwen/Qwen3-4B` veya `Qwen/Qwen3-8B`

Free CPU Space ile 8B model gercekci degil. Bu yuzden once kucuk modelle endpoint, prompt ve mobil entegrasyon dogrulanir; performans yetmezse ayni API sozlesmesi korunarak model buyutulur.

## Endpointler

- `GET /health`
- `POST /v1/chat`
- `POST /v1/json`

Mobil app `MATCHPROFILE_SELF_HOSTED_LLM_URL` degerini bu Space URL'i olarak alir:

```text
https://<kullanici>-<space-adi>.hf.space
```

Opsiyonel koruma icin Space secret olarak `MATCHPROFILE_SPACE_TOKEN` tanimla. Sonra mobil build'e ayni token'i `MATCHPROFILE_SELF_HOSTED_LLM_TOKEN` ile ver.

## HF Space kurulumu

1. Hugging Face'de yeni Space ac.
2. SDK olarak Docker sec.
3. Bu klasordeki dosyalari Space'e yukle.
4. Secrets/Variables bolumunde gerekirse `MODEL_ID` degerini degistir.
5. App tarafinda:

```text
--dart-define=MATCHPROFILE_SELF_HOSTED_LLM_URL=https://<kullanici>-<space-adi>.hf.space
--dart-define=MATCHPROFILE_SELF_HOSTED_LLM_TOKEN=<opsiyonel-token>
```

Gemini artik sadece yedek katmandir. Groq aktif mimariden cikarildi.
