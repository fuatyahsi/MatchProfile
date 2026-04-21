// ══════════════════════════════════════════════════════════════
//  Embedding Servisi — Metin → Vektör Dönüşümü
//  ──────────────────────────────────────────────
//  HuggingFace Inference API (ücretsiz katman) kullanarak
//  kullanıcı metinlerini 384 boyutlu anlamsal vektörlere çevirir.
//  API yoksa yerel TF-IDF benzeri basit vektörleme yapar.
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'ai_config.dart';

/// 384 boyutlu anlamsal vektör
typedef Embedding = List<double>;

class EmbeddingService {
  EmbeddingService._();
  static final EmbeddingService instance = EmbeddingService._();

  /// Önbellek: aynı metin iki kez API'ye gönderilmez
  final Map<int, Embedding> _cache = <int, Embedding>{};

  // ══════════════════════════════════════════════
  //  Ana Fonksiyon
  // ══════════════════════════════════════════════

  /// Metni vektöre çevirir. API varsa HuggingFace, yoksa yerel fallback.
  Future<Embedding> embed(String text) async {
    if (text.trim().isEmpty) return _zeroVector();

    final int cacheKey = text.trim().hashCode;
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    Embedding result;
    if (AIConfig.instance.hasHuggingFace) {
      try {
        result = await _embedViaHuggingFace(text.trim());
      } catch (_) {
        result = _localEmbed(text.trim());
      }
    } else {
      result = _localEmbed(text.trim());
    }

    _cache[cacheKey] = result;
    return result;
  }

  /// Birden fazla metni toplu vektörler
  Future<List<Embedding>> embedBatch(List<String> texts) async {
    final List<Embedding> results = <Embedding>[];
    for (final String text in texts) {
      results.add(await embed(text));
    }
    return results;
  }

  /// İki vektör arasındaki kosinüs benzerliği (0.0–1.0)
  static double cosineSimilarity(Embedding a, Embedding b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dot = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    final double denom = math.sqrt(normA) * math.sqrt(normB);
    if (denom == 0) return 0.0;
    return (dot / denom).clamp(0.0, 1.0);
  }

  /// İki vektörün ağırlıklı ortalaması (profil birleştirme için)
  static Embedding weightedMerge(Embedding a, Embedding b, double weightA) {
    if (a.length != b.length) return a;
    final double weightB = 1.0 - weightA;
    return List<double>.generate(
      a.length,
      (int i) => a[i] * weightA + b[i] * weightB,
    );
  }

  // ══════════════════════════════════════════════
  //  HuggingFace API
  // ══════════════════════════════════════════════

