// ══════════════════════════════════════════════════════════════
//  Gemini Sohbet Servisi
//  ──────────────────────────────────
//  Gemini 2.5 Flash üzerinden Türkçe sohbet yanıtları üretir.
//  Kullanım alanları:
//   • Chat onboarding "Sırdaş" yanıtları
//   • Yapısal JSON ve sohbet üretimi
//   • Reflection yorumları
//
//  Groq'tan farkı: Türkçe akıcılığı daha iyi, JSON modu opsiyonel.
//  Ücretsiz katman (Google AI Studio): 10 RPM / 500 RPD.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'ai_config.dart';

class GeminiChatService {
  GeminiChatService._();
  static final GeminiChatService instance = GeminiChatService._();

  GenerativeModel? _textModel;
  String? _cachedKey;

  GenerativeModel _buildModel({required bool jsonMode}) {
    return GenerativeModel(
      model: AIConfig.geminiModel,
      apiKey: AIConfig.instance.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AIConfig.geminiTemperature,
        maxOutputTokens: AIConfig.geminiMaxTokens,
        responseMimeType: jsonMode ? 'application/json' : 'text/plain',
      ),
    );
  }

  GenerativeModel _textModelCached() {
    final String key = AIConfig.instance.geminiApiKey;
    if (_textModel != null && _cachedKey == key) return _textModel!;
    _cachedKey = key;
    _textModel = _buildModel(jsonMode: false);
    return _textModel!;
  }

  /// Düz metin sohbet yanıtı — Türkçe kalite önceliği.
  /// JSON DEĞİL: chat mesajı zorunlu JSON wrap'i olmadan üretilir.
  Future<String> generateReply({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (!AIConfig.instance.hasGemini) {
      throw Exception('Gemini API anahtarı yapılandırılmamış');
    }

    try {
      final GenerativeModel model = _textModelCached();
      final GenerateContentResponse response = await model.generateContent(
        <Content>[
          Content.text('$systemPrompt\n\n---\nKULLANICI:\n$userMessage'),
        ],
      );
      final String? text = response.text;
      if (text == null || text.trim().isEmpty) {
        throw Exception('Gemini boş yanıt döndü');
      }
      return text.trim();
    } catch (e) {
      debugPrint('Gemini reply hatası: $e');
      rethrow;
    }
  }

  /// JSON zorunlu yanıt — schema'ya uygun çıktı ister.
  /// InsightReport, PsycheAnchor gibi yapısal çağrılar için.
  Future<Map<String, dynamic>> generateJson({
    required String systemPrompt,
    required String userMessage,
  }) async {
    if (!AIConfig.instance.hasGemini) {
      throw Exception('Gemini API anahtarı yapılandırılmamış');
    }

    final GenerativeModel model = _buildModel(jsonMode: true);
    final GenerateContentResponse response = await model.generateContent(
      <Content>[
        Content.text('$systemPrompt\n\n---\nKULLANICI:\n$userMessage'),
      ],
    );

    final String? text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini boş yanıt döndü');
    }

    return _decodeJsonObject(text);
  }

  Map<String, dynamic> _decodeJsonObject(String raw) {
    // Önce olduğu gibi dene.
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    // Markdown fence'ini temizle ve tekrar dene.
    final String cleaned = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      final dynamic decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}

    // İlk { ve son } arasındaki bloğu çek.
    final int firstBrace = cleaned.indexOf('{');
    final int lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace > firstBrace) {
      final String extracted = cleaned.substring(firstBrace, lastBrace + 1);
      final dynamic decoded = jsonDecode(extracted);
      if (decoded is Map<String, dynamic>) return decoded;
    }

    throw Exception('Gemini JSON çözümlenemedi');
  }
}
