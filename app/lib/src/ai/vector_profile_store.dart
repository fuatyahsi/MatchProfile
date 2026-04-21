// ══════════════════════════════════════════════════════════════
//  Vektörel Profil Deposu — Kullanıcının "Anlamsal Kimliği"
//  ──────────────────────────────────
//  Her kullanıcının açık uçlu cevapları 384 boyutlu vektörlere
//  dönüştürülür ve bir "vektörel kimlik" oluşturur.
//  Bu kimlik, analiz sırasında kullanıcının kavramlara
//  yüklediği öznel anlamı temsil eder.
//
//  Örnek: "sessizlik" bir kullanıcı için huzur, diğeri için
//  ilgisizlik demek. Bu fark vektörel uzayda yakalanır.
//
//  Yerel depo (bellekte) + opsiyonel Supabase pgvector.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'ai_config.dart';
import 'embedding_service.dart';

/// Vektörel profil girişi
class VectorEntry {
  const VectorEntry({
    required this.fieldName,
    required this.originalText,
    required this.embedding,
    required this.createdAt,
    this.metadata = const <String, dynamic>{},
  });

  final String fieldName;
  final String originalText;
  final Embedding embedding;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
}

/// Benzerlik sorgu sonucu
class SimilarityResult {
  const SimilarityResult({
    required this.entry,
    required this.score,
  });

  final VectorEntry entry;
  final double score;
}

/// Kavramsal profil boyutu (ağırlıklı vektör ortalaması)
class ConceptDimension {
  const ConceptDimension({
    required this.concept,
    required this.embedding,
    required this.sourceFields,
    required this.strength,
  });

  final String concept;
  final Embedding embedding;
  final List<String> sourceFields;

  /// 0.0–1.0: bu kavramın kullanıcı profilindeki ağırlığı
  final double strength;
}

class VectorProfileStore {
  VectorProfileStore._();
  static final VectorProfileStore instance = VectorProfileStore._();

  /// Yerel vektör deposu
  final Map<String, VectorEntry> _store = <String, VectorEntry>{};

  /// Kavramsal boyutlar (hesaplanmış)
  final Map<String, ConceptDimension> _conceptDimensions =
      <String, ConceptDimension>{};

  // ══════════════════════════════════════════════
  //  Profil Vektörleme
  // ══════════════════════════════════════════════

  /// Tüm açık uçlu alan cevaplarını vektörle ve depola
  Future<void> embedProfile(Map<String, String> freeTextFields) async {
    for (final MapEntry<String, String> entry in freeTextFields.entries) {
      if (entry.value.trim().length >= 10) {
        final Embedding vector =
            await EmbeddingService.instance.embed(entry.value);

        _store[entry.key] = VectorEntry(
          fieldName: entry.key,
          originalText: entry.value,
          embedding: vector,
          createdAt: DateTime.now(),
        );
      }
    }

    // Kavramsal boyutları hesapla
    await _computeConceptDimensions();
  }

  /// Tek bir metin girişini vektörle ve depola (günlük kayıtlar için)
  Future<void> embedEntry(String key, String text) async {
    if (text.trim().length < 5) return;

    final Embedding vector = await EmbeddingService.instance.embed(text);
    _store[key] = VectorEntry(
      fieldName: key,
      originalText: text,
      embedding: vector,
      createdAt: DateTime.now(),
    );
  }

  // ══════════════════════════════════════════════
  //  Benzerlik Sorgusu
  // ══════════════════════════════════════════════

  /// Verilen metne en benzer profil alanlarını bul
  Future<List<SimilarityResult>> findSimilar(
    String queryText, {
    int topK = 5,
    double minScore = 0.3,
  }) async {
    if (_store.isEmpty) return const <SimilarityResult>[];

    final Embedding queryVector =
        await EmbeddingService.instance.embed(queryText);

    final List<SimilarityResult> results = <SimilarityResult>[];
    for (final VectorEntry entry in _store.values) {
      final double score =
          EmbeddingService.cosineSimilarity(queryVector, entry.embedding);
      if (score >= minScore) {
        results.add(SimilarityResult(entry: entry, score: score));
      }
    }

    results.sort((SimilarityResult a, SimilarityResult b) =>
        b.score.compareTo(a.score));
    return results.take(topK).toList();
  }

  /// "Sessizlik" gibi bir kavramın kullanıcı için ne anlama geldiğini bul
  Future<String> resolveConceptMeaning(String concept) async {
    final List<SimilarityResult> similar =
        await findSimilar(concept, topK: 3, minScore: 0.25);

    if (similar.isEmpty) return 'Bu kavram hakkında yeterli veri yok.';

    final StringBuffer sb = StringBuffer();
    sb.write('Bu kullanıcı için "$concept" kavramı ');

    final SimilarityResult top = similar.first;
    sb.write('"${top.entry.fieldName}" bağlamında ');
    sb.write('şu anlama yakın: "${_truncate(top.entry.originalText, 100)}"');

    if (similar.length > 1) {
      sb.write('. Ayrıca "${similar[1].entry.fieldName}" ile de ilişkili.');
    }

    return sb.toString();
  }

