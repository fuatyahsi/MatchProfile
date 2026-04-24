// ══════════════════════════════════════════════════════════════
//  Gemini Sohbet Servisi
//  ──────────────────────────────────
//  Gemini 2.5 Flash üzerinden Türkçe sohbet yanıtları üretir.
//  Kullanım alanları:
//   • Chat onboarding "Sırdaş" yanıtları
//   • Yapısal JSON ve sohbet üretimi
//   • Reflection yorumları
//
//  Türkçe akıcılığı yüksek, JSON modu opsiyonel yedek LLM servisi.
//  Ücretsiz katman (Google AI Studio): 10 RPM / 500 RPD.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'ai_config.dart';

class GeminiChatService {
  GeminiChatService._();
  static final GeminiChatService instance = GeminiChatService._();

  final Map<String, GenerativeModel> _modelCache = <String, GenerativeModel>{};

  GenerativeModel _buildModel({
    required String modelName,
    required bool jsonMode,
  }) {
    return GenerativeModel(
      model: modelName,
      apiKey: AIConfig.instance.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AIConfig.geminiTemperature,
        maxOutputTokens: AIConfig.geminiMaxTokens,
        responseMimeType: jsonMode ? 'application/json' : 'text/plain',
      ),
    );
  }

  GenerativeModel _cachedModel({
    required String modelName,
    required bool jsonMode,
  }) {
    final String cacheKey =
        '${AIConfig.instance.geminiApiKey}|$modelName|${jsonMode ? 'json' : 'text'}';
    return _modelCache.putIfAbsent(
      cacheKey,
      () => _buildModel(modelName: modelName, jsonMode: jsonMode),
    );
  }

  bool _isRetryableGeminiError(Object error) {
    final String text = error.toString().toLowerCase();
    return text.contains('503') ||
        text.contains('unavailable') ||
        text.contains('429') ||
        text.contains('resource_exhausted');
  }

  Future<T> _runWithRetry<T>({
    required Future<T> Function() action,
  }) async {
    try {
      return await action();
    } catch (e) {
      if (!_isRetryableGeminiError(e)) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return action();
    }
  }

  Future<String> _generateTextWithModel({
    required String modelName,
    required String systemPrompt,
    required String userMessage,
  }) async {
    final GenerativeModel model =
        _cachedModel(modelName: modelName, jsonMode: false);
    final GenerateContentResponse response = await _runWithRetry(
      action: () => model.generateContent(
        <Content>[
          Content.text('$systemPrompt\n\n---\nKULLANICI:\n$userMessage'),
        ],
      ),
    );
    final String? text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini boş yanıt döndü');
    }
    return text.trim();
  }

  Future<Map<String, dynamic>> _generateJsonWithModel({
    required String modelName,
    required String systemPrompt,
    required String userMessage,
  }) async {
    final GenerativeModel model =
        _cachedModel(modelName: modelName, jsonMode: true);
    final GenerateContentResponse response = await _runWithRetry(
      action: () => model.generateContent(
        <Content>[
          Content.text('$systemPrompt\n\n---\nKULLANICI:\n$userMessage'),
        ],
      ),
    );
    final String? text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini boş yanıt döndü');
    }
    return _decodeJsonObject(text);
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

    final List<String> models = <String>{
      AIConfig.geminiChatModel,
      AIConfig.geminiStructuredModel,
    }.toList();

    Object? lastError;
    for (final String modelName in models) {
      try {
        return await _generateTextWithModel(
          modelName: modelName,
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        );
      } catch (e) {
        debugPrint('Gemini reply hatası [$modelName]: $e');
        lastError = e;
      }
    }
    throw lastError ?? Exception('Gemini reply başarısız');
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

    final List<String> models = <String>{
      AIConfig.geminiStructuredModel,
      AIConfig.geminiChatModel,
    }.toList();

    Object? lastError;
    for (final String modelName in models) {
      try {
        return await _generateJsonWithModel(
          modelName: modelName,
          systemPrompt: systemPrompt,
          userMessage: userMessage,
        );
      } catch (e) {
        debugPrint('Gemini json hatası [$modelName]: $e');
        lastError = e;
      }
    }
    throw lastError ?? Exception('Gemini JSON başarısız');
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
