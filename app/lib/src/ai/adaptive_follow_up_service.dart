import '../models.dart';

class AdaptiveFollowUpQuestion {
  const AdaptiveFollowUpQuestion({
    required this.id,
    required this.label,
    required this.helper,
    required this.rationale,
  });

  final String id;
  final String label;
  final String helper;
  final String rationale;
}

class AdaptiveFollowUpService {
  const AdaptiveFollowUpService._();

  static List<AdaptiveFollowUpQuestion> buildQuestions(
    OnboardingProfile profile,
  ) {
    final String namePrefix =
        profile.displayName.trim().isEmpty ? '' : '${profile.displayName}, ';
    final String primaryValue = profile.values.isNotEmpty
        ? profile.values.first.toLowerCase()
        : 'netlik';
    final String primaryAlarm = profile.alarmTriggers.isNotEmpty
        ? profile.alarmTriggers.first.toLowerCase()
        : 'tutarsizlik';
    final String primaryBlindSpot = profile.blindSpots.isNotEmpty
        ? profile.blindSpots.first.toLowerCase()
        : 'belirsizlik';
    final List<ProfileInconsistency> inconsistencies =
        profile.detectInconsistencies();
    final String topIssue =
        inconsistencies.isNotEmpty ? inconsistencies.first.title : '';
    final String topNarrativePattern = profile.detectedNarrativePatterns.isNotEmpty
        ? profile.detectedNarrativePatterns.first
        : '';

    final List<AdaptiveFollowUpQuestion> items = <AdaptiveFollowUpQuestion>[];

    if (_shouldAskAssurance(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'high_assurance_thought',
          label: _buildAssuranceLabel(
            namePrefix: namePrefix,
            primaryValue: primaryValue,
            vulnerabilityArea: profile.vulnerabilityArea,
          ),
          helper:
              'Buradaki cevap, guvence ihtiyacinin kaynagini ayirmamiza yardim edecek. Sarsilan sey iliski istegin mi, secilme ihtiyacin mi, yoksa kontrol duygun mu?',
          rationale: 'Yuksek guvence ihtiyaci / belirsizlik hassasiyeti',
        ),
      );
    }