  Future<Embedding> _embedViaHuggingFace(String text) async {
    final Uri url = Uri.parse(
      '${AIConfig.hfBaseUrl}/pipeline/feature-extraction/${AIConfig.hfEmbeddingModel}',
    );

    final http.Response response = await http.post(
      url,
      headers: AIConfig.instance.hfHeaders,
      body: jsonEncode(<String, dynamic>{
        'inputs': text,
        'options': <String, dynamic>{'wait_for_model': true},
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('HuggingFace API hatası: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);

    // API response: [[0.123, -0.456, ...]] veya [0.123, -0.456, ...]
    if (decoded is List && decoded.isNotEmpty) {
      if (decoded.first is List) {
        // Sentence-transformers modeli: token vektörlerinin ortalaması
        final List<dynamic> tokenVectors = decoded;
        return _meanPool(tokenVectors);
      }
      return decoded.cast<double>().toList();
    }

    throw Exception('Beklenmeyen API yanıt formatı');
  }

  /// Token vektörlerinin ortalamasını al (mean pooling)
  Embedding _meanPool(List<dynamic> tokenVectors) {
    if (tokenVectors.isEmpty) return _zeroVector();

    // Eğer ilk eleman da liste ise: [[tok1_vec], [tok2_vec], ...] formatı
    if (tokenVectors.first is List) {
      final List<List<dynamic>> vectors = tokenVectors
          .map((dynamic v) => v as List<dynamic>)
          .toList();

      // Her token vektörü aynı boyutta
      if (vectors.isEmpty || vectors.first.isEmpty) return _zeroVector();

      final int dim = vectors.first.length;
      final List<double> mean = List<double>.filled(dim, 0.0);

      for (final List<dynamic> vec in vectors) {
        for (int i = 0; i < dim && i < vec.length; i++) {
          mean[i] += (vec[i] as num).toDouble();
        }
      }

      final int count = vectors.length;
      for (int i = 0; i < dim; i++) {
        mean[i] /= count;
      }
      return mean;
    }

    // Düz vektör
    return tokenVectors.map((dynamic v) => (v as num).toDouble()).toList();
  }

  // ══════════════════════════════════════════════
  //  Yerel Fallback: Karakter N-gram Vektörleme
  // ══════════════════════════════════════════════

  /// HuggingFace yokken devreye giren basit ama etkili vektörleme.
  /// Karakter 3-gram frekanslarını sabit boyutlu vektöre hash'ler.
  /// Türkçe morfolojisini doğal olarak yakalar (ek alma, kök benzerliği).
  Embedding _localEmbed(String text) {
    final String normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sçğıöşüâîû]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (normalized.length < 3) return _zeroVector();

    final int dim = AIConfig.embeddingDimension;
    final List<double> vector = List<double>.filled(dim, 0.0);

    // Karakter 3-gram
    for (int i = 0; i <= normalized.length - 3; i++) {
      final String trigram = normalized.substring(i, i + 3);
      final int hash = _stableHash(trigram) % dim;
      // Alternatif işaret: çarpışma azaltma
      final double sign = (hash % 2 == 0) ? 1.0 : -1.0;
      vector[hash.abs()] += sign;
    }

    // Kelime seviyesi (5-gram)
    final List<String> words = normalized.split(' ');
    for (final String word in words) {
      if (word.length >= 3) {
        final int hash = _stableHash(word) % dim;
        vector[hash.abs()] += 2.0; // Kelime düzeyi ağırlık
      }
    }

    // Anlamsal kategori boost: psikolojik anahtar kelimeler
    for (final MapEntry<String, int> entry in _semanticBuckets.entries) {
      if (normalized.contains(entry.key)) {
        final int bucket = entry.value % dim;
        vector[bucket] += 3.0;
      }
    }

    // L2 normalizasyon
    double norm = 0.0;
    for (final double v in vector) {
      norm += v * v;
    }
    norm = math.sqrt(norm);
    if (norm > 0) {
      for (int i = 0; i < dim; i++) {
        vector[i] /= norm;
      }
    }

    return vector;
  }

  Embedding _zeroVector() => List<double>.filled(AIConfig.embeddingDimension, 0.0);

  /// Kararlı hash (platform bağımsız)
  static int _stableHash(String s) {
    int hash = 5381;
    for (int i = 0; i < s.length; i++) {
      hash = ((hash << 5) + hash + s.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Psikolojik kavramları belirli vektör bölgelerine yönlendirir.
  /// Bu sayede "güven" yazan iki farklı kullanıcının vektörleri
  /// güven boyutunda benzerlik gösterir.
  static const Map<String, int> _semanticBuckets = <String, int>{
    // Bağlanma
    'bağlan': 10, 'bağıml': 11, 'yapış': 12, 'ayrıl': 13,
    'terk': 14, 'kaybet': 15, 'yalnız': 16,
    // Güven
    'güven': 20, 'inan': 21, 'ihanet': 22, 'aldatı': 23,
    'yalan': 24, 'dürüst': 25, 'şeffaf': 26,
    // Sınır
    'sınır': 30, 'hayır': 31, 'kabul': 32, 'red': 33,
    'feda': 34, 'katlan': 35, 'idare': 36,
    // Duygu
    'kork': 40, 'kaygı': 41, 'endişe': 42, 'öfke': 43,
    'kırgın': 44, 'üzgün': 45, 'mutlu': 46,
    'huzur': 47, 'sevinç': 48,
    // İdealleştirme
    'mükemmel': 50, 'kusursuz': 51, 'potansiyel': 52,
    'değiştir': 53, 'kurtarab': 54, 'hayal': 55,
    // Öz farkındalık
    'fark et': 60, 'farkında': 61, 'öğren': 62,
    'kabul et': 63, 'hatam': 64, 'sorumlul': 65,
    // İletişim
    'konuş': 70, 'dinle': 71, 'anlat': 72,
    'ifade': 73, 'sessiz': 74, 'sus': 75,
    // Kontrol
    'kontrol': 80, 'kıskan': 81, 'sahiplen': 82,
    'takip': 83, 'mesaj': 84,
    // Değer
    'saygı': 90, 'eşitlik': 91, 'özgürlük': 92,
    'bağımsız': 93, 'destek': 94, 'sadakat': 95,
    // Cinsellik / Yakınlık
    'yakınlık': 100, 'dokunma': 101, 'fiziksel': 102,
    'çekim': 103, 'tutku': 104,
  };

  /// Önbelleği temizle
  void clearCache() => _cache.clear();
}
