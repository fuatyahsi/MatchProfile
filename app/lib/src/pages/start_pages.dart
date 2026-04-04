import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

// ═══════════════════════════════════════════════
//  Welcome Page
// ═══════════════════════════════════════════════

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: TagPill(
                  text: 'Premium Beta',
                  background: t.roseGold.withValues(alpha: 0.12),
                  foreground: t.roseGold,
                ),
              ),
              const SizedBox(height: 24),
              GradientCard(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.roseGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: t.roseGold.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        'Romantik karar zekası',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.roseGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Seni tanıyarak\nbaşlayalım.',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: t.ivoryText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'MatchProfile önce seni ölçmez, tanır. Romantik karar profilini çıkarır, tutarsızlıklarını gösterir, sonra her insight\'ı sana göre kişiselleştirir.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: t.ivoryText.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('welcome_start_button'),
                        onPressed: onStart,
                        child: const Text('Profilimi oluştur'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SectionHeader(
                      kicker: 'Neden profil?',
                      title:
                          'Herkes aynı soruları görmemeli. Herkes aynı yorumu almamalı.',
                    ),
                    const SizedBox(height: 18),
                    _WelcomeFeature(
                      icon: Icons.psychology_outlined,
                      title: 'Romantik karar profili',
                      description:
                          'İlişki niyeti, tempo, iletişim stili, kör noktalar, idealizasyon riski ve güvence ihtiyacın profilleşir.',
                    ),
                    const SizedBox(height: 14),
                    _WelcomeFeature(
                      icon: Icons.tune_outlined,
                      title: 'Kişiselleştirilmiş insight',
                      description:
                          'Reflection yorumları ve validation soruları kör noktalarına göre tonlanır.',
                    ),
                    const SizedBox(height: 14),
                    _WelcomeFeature(
                      icon: Icons.edit_note_outlined,
                      title: 'Serbest alan',
                      description:
                          'Ölçeklerin yakalayamadığı travma, aile etkisi, kültürel sınır ve kişisel gerçeği sen yazarsın.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SurfaceCard(
                tint: t.charcoal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '8 bölüm · ~12 dakika',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kendini anlat, ilişki niyetini belirle, değerlerini sırala, iletişim stilini keşfet, kör noktalarını tanı, inançlarını ölç, sınırlarını çiz, serbest alanı doldur.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: t.roseGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: t.roseGold),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
//  Onboarding Page — 8-Section Deep Profiling
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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 10; // 8 sections + summary + legal

  // ── Section 1: Kendini anlat ──
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _selfDescCtrl = TextEditingController();
  final Set<String> _coreTraits = <String>{};
  String _currentLifeTheme = '';
  final TextEditingController _datingChallengeCtrl = TextEditingController();
  final TextEditingController _freeformAboutMeCtrl = TextEditingController();

  // ── Section 2: İlişki niyeti ──
  RelationshipGoal? _goal;
  PacingPreference _pacing = PacingPreference.balanced;
  final TextEditingController _openingUpTimeCtrl = TextEditingController();
  final TextEditingController _trustBuilderCtrl = TextEditingController();
  RelationshipExperience _experience = RelationshipExperience.several;
  final TextEditingController _recentChallengeCtrl = TextEditingController();

  // ── Section 3: Değerler ──
  final Set<String> _values = <String>{};
  final TextEditingController _respectSignalCtrl = TextEditingController();
  final Set<String> _dealbreakers = <String>{};
  final TextEditingController _dealbreakerFreeCtrl = TextEditingController();
  final Set<String> _lifestyleFactors = <String>{};
  String _potentialVsBehavior = 'Bugünkü davranışı';

  // ── Section 4: İletişim ──
  CommunicationPreference _commPref = CommunicationPreference.balancedRegular;
  final TextEditingController _showsInterestCtrl = TextEditingController();
  String _directVsSoft = 'Doğrudan';
  final TextEditingController _messagingCtrl = TextEditingController();
  AmbiguityResponse _ambiguityResp = AmbiguityResponse.overthink;
  ConflictStyle _conflictStyle = ConflictStyle.talkItOut;

  // ── Section 5: Kör noktalar ──
  final Set<String> _blindSpots = <String>{};
  final TextEditingController _recurringPatternCtrl = TextEditingController();
  final TextEditingController _feedbackCtrl = TextEditingController();
  final TextEditingController _misjudgmentCtrl = TextEditingController();
  final TextEditingController _cloudedByCtrl = TextEditingController();

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
    _pageController.dispose();
    _nameCtrl.dispose();
    _selfDescCtrl.dispose();
    _datingChallengeCtrl.dispose();
    _freeformAboutMeCtrl.dispose();
    _openingUpTimeCtrl.dispose();
    _trustBuilderCtrl.dispose();
    _recentChallengeCtrl.dispose();
    _respectSignalCtrl.dispose();
    _dealbreakerFreeCtrl.dispose();
    _showsInterestCtrl.dispose();
    _messagingCtrl.dispose();
    _recurringPatternCtrl.dispose();
    _feedbackCtrl.dispose();
    _misjudgmentCtrl.dispose();
    _cloudedByCtrl.dispose();
    _boundaryDiffCtrl.dispose();
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

  void _goNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentPage + 1) / _totalPages;

    return Scaffold(
      body: AppBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: <Widget>[
                    if (_currentPage > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: _goBack,
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            _sectionTitle(_currentPage),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: t.roseGold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) =>
                      setState(() => _currentPage = page),
                  children: <Widget>[
                    _buildSection1(context),
                    _buildSection2(context),
                    _buildSection3(context),
                    _buildSection4(context),
                    _buildSection5(context),
                    _buildSection6(context),
                    _buildSection7(context),
                    _buildSection8(context),
                    _buildConditionalFollowUps(context),
                    _buildSummaryAndLegal(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sectionTitle(int page) {
    return switch (page) {
      0 => 'Bölüm 1 / 8 · Kendini Anlat',
      1 => 'Bölüm 2 / 8 · İlişki Niyeti',
      2 => 'Bölüm 3 / 8 · Değerler',
      3 => 'Bölüm 4 / 8 · İletişim Stili',
      4 => 'Bölüm 5 / 8 · Kör Noktalar',
      5 => 'Bölüm 6 / 8 · İnançlar',
      6 => 'Bölüm 7 / 8 · Güvenlik & Sınırlar',
      7 => 'Bölüm 8 / 8 · Açık Alan',
      8 => 'Derinleşme Soruları',
      9 => 'Profil Özeti',
      _ => '',
    };
  }

  // ─────────────────────────────────────────
  //  Section 1: Kendini Anlat
  // ─────────────────────────────────────────

  Widget _buildSection1(BuildContext context) {
    return _OnboardingSection(
      onNext: _nameCtrl.text.trim().isNotEmpty ? _goNext : null,
      children: <Widget>[
        const _SectionIntro(
          title: 'Seni tanıyalım',
          subtitle:
              'Bu bölümde kim olduğunu, hayatında nerede olduğunu ve dating tarafında ne yaşadığını anlayacağız.',
        ),
        const SizedBox(height: 20),
        TextField(
          key: const Key('onboarding_name_field'),
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Sana nasıl hitap edelim?',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _selfDescCtrl,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Kendini bize 4-6 cümleyle anlat',
            hintText: 'Seni sen yapan şeyler neler?',
          ),
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'Seni en iyi anlatan 5 özelliği seç',
          options: const <String>[
            'Sakin',
            'Yoğun',
            'Analitik',
            'Duygusal',
            'Sosyal',
            'Seçici',
            'Temkinli',
            'Romantik',
            'Bağımsız',
            'Korumacı',
          ],
          selected: _coreTraits,
          maxSelection: 5,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Bu dönem hayatında en baskın tema ne?',
          options: const <String>[
            'Kariyer',
            'Okul',
            'İyileşme',
            'Keşif',
            'Düzen kurma',
            'Yalnız kalma ihtiyacı',
            'İlişkiye alan açma',
          ],
          selected: _currentLifeTheme,
          onChanged: (String v) => setState(() => _currentLifeTheme = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _datingChallengeCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Dating tarafında şu an en çok neyi çözmeye çalışıyorsun?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _freeformAboutMeCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Formda sorulmayan ama bilmemiz gereken bir şey var mı?',
            hintText:
                'Travma, geçmiş deneyim, aile etkisi, kültürel sınır, dini hassasiyet...',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 2: İlişki Niyeti ve Zamanlama
  // ─────────────────────────────────────────

  Widget _buildSection2(BuildContext context) {
    return _OnboardingSection(
      onNext: _goal != null ? _goNext : null,
      children: <Widget>[
        const _SectionIntro(
          title: 'İlişki niyetin ve zamanlaması',
          subtitle:
              'Ne aradığını, hangi tempoda ilerlediğini ve geçmiş deneyim seviyeni anlayacağız.',
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
        _ChipSingleQuestion(
          title: 'Doğal ilerleme tempon nasıl olmalı?',
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
        TextField(
          controller: _openingUpTimeCtrl,
          decoration: const InputDecoration(
            labelText: 'Birine açılman genelde ne kadar sürer?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _trustBuilderCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'İlk aşamada sende güven oluşturan şey nedir?',
          ),
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
        TextField(
          controller: _recentChallengeCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Son bir yılda seni en çok zorlayan dating deneyimi neydi?',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 3: Değerler ve Vazgeçilmezler
  // ─────────────────────────────────────────

  Widget _buildSection3(BuildContext context) {
    return _OnboardingSection(
      onNext: _values.length >= 3 ? _goNext : null,
      children: <Widget>[
        const _SectionIntro(
          title: 'Değerlerin ve vazgeçilmezlerin',
          subtitle:
              'Bir ilişkide olmazsa olmazlarını, sınırlarını ve yaşam tarzı uyumunu belirle.',
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'En kritik 5 değer hangisi?',
          options: const <String>[
            'Dürüstlük',
            'Duygusal olgunluk',
            'Net iletişim',
            'Sadakat',
            'Şefkat',
            'Mizah',
            'İstikrar',
            'Entelektüel uyum',
            'Aile yaklaşımı',
            'Yaşam ritmi',
            'Saygı',
            'Hedef uyumu',
          ],
          selected: _values,
          maxSelection: 5,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _respectSignalCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Saygı gördüğünü sana en çok ne hissettirir?',
          ),
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'Asla tolere etmem dediğin davranışlar',
          options: const <String>[
            'Yalan',
            'Manipülasyon',
            'Tutarsızlık',
            'Duygusal istismar',
            'Cinsel baskı',
            'Kontrol etme',
            'Küçümseme',
            'İlgisizlik',
            'Sadakatsizlik',
          ],
          selected: _dealbreakers,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dealbreakerFreeCtrl,
          decoration: const InputDecoration(
            hintText: 'Listede olmayan dealbreaker...',
          ),
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'Yaşam tarzı uyumu — sana önemli olanlar',
          options: const <String>[
            'Sosyal tempo',
            'Alkol/madde',
            'Gece hayatı',
            'Kariyer önceliği',
            'Aile yakınlığı',
            'Şehir planı',
            'Çocuk isteği',
          ],
          selected: _lifestyleFactors,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Potansiyeli mi, bugünkü davranışı mı daha belirleyici?',
          options: const <String>[
            'Bugünkü davranışı',
            'Potansiyeli de önemli',
            'İkisi eşit',
          ],
          selected: _potentialVsBehavior,
          onChanged: (String v) => setState(() => _potentialVsBehavior = v),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 4: İletişim ve Yakınlık Stili
  // ─────────────────────────────────────────

  Widget _buildSection4(BuildContext context) {
    return _OnboardingSection(
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'İletişim ve yakınlık stilin',
          subtitle:
              'İlgi gösterme biçimini, mesaj temposunu, belirsizlikteki ve tartışmadaki eğilimini anlayacağız.',
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'En rahat hissettiğin iletişim biçimi',
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
        TextField(
          controller: _showsInterestCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Sen ilgini en çok nasıl gösterirsin?',
          ),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Doğrudan mı, yumuşak mı?',
          options: const <String>['Doğrudan', 'Yumuşak', 'Duruma göre'],
          selected: _directVsSoft,
          onChanged: (String v) => setState(() => _directVsSoft = v),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _messagingCtrl,
          decoration: const InputDecoration(
            labelText: 'Mesaj temposu senin için ne kadar anlam taşır?',
          ),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Belirsizlikte ne yaparsın?',
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
          title: 'Tartışma anında eğilimin',
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
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 5: Kör Noktalar ve Pattern'ler
  // ─────────────────────────────────────────

  Widget _buildSection5(BuildContext context) {
    return _OnboardingSection(
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'Kör noktaların ve tekrar eden döngülerin',
          subtitle:
              'Bu bölüm en zor ama en değerli kısım. Dürüst cevaplar, daha doğru insight demek.',
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'Sende en çok hangileri oluyor?',
          options: const <String>[
            'Yüksek çekimi uyum sanma',
            'Red flag\'i rasyonalize etme',
            'Çok erken bağlanma',
            'Fazla hızlı eleme',
            'Potansiyele aşırı yatırım',
            'Tutarsızlığı heyecan sanma',
            'Kurtarıcı rolüne girme',
            'Kendi ihtiyacını geri plana atma',
          ],
          selected: _blindSpots,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _recurringPatternCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Geçmiş tanışmalarda en sık tekrar eden döngün ne oldu?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _feedbackCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Yakınların ilişki konusunda en çok hangi geri bildirimi verdi?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _misjudgmentCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Birini değerlendirirken en çok nerede yanıldığını düşünüyorsun?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cloudedByCtrl,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Hoşuna giden biri olduğunda kararını en çok ne bulandırıyor?',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 6: Aşka Dair İnançlar (1–7)
  // ─────────────────────────────────────────

  Widget _buildSection6(BuildContext context) {
    return _OnboardingSection(
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'Aşka dair inançların',
          subtitle:
              'Her ifadeye 1 (kesinlikle katılmıyorum) ile 7 (kesinlikle katılıyorum) arasında puan ver. İdealizasyon eğilimini ve gerçekçilik dengesini ölçeceğiz.',
        ),
        const SizedBox(height: 20),
        _BeliefSlider(
          label: 'Doğru kişi varsa şartlar ne kadar zor olsa da ilişki yolunu bulur.',
          value: _beliefRightPerson,
          onChanged: (double v) => setState(() => _beliefRightPerson = v),
        ),
        _BeliefSlider(
          label: 'Gerçek uyum çok hızlı hissedilir.',
          value: _beliefChemistryFast,
          onChanged: (double v) => setState(() => _beliefChemistryFast = v),
        ),
        _BeliefSlider(
          label: 'Çok güçlü çekim varsa bu önemli bir işarettir.',
          value: _beliefStrongAttraction,
          onChanged: (double v) => setState(() => _beliefStrongAttraction = v),
        ),
        _BeliefSlider(
          label: 'Bir ilişki ya çok doğru gelir ya da gelmez.',
          value: _beliefFeelsRight,
          onChanged: (double v) => setState(() => _beliefFeelsRight = v),
        ),
        _BeliefSlider(
          label: 'İlk hislerim çoğu zaman bana gerçeği söyler.',
          value: _beliefFirstFeelings,
          onChanged: (double v) => setState(() => _beliefFirstFeelings = v),
        ),
        _BeliefSlider(
          label: 'Birinin potansiyeli, bugünkü davranışı kadar değerlidir.',
          value: _beliefPotentialValue,
          onChanged: (double v) => setState(() => _beliefPotentialValue = v),
        ),
        _BeliefSlider(
          label: 'Netlik yoksunluğu ilk aşamalarda normaldir.',
          value: _beliefAmbiguityNormal,
          onChanged: (double v) => setState(() => _beliefAmbiguityNormal = v),
        ),
        _BeliefSlider(
          label: 'Sevgi varsa insanlar temel sorunları zamanla aşar.',
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
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'Güvenlik, sınır ve kırılganlıkların',
          subtitle:
              'Hangi davranışlarda alarm verirsin, en hassas alanın ne, yorulduğunda ne yaparsın?',
        ),
        const SizedBox(height: 20),
        _ChipQuestion(
          title: 'Sende alarm yaratan davranışlar',
          options: const <String>[
            'Tutarsızlık',
            'Manipülasyon',
            'Cinsel baskı',
            'Aşırı hız',
            'Duygusal kapalılık',
            'Küçümseme',
            'Sınır ihlali',
            'Gaslighting',
            'Görünürlükten kaçma',
          ],
          selected: _alarmTriggers,
          maxSelection: 99,
          onChanged: (Set<String> v) => setState(() {}),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'En hassas olduğun alan',
          options: const <String>[
            'Terk edilme',
            'Yanlış kişiyi seçme',
            'Kullanılmış hissetme',
            'Yetersiz görünme',
            'Kontrol kaybı',
          ],
          selected: _vulnerabilityArea,
          onChanged: (String v) => setState(() => _vulnerabilityArea = v),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Güvence ihtiyacın',
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
          title: 'Kıskançlık / sahiplenme eğilimin',
          options: const <String>['Düşük', 'Orta', 'Yüksek'],
          selected: _jealousyLevel,
          onChanged: (String v) => setState(() => _jealousyLevel = v),
        ),
        const SizedBox(height: 20),
        _ChipSingleQuestion(
          title: 'Duygusal yorulduğunda ne yaparsın?',
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
        TextField(
          controller: _boundaryDiffCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Sınır koymakta zorlandığın alan varsa yaz',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Section 8: Açık Profil Alanı
  // ─────────────────────────────────────────

  Widget _buildSection8(BuildContext context) {
    return _OnboardingSection(
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'Açık alan — serbest anlatı',
          subtitle:
              'Ölçeklerin yakalayamadığı her şeyi buraya yazabilirsin. Aile etkisi, bağlanma hikayesi, travma, kültürel sınırlar...',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _attachmentHistoryCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText:
                'Çocukluk, aile yapısı veya bağlanma biçiminin seni etkilediğini düşündüğün bir şey var mı?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _misunderstandingCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Seni yanlış anlamamıza en çok neden olabilecek şey nedir?',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _partnerKnowCtrl,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Bir partnerin senin hakkında en erken bilmesini istediğin şey',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _freeformProfileCtrl,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText:
                'MatchProfile\'ın seni daha doğru okuyabilmesi için bilmesi gereken her şey',
            hintText:
                'Bu alan tamamen sana ait. İstediğin kadar uzun yazabilirsin.',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Conditional Follow-up Questions
  // ─────────────────────────────────────────

  Widget _buildConditionalFollowUps(BuildContext context) {
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
    final bool showFastAttach = _blindSpots.contains('Çok erken bağlanma');
    final bool showFastElim = _blindSpots.contains('Fazla hızlı eleme');

    final bool hasAnyConditional = showHighAssurance ||
        showIdealization ||
        showFirstRel ||
        showBoundary ||
        showFastAttach ||
        showFastElim;

    if (!hasAnyConditional) {
      // Skip this page automatically after a brief display
      return _OnboardingSection(
        onNext: _goNext,
        children: <Widget>[
          const _SectionIntro(
            title: 'Derinleşme soruları',
            subtitle: 'Profiline göre ek soru gerekmedi. Devam edebilirsin.',
          ),
        ],
      );
    }

    return _OnboardingSection(
      onNext: _goNext,
      children: <Widget>[
        const _SectionIntro(
          title: 'Derinleşme soruları',
          subtitle:
              'Cevaplarına göre sana özel birkaç ek soru çıktı. Bunlar profilini daha doğru yapmamıza yardımcı olacak.',
        ),
        const SizedBox(height: 20),
        if (showHighAssurance) ...<Widget>[
          TextField(
            controller: _highAssuranceThoughtCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Cevapsız kaldığında aklından ilk ne geçer?',
              helperText: 'Güvence ihtiyacın yüksek — bu normal, ama anlamak önemli.',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showIdealization) ...<Widget>[
          TextField(
            controller: _idealizationAwarenessCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText:
                  'Birine potansiyel yüklediğini en son ne zaman fark ettin?',
              helperText: 'İdealizasyon eğilimin ortalamanın üstünde çıktı.',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showFirstRel) ...<Widget>[
          TextField(
            controller: _firstRelLearningCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Henüz en çok öğrenmeye çalıştığın şey ne?',
              helperText: 'İlk deneyimler özel bir hassasiyet gerektirir.',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showBoundary) ...<Widget>[
          TextField(
            controller: _noSecondChanceCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Hangi davranışta ikinci şans vermezsin?',
              helperText: 'Sınır hassasiyetin yüksek — bu değerli bir farkındalık.',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showFastAttach) ...<Widget>[
          TextField(
            controller: _fastAttachDriverCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText:
                  'Yakınlık mı seni hızlandırıyor, yalnız kalma korkusu mu?',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showFastElim) ...<Widget>[
          TextField(
            controller: _fastElimReasonCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText:
                  'Kendini korumak için mi eliyorsun, gerçekten uyum görmediğin için mi?',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Profile Summary + Legal
  // ─────────────────────────────────────────

  Widget _buildSummaryAndLegal(BuildContext context) {
    final OnboardingProfile tempProfile = _buildProfile();
    final String summary = tempProfile.generateProfileSummary();
    final List<ProfileInconsistency> inconsistencies =
        tempProfile.detectInconsistencies();
    final List<CharacterInsight> characterInsights =
        tempProfile.generateCharacterAnalysis();
    final bool canSubmit = _ageConfirmed && _policyAccepted;

    return _OnboardingSection(
      onNext: canSubmit ? _submit : null,
      nextLabel: 'Profilimi kaydet',
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
                      color: t.roseGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: t.roseGold.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: t.roseGold, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _nameCtrl.text.trim(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: t.roseGold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                summary,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: t.ivoryText.withValues(alpha: 0.88),
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

        // ── Radar chart overview ──
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Profil Radarı',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Romantik karar profilinin çok boyutlu görünümü',
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
                    label: 'İdealizasyon',
                    value: tempProfile.idealizationScore,
                    size: 80,
                    color: tempProfile.highIdealization
                        ? t.roseCaution
                        : t.roseGold,
                    subtitle: tempProfile.highIdealization ? 'Yüksek risk' : null,
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
                    color: tempProfile.emotionalDependencyRisk > 0.5
                        ? t.roseCaution
                        : t.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Profile score bars — detailed ──
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
                subtitle: 'İdealizasyonun tersi',
              ),
              ProfileScoreBar(
                label: 'Öz farkındalık',
                value: tempProfile.selfAwarenessScore,
                color: t.warmGold,
                subtitle: 'Kör nokta ve pattern farkındalığı',
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
                color: t.roseGold,
                subtitle: 'Tüm metriklerin ortalaması',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ── Character analysis insights ──
        ...characterInsights.map((CharacterInsight insight) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(insight.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Text(
                      insight.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                    ),
                    if (insight.score != null) ...<Widget>[
                      const SizedBox(height: 12),
                      ProfileScoreBar(
                        label: insight.scoreLabel ?? '',
                        value: insight.score!,
                        color: t.roseGold,
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

        const SizedBox(height: 14),
        TextField(
          controller: _summaryFeedbackCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Bu analiz nerede doğru, nerede eksik, nerede yanlış?',
            hintText: 'Dürüst geri bildirimin profili daha keskin yapar.',
          ),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          tint: t.charcoal,
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
                title: const Text('KVKK ve beta koşullarını kabul ediyorum'),
                subtitle: const Text(
                  'Verilerim yalnızca profilimi kişiselleştirmek için kullanılacak.',
                ),
                onChanged: (bool? v) =>
                    setState(() => _policyAccepted = v ?? false),
              ),
            ],
          ),
        ),
      ],
    );
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
      // Section 2
      goal: _goal ?? RelationshipGoal.unsure,
      pacingPreference: _pacing,
      openingUpTime: _openingUpTimeCtrl.text.trim(),
      trustBuilder: _trustBuilderCtrl.text.trim(),
      relationshipExperience: _experience,
      recentDatingChallenge: _recentChallengeCtrl.text.trim(),
      // Section 3
      values: _values.toList(),
      respectSignal: _respectSignalCtrl.text.trim(),
      dealbreakers: allDealbreakers,
      lifestyleFactors: _lifestyleFactors.toList(),
      potentialVsBehavior: _potentialVsBehavior,
      // Section 4
      communicationPreference: _commPref,
      showsInterestHow: _showsInterestCtrl.text.trim(),
      directVsSoft: _directVsSoft,
      messagingImportance: _messagingCtrl.text.trim(),
      ambiguityResponse: _ambiguityResp,
      conflictStyle: _conflictStyle,
      // Section 5
      blindSpots: _blindSpots.toList(),
      recurringPattern: _recurringPatternCtrl.text.trim(),
      feedbackFromCloseOnes: _feedbackCtrl.text.trim(),
      biggestMisjudgment: _misjudgmentCtrl.text.trim(),
      judgmentCloudedBy: _cloudedByCtrl.text.trim(),
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

  void _submit() {
    final OnboardingProfile profile = _buildProfile();
    widget.controller.completeOnboarding(profile);
    widget.onComplete();
  }
}

// ═══════════════════════════════════════════════
//  Reusable Onboarding Widgets
// ═══════════════════════════════════════════════

class _OnboardingSection extends StatelessWidget {
  const _OnboardingSection({
    required this.children,
    required this.onNext,
    this.nextLabel = 'Devam et',
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
                color: t.mutedText,
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
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final int maxSelection;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (maxSelection < 99) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            'En fazla $maxSelection seçim',
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
