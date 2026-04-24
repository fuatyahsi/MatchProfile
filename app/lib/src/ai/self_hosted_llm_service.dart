import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ai_config.dart';

class SelfHostedLlmService {
  SelfHostedLlmService._();
  static final SelfHostedLlmService instance = SelfHostedLlmService._();

  Uri _endpoint(String path) {
    final String rawBase = AIConfig.instance.selfHostedLlmUrl.trim();
    if (rawBase.isEmpty) {
      throw Exception('Self-hosted LLM URL yapilandirilmamis');
    }
    final String base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final String cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath');
  }

  Future<String> completeText({
    required String systemPrompt,
    required String userMessage,
    String task = 'chat',
  }) async {
    final Map<String, dynamic> json = await _postJson(
      path: '/v1/chat',
      body: <String, dynamic>{
        'task': task,
        'systemPrompt': systemPrompt,
        'userMessage': userMessage,
        'maxNewTokens': 96,
        'temperature': 0.35,
      },
    );

    final dynamic reply =
        json['reply'] ?? json['assistant_reply'] ?? json['text'] ?? json['content'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }
    throw Exception('Self-hosted LLM bos metin yaniti dondu');
  }

  Future<Map<String, dynamic>> completeJson({
    required String systemPrompt,
    required String userMessage,
    String task = 'json',
  }) async {
    final Map<String, dynamic> json = await _postJson(
      path: '/v1/json',
      body: <String, dynamic>{
        'task': task,
        'systemPrompt': systemPrompt,
        'userMessage': userMessage,
        'maxNewTokens': _jsonTokenBudget(task),
        'temperature': 0.12,
      },
    );

    final dynamic result = json['result'] ?? json['json'] ?? json['data'];
    if (result is Map<String, dynamic>) return result;
    return json;
  }

  Future<Map<String, dynamic>> _postJson({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final http.Response response = await http
            .post(
              _endpoint(path),
              headers: AIConfig.instance.selfHostedHeaders,
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 65));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception(
            'Self-hosted LLM HTTP ${response.statusCode}: ${_snippet(response.body)}',
          );
        }

        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw Exception('Self-hosted LLM JSON object dondurmedi');
      } catch (e) {
        lastError = e;
        debugPrint('Self-hosted LLM hatasi (${attempt + 1}/2): $e');
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 900));
        }
      }
    }
    throw lastError ?? Exception('Self-hosted LLM cagrisi basarisiz');
  }

  String _snippet(String raw) {
    final String compact = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 280) return compact;
    return '${compact.substring(0, 280)}...';
  }

  int _jsonTokenBudget(String task) {
    return switch (task) {
      'chat_onboarding_turn' => 220,
      'belief_extraction' => 160,
      'psyche_anchor' => 360,
      'reflection_report' => 380,
      _ => 320,
    };
  }
}
