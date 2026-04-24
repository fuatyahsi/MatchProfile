// ══════════════════════════════════════════════════════════════
//  AI Servis Yapılandırması
//  ──────────────────────────────────
//  İki katmanlı strateji:
//   • Self-hosted HF Space → Ana LLM yolu (Qwen açık kaynak hedefi)
//   • Gemini 2.5 ailesi → Opsiyonel kalite / yedek katman
//  Hepsi ücretsiz katman. Hiçbiri zorunlu değil —
//  yoksa kural tabanlı motor (TextAnalysisEngine) devrede kalır.
//
//  Anahtarlar SharedPreferences'a şifresiz kaydedilir. Dev/kişisel
//  kullanım için yeterli. Prod'a çıkarken flutter_secure_storage'a
//  migrate edilmeli.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIConfig {
  AIConfig._() {
    const String envGemini =
        String.fromEnvironment('MATCHPROFILE_GEMINI_API_KEY');
    const String envSelfHostedUrl =
        String.fromEnvironment('MATCHPROFILE_SELF_HOSTED_LLM_URL');
    const String envSelfHostedToken =
        String.fromEnvironment('MATCHPROFILE_SELF_HOSTED_LLM_TOKEN');
    const String envHf = String.fromEnvironment('MATCHPROFILE_HF_API_KEY');
    const String envSupabaseUrl =
        String.fromEnvironment('MATCHPROFILE_SUPABASE_URL');
    const String envSupabaseAnon =
        String.fromEnvironment('MATCHPROFILE_SUPABASE_ANON_KEY');

    if (envGemini.isNotEmpty) _geminiApiKey = envGemini;
    if (envSelfHostedUrl.isNotEmpty) _selfHostedLlmUrl = envSelfHostedUrl;
    if (envSelfHostedToken.isNotEmpty) _selfHostedLlmToken = envSelfHostedToken;
    if (envHf.isNotEmpty) _hfApiKey = envHf;
    if (envSupabaseUrl.isNotEmpty) _supabaseUrl = envSupabaseUrl;
    if (envSupabaseAnon.isNotEmpty) _supabaseAnonKey = envSupabaseAnon;
  }
  static final AIConfig instance = AIConfig._();

  // ── Storage key'leri ──
  static const String _prefsKeyGemini = 'ai_gemini_api_key';
  static const String _prefsKeySelfHostedUrl = 'ai_self_hosted_llm_url';
  static const String _prefsKeySelfHostedToken = 'ai_self_hosted_llm_token';
  static const String _prefsKeyHf = 'ai_hf_api_key';
  static const String _prefsKeySupabaseUrl = 'ai_supabase_url';
  static const String _prefsKeySupabaseAnon = 'ai_supabase_anon_key';

  bool _loaded = false;
  bool get hasLoadedFromStorage => _loaded;

  // ── Self-hosted LLM (HF Space / kendi backend) ──
  String? _selfHostedLlmUrl;
  String? _selfHostedLlmToken;
  static const String selfHostedProviderLabel = 'Self-hosted Qwen';

  // ── Gemini (Ana LLM ailesi) ──
  String? _geminiApiKey;
  // 2.5 Flash: daha kaliteli derin analiz / structured JSON
  static const String geminiStructuredModel = 'gemini-2.5-flash';
  // 2.5 Flash-Lite: daha ucuz / daha hızlı sohbet ve düşük gecikme
  static const String geminiChatModel = 'gemini-2.5-flash-lite';
  static const String geminiProviderLabel = 'Gemini 2.5';
  static const int geminiMaxTokens = 2048;
  static const double geminiTemperature = 0.7;

  // ── HuggingFace (Embedding) ──
  String? _hfApiKey;
  static const String hfBaseUrl = 'https://api-inference.huggingface.co';
  // Ücretsiz, yüksek kalite Türkçe destekli model
  static const String hfEmbeddingModel =
      'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2';
  static const int embeddingDimension = 384;

  // ── Supabase (Vector Store) ──
  String? _supabaseUrl;
  String? _supabaseAnonKey;

  // ── Durum ──
  bool get hasSelfHostedLlm =>
      _selfHostedLlmUrl != null && _selfHostedLlmUrl!.trim().isNotEmpty;
  bool get hasGemini =>
      _geminiApiKey != null && _geminiApiKey!.isNotEmpty;
  bool get hasHuggingFace => _hfApiKey != null && _hfApiKey!.isNotEmpty;
  bool get hasSupabase =>
      _supabaseUrl != null &&
      _supabaseUrl!.isNotEmpty &&
      _supabaseAnonKey != null &&
      _supabaseAnonKey!.isNotEmpty;

  /// AI pipeline aktif mi? En az bir sohbet LLM'i yapılandırılmış olmalı
  bool get isAIPipelineAvailable => hasSelfHostedLlm || hasGemini;

  /// Tam pipeline: ana LLM + embedding
  bool get isFullPipelineAvailable =>
      (hasSelfHostedLlm || hasGemini) && hasHuggingFace;

  /// Sohbet için tercih edilen servis kullanılabilir mi?
  /// Önerilen: self-hosted HF Space. Yoksa Gemini'ye düşer.
  bool get isChatLlmAvailable => hasSelfHostedLlm || hasGemini;

  String get geminiApiKey => _geminiApiKey ?? '';
  String get selfHostedLlmUrl => _selfHostedLlmUrl ?? '';
  String get selfHostedLlmToken => _selfHostedLlmToken ?? '';
  String get hfApiKey => _hfApiKey ?? '';
  String get supabaseUrl => _supabaseUrl ?? '';
  String get supabaseAnonKey => _supabaseAnonKey ?? '';

  // ── Kalıcı Saklama ──

  /// Uygulama başlangıcında çağrılır. Daha önce kaydedilmiş anahtarları
  /// SharedPreferences'tan yükler.
  ///
  /// Env değişkenlerinden (--dart-define) gelen değerler daha önce
  /// constructor'da set edildiyse, kaydedilmiş değer onları EZMEZ —
  /// env önceliklidir.
  Future<void> loadFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? savedGemini = prefs.getString(_prefsKeyGemini);
      if (savedGemini != null && savedGemini.isNotEmpty && !hasGemini) {
        _geminiApiKey = savedGemini;
      }

      final String? savedSelfHostedUrl =
          prefs.getString(_prefsKeySelfHostedUrl);
      if (savedSelfHostedUrl != null &&
          savedSelfHostedUrl.isNotEmpty &&
          !hasSelfHostedLlm) {
        _selfHostedLlmUrl = savedSelfHostedUrl;
      }

      final String? savedSelfHostedToken =
          prefs.getString(_prefsKeySelfHostedToken);
      if (savedSelfHostedToken != null &&
          savedSelfHostedToken.isNotEmpty &&
          (_selfHostedLlmToken == null || _selfHostedLlmToken!.isEmpty)) {
        _selfHostedLlmToken = savedSelfHostedToken;
      }

      final String? savedHf = prefs.getString(_prefsKeyHf);
      if (savedHf != null && savedHf.isNotEmpty && !hasHuggingFace) {
        _hfApiKey = savedHf;
      }

      final String? savedSupabaseUrl = prefs.getString(_prefsKeySupabaseUrl);
      if (savedSupabaseUrl != null &&
          savedSupabaseUrl.isNotEmpty &&
          (_supabaseUrl == null || _supabaseUrl!.isEmpty)) {
        _supabaseUrl = savedSupabaseUrl;
      }

      final String? savedSupabaseAnon =
          prefs.getString(_prefsKeySupabaseAnon);
      if (savedSupabaseAnon != null &&
          savedSupabaseAnon.isNotEmpty &&
          (_supabaseAnonKey == null || _supabaseAnonKey!.isEmpty)) {
        _supabaseAnonKey = savedSupabaseAnon;
      }

      _loaded = true;
      if (kDebugMode) {
        debugPrint(
            'AIConfig yüklendi: SelfHosted=$hasSelfHostedLlm Gemini=$hasGemini HF=$hasHuggingFace');
      }
    } catch (e) {
      debugPrint('AIConfig storage okuma hatası: $e');
      _loaded = true; // Hata olsa bile engellemesin
    }
  }

  /// Mevcut anahtarları diske yaz.
  Future<void> _persistToStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      Future<void> writeOrRemove(String key, String? value) async {
        if (value != null && value.isNotEmpty) {
          await prefs.setString(key, value);
        } else {
          await prefs.remove(key);
        }
      }

      await writeOrRemove(_prefsKeyGemini, _geminiApiKey);
      await writeOrRemove(_prefsKeySelfHostedUrl, _selfHostedLlmUrl);
      await writeOrRemove(_prefsKeySelfHostedToken, _selfHostedLlmToken);
      await writeOrRemove(_prefsKeyHf, _hfApiKey);
      await writeOrRemove(_prefsKeySupabaseUrl, _supabaseUrl);
      await writeOrRemove(_prefsKeySupabaseAnon, _supabaseAnonKey);
    } catch (e) {
      debugPrint('AIConfig storage yazma hatası: $e');
    }
  }

  // ── Yapılandırma ──

  /// Anahtarları RAM'e yazar. Varsayılan olarak aynı anda diske de kaydeder.
  /// Diske yazmak istemiyorsan [persist] = false geç.
  void configure({
    String? geminiApiKey,
    String? selfHostedLlmUrl,
    String? selfHostedLlmToken,
    String? huggingFaceApiKey,
    String? supabaseUrl,
    String? supabaseAnonKey,
    bool persist = true,
  }) {
    if (geminiApiKey != null) _geminiApiKey = geminiApiKey;
    if (selfHostedLlmUrl != null) _selfHostedLlmUrl = selfHostedLlmUrl;
    if (selfHostedLlmToken != null) _selfHostedLlmToken = selfHostedLlmToken;
    if (huggingFaceApiKey != null) _hfApiKey = huggingFaceApiKey;
    if (supabaseUrl != null) _supabaseUrl = supabaseUrl;
    if (supabaseAnonKey != null) _supabaseAnonKey = supabaseAnonKey;

    if (persist) {
      // Fire-and-forget — UI'yi bloklamasın.
      unawaited(_persistToStorage());
    }
  }

  /// Tüm anahtarları temizle (RAM + disk).
  Future<void> clearAll() async {
    _geminiApiKey = null;
    _selfHostedLlmUrl = null;
    _selfHostedLlmToken = null;
    _hfApiKey = null;
    _supabaseUrl = null;
    _supabaseAnonKey = null;
    await _persistToStorage();
  }

  /// Sadece belirli anahtarları temizle.
  Future<void> clearKeys({
    bool gemini = false,
    bool selfHosted = false,
    bool huggingFace = false,
    bool supabase = false,
  }) async {
    if (gemini) _geminiApiKey = null;
    if (selfHosted) {
      _selfHostedLlmUrl = null;
      _selfHostedLlmToken = null;
    }
    if (huggingFace) _hfApiKey = null;
    if (supabase) {
      _supabaseUrl = null;
      _supabaseAnonKey = null;
    }
    await _persistToStorage();
  }

  // ── HTTP Header'ları ──

  Map<String, String> get selfHostedHeaders {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (selfHostedLlmToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${selfHostedLlmToken.trim()}';
    }
    return headers;
  }

  Map<String, String> get hfHeaders => <String, String>{
        'Authorization': 'Bearer $hfApiKey',
        'Content-Type': 'application/json',
      };

  Map<String, String> get supabaseHeaders => <String, String>{
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };
}

/// Mini yardımcı: Future'u fire-and-forget çalıştırırken analyzer uyarısı önler.
void unawaited(Future<void> future) {
  future.catchError((Object e) {
    debugPrint('unawaited future hatası: $e');
  });
}
