import 'package:flutter/material.dart';

import '../ai/ai_config.dart';
import '../ai/ai_contracts.dart';
import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

enum _MirrorDialogAction {
  continueToApp,
  retryLlm,
}

// ═══════════════════════════════════════════════
//  Welcome Page — Koyu Editöryal Tasarım
// ═══════════════════════════════════════════════

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: <Widget>[
            // ── Üst bar: logo + beta etiketi ──
            Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: t.primaryYellow.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: t.primaryYellow,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'MatchProfile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.primaryYellow.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: t.primaryYellow.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'BETA',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: t.primaryYellow.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // ── Ana başlık bloğu ──
            Text(
              'Romantik karar\nzekası.',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w200,
                height: 1.1,
                letterSpacing: -1.0,
                color: t.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 1,
              color: t.primaryYellow.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'MatchProfile seni ölçmez, tanır. Romantik karar profilini çıkarır, tutarsızlıklarını gösterir, her içgörüyü sana göre kişiselleştirir.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: t.textSecondary,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 32),

            // ── CTA butonu ──
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('welcome_start_button'),
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: t.primaryYellow,
                  foregroundColor: t.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Profilimi oluştur',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Sohbet · yaklaşık 5 dakika',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: t.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Ayırıcı çizgi ──
            Container(
              height: 0.5,
              color: t.borderLight.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 32),

            // ── Özellik listesi ──
            Text(
              'NASIL ÇALIŞIR',
              style: theme.textTheme.bodySmall?.copyWith(
                color: t.primaryYellow.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.chat_outlined,
              title: 'Sohbetle profil oluştur',
              description:
                  'Form doldurmak yok. Sırdaşınla sohbet ederek romantik karar profilini oluşturursun.',
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.psychology_outlined,
              title: 'Derin analiz',
              description:
                  'Sohbetten 8 boyutlu profil çıkarılır: değerler, kör noktalar, iletişim stili, sınırlar.',
            ),
            const SizedBox(height: 20),
            _WelcomeFeature(
              icon: Icons.tune_outlined,
              title: 'Kişiselleştirilmiş içgörü',
              description:
                  'Her yansıtma yorumu ve doğrulama sorusu sana özel tonlanır.',
            ),
            const SizedBox(height: 32),

            // ── Alt not ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.cardWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: t.borderLight.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    color: t.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Veriler yalnızca cihazında saklanır. Hiçbir şey dışarıya aktarılmaz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: t.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  const _WelcomeFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: t.borderLight.withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: Icon(icon, size: 17, color: t.primaryYellow.withValues(alpha: 0.8)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Onboarding Page — 8 Bölüm Derin Profilleme
//  Kaydırılabilir gradient kartlarla giriş
// ═══════════════════════════════════════════════

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.controller,
    required this.onComplete,
  });

  final MatchProfileController controller;
  final VoidCallback onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Hub mode (true) shows 8 gradient cards; section mode (false) shows questions
  bool _hubMode = true;
  int _activeSectionIndex = 0;
  final Set<int> _completedSections = <int>{};

  // ── Section 1: Kendini anlat ──
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _selfDescCtrl = TextEditingController();
  final Set<String> _coreTraits = <String>{};
  String _currentLifeTheme = '';
  final TextEditingController _datingChallengeCtrl = TextEditingController();
  final TextEditingController _freeformAboutMeCtrl = TextEditingController();
  final TextEditingController _friendDescCtrl = TextEditingController();
  final TextEditingController _threeExperiencesCtrl = TextEditingController();

  // ── Section 2: İlişki niyeti ──
  RelationshipGoal? _goal;
  PacingPreference _pacing = PacingPreference.balanced;
  final TextEditingController _openingUpTimeCtrl = TextEditingController();
  final TextEditingController _trustBuilderCtrl = TextEditingController();
  RelationshipExperience _experience = RelationshipExperience.several;
  final TextEditingController _recentChallengeCtrl = TextEditingController();
  final TextEditingController _idealDayCtrl = TextEditingController();

  // ── Section 3: Değerler ──
  final Set<String> _values = <String>{};
  final TextEditingController _respectSignalCtrl = TextEditingController();
  final Set<String> _dealbreakers = <String>{};
  final TextEditingController _dealbreakerFreeCtrl = TextEditingController();
  final Set<String> _lifestyleFactors = <String>{};
  String _potentialVsBehavior = 'Bugünkü davranışı';
  final TextEditingController _valueConflictCtrl = TextEditingController();

  // ── Section 4: İletişim ──
  CommunicationPreference _commPref = CommunicationPreference.balancedRegular;
  final TextEditingController _showsInterestCtrl = TextEditingController();
  String _directVsSoft = 'Doğrudan ve net';
  final TextEditingController _messagingCtrl = TextEditingController();
  AmbiguityResponse _ambiguityResp = AmbiguityResponse.overthink;
  ConflictStyle _conflictStyle = ConflictStyle.talkItOut;
  final TextEditingController _unheardCtrl = TextEditingController();

  // ── Section 5: Kör noktalar ──
  final Set<String> _blindSpots = <String>{};
  final TextEditingController _recurringPatternCtrl = TextEditingController();
  final TextEditingController _feedbackCtrl = TextEditingController();
  final TextEditingController _misjudgmentCtrl = TextEditingController();
  final TextEditingController _cloudedByCtrl = TextEditingController();
  final TextEditingController _stayedTooLongCtrl = TextEditingController();
  final TextEditingController _feelingsChangedCtrl = TextEditingController();

  // ── Section 6: İnançlar (1–7) ──
  double _beliefRightPerson = 4;
  double _beliefChemistryFast = 4;
  double _beliefStrongAttraction = 4;
  double _beliefFeelsRight = 4;
  double _beliefFirstFeelings = 4;
  double _beliefPotentialValue = 4;
  double _beliefAmbiguityNormal = 4;
  double _beliefLoveOvercomes = 4;

  // ── Section 7: Güvenlik ──
  final Set<String> _alarmTriggers = <String>{};
  String _vulnerabilityArea = '';
  AssuranceNeed _assuranceNeed = AssuranceNeed.medium;
  String _jealousyLevel = 'Orta';
  FatigueResponse _fatigueResp = FatigueResponse.pullAway;
  final TextEditingController _boundaryDiffCtrl = TextEditingController();
  final TextEditingController _safetyExperienceCtrl = TextEditingController();

  // ── Section 8: Açık alan ──
  final TextEditingController _attachmentHistoryCtrl = TextEditingController();
  final TextEditingController _misunderstandingCtrl = TextEditingController();
  final TextEditingController _partnerKnowCtrl = TextEditingController();
  final TextEditingController _freeformProfileCtrl = TextEditingController();
  final TextEditingController _summaryFeedbackCtrl = TextEditingController();

  // ── Conditional follow-ups ──
  final TextEditingController _highAssuranceThoughtCtrl =
      TextEditingController();
  final TextEditingController _idealizationAwarenessCtrl =
      TextEditingController();
  final TextEditingController _firstRelLearningCtrl = TextEditingController();
  final TextEditingController _noSecondChanceCtrl = TextEditingController();
  final TextEditingController _fastAttachDriverCtrl = TextEditingController();
  final TextEditingController _fastElimReasonCtrl = TextEditingController();

  // ── Legal ──
  bool _ageConfirmed = false;
  bool _policyAccepted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _selfDescCtrl.dispose();
    _datingChallengeCtrl.dispose();
    _freeformAboutMeCtrl.dispose();
    _friendDescCtrl.dispose();
    _threeExperiencesCtrl.dispose();
    _openingUpTimeCtrl.dispose();
    _trustBuilderCtrl.dispose();
    _recentChallengeCtrl.dispose();
    _idealDayCtrl.dispose();
    _respectSignalCtrl.dispose();
    _dealbreakerFreeCtrl.dispose();
    _valueConflictCtrl.dispose();
    _showsInterestCtrl.dispose();
    _messagingCtrl.dispose();
    _unheardCtrl.dispose();
    _recurringPatternCtrl.dispose();
    _feedbackCtrl.dispose();
    _misjudgmentCtrl.dispose();
    _cloudedByCtrl.dispose();
    _stayedTooLongCtrl.dispose();
    _feelingsChangedCtrl.dispose();
    _boundaryDiffCtrl.dispose();
    _safetyExperienceCtrl.dispose();
    _attachmentHistoryCtrl.dispose();
    _misunderstandingCtrl.dispose();
    _partnerKnowCtrl.dispose();
    _freeformProfileCtrl.dispose();
    _summaryFeedbackCtrl.dispose();
    _highAssuranceThoughtCtrl.dispose();
    _idealizationAwarenessCtrl.dispose();
    _firstRelLearningCtrl.dispose();
    _noSecondChanceCtrl.dispose();
    _fastAttachDriverCtrl.dispose();
    _fastElimReasonCtrl.dispose();
    super.dispose();
  }

  static const List<String> _sectionTitles = <String>[
    'Kendini Anlat',
    'İlişki Niyeti',
    'Değerler',
    'İletişim Stili',
    'Kör Noktalar',
    'İnançlar',
    'Güvenlik ve Sınırlar',
    'Açık Alan',
  ];

  static const List<String> _sectionDescriptions = <String>[
    'Kim olduğunu, bu dönem nerede olduğunu ve tanışma süreçlerinde ne yaşadığını anlayacağız.',
    'Ne aradığını, nasıl bir tempo istediğini ve geçmiş deneyimlerinin seni nereye taşıdığını öğreneceğiz.',
    'Bir ilişkide olmazsa olmazlarını, net sınırlarını ve günlük hayatta hangi konularda uyum aradığını çıkaracağız.',
    'İlgini nasıl gösterdiğini, mesaj düzenine ne kadar önem verdiğini, belirsizlikte ve tartışmada ne yaptığını anlayacağız.',
    'Bu bölüm en zor ama en değerli kısım. Dürüst cevaplar, daha doğru içgörü demek.',
    'Aşka dair temel inançlarını ölçeceğiz. İlk hislerine, çekime ve potansiyele ne kadar güvendiğini göreceğiz.',
    'Hangi davranışlarda alarm verirsin, en hassas alanın ne, yorulduğunda ne yaparsın?',
    'Listelerin yakalayamadığı her şeyi buraya yazabilirsin. Aile etkisi, çocukluktan gelen kalıplar, kültürel sınırlar...',
  ];

  static const List<IconData> _sectionIcons = <IconData>[
    Icons.person_outline_rounded,
    Icons.favorite_border_rounded,
    Icons.diamond_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.visibility_off_outlined,
    Icons.auto_awesome_outlined,
    Icons.shield_outlined,
    Icons.edit_note_outlined,
  ];

  static List<List<Color>> get _sectionColors => <List<Color>>[
        SectionGradients.selfIntro,
        SectionGradients.relationship,
        SectionGradients.values,
        SectionGradients.communication,
        SectionGradients.blindSpots,
        SectionGradients.beliefs,
        SectionGradients.safety,
        SectionGradients.openField,
      ];

  void _openSection(int index) {
    setState(() {
      _hubMode = false;
      _activeSectionIndex = index;
    });
  }

  void _completeCurrentSection() {
    setState(() {
      _completedSections.add(_activeSectionIndex);
      _hubMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hubMode) return _buildHub(context);
    return _buildSectionDetail(context);
  }

  // ═══════════════════════════════════════
  //  Hub — 8 Kaydırılabilir Gradient Kart
  // ═══════════════════════════════════════

  Widget _buildHub(BuildContext context) {
    final bool allDone = _completedSections.length >= 8;

    return Scaffold(
      key: const Key('onboarding_hub_screen'),
      backgroundColor: t.scaffoldBg,
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Profil Oluştur',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_completedSections.length} / 8 bölüm tamamlandı',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: t.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Progress ring
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: _completedSections.length / 8.0,
                            strokeWidth: 4,
                            backgroundColor: t.borderLight,
                            color: t.primaryYellow,
                          ),
                          Text(
                            '${_completedSections.length}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: t.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _completedSections.length / 8.0,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: allDone ? 9 : 8, // +1 for summary button
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 8) {
                      return _buildGoToSummaryCard(context);
                    }
                    final bool isDone = _completedSections.contains(index);
                    return FeatureGradientCard(
                      key: Key('onboarding_section_card_$index'),
                      kicker:
                          'BÖLÜM ${index + 1} / 8${isDone ? " · ✓ TAMAMLANDI" : ""}',
                      title: _sectionTitles[index],
                      description: _sectionDescriptions[index],
                      icon: _sectionIcons[index],
                      gradientColors: _sectionColors[index],
                      swipeHint: isDone
                          ? 'Düzenlemek için dokun'
                          : 'Başlamak için dokun veya sağa kaydır',
                      onOpen: () => _openSection(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoToSummaryCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            setState(() {
              _hubMode = false;
              _activeSectionIndex = 8; // Summary page
            });
          },
          icon: const Icon(Icons.psychology_rounded),
          label: const Text('Profil Özetine Git'),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  //  Section Detail — Questions
  // ═══════════════════════════════════════

  Widget _buildSectionDetail(BuildContext context) {
    // Section 8 = summary/legal page
    if (_activeSectionIndex == 8) {
      return _buildSummaryPage(context);
    }

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top bar with back button and section title
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => setState(() => _hubMode = true),
                    ),
                    Expanded(
                      child: Text(
                        'Bölüm ${_activeSectionIndex + 1} / 8 · ${_sectionTitles[_activeSectionIndex]}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: t.primaryDark,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildSectionQuestions(context, _activeSectionIndex),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionQuestions(BuildContext context, int section) {
    return switch (section) {
      0 => _buildSection1(context),
      1 => _buildSection2(context),
      2 => _buildSection3(context),
      3 => _buildSection4(context),
      4 => _buildSection5(context),
      5 => _buildSection6(context),
      6 => _buildSection7(context),
      7 => _buildSection8(context),
      _ => const SizedBox.shrink(),
    };
  }

  // ─────────────────────────────────────────
  //  Section 1: Kendini Anlat — Derin Sorular
  // ─────────────────────────────────────────

  Widget _buildSection1(BuildContext context) {
    return _OnboardingSection(
      onNext: _nameCtrl.text.trim().isNotEmpty && _coreTraits.length == 10
          ? _completeCurrentSection
          : null,
      nextLabel: 'Devam et',
      children: <Widget>[
        // Gradient header card
        _SectionHeaderCard(
          index: 0,
          colors: SectionGradients.selfIntro,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        PremiumTextField(
          keyName: 'onboarding_name_field',
          controller: _nameCtrl,
          label: 'Sana nasıl hitap edelim?',
          hint: 'Örneğin: Deniz',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _selfDescCtrl,
          question:
              'Kendini hiç tanımayan birine 4-5 cümleyle anlatsan, ne derdin?',
          helper:
              'Sadece dışarıdan görünen değil, içeride taşıdığın tarafları da yaz. Çelişkilerin burada çok değerli.',
          hint:
              'Sakin görünürüm ama etkilenince içimde çok hızlanan bir taraf var gibi doğal bir dille yazabilirsin.',
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Seni en iyi anlatan 10 özelliği seç. Şu anda seni tanıyan biri en hızlı hangi yönlerini fark ederdi?',
          options: const <String>[
            'Sakin',
            'Duygusal',
            'Analitik',
            'Sosyal',
            'Seçici',
            'Temkinli',
            'Romantik',
            'Bağımsız',
            'Sadık',
            'Hızlı karar veren',
            'Kararsız',
            'Vicdanlı',
            'Meraklı',
            'Planlı',
            'Spontane',
            'Sabırlı',
            'İnatçı',
            'Koruyucu',
            'Neşeli',
            'Mesafeli',
            'Gözlemci',
            'Kolay bağlanan',
            'Kontrolü seven',
            'Uyumlu',
          ],
          selected: _coreTraits,
          maxSelection: 10,
          selectionHelpText: 'Tam 10 seçim yap',
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Şu anda hayatında en çok enerjini alan veya seni en çok meşgul eden konu hangisi?',
          options: const <String>[
            'İş / kariyer',
            'Okul / sınavlar',
            'İyileşme / toparlanma',
            'Yeni düzen kurma',
            'Kendime odaklanma',
            'Yalnız kalma ihtiyacı',
            'İlişkiye alan açma',
            'Hayatımda belirsizlik var',
          ],
          selected: _currentLifeTheme,
          onChanged: (String v) => setState(() => _currentLifeTheme = v),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _datingChallengeCtrl,
          question:
              'Tanisma sureclerinde seni en cok zorlayan, surekli tekrar eden sorun ne?',
          helper:
              'Burada hem karsi taraftan gelen zorlugu hem senin tekrar eden kalibini birlikte yazabilirsin.',
          hint:
              'Biri sicak davraninca hizli anlam yukluyorum, sonra netlik gelmeyince cok dusunmeye basliyorum gibi somut yaz.',
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _threeExperiencesCtrl,
          question:
              'Son uc tanisma deneyimini birer cumleyle ozetle. Ortak bir tema var mi?',
          helper:
              'Tek tek kisa yazabilirsin ama sonunda ortak tekrar eden temayi soylemen analiz icin cok degerli.',
          hint:
              '1. Hizli basladi. 2. Ben daha cok baglandim. 3. Iyi basladi ama netlesmedi. Ortak tema: erken anlam yukluyorum gibi.',
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _friendDescCtrl,
          question:
              'En yakin arkadasin seni iliski konusunda nasil tanimlar? Bu tanima katilir misin?',
          helper:
              'Yakin cevrenin sende gordugu kor nokta veya guclu taraf burada cok ogretici olur.',
          hint:
              'Cok secici derler ama hoslandigimda fazla umutlu olabildigimi de soylerler gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _freeformAboutMeCtrl,
          question:
              'Formda geçmeyen ama profilini etkileyebilecek özel bir bilgi var mı?',
          helper:
              'Travma, aile baskısı, evlilik, gizli ilişki, çocuk, kimlik süreci, kültürel veya dini hassasiyet gibi hayat bağlamları burada çok kıymetli.',
          hint:
              'Bunu çok kişiye anlatmıyorum ama ilişkilerimde karar verme biçimimi etkiliyor... diye başlayabilirsin.',
          minLines: 4,
          maxLines: 8,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 2: İlişki Niyeti ve Zamanlama
  // ─────────────────────────────────────────

  Widget _buildSection2(BuildContext context) {
    return _OnboardingSection(
      onNext: _goal != null ? _completeCurrentSection : null,
      children: <Widget>[
        _SectionHeaderCard(
          index: 1,
          colors: SectionGradients.relationship,
          icon: Icons.favorite_border_rounded,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Şu anda ne arıyorsun?',
          options: RelationshipGoal.values
              .map((RelationshipGoal g) => g.label)
              .toList(),
          selected: _goal?.label ?? '',
          onChanged: (String v) => setState(() {
            _goal = RelationshipGoal.values.firstWhere(
              (RelationshipGoal g) => g.label == v,
            );
          }),
        ),
        const SizedBox(height: 20),
        NarrativePromptCard(
          controller: _idealDayCtrl,
          question:
              'Eger bugun istedigin iliskiyi yasamaya baslasan, 6 ay sonra gunluk hayatin nasil gorunurdu?',
          helper:
              'Soyut degil, gunluk hayatin icindeki sahneleri tarif et. Bu cevap tempo ve beklenti farkini acik gosterir.',
          hint:
              'Hafta ici kendi alanlarimiz olur, hafta sonu birlikte plan yapariz, iletisimimiz net olur gibi somut yaz.',
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Tanışma sürecinde doğal hız tercihin nasıl? Her adım nasıl ilerlemeli?',
          options: PacingPreference.values
              .map((PacingPreference p) => p.label)
              .toList(),
          selected: _pacing.label,
          onChanged: (String v) => setState(() {
            _pacing = PacingPreference.values.firstWhere(
              (PacingPreference p) => p.label == v,
            );
          }),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _openingUpTimeCtrl,
          question:
              'Duygusal olarak birinin yaninda kendini guvende hissetmen icin genellikle ne olmasi gerekir?',
          helper:
              'Burada hem kosullari hem de bu surecin sende nasil bir his yarattigini yaz.',
          hint:
              'Tutarlilik, beni merak etmesi ve belirsiz birakmamasi gerekiyor gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _trustBuilderCtrl,
          question:
              'Birinde guven insa eden ilk davranis ne oluyor? Kelimeler mi, tutarlilik mi, bir jest mi?',
          helper:
              'Bunu somutlastirirsan sistem ilgi ile guveni daha iyi ayirir.',
          hint:
              'Beni dikkatle dinlemesi, soylediklerimi hatirlamasi ve iletisimde kaybolmamasi gibi.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'İlişki deneyimini nasıl tanımlarsın?',
          options: RelationshipExperience.values
              .map((RelationshipExperience e) => e.label)
              .toList(),
          selected: _experience.label,
          onChanged: (String v) => setState(() {
            _experience = RelationshipExperience.values.firstWhere(
              (RelationshipExperience e) => e.label == v,
            );
          }),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _recentChallengeCtrl,
          question:
              'Son bir yilda seni en cok sarsan tanisma deneyimi ne oldu? Ne hissettin ve ne yaptin?',
          helper:
              'Bu alan son kirilma noktanin profiline nasil yerlestigini gosterir.',
          hint:
              'Birinin ilgisini oldugundan daha ciddi okuyup umutlandim, sonra geri cekilince sarsildim gibi yazabilirsin.',
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 3: Değerler ve Vazgeçilmezler
  // ─────────────────────────────────────────

  Widget _buildSection3(BuildContext context) {
    return _OnboardingSection(
      onNext: _values.length == 10 ? _completeCurrentSection : null,
      children: <Widget>[
        _SectionHeaderCard(
          index: 2,
          colors: SectionGradients.values,
          icon: Icons.diamond_outlined,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Bir ilişkide senin için vazgeçilmez olan 10 şeyi seç. Sadece kulağa hoş geleni değil, gerçekten yaşayabileceğin şeyleri seç.',
          options: const <String>[
            'Dürüstlük',
            'Sözünde durmak',
            'Net konuşmak',
            'Saygılı davranmak',
            'Duygusal olgunluk',
            'Şefkat',
            'Güven vermek',
            'Sadakat',
            'Mizah',
            'Günlük düzenimizin benzemesi',
            'İlişkiden aynı şeyi istemek',
            'Gelecek planlarımızın uyuşması',
            'Özel alana saygı',
            'Ailesiyle kurduğu ilişki',
            'Çocuk isteğinde uyum',
            'Hayata bakışımızın benzemesi',
            'Parayı kullanma biçimi',
            'Temizlik ve düzen',
            'Çalışkanlık',
            'Sorumluluk almak',
            'Cinsellikte saygı',
            'Krizde sakin kalabilmek',
          ],
          selected: _values,
          maxSelection: 10,
          selectionHelpText: 'Tam 10 seçim yap',
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _respectSignalCtrl,
          question:
              'Karsi tarafin sana saygi duydugunu hangi davranistan anlarsin? Somut bir ornek ver.',
          helper:
              'Saygi senin icin neye benziyor, bunu ne kadar somut tarif edersen deger haritasi o kadar netlesir.',
          hint:
              'Rahatsiz oldugumda savunmaya gecmeden duymasi ya da beni belirsizlikte birakmamasi gibi.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Aşağıdaki davranışlardan hangileri senin için kesin sınır? Bunlardan biri olursa devam etmek istemezsin.',
          options: const <String>[
            'Yalan söylemek',
            'Duygusal baskı kurmak',
            'Tutarsız davranmak',
            'Duygusal şiddet',
            'Cinsel baskı',
            'Kontrol etmeye çalışmak',
            'Küçümsemek veya aşağılamak',
            'İlgisizlik ve umursamazlık',
            'Sadakatsizlik',
            'Öfke patlamaları',
            'Sınır ihlali',
            'Manipülasyon',
            'Aşırı kıskançlık',
            'Bağımlılık problemi',
            'Sorumluluktan kaçmak',
          ],
          selected: _dealbreakers,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 8),
        NarrativePromptCard(
          controller: _dealbreakerFreeCtrl,
          question:
              'Listede olmayan ama senin icin kesin sinir olan bir davranis var mi?',
          helper:
              'Buraya herkesin anlamayabilecegi ama senin icin cizgiyi gecen davranislari yazabilirsin.',
          hint:
              'Beni gorunmez hissettiren bir davranis ya da mahremiyetimi ihlal eden bir sey gibi.',
          minLines: 2,
          maxLines: 4,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Günlük hayatta uyum için hangi konular senin için önemli?',
          options: const <String>[
            'Sosyalliği',
            'Alkol ve madde kullanımı',
            'Gece dışarı çıkmayı sevmesi',
            'İşin hayatında ne kadar önde olduğu',
            'Ailesiyle ne kadar iç içe olduğu',
            'Nerede yaşamak istediği',
            'Çocuk isteği',
            'İnançlar',
            'Parayı kullanma biçimi',
            'Temizlik ve düzen',
            'Boş zamanı nasıl geçirdiği',
            'Günlük düzeni',
          ],
          selected: _lifestyleFactors,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Birini değerlendirirken hangisi ağır basıyor: bugünkü davranışı mı, yoksa gelecekteki potansiyeli mi?',
          options: const <String>[
            'Bugünkü davranışı',
            'Potansiyeli de önemli',
            'İkisi eşit',
          ],
          selected: _potentialVsBehavior,
          onChanged: (String v) => setState(() => _potentialVsBehavior = v),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _valueConflictCtrl,
          question:
              'Bir degerin ile bir istegin catistiginda ne yaparsin? Gecmiste boyle bir durum yasadin mi?',
          helper:
              'Buradaki cevap, kagittaki degerlerin gercekte nasil esnedigini gosterir.',
          hint:
              'Bagimsizligima onem veririm ama cok hoslandigim biri olunca bunu esnetebiliyorum gibi yazabilirsin.',
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 4: İletişim ve Yakınlık Stili
  // ─────────────────────────────────────────

  Widget _buildSection4(BuildContext context) {
    return _OnboardingSection(
      onNext: _completeCurrentSection,
      children: <Widget>[
        _SectionHeaderCard(
          index: 3,
          colors: SectionGradients.communication,
          icon: Icons.chat_bubble_outline_rounded,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Birini tanırken hangi iletişim temposu sana en doğal gelir?',
          options: CommunicationPreference.values
              .map((CommunicationPreference c) => c.label)
              .toList(),
          selected: _commPref.label,
          onChanged: (String v) => setState(() {
            _commPref = CommunicationPreference.values.firstWhere(
              (CommunicationPreference c) => c.label == v,
            );
          }),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _showsInterestCtrl,
          question:
              'Sen birine ilgi duydugunda bunu nasil gosterirsin? Dogrudan mi soylersin, yoksa davranislarinla mi belli edersin?',
          helper:
              'Kendini nasil ortaya koydugun, yakinlik temposunu ve yanlis okunma riskini degistirir.',
          hint:
              'Daha cok soru sorarim, daha gorunur olurum ama acik acik soylemem gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Genelde konuşurken hangi tarza daha yakınsın?',
          options: const <String>[
            'Doğrudan ve net',
            'Yumuşak ve dolaylı',
            'Duruma göre değişir',
            'Önce yoklar, sonra netleşirim',
            'Yazarken daha rahatım',
          ],
          selected: _directVsSoft,
          onChanged: (String v) => setState(() => _directVsSoft = v),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _messagingCtrl,
          question:
              'Mesaj sikligi ve yanit hizi senin icin ne kadar anlam tasir? Gec cevap seni nasil etkiler?',
          helper:
              'Mesaj ritmi bazen ilgiyi, bazen sadece aliskanligi gosterir. Senin icin hangisi oldugunu burada anlatiyorsun.',
          hint:
              'Aninda cevap beklemem ama ilgili gorunup sonra kaybolmasi beni cok dusundurur gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Belirsizlik yaşadığında, örneğin karşı tarafın niyetini anlayamadığında, genelde ilk ne yaparsın?',
          options: AmbiguityResponse.values
              .map((AmbiguityResponse a) => a.label)
              .toList(),
          selected: _ambiguityResp.label,
          onChanged: (String v) => setState(() {
            _ambiguityResp = AmbiguityResponse.values.firstWhere(
              (AmbiguityResponse a) => a.label == v,
            );
          }),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Bir anlaşmazlık yaşadığında ilk davranışın genelde ne oluyor?',
          options: ConflictStyle.values
              .map((ConflictStyle c) => c.label)
              .toList(),
          selected: _conflictStyle.label,
          onChanged: (String v) => setState(() {
            _conflictStyle = ConflictStyle.values.firstWhere(
              (ConflictStyle c) => c.label == v,
            );
          }),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _unheardCtrl,
          question:
              'Bir iliskide kendini duyulmamis veya anlasilmamis hissettiginde ne yaparsin?',
          helper:
              'Burada ilk tepkin, iliskide catismayi nasil tasidigini gosterir.',
          hint:
              'Once anlatirim, yine duyulmadigimi hissedersem icime cekilirim gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 5: Kör Noktalar ve Döngüler
  // ─────────────────────────────────────────

  Widget _buildSection5(BuildContext context) {
    return _OnboardingSection(
      onNext: _completeCurrentSection,
      children: <Widget>[
        _SectionHeaderCard(
          index: 4,
          colors: SectionGradients.blindSpots,
          icon: Icons.visibility_off_outlined,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Aşağıdaki kalıplardan hangilerini kendinde fark ediyorsun? Dürüst ol — herkes en az birini yaşar.',
          options: const <String>[
            'Yoğun çekimi gerçek uyum sanma',
            'Uyarı işaretlerini mantığa bürüme',
            'Çok erken duygusal bağlanma',
            'Çok hızlı eleme ve vazgeçme',
            'Potansiyele aşırı yatırım yapma',
            'Tutarsızlığı heyecan sanma',
            'Kurtarıcı rolüne girme',
            'Kendi ihtiyacını sürekli geri plana atma',
            'Mükemmeliyetçi beklentiler kurma',
            'İlgisizliği gizemle karıştırma',
          ],
          selected: _blindSpots,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _recurringPatternCtrl,
          question:
              'Son bes yilda tanisma deneyimlerinin ortak bir sonu var mi? Bu sonu genellikle sen mi baslatiyorsun, karsi taraf mi?',
          helper:
              'Burada dongu gorunur hale gelir. Baslangic guzel olsa bile sonlar birbirine benziyorsa bunu acik yaz.',
          hint:
              'Ilk haftalar iyi gidiyor, sonra karsi taraf mesafe koyuyor ya da ben hizli anlam yukleyip yoruluyorum gibi.',
          minLines: 4,
          maxLines: 7,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _stayedTooLongCtrl,
          question:
              'Bir iliskinin sana iyi gelmedigini bildigin halde devam ettigin bir donem oldu mu? Seni devam ettiren ne oldu?',
          helper:
              'Umut, korku, yalnizlik, potansiyel, baglanma... Buradaki sebep kor noktani acik eder.',
          hint:
              'Gordugum sey rahatsiz ediciydi ama yine de buyusunun bozulmasini istemedim gibi durust yazabilirsin.',
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _feedbackCtrl,
          question:
              'Yakinlarin iliski konusunda sana en cok hangi geri bildirimi veriyor? Bu geri bildirime katiliyor musun?',
          helper:
              'Seni seven insanlarin aynasi bazen kendi anlattigindan daha sert ve daha dogru olabilir.',
          hint:
              'Iyi hissettiren seyle guven vereni karistiriyorsun derler ve buna biraz katiliyorum gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _misjudgmentCtrl,
          question:
              'Birini degerlendirirken en cok nerede yaniliyorsun? Fazla mi olumlu bakiyorsun, yoksa fazla mi supheci oluyorsun?',
          helper:
              'Buradaki cevap, ilk okuma hatani sistemin daha erken yakalamasina yardim eder.',
          hint:
              'Ilgi gordugumde bunu karakter ve niyetle fazla hizli eslestirebiliyorum gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _cloudedByCtrl,
          question:
              'Hosuna giden biri oldugunda saglikli dusunme yetini en cok ne bulandiriyor?',
          helper:
              'Cekim, ilgi gormek, yalnizlik, secilme ihtiyaci ya da heyecan burada fark yaratir.',
          hint:
              'Ozel hissetmek ve hizli yakinlik benim icin en riskli alan gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _feelingsChangedCtrl,
          question:
              'Birine karsi hislerinin degistigini fark ettiginde bunu acikca soyleyebiliyor musun, yoksa sinyal mi veriyorsun?',
          helper:
              'Duygusal cikislarini nasil yaptigin, iliskide netlik kalibini dogrudan etkiler.',
          hint:
              'Genelde soylemeye calisirim ama bazen once davranisla geri cekilirim gibi yazabilirsin.',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 6: Aşka Dair İnançlar (1–7)
  // ─────────────────────────────────────────

  Widget _buildSection6(BuildContext context) {
    return _OnboardingSection(
      onNext: _completeCurrentSection,
      children: <Widget>[
        _SectionHeaderCard(
          index: 5,
          colors: SectionGradients.beliefs,
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 10),
        Text(
          'Her ifadeye 1 (kesinlikle katılmıyorum) ile 7 (kesinlikle katılıyorum) arasında puan ver.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textSecondary,
              ),
        ),
        const SizedBox(height: 20),
        _BeliefSlider(
          label:
              'Eğer doğru kişiyse, koşullar ne kadar zor olursa olsun ilişki bir yolunu bulur.',
          value: _beliefRightPerson,
          onChanged: (double v) => setState(() => _beliefRightPerson = v),
        ),
        _BeliefSlider(
          label:
              'Gerçek uyum çok hızlı hissedilir — eğer yavaş geliyorsa muhtemelen o kişi değildir.',
          value: _beliefChemistryFast,
          onChanged: (double v) => setState(() => _beliefChemistryFast = v),
        ),
        _BeliefSlider(
          label:
              'Çok güçlü fiziksel veya duygusal çekim varsa bu önemli bir uyum işaretidir.',
          value: _beliefStrongAttraction,
          onChanged: (double v) => setState(() => _beliefStrongAttraction = v),
        ),
        _BeliefSlider(
          label:
              'Bir ilişki ya çok doğru gelir ya da gelmez — arada bir his genellikle yetersizdir.',
          value: _beliefFeelsRight,
          onChanged: (double v) => setState(() => _beliefFeelsRight = v),
        ),
        _BeliefSlider(
          label:
              'İlk izlenimlerim ve içgüdülerim çoğu zaman doğruyu söyler.',
          value: _beliefFirstFeelings,
          onChanged: (double v) => setState(() => _beliefFirstFeelings = v),
        ),
        _BeliefSlider(
          label:
              'Birinin bugünkü davranışı kadar gelecekteki potansiyeli de değerlidir.',
          value: _beliefPotentialValue,
          onChanged: (double v) => setState(() => _beliefPotentialValue = v),
        ),
        _BeliefSlider(
          label:
              'İlk aşamalarda netlik yokluğu normaldir, zamanla oturur.',
          value: _beliefAmbiguityNormal,
          onChanged: (double v) => setState(() => _beliefAmbiguityNormal = v),
        ),
        _BeliefSlider(
          label:
              'Gerçek sevgi varsa insanlar temel sorunlarını zamanla aşabilir.',
          value: _beliefLoveOvercomes,
          onChanged: (double v) => setState(() => _beliefLoveOvercomes = v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 7: Güvenlik, Sınır, Kırılganlıklar
  // ─────────────────────────────────────────

  Widget _buildSection7(BuildContext context) {
    return _OnboardingSection(
      onNext: _completeCurrentSection,
      children: <Widget>[
        _SectionHeaderCard(
          index: 6,
          colors: SectionGradients.safety,
          icon: Icons.shield_outlined,
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title:
              'Tanışma sürecinde sende alarm yaratan, geri adım attıran davranışlar hangileri?',
          options: const <String>[
            'Tutarsız davranmak',
            'Duygusal baskı uygulamak',
            'Cinsel baskı yapmak',
            'Aşırı hız dayatmak',
            'Duygusal olarak kapalı olmak',
            'Küçümsemek veya dalga geçmek',
            'Sınır ihlali yapmak',
            'Gerçekliği çarpıtmak',
            'Sosyal ortamda sahiplenmemek',
          ],
          selected: _alarmTriggers,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'İlişkide en hassas olduğun, en çok acı veren alan hangisi?',
          options: const <String>[
            'Terk edilme korkusu',
            'Yanlış kişiyi seçme endişesi',
            'Kullanılmış hissetme',
            'Yetersiz görünme kaygısı',
            'Kontrol kaybı',
          ],
          selected: _vulnerabilityArea,
          onChanged: (String v) => setState(() => _vulnerabilityArea = v),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Karşı taraftan güvence alma ihtiyacın ne seviyede? Sık sık onay veya teyit arar mısın?',
          options: AssuranceNeed.values
              .map((AssuranceNeed a) => a.label)
              .toList(),
          selected: _assuranceNeed.label,
          onChanged: (String v) => setState(() {
            _assuranceNeed = AssuranceNeed.values.firstWhere(
              (AssuranceNeed a) => a.label == v,
            );
          }),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Kıskançlık veya sahiplenme eğilimin nasıl?',
          options: const <String>['Düşük', 'Orta', 'Yüksek'],
          selected: _jealousyLevel,
          onChanged: (String v) => setState(() => _jealousyLevel = v),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title:
              'Duygusal olarak yorulduğunda ilişkide ne yaparsın?',
          options: FatigueResponse.values
              .map((FatigueResponse f) => f.label)
              .toList(),
          selected: _fatigueResp.label,
          onChanged: (String v) => setState(() {
            _fatigueResp = FatigueResponse.values.firstWhere(
              (FatigueResponse f) => f.label == v,
            );
          }),
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _boundaryDiffCtrl,
          question:
              'Sinir koymakta zorlandigin bir alan var mi? Varsa neden zor oldugunu yaz.',
          helper:
              'Sadece neye hayir diyemedigini degil, neden diyemedigini de yaz. Tam kor nokta orada olur.',
          hint:
              'Karsi tarafi kaybetmekten ya da kirici gorunmekten cekindigim icin gec kalabiliyorum gibi.',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _safetyExperienceCtrl,
          kicker: 'HASSAS ALAN',
          question:
              'Gecmiste guvenligini tehdit eden bir iliski deneyimin oldu mu? Kisaca paylasmak istersen yaz.',
          helper:
              'Bu alan tamamen istege bagli. Paylasirsan uygulama bunu guvenlik ve sinir yorumlarinda merkezde tutar.',
          hint:
              'Duygusal olarak manipule edildigim bir surec oldu ve sezgime gec guvendim gibi yazabilirsin.',
          minLines: 3,
          maxLines: 6,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 8: Açık Profil Alanı
  // ─────────────────────────────────────────

  Widget _buildSection8(BuildContext context) {
    return _OnboardingSection(
      onNext: _completeCurrentSection,
      children: <Widget>[
        _SectionHeaderCard(
          index: 7,
          colors: SectionGradients.openField,
          icon: Icons.edit_note_outlined,
        ),
        const SizedBox(height: 20),
        NarrativePromptCard(
          controller: _attachmentHistoryCtrl,
          kicker: 'DERİN BAĞLAM',
          question:
              'Çocukluk dönemin, aile yapın veya büyüme koşulların bugünkü ilişki biçimini nasıl etkiliyor?',
          helper:
              'Bağlanma biçimin, güven eşiğin ve yakınlık kurarken taşıdığın korkular bu profili ciddi şekilde etkiler.',
          hint:
              'Ailemde sorunlar konuşulmazdı, bu yüzden netlik istememe rağmen rahatsızlıklarımı geç söyleyebiliyorum gibi.',
          minLines: 4,
          maxLines: 8,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _misunderstandingCtrl,
          question:
              'Seni yanlış anlamamıza en çok neden olabilecek şey nedir?',
          helper:
              'Dışarıdan görünen halin ile içeride yaşadığın şey aynı değilse bunu burada söyle.',
          hint:
              'Dışarıdan kontrollü görünürüm ama etkilenince içimde çok daha hızlı bağ kuran bir taraf var gibi.',
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _partnerKnowCtrl,
          question:
              'Bir partnerin senin hakkında en erken bilmesini istediğin şey ne olurdu?',
          helper:
              'Buradaki cevap, ilişkide en erken görünmesini istediğin gerçek ihtiyacını verir.',
          hint:
              'Belirsizlik uzadığında içimde çok düşünmeye başlarım; o yüzden dürüstlük ve netlik benim için çok önemli gibi.',
          minLines: 3,
          maxLines: 6,
        ),
        const SizedBox(height: 16),
        NarrativePromptCard(
          controller: _freeformProfileCtrl,
          kicker: 'SANA ÖZEL',
          question:
              'Seni daha doğru tanımamız için bilmemiz gereken başka bir şey var mı?',
          helper:
              'Bu alan tamamen sana ait. İstersen çok kişisel, hassas veya kimseye söylemediğin bilgileri bile yazabilirsin. Uygulama bunları karar bağlamı olarak kullanır.',
          hint:
              'Evliyim ama başka bir ilişkim var... Çocuğum var ama kimse bilmiyor... Cinsiyet geçiş sürecindeyim ama henüz paylaşmadım... gibi seni gerçekten etkileyen bilgileri yazabilirsin.',
          minLines: 5,
          maxLines: 10,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Profile Summary + Conditional + Legal
  // ─────────────────────────────────────────

  Widget _buildSummaryPage(BuildContext context) {
    final OnboardingProfile tempProfile = _buildProfile();
    final String summary = tempProfile.generateProfileSummary();
    final List<ProfileInconsistency> inconsistencies =
        tempProfile.detectInconsistencies();
    final List<CharacterInsight> characterInsights =
        tempProfile.generateCharacterAnalysis();
    final bool canSubmit = _ageConfirmed && _policyAccepted;

    // Conditional follow-up checks
    final bool showHighAssurance = _assuranceNeed == AssuranceNeed.high;
    final double idScore =
        (_beliefRightPerson + _beliefChemistryFast + _beliefStrongAttraction +
                _beliefFeelsRight + _beliefFirstFeelings + _beliefPotentialValue) /
            42.0;
    final bool showIdealization = idScore > 0.65;
    final bool showFirstRel =
        _experience == RelationshipExperience.first ||
        _experience == RelationshipExperience.few;
    final bool showBoundary = _alarmTriggers.length >= 4 ||
        _boundaryDiffCtrl.text.trim().isNotEmpty;
    final bool showFastAttach = _blindSpots.contains('Çok erken duygusal bağlanma');
    final bool showFastElim = _blindSpots.contains('Çok hızlı eleme ve vazgeçme');

    final List<_PersonalizedFollowUp> followUps = _buildAdaptiveFollowUpsV2(
      tempProfile,
      showHighAssurance: showHighAssurance,
      showIdealization: showIdealization,
      showFirstRel: showFirstRel,
      showBoundary: showBoundary,
      showFastAttach: showFastAttach,
      showFastElim: showFastElim,
    );
    final bool hasConditional = followUps.isNotEmpty;

    return Scaffold(
      backgroundColor: t.scaffoldBg,
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => setState(() => _hubMode = true),
                    ),
                    Expanded(
                      child: Text(
                        'Profil Özeti',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: t.primaryDark,
                            ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: <Widget>[
                    const _SectionIntro(
                      title: 'Romantik karar profilin',
                      subtitle:
                          'Cevaplarından üretilen karakter analizi. Dürüst, bazen rahatsız edici ama sana faydalı.',
                    ),
                    const SizedBox(height: 20),

                    // ── Profile summary hero card ──
                    GradientCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: t.primaryYellow.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: t.primaryYellow.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(Icons.psychology_rounded,
                                    color: t.primaryYellow, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _nameCtrl.text.trim(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: t.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            summary,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.6,
                                    ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tempProfile.profileHighlights
                                .map((String tag) => TagPill(text: tag))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Radar chart ──
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Profil Radarı',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                              'Romantik karar profilinin çok boyutlu görünümü',
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 16),
                          Center(
                            child: ProfileRadarChart(
                              size: 220,
                              labels: const <String>[
                                'Gerçekçilik',
                                'Sınır',
                                'Öz farkındalık',
                                'Duygu düzenl.',
                                'İletişim',
                                'Hazırlık',
                              ],
                              values: <double>[
                                tempProfile.romanticRealismScore,
                                tempProfile.boundaryHealthScore,
                                tempProfile.selfAwarenessScore,
                                tempProfile.emotionalRegulationScore,
                                tempProfile.communicationAlignmentScore,
                                tempProfile.relationshipReadiness,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Circular gauges ──
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Temel Metrikler',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              RadialScoreGauge(
                                label: 'İdealleştirme',
                                value: tempProfile.idealizationScore,
                                size: 80,
                                color: tempProfile.highIdealization
                                    ? t.roseCaution
                                    : t.primaryYellow,
                                subtitle: tempProfile.highIdealization
                                    ? 'Yüksek risk'
                                    : null,
                              ),
                              RadialScoreGauge(
                                label: 'Sınır',
                                value: tempProfile.boundaryHealthScore,
                                size: 80,
                                color: tempProfile.boundaryHealthScore < 0.4
                                    ? t.roseCaution
                                    : t.softGreen,
                              ),
                              RadialScoreGauge(
                                label: 'Bağımlılık',
                                value: tempProfile.emotionalDependencyRisk,
                                size: 80,
                                color:
                                    tempProfile.emotionalDependencyRisk > 0.5
                                        ? t.roseCaution
                                        : t.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Profile score bars ──
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Detaylı Profil Metrikleri',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          ProfileScoreBar(
                            label: 'Romantik gerçekçilik',
                            value: tempProfile.romanticRealismScore,
                            color: t.softGreen,
                            subtitle: 'İdealleştirmenin tersi',
                          ),
                          ProfileScoreBar(
                            label: 'Öz farkındalık',
                            value: tempProfile.selfAwarenessScore,
                            color: t.warmGold,
                            subtitle: 'Kör nokta ve döngü farkındalığı',
                          ),
                          ProfileScoreBar(
                            label: 'Duygu düzenleme',
                            value: tempProfile.emotionalRegulationScore,
                            color: t.blushRose,
                            subtitle: 'Stres altında duygu yönetimi',
                          ),
                          ProfileScoreBar(
                            label: 'İletişim tutarlılığı',
                            value: tempProfile.communicationAlignmentScore,
                            color: t.peach,
                            subtitle: 'Söylem ile davranış uyumu',
                          ),
                          ProfileScoreBar(
                            label: 'Kendini koruma refleksi',
                            value: tempProfile.selfProtectionScore,
                            color: t.dustyRose,
                          ),
                          ProfileScoreBar(
                            label: 'İlişki hazırlığı',
                            value: tempProfile.relationshipReadiness,
                            color: t.primaryYellow,
                            subtitle: 'Tüm metriklerin ortalaması',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── Character analysis ──
                    ...characterInsights.map(
                        (CharacterInsight insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: SurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(insight.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 10),
                                    Text(
                                      insight.body,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.6),
                                    ),
                                    if (insight.score != null) ...<Widget>[
                                      const SizedBox(height: 12),
                                      ProfileScoreBar(
                                        label: insight.scoreLabel ?? '',
                                        value: insight.score!,
                                        color: t.primaryYellow,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )),

                    // ── Inconsistency warnings ──
                    if (inconsistencies.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        'Tutarsızlık tespitleri',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bu uyarılar seni yargılamak için değil — farkındalık yaratmak için. Hepimizde var.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      ...inconsistencies.map(
                        (ProfileInconsistency issue) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InconsistencyCard(
                            title: issue.title,
                            explanation: issue.explanation,
                            severity: issue.severity,
                          ),
                        ),
                      ),
                    ],

                    // ── Conditional follow-up questions ──
                    if (hasConditional) ...<Widget>[
                      const SizedBox(height: 18),
                      Text(
                        'Derinleşme soruları',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bu sorular seçtiğin değerler, kör noktalar, anlatı kalıpların ve hassas alanlarına göre seçildi. Her kullanıcı aynı seti görmez.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      ...followUps.map(
                        (_PersonalizedFollowUp item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NarrativePromptCard(
                            controller: item.controller,
                            kicker: 'SANA ÖZEL SORU',
                            question: item.label,
                            helper: item.helper,
                            hint:
                                'Burada ne kadar dürüst ve somut olursan, sonraki analizler o kadar sana özel olur.',
                            minLines: 3,
                            maxLines: 6,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    NarrativePromptCard(
                      controller: _summaryFeedbackCtrl,
                      kicker: 'GERİ BİLDİRİM',
                      question:
                          'Bu analiz sana göre nerede doğru, nerede eksik, nerede yanlış?',
                      helper:
                          'Dürüst geri bildirimin profili daha keskin yapar. Bu alan sonraki yorumların tonunu da kalibre eder.',
                      hint:
                          'Çekim ile uyumu karıştırma kısmı doğru geldi ama beni tamamen kontrolsüz göstermesi eksik gibi yazabilirsin.',
                      minLines: 4,
                      maxLines: 7,
                    ),
                    const SizedBox(height: 24),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CheckboxListTile(
                            key: const Key('onboarding_age_checkbox'),
                            value: _ageConfirmed,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('18 yaşından büyüğüm'),
                            onChanged: (bool? v) =>
                                setState(() => _ageConfirmed = v ?? false),
                          ),
                          CheckboxListTile(
                            key: const Key('onboarding_policy_checkbox'),
                            value: _policyAccepted,
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                                'Kişisel verilerin korunması ve beta koşullarını kabul ediyorum'),
                            subtitle: const Text(
                              'Verilerim yalnızca profilimi kişiselleştirmek için kullanılacak.',
                            ),
                            onChanged: (bool? v) =>
                                setState(() => _policyAccepted = v ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('onboarding_complete_button'),
                        onPressed: canSubmit ? _submit : null,
                        child: const Text('Profilimi kaydet'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  List<_PersonalizedFollowUp> _buildPersonalizedFollowUps(
    OnboardingProfile profile, {
    required bool showHighAssurance,
    required bool showIdealization,
    required bool showFirstRel,
    required bool showBoundary,
    required bool showFastAttach,
    required bool showFastElim,
  }) {
    final String primaryValue = profile.values.isNotEmpty
        ? profile.values.first.toLowerCase()
        : 'netlik';
    final String primaryAlarm = profile.alarmTriggers.isNotEmpty
        ? profile.alarmTriggers.first.toLowerCase()
        : 'tutarsızlık';
    final String primaryBlindSpot = profile.blindSpots.isNotEmpty
        ? profile.blindSpots.first.toLowerCase()
        : 'belirsizlik';
    final String topIssue = profile.detectInconsistencies().isNotEmpty
        ? profile.detectInconsistencies().first.title
        : '';
    final String topNarrativePattern = profile.detectedNarrativePatterns.isNotEmpty
        ? profile.detectedNarrativePatterns.first
        : '';
    final String namePrefix =
        profile.displayName.trim().isEmpty ? '' : '${profile.displayName}, ';
    final List<_PersonalizedFollowUp> items = <_PersonalizedFollowUp>[];

    if (showHighAssurance) {
      items.add(
        _PersonalizedFollowUp(
          controller: _highAssuranceThoughtCtrl,
          label:
              '${namePrefix}belirsizlik uzadığında sende en çok ne sarsılıyor: seçilme hissin mi, kontrol duygun mu, yoksa "$primaryValue" beklentin mi?',
          helper:
              'Profilinde "${profile.vulnerabilityArea.toLowerCase()}" alanı daha hassas görünüyor. Buradaki cevap güvence ihtiyacının kaynağını ayırmamıza yardım edecek.',
        ),
      );
    }

    if (showIdealization) {
      final String helper = topNarrativePattern.isNotEmpty
          ? 'Anlatında "$topNarrativePattern" sinyali de görüldü. Burada çekim ile somut davranışı ayırmaya çalışıyoruz.'
          : 'İlk his ile bugünkü davranışı ayırabildiğin yerlerde profil çok daha keskinleşir.';
      items.add(
        _PersonalizedFollowUp(
          controller: _idealizationAwarenessCtrl,
          label:
              'Son dönemde güçlü çekimi doğrudan ciddi potansiyel gibi okuduğun bir örnek oldu mu? O kişide gerçekten gördüğün 3 somut davranış neydi?',
          helper: helper,
        ),
      );
    }

    if (showFirstRel) {
      items.add(
        _PersonalizedFollowUp(
          controller: _firstRelLearningCtrl,
          label:
              '"${profile.goal.label}" isterken şu an en çok hangi konuda yönünü kaybediyorsun: tempo, niyet okuma, sınır koyma, yoksa seçilme baskısı mı?',
          helper:
              'Az deneyimde zorlandığın başlık netleşirse yorum dili de daha doğru kişiselleşir.',
        ),
      );
    }

    if (showBoundary) {
      final String helper = topIssue.isNotEmpty
          ? '"$topIssue" başlığı da sende çalışıyor olabilir. Fark etmek ile sınır uygulamak arasındaki boşluğu anlamaya çalışıyoruz.'
          : 'Alarm aldığın şeyi pratikte ne kadar erken durdurduğunu görmek, sınır gücünü daha doğru okumamızı sağlar.';
      items.add(
        _PersonalizedFollowUp(
          controller: _noSecondChanceCtrl,
          label:
              '"$primaryAlarm" senin için belirgin bir alarm. Son dönemde bunu görüp yine de kaldığın bir an oldu mu? Olduysa seni orada tutan neydi?',
          helper: helper,
        ),
      );
    }

    if (showFastAttach) {
      items.add(
        _PersonalizedFollowUp(
          controller: _fastAttachDriverCtrl,
          label:
              'Birine hızlı bağlandığında seni asıl taşıyan ne oluyor: görülmek, özel hissetmek, yalnız kalmamak, yoksa hikâyeyi erkenden tamamlamak mı?',
          helper:
              'Seçtiğin kör noktalarda "$primaryBlindSpot" öne çıktı. Buradaki cevap erken bağlanmanın duygusal motorunu ayırmamıza yardım edecek.',
        ),
      );
    }

    if (showFastElim) {
      items.add(
        _PersonalizedFollowUp(
          controller: _fastElimReasonCtrl,
          label:
              'Birini erken elediğinde bunu daha çok kendini korumak için mi yapıyorsun, yoksa gerçekten "$primaryValue" eksikliği mi görüyorsun? Son bir örnek ver.',
          helper:
              'Bu ayrım önemli: hızlı eleme bazen sezgi, bazen de korunma refleksi olur.',
        ),
      );
    }

    return items;
  }

  List<_PersonalizedFollowUp> _buildAdaptiveFollowUpsV2(
    OnboardingProfile profile, {
    required bool showHighAssurance,
    required bool showIdealization,
    required bool showFirstRel,
    required bool showBoundary,
    required bool showFastAttach,
    required bool showFastElim,
  }) {
    final Set<String> enabledIds = <String>{
      if (showHighAssurance) 'high_assurance_thought',
      if (showIdealization) 'idealization_awareness',
      if (showFirstRel) 'first_relationship_learning',
      if (showBoundary) 'no_second_chance_behavior',
      if (showFastAttach) 'fast_attachment_driver',
      if (showFastElim) 'fast_elimination_reason',
    };
    final List<_PersonalizedFollowUp> items = <_PersonalizedFollowUp>[];
    for (final question in widget.controller.buildAdaptiveFollowUps(profile)) {
      if (!enabledIds.contains(question.id)) continue;
      final TextEditingController? mappedController =
          _controllerForAdaptiveFollowUp(question.id);
      if (mappedController == null) continue;
      items.add(
        _PersonalizedFollowUp(
          controller: mappedController,
          label: question.label,
          helper: '${question.helper} Neden bu soru: ${question.rationale}.',
        ),
      );
    }
    return items;
  }

  TextEditingController? _controllerForAdaptiveFollowUp(String id) {
    switch (id) {
      case 'high_assurance_thought':
        return _highAssuranceThoughtCtrl;
      case 'idealization_awareness':
        return _idealizationAwarenessCtrl;
      case 'first_relationship_learning':
        return _firstRelLearningCtrl;
      case 'no_second_chance_behavior':
        return _noSecondChanceCtrl;
      case 'fast_attachment_driver':
        return _fastAttachDriverCtrl;
      case 'fast_elimination_reason':
        return _fastElimReasonCtrl;
    }
    return null;
  }

  OnboardingProfile _buildProfile() {
    final List<String> allDealbreakers = <String>[
      ..._dealbreakers,
      if (_dealbreakerFreeCtrl.text.trim().isNotEmpty)
        _dealbreakerFreeCtrl.text.trim(),
    ];

    return OnboardingProfile(
      // Section 1
      displayName: _nameCtrl.text.trim(),
      selfDescription: _selfDescCtrl.text.trim(),
      coreTraits: _coreTraits.toList(),
      currentLifeTheme: _currentLifeTheme,
      datingChallenge: _datingChallengeCtrl.text.trim(),
      freeformAboutMe: _freeformAboutMeCtrl.text.trim(),
      friendDescription: _friendDescCtrl.text.trim(),
      threeExperiences: _threeExperiencesCtrl.text.trim(),
      // Section 2
      goal: _goal ?? RelationshipGoal.unsure,
      pacingPreference: _pacing,
      openingUpTime: _openingUpTimeCtrl.text.trim(),
      trustBuilder: _trustBuilderCtrl.text.trim(),
      relationshipExperience: _experience,
      recentDatingChallenge: _recentChallengeCtrl.text.trim(),
      idealDay: _idealDayCtrl.text.trim(),
      // Section 3
      values: _values.toList(),
      respectSignal: _respectSignalCtrl.text.trim(),
      dealbreakers: allDealbreakers,
      lifestyleFactors: _lifestyleFactors.toList(),
      potentialVsBehavior: _potentialVsBehavior,
      valueConflict: _valueConflictCtrl.text.trim(),
      // Section 4
      communicationPreference: _commPref,
      showsInterestHow: _showsInterestCtrl.text.trim(),
      directVsSoft: _directVsSoft,
      messagingImportance: _messagingCtrl.text.trim(),
      ambiguityResponse: _ambiguityResp,
      conflictStyle: _conflictStyle,
      unheardFeeling: _unheardCtrl.text.trim(),
      // Section 5
      blindSpots: _blindSpots.toList(),
      recurringPattern: _recurringPatternCtrl.text.trim(),
      feedbackFromCloseOnes: _feedbackCtrl.text.trim(),
      biggestMisjudgment: _misjudgmentCtrl.text.trim(),
      judgmentCloudedBy: _cloudedByCtrl.text.trim(),
      stayedTooLong: _stayedTooLongCtrl.text.trim(),
      feelingsChanged: _feelingsChangedCtrl.text.trim(),
      // Section 6
      beliefRightPersonFindsWay: _beliefRightPerson.round(),
      beliefChemistryFeltFast: _beliefChemistryFast.round(),
      beliefStrongAttractionIsSign: _beliefStrongAttraction.round(),
      beliefFeelsRightOrNot: _beliefFeelsRight.round(),
      beliefFirstFeelingsAreTruth: _beliefFirstFeelings.round(),
      beliefPotentialEqualsValue: _beliefPotentialValue.round(),
      beliefAmbiguityIsNormal: _beliefAmbiguityNormal.round(),
      beliefLoveOvercomesIssues: _beliefLoveOvercomes.round(),
      // Section 7
      alarmTriggers: _alarmTriggers.toList(),
      vulnerabilityArea: _vulnerabilityArea,
      assuranceNeed: _assuranceNeed,
      jealousyLevel: _jealousyLevel,
      fatigueResponse: _fatigueResp,
      boundaryDifficulty: _boundaryDiffCtrl.text.trim(),
      safetyExperience: _safetyExperienceCtrl.text.trim(),
      // Section 8
      attachmentHistory: _attachmentHistoryCtrl.text.trim(),
      misunderstandingRisk: _misunderstandingCtrl.text.trim(),
      partnerShouldKnowEarly: _partnerKnowCtrl.text.trim(),
      freeformForProfile: _freeformProfileCtrl.text.trim(),
      profileSummaryFeedback: _summaryFeedbackCtrl.text.trim(),
      // Conditional
      highAssuranceThought: _highAssuranceThoughtCtrl.text.trim().isEmpty
          ? null
          : _highAssuranceThoughtCtrl.text.trim(),
      idealizationAwareness: _idealizationAwarenessCtrl.text.trim().isEmpty
          ? null
          : _idealizationAwarenessCtrl.text.trim(),
      firstRelationshipLearning: _firstRelLearningCtrl.text.trim().isEmpty
          ? null
          : _firstRelLearningCtrl.text.trim(),
      noSecondChanceBehavior: _noSecondChanceCtrl.text.trim().isEmpty
          ? null
          : _noSecondChanceCtrl.text.trim(),
      fastAttachmentDriver: _fastAttachDriverCtrl.text.trim().isEmpty
          ? null
          : _fastAttachDriverCtrl.text.trim(),
      fastEliminationReason: _fastElimReasonCtrl.text.trim().isEmpty
          ? null
          : _fastElimReasonCtrl.text.trim(),
      // Legal
      ageConfirmed: _ageConfirmed,
      policyAccepted: _policyAccepted,
    );
  }

  Future<void> _submit() async {
    final OnboardingProfile profile = _buildProfile();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: t.cardWhite,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: t.primaryYellow),
            SizedBox(height: 24),
            Text(
              "Seni tanıyorum...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              "Profilin derinlemesine analiz ediliyor ve sırdaş bağlantın kuruluyor.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final AiEnvelope<UserPsycheAnchor> anchorRun =
        await widget.controller.generatePsycheAnchorEnvelope(profile);
    final UserPsycheAnchor anchor = anchorRun.payload;
    profile.psycheAnchor = anchor;

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    final AiEnvelope<UserPsycheAnchor> finalMirrorRun =
        await _showMirrorReport(profile, anchorRun);
    profile.psycheAnchor = finalMirrorRun.payload;

    widget.controller.completeOnboarding(profile);
    widget.onComplete();
  }

  Future<AiEnvelope<UserPsycheAnchor>> _showMirrorReport(
    OnboardingProfile profile,
    AiEnvelope<UserPsycheAnchor> initialRun,
  ) async {
    AiEnvelope<UserPsycheAnchor> mirrorRun = initialRun;

    while (mounted) {
      final UserPsycheAnchor anchor = mirrorRun.payload;
      final bool aiActive = mirrorRun.mode == AiRunMode.llm;
      final bool canRetryLlm =
          (AIConfig.instance.hasGemini || AIConfig.instance.hasGroq) &&
          mirrorRun.mode != AiRunMode.llm;
      final String statusText = switch (mirrorRun.mode) {
        AiRunMode.llm => 'LLM derin okuma aktif',
        AiRunMode.hybrid => 'Hibrit analiz',
        AiRunMode.vector => 'Vektör destekli',
        AiRunMode.local => 'Temel mod',
      };
      final String statusHint = aiActive
          ? 'Bu ayna raporu canlı LLM ile üretildi.'
          : (mirrorRun.error?.trim().isNotEmpty ?? false)
              ? 'LLM bu turda gelemedi. Şu an temel motorun çıktısını görüyorsun.'
              : 'LLM anahtarı bağlı değil veya bu turda kullanılmadı. Şu an temel motorun çıktısını görüyorsun.';

      final _MirrorDialogAction? action =
          await showDialog<_MirrorDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: t.cardWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Ayna Raporun',
            style: TextStyle(
              color: t.primaryYellow,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  aiActive ? Icons.auto_awesome_rounded : Icons.psychology,
                  size: 48,
                  color: aiActive ? t.softGreen : t.primaryYellow,
                ),
                const SizedBox(height: 16),
                TagPill(
                  text: statusText,
                  background:
                      (aiActive ? t.softGreen : t.primaryYellow).withValues(
                    alpha: 0.12,
                  ),
                  foreground: aiActive ? t.softGreen : t.primaryYellow,
                ),
                const SizedBox(height: 12),
                Text(
                  '${mirrorRun.provider ?? 'local'} • ${mirrorRun.latencyMs} ms',
                  style: const TextStyle(
                    color: t.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (aiActive ? t.softGreen : t.primaryYellow).withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          (aiActive ? t.softGreen : t.primaryYellow).withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: Text(
                    statusHint,
                    style: const TextStyle(
                      color: t.textPrimary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ),
                if ((mirrorRun.note?.trim().isNotEmpty ?? false) ||
                    (mirrorRun.error?.trim().isNotEmpty ?? false)) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: t.borderLight.withValues(alpha: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'AI iz kaydı',
                          style: TextStyle(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (mirrorRun.note?.trim().isNotEmpty ?? false) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            mirrorRun.note!,
                            style: const TextStyle(
                              color: t.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (mirrorRun.error?.trim().isNotEmpty ?? false) ...<Widget>[
                          const SizedBox(height: 8),
                          Text(
                            mirrorRun.error!,
                            style: const TextStyle(
                              color: t.roseCaution,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  anchor.mirrorReport,
                  style: const TextStyle(
                    color: t.textPrimary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                if (anchor.sensitiveMemories.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  SensitiveContextDeck(
                    memories: anchor.sensitiveMemories,
                    maxItems: 2,
                    title: 'Bunu da hesaba kattim',
                    subtitle:
                        'Bana actigin ozel hayat baglamini sonraki yorumlara tasiyorum.',
                  ),
                ],
                if (anchor.coreRealities.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: anchor.coreRealities
                          .map((String item) => TagPill(text: item))
                          .toList(growable: false),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            if (canRetryLlm)
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _MirrorDialogAction.retryLlm),
                child: const Text('LLM ile tekrar dene'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primaryYellow,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pop(ctx, _MirrorDialogAction.continueToApp),
              child: const Text('Anladım, Uygulamaya Geç'),
            ),
          ],
        ),
      );

      if (action == _MirrorDialogAction.retryLlm) {
        if (!mounted) return mirrorRun;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: t.cardWhite,
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(color: t.primaryYellow),
                SizedBox(height: 20),
                Text('LLM yeniden deneniyor...'),
              ],
            ),
          ),
        );
        mirrorRun = await widget.controller.generatePsycheAnchorEnvelope(
          profile,
        );
        if (!mounted) return mirrorRun;
        Navigator.pop(context);
        continue;
      }

      return mirrorRun;
    }

    return mirrorRun;
  }
}

// ═══════════════════════════════════════════════
//  Reusable Onboarding Widgets
// ═══════════════════════════════════════════════

class _SectionHeaderCard extends StatelessWidget {
  const _SectionHeaderCard({
    required this.index,
    required this.colors,
    required this.icon,
  });

  final int index;
  final List<Color> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'BÖLÜM ${index + 1} / 8',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _OnboardingPageState._sectionTitles[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSection extends StatelessWidget {
  const _OnboardingSection({
    required this.children,
    required this.onNext,
    this.nextLabel = 'Tamamla ve devam et',
  });

  final List<Widget> children;
  final VoidCallback? onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: children,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('onboarding_next_button'),
              onPressed: onNext,
              child: Text(nextLabel),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: t.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _ChipQuestion extends StatelessWidget {
  const _ChipQuestion({
    required this.title,
    required this.options,
    required this.selected,
    required this.maxSelection,
    required this.onChanged,
    this.selectionHelpText,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final int maxSelection;
  final ValueChanged<Set<String>> onChanged;
  final String? selectionHelpText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (maxSelection < 99) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            selectionHelpText ?? 'En fazla $maxSelection seçim',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((String option) {
            final bool isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool on) {
                if (on && selected.length >= maxSelection) return;
                if (on) {
                  selected.add(option);
                } else {
                  selected.remove(option);
                }
                onChanged(selected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ChipSingleQuestion extends StatelessWidget {
  const _ChipSingleQuestion({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((String option) {
            return ChoiceChip(
              label: Text(option),
              selected: selected == option,
              onSelected: (_) => onChanged(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PersonalizedFollowUp {
  const _PersonalizedFollowUp({
    required this.controller,
    required this.label,
    required this.helper,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
}

class _BeliefSlider extends StatelessWidget {
  const _BeliefSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text('1',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Expanded(
                child: Slider(
                  value: value,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  label: value.round().toString(),
                  onChanged: onChanged,
                ),
              ),
              Text('7',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
