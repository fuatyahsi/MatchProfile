// ══════════════════════════════════════════════════════════════
//  Groq LLM Analiz Servisi
//  ──────────────────────────────────
//  Llama 3.3 70B (Groq ücretsiz katman) üzerinden
//  kişiselleştirilmiş romantik karar analizi.
//  Her çağrı, kullanıcının profil vektörüne özel
//  dinamik sistem talimatı ile zenginleştirilir.
// ══════════════════════════════════════════════════════════════

// ignore_for_file: unintended_html_in_doc_comment

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ai_config.dart';

/// LLM'den dönen yapılandırılmış analiz sonucu
class LLMAnalysisResult {
  const LLMAnalysisResult({
    required this.rawResponse,
    this.profileInsight = '',
    this.blindSpotWarning = '',
    this.patternDetection = '',
    this.personalizedAdvice = '',
    this.biasFlags = const <String>[],
    this.valueExtractions = const <String>[],
    this.emotionalToneLabel = '',
    this.confidenceScore = 0.0,
    this.error,
  });

  final String rawResponse;
  final String profileInsight;
  final String blindSpotWarning;
  final String patternDetection;
  final String personalizedAdvice;
  final List<String> biasFlags;
  final List<String> valueExtractions;
  final String emotionalToneLabel;
  final double confidenceScore;
  final String? error;

  bool get hasError => error != null;
  bool get isEmpty => rawResponse.isEmpty;
}

/// Analiz türleri
enum AnalysisType {
  profileDeepDive,      // Profil oluşturma sonrası derin analiz
  dateReflection,       // Buluşma yansıtması
  interactionInsight,   // Etkileşim içgörüsü
  dailyCheckInFeedback, // Günlük kayıt geri bildirimi
  patternEvolution,     // Döngü evrim analizi
  narrativeAnalysis,    // Serbest metin derinlik analizi
}

class GroqAnalysisService {
  GroqAnalysisService._();
  static final GroqAnalysisService instance = GroqAnalysisService._();

  // ══════════════════════════════════════════════
  //  Ana Analiz Fonksiyonu
  // ══════════════════════════════════════════════

  /// Dinamik sistem talimatı + kullanıcı mesajı ile LLM çağrısı
  Future<LLMAnalysisResult> analyze({
    required String systemPrompt,
    required String userMessage,
    AnalysisType type = AnalysisType.dateReflection,
  }) async {
    if (!AIConfig.instance.hasGroq) {
      return const LLMAnalysisResult(
        rawResponse: '',
        error: 'Groq API anahtarı yapılandırılmamış',
      );
    }

    try {
      final String raw = await _callGroq(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        jsonMode: true,
      );
      return _parseResponse(raw, type);
    } catch (e) {
      debugPrint('Groq analiz hatası: $e');
      return LLMAnalysisResult(
        rawResponse: '',
        error: e.toString(),
      );
    }
  }