  // ══════════════════════════════════════════════
  //  Kavramsal Boyut Hesaplama
  // ══════════════════════════════════════════════

  /// Kullanıcının profil vektörlerinden kavramsal boyutlar çıkar.
  /// Bu, "bu kullanıcı için güven ne demek?" sorusunu cevaplayabilir.
  Future<void> _computeConceptDimensions() async {
    _conceptDimensions.clear();

    // Her kavram için ilgili alanların vektör ortalamasını al
    for (final MapEntry<String, List<String>> concept
        in _conceptFieldMap.entries) {
      final List<VectorEntry> matching = <VectorEntry>[];
      for (final String field in concept.value) {
        final VectorEntry? entry = _store[field];
        if (entry != null) matching.add(entry);
      }

      if (matching.isEmpty) continue;

      // Ağırlıklı ortalama (uzun metinlere daha fazla ağırlık)
      Embedding merged = matching.first.embedding;
      for (int i = 1; i < matching.length; i++) {
        final double weight = matching[i].originalText.length /
            (matching[i].originalText.length +
                matching[i - 1].originalText.length);
        merged = EmbeddingService.weightedMerge(
          merged,
          matching[i].embedding,
          1.0 - weight,
        );
      }

      _conceptDimensions[concept.key] = ConceptDimension(
        concept: concept.key,
        embedding: merged,
        sourceFields: matching.map((VectorEntry e) => e.fieldName).toList(),
        strength: (matching.length / concept.value.length).clamp(0.0, 1.0),
      );
    }
  }

  /// Kavram → ilgili profil alanları eşlemesi
  static const Map<String, List<String>> _conceptFieldMap =
      <String, List<String>>{
    'güven': <String>[
      'trustBuilder', 'safetyExperience', 'respectSignal', 'boundaryDifficulty'
    ],
    'bağlanma': <String>[
      'attachmentHistory', 'stayedTooLong', 'feelingsChanged', 'openingUpTime'
    ],
    'iletişim': <String>[
      'showsInterestHow', 'messagingImportance', 'unheardFeeling'
    ],
    'değerler': <String>[
      'respectSignal', 'valueConflict', 'idealDay'
    ],
    'öz_farkındalık': <String>[
      'selfDescription', 'friendDescription', 'recurringPattern',
      'biggestMisjudgment', 'feedbackFromCloseOnes'
    ],
    'romantik_beklenti': <String>[
      'datingChallenge', 'recentDatingChallenge', 'threeExperiences'
    ],
    'sınırlar': <String>[
      'boundaryDifficulty', 'respectSignal', 'valueConflict', 'safetyExperience'
    ],
  };

  /// Kavramsal boyutları al
  Map<String, ConceptDimension> get conceptDimensions =>
      Map<String, ConceptDimension>.unmodifiable(_conceptDimensions);

  /// İki kavram arasındaki mesafeyi ölç (kullanıcı perspektifinden)
  double conceptDistance(String conceptA, String conceptB) {
    final ConceptDimension? a = _conceptDimensions[conceptA];
    final ConceptDimension? b = _conceptDimensions[conceptB];
    if (a == null || b == null) return 0.0;
    return EmbeddingService.cosineSimilarity(a.embedding, b.embedding);
  }

  // ══════════════════════════════════════════════
  //  Supabase pgvector (Opsiyonel)
  // ══════════════════════════════════════════════

  /// Profil vektörlerini Supabase'e senkronize et
  Future<bool> syncToSupabase(String userId) async {
    if (!AIConfig.instance.hasSupabase) return false;

    try {
      for (final MapEntry<String, VectorEntry> entry in _store.entries) {
        await _upsertToSupabase(userId, entry.key, entry.value);
      }
      return true;
    } catch (e) {
      debugPrint('Supabase sync hatası: $e');
      return false;
    }
  }

  Future<void> _upsertToSupabase(
    String userId,
    String fieldName,
    VectorEntry entry,
  ) async {
    final Uri url = Uri.parse(
      '${AIConfig.instance.supabaseUrl}/rest/v1/profile_vectors',
    );

    await http.post(
      url,
      headers: <String, String>{
        ...AIConfig.instance.supabaseHeaders,
        'Prefer': 'resolution=merge-duplicates',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'field_name': fieldName,
        'original_text': entry.originalText,
        'embedding': entry.embedding,
        'created_at': entry.createdAt.toIso8601String(),
      }),
    );
  }

  // ══════════════════════════════════════════════
  //  Yardımcılar
  // ══════════════════════════════════════════════

  int get entryCount => _store.length;
  bool get isEmpty => _store.isEmpty;

  void clear() {
    _store.clear();
    _conceptDimensions.clear();
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }
}