    if (_shouldAskIdealization(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'idealization_awareness',
          label: _buildIdealizationLabel(topNarrativePattern: topNarrativePattern),
          helper: topNarrativePattern.isNotEmpty
              ? 'Metinlerinde "$topNarrativePattern" sinyali de goruldu. Burada cekim ile somut davranisi ayirmaya calisiyoruz.'
              : 'Burada ilk his ile somut davranis arasindaki farki netlestirmek istiyoruz.',
          rationale: 'Idealizasyon / hizli anlam yukleme riski',
        ),
      );
    }

    if (_shouldAskExperience(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'first_relationship_learning',
          label:
              '"${profile.goal.label}" isterken en cok hangi baslikta zorlandigini hissediyorsun: tempo, niyet okuma, sinir koyma, ilgiye fazla anlam yukleme, yoksa secilme baskisi mi? Bir ornekle anlat.',
          helper:
              'Az deneyim veya ilk ciddi deneyim tarafinda zorlanilan alan netlesirse yorum dili daha dogru kisilesir.',
          rationale: 'Dusuk deneyim / ilk iliski ogrenme ihtiyaci',
        ),
      );
    }

    if (_shouldAskBoundary(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'no_second_chance_behavior',
          label:
              '"$primaryAlarm" senin icin belirgin bir alarm gibi duruyor. Bunu gordugun halde kaldigin bir an oldu mu? Olduysa seni orada tutan sey umut mu, cekim mi, empati mi, yoksa "abartiyor olabilirim" dusuncesi miydi?',
          helper: topIssue.isNotEmpty
              ? '"$topIssue" basligi da sende calisiyor olabilir. Fark etmek ile sinir uygulamak arasindaki boslugu anlamaya calisiyoruz.'
              : 'Alarmi fark etmek ile onun arkasinda durmak ayni sey degil. Bu cevap sinir gucunu daha dogru okumamizi saglar.',
          rationale: 'Sinir uygulama gucu / alarm toleransi',
        ),
      );
    }

    if (_shouldAskFastAttachment(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'fast_attachment_driver',
          label:
              'Birine hizli baglandiginda seni asil tasiyan sey ne oluyor: gorulmek, ozel hissetmek, yalniz kalmamak, hikayeyi erkenden tamamlamak, yoksa yuksek cekimi "uyum" sanmak mi? Son bir ornekle anlat.',
          helper:
              'Sectigin kor noktalarda "$primaryBlindSpot" one cikiyor. Buradaki cevap erken baglanmanin duygusal motorunu ayirmamiza yardim edecek.',
          rationale: 'Erken baglanma motoru',
        ),
      );
    }

    if (_shouldAskFastElimination(profile)) {
      items.add(
        AdaptiveFollowUpQuestion(
          id: 'fast_elimination_reason',
          label:
              'Birini erken elediginde bunu daha cok kendini korumak icin mi yapiyorsun, yoksa gercekten "$primaryValue" eksikligi gordugun icin mi? Son bir ornek ver; sonra donup baktiginda karar dogru muydu?',
          helper:
              'Burada amac, secicilik ile savunmaci kacisi birbirinden ayirmak.',
          rationale: 'Hizli eleme / korunma refleksi',
        ),
      );
    }

    return items;
  }

  static bool _shouldAskAssurance(OnboardingProfile profile) =>
      profile.highAssurance || profile.assuranceNeed == AssuranceNeed.high;

  static bool _shouldAskIdealization(OnboardingProfile profile) =>
      profile.highIdealization ||
      profile.detectedNarrativePatterns.any(
        (String item) =>
            item.toLowerCase().contains('ideal') ||
            item.toLowerCase().contains('hizli') ||
            item.toLowerCase().contains('cekim'),
      );

  static bool _shouldAskExperience(OnboardingProfile profile) =>
      profile.relationshipExperience == RelationshipExperience.first ||
      profile.relationshipExperience == RelationshipExperience.few;

  static bool _shouldAskBoundary(OnboardingProfile profile) =>
      profile.alarmTriggers.length >= 3 ||
      profile.boundaryDifficulty.trim().isNotEmpty ||
      profile.highBoundarySensitivity;

  static bool _shouldAskFastAttachment(OnboardingProfile profile) =>
      profile.hasFastAttachment ||
      profile.blindSpots.any(
        (String item) =>
            item.toLowerCase().contains('erken') ||
            item.toLowerCase().contains('baglan'),
      );

  static bool _shouldAskFastElimination(OnboardingProfile profile) =>
      profile.hasFastElimination ||
      profile.blindSpots.any(
        (String item) =>
            item.toLowerCase().contains('eleme') ||
            item.toLowerCase().contains('vazgec'),
      );

  static String _buildAssuranceLabel({
    required String namePrefix,
    required String primaryValue,
    required String vulnerabilityArea,
  }) {
    final String loweredVulnerability = vulnerabilityArea.toLowerCase();
    if (loweredVulnerability.contains('terk')) {
      return '${namePrefix}belirsizlik uzadiginda sende ilk sarsilan sey ne oluyor: terk edilme korkusu mu, secilmedigini dusunmek mi, yoksa "$primaryValue" beklentinin bosa cikmasi mi?';
    }
    if (loweredVulnerability.contains('yanlis')) {
      return '${namePrefix}belirsizlikte seni en cok ne huzursuz ediyor: yanlis kisiyi secme ihtimali mi, bosa emek verme korkusu mu, yoksa "$primaryValue" beklentinin karsilanmamasi mi?';
    }
    if (loweredVulnerability.contains('kullan')) {
      return '${namePrefix}belirsizlik uzadiginda sende en cok ne tetikleniyor: kullanilmis hissetmek mi, secilmedigini dusunmek mi, yoksa kontrolu kaybetmek mi?';
    }
    return '${namePrefix}belirsizlik uzadiginda sende en cok ne sarsiliyor: secilme hissin mi, kontrol duygun mu, yoksa "$primaryValue" beklentin mi?';
  }

  static String _buildIdealizationLabel({
    required String topNarrativePattern,
  }) {
    if (topNarrativePattern.toLowerCase().contains('potansiyel')) {
      return 'Son donemde birinde bugunku davranistan cok potansiyele yatirim yaptigin bir an oldu mu? O kiside somut olarak gercekten ne vardi, sen ne ekledin?';
    }
    if (topNarrativePattern.toLowerCase().contains('cekim')) {
      return 'Son donemde guclu cekimi dogrudan ciddi potansiyel gibi okudugun bir ornek oldu mu? O kiside gercekten gordugun 3 somut davranis neydi?';
    }
    return 'Son donemde ilk hissi veya guclu etkilenmeyi dogrudan uyum gibi okudugun bir an oldu mu? O kiside gercekten gordugun somut davranislar neydi?';
  }
}