  /// Genel amacli JSON tamamlama. Reflection gibi ozel payload'lar icin kullanilir.
  Future<Map<String, dynamic>> completeJson({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (!AIConfig.instance.hasGroq) {
      throw Exception('Groq API anahtari yapilandirilmamis');
    }

    final String raw = await _callGroq(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      jsonMode: true,
    );
    try {
      return _decodeJsonObject(raw);
    } catch (e) {
      throw Exception(
        'Groq JSON cozumlenemedi: $e | ham yanit onizleme: ${_compactSnippet(raw)}',
      );
    }
  }

  /// Düz metin yanıt — JSON zorunluluğu yok.
  /// Sohbet fallback'leri için kullanılabilir (Gemini yoksa).
  Future<String> completeText({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (!AIConfig.instance.hasGroq) {
      throw Exception('Groq API anahtari yapilandirilmamis');
    }
    return _callGroq(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      jsonMode: false,
    );
  }

  /// Profil oluşturma sonrası derin karakter analizi
  Future<LLMAnalysisResult> analyzeProfile({
    required String systemPrompt,
    required Map<String, String> freeTextFields,
  }) async {
    final StringBuffer userMsg = StringBuffer();
    userMsg.writeln('Kullanıcının profil cevapları:');
    userMsg.writeln('');

    for (final MapEntry<String, String> entry in freeTextFields.entries) {
      if (entry.value.trim().isNotEmpty) {
        userMsg.writeln('## ${entry.key}');
        userMsg.writeln(entry.value.trim());
        userMsg.writeln('');
      }
    }

    userMsg.writeln('---');
    userMsg.writeln('Yukarıdaki tüm cevapları birlikte analiz et. '
        'Satır arası değerleri, önyargıları, tutarsızlıkları ve yazış stilinden '
        'çıkarılabilecek karakter özelliklerini tespit et.');

    return analyze(
      systemPrompt: systemPrompt,
      userMessage: userMsg.toString(),
      type: AnalysisType.profileDeepDive,
    );
  }

  /// Günlük kayıt metnini analiz et
  Future<LLMAnalysisResult> analyzeDailyEntry({
    required String systemPrompt,
    required String miniReflection,
    required String romanticThought,
    required String moodLabel,
    required List<String> triggerLabels,
  }) async {
    final StringBuffer userMsg = StringBuffer();
    userMsg.writeln('Bugünkü kayıt:');
    userMsg.writeln('Ruh hali: $moodLabel');
    if (triggerLabels.isNotEmpty) {
      userMsg.writeln('Tetikleyiciler: ${triggerLabels.join(", ")}');
    }
    if (miniReflection.trim().isNotEmpty) {
      userMsg.writeln('Kısa yansıtma: $miniReflection');
    }
    if (romanticThought.trim().isNotEmpty) {
      userMsg.writeln('Romantik düşünce: $romanticThought');
    }
    userMsg.writeln('---');
    userMsg.writeln('Bu kaydı kullanıcının profil bağlamında analiz et.');

    return analyze(
      systemPrompt: systemPrompt,
      userMessage: userMsg.toString(),
      type: AnalysisType.dailyCheckInFeedback,
    );
  }

  // ══════════════════════════════════════════════
  //  Groq API Çağrısı
  // ══════════════════════════════════════════════

  Future<String> _callGroq({
    required String systemPrompt,
    required String userMessage,
    bool jsonMode = true,
  }) async {
    final Uri url = Uri.parse('${AIConfig.groqBaseUrl}/chat/completions');

    final Map<String, dynamic> body = <String, dynamic>{
      'model': AIConfig.groqModel,
      'messages': <Map<String, String>>[
        <String, String>{'role': 'system', 'content': systemPrompt},
        <String, String>{'role': 'user', 'content': userMessage},
      ],
      'max_tokens': AIConfig.groqMaxTokens,
      'temperature': AIConfig.groqTemperature,
      // Llama/Qwen tekrar eğilimini azaltan penalty parametreleri
      'frequency_penalty': AIConfig.groqFrequencyPenalty,
      'presence_penalty': AIConfig.groqPresencePenalty,
      // Qwen3 reasoning çıktısını (<think>...</think>) kullanıcıdan gizle.
      // Model yine de "düşünür" ama yanıt içeriğinde reasoning bloğu dönmez.
      'reasoning_format': 'hidden',
      if (jsonMode)
        'response_format': <String, String>{'type': 'json_object'},
    };

    final http.Response response = await http.post(
      url,
      headers: AIConfig.instance.groqHeaders,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      final String errorBody = _compactSnippet(response.body);
      throw Exception('Groq API ${response.statusCode}: $errorBody');
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> choices = decoded['choices'] as List<dynamic>;
    if (choices.isEmpty) throw Exception('Groq boş yanıt döndü');

    final Map<String, dynamic> firstChoice =
        choices[0] as Map<String, dynamic>;
    final Map<String, dynamic> message =
        firstChoice['message'] as Map<String, dynamic>;
    final String content = message['content'] as String;
    return _stripReasoning(content);
  }

  /// Qwen3 gibi reasoning modellerinden sızabilen <think>...</think>
  /// bloklarını yanıttan temizler. reasoning_format=hidden zaten
  /// çoğu durumu örtmeli — bu yardımcı savunma amaçlı (API flag'i
  /// desteklenmezse veya kapalı modellerde).
  ///
  /// Açık <think> olup kapanmıyorsa (max_token kesilirse) en soldaki
  /// `<think>` ifadesinden metin sonuna kadar hepsini atar.
  String _stripReasoning(String raw) {
    // 1) Tam kapalı <think>...</think> bloklarını (çok satırlı) kaldır
    final RegExp closed =
        RegExp(r'<think>[\s\S]*?</think>', multiLine: true, caseSensitive: false);
    String cleaned = raw.replaceAll(closed, '');

    // 2) Kapanmamış <think> varsa → oradan sonrası da reasoning, at
    final RegExp openOnly =
        RegExp(r'<think>[\s\S]*$', multiLine: true, caseSensitive: false);
    cleaned = cleaned.replaceAll(openOnly, '');

    // 3) Tek başına kalan </think> kapanışını da sil
    cleaned = cleaned.replaceAll(
        RegExp(r'</think>', caseSensitive: false), '');

    return cleaned.trim();
  }

  String _compactSnippet(String raw) {
    final String normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 240) return normalized;
    return '${normalized.substring(0, 240)}...';
  }

  // ══════════════════════════════════════════════
  //  Yanıt Ayrıştırma
  // ══════════════════════════════════════════════

  LLMAnalysisResult _parseResponse(String raw, AnalysisType type) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(raw) as Map<String, dynamic>;

      return LLMAnalysisResult(
        rawResponse: raw,
        profileInsight: _str(json, 'profil_icgoru'),
        blindSpotWarning: _str(json, 'kor_nokta_uyarisi'),
        patternDetection: _str(json, 'dongu_tespiti'),
        personalizedAdvice: _str(json, 'kisisel_tavsiye'),
        biasFlags: _strList(json, 'onyargi_bayraklari'),
        valueExtractions: _strList(json, 'deger_cikarimi'),
        emotionalToneLabel: _str(json, 'duygusal_ton'),
        confidenceScore: _double(json, 'guven_skoru'),
      );
    } catch (e) {
      // JSON parse başarısız → ham metin olarak dön
      return LLMAnalysisResult(
        rawResponse: raw,
        profileInsight: raw,
        confidenceScore: 0.3,
      );
    }
  }

  String _str(Map<String, dynamic> json, String key) {
    final dynamic val = json[key];
    if (val is String) return val;
    return '';
  }

  List<String> _strList(Map<String, dynamic> json, String key) {
    final dynamic val = json[key];
    if (val is List) return val.map((dynamic v) => v.toString()).toList();
    return const <String>[];
  }

  double _double(Map<String, dynamic> json, String key) {
    final dynamic val = json[key];
    if (val is num) return val.toDouble().clamp(0.0, 1.0);
    return 0.0;
  }

  Map<String, dynamic> _decodeJsonObject(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    final String cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final dynamic decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    final int firstBrace = cleaned.indexOf('{');
    final int lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      final String extracted = cleaned.substring(firstBrace, lastBrace + 1);
      final dynamic decoded = jsonDecode(extracted);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    throw Exception('JSON object decode edilemedi');
  }
}
