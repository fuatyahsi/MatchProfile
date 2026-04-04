import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

// ═══════════════════════════════════════════════
//  Profile Edit — Update onboarding answers
// ═══════════════════════════════════════════════

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final OnboardingProfile _original;

  // ── Section 1 ──
  late TextEditingController _displayNameCtrl;
  late TextEditingController _selfDescCtrl;
  late List<String> _coreTraits;
  late TextEditingController _lifeThemeCtrl;
  late TextEditingController _datingChallengeCtrl;
  late TextEditingController _freeformAboutMeCtrl;

  // ── Section 2 ──
  late RelationshipGoal _goal;
  late PacingPreference _pacing;
  late TextEditingController _openingUpTimeCtrl;
  late TextEditingController _trustBuilderCtrl;
  late RelationshipExperience _experience;
  late TextEditingController _recentChallengeCtrl;

  // ── Section 3 ──
  late List<String> _values;
  late TextEditingController _respectSignalCtrl;
  late List<String> _dealbreakers;
  late List<String> _lifestyleFactors;
  late TextEditingController _potentialVsBehaviorCtrl;

  // ── Section 4 ──
  late CommunicationPreference _commPref;
  late TextEditingController _showsInterestCtrl;
  late TextEditingController _directVsSoftCtrl;
  late TextEditingController _messagingCtrl;
  late AmbiguityResponse _ambiguity;
  late ConflictStyle _conflict;

  // ── Section 5 ──
  late List<String> _blindSpots;
  late TextEditingController _recurringPatternCtrl;
  late TextEditingController _feedbackCtrl;
  late TextEditingController _misjudgmentCtrl;
  late TextEditingController _judgmentCloudedCtrl;

  // ── Section 6: Belief scales ──
  late int _beliefRightPerson;
  late int _beliefChemistry;
  late int _beliefAttraction;
  late int _beliefFeelsRight;
  late int _beliefFirstFeelings;
  late int _beliefPotential;
  late int _beliefAmbiguity;
  late int _beliefLoveOvercomes;

  // ── Section 7 ──
  late List<String> _alarmTriggers;
  late TextEditingController _vulnerabilityCtrl;
  late AssuranceNeed _assurance;
  late TextEditingController _jealousyCtrl;
  late FatigueResponse _fatigue;
  late TextEditingController _boundaryCtrl;

  // ── Section 8 ──
  late TextEditingController _attachmentHistoryCtrl;
  late TextEditingController _misunderstandingCtrl;
  late TextEditingController _partnerShouldKnowCtrl;
  late TextEditingController _freeformProfileCtrl;

  // Track which sections are expanded
  final List<bool> _expanded = List<bool>.filled(8, false);

  @override
  void initState() {
    super.initState();
    _original = widget.controller.profile!;
    _initFromProfile(_original);
  }

  void _initFromProfile(OnboardingProfile p) {
    _displayNameCtrl = TextEditingController(text: p.displayName);
    _selfDescCtrl = TextEditingController(text: p.selfDescription);
    _coreTraits = List<String>.from(p.coreTraits);
    _lifeThemeCtrl = TextEditingController(text: p.currentLifeTheme);
    _datingChallengeCtrl = TextEditingController(text: p.datingChallenge);
    _freeformAboutMeCtrl = TextEditingController(text: p.freeformAboutMe);

    _goal = p.goal;
    _pacing = p.pacingPreference;
    _openingUpTimeCtrl = TextEditingController(text: p.openingUpTime);
    _trustBuilderCtrl = TextEditingController(text: p.trustBuilder);
    _experience = p.relationshipExperience;
    _recentChallengeCtrl = TextEditingController(text: p.recentDatingChallenge);

    _values = List<String>.from(p.values);
    _respectSignalCtrl = TextEditingController(text: p.respectSignal);
    _dealbreakers = List<String>.from(p.dealbreakers);
    _lifestyleFactors = List<String>.from(p.lifestyleFactors);
    _potentialVsBehaviorCtrl =
        TextEditingController(text: p.potentialVsBehavior);

    _commPref = p.communicationPreference;
    _showsInterestCtrl = TextEditingController(text: p.showsInterestHow);
    _directVsSoftCtrl = TextEditingController(text: p.directVsSoft);
    _messagingCtrl = TextEditingController(text: p.messagingImportance);
    _ambiguity = p.ambiguityResponse;
    _conflict = p.conflictStyle;

    _blindSpots = List<String>.from(p.blindSpots);
    _recurringPatternCtrl = TextEditingController(text: p.recurringPattern);
    _feedbackCtrl = TextEditingController(text: p.feedbackFromCloseOnes);
    _misjudgmentCtrl = TextEditingController(text: p.biggestMisjudgment);
    _judgmentCloudedCtrl = TextEditingController(text: p.judgmentCloudedBy);

    _beliefRightPerson = p.beliefRightPersonFindsWay;
    _beliefChemistry = p.beliefChemistryFeltFast;
    _beliefAttraction = p.beliefStrongAttractionIsSign;
    _beliefFeelsRight = p.beliefFeelsRightOrNot;
    _beliefFirstFeelings = p.beliefFirstFeelingsAreTruth;
    _beliefPotential = p.beliefPotentialEqualsValue;
    _beliefAmbiguity = p.beliefAmbiguityIsNormal;
    _beliefLoveOvercomes = p.beliefLoveOvercomesIssues;

    _alarmTriggers = List<String>.from(p.alarmTriggers);
    _vulnerabilityCtrl = TextEditingController(text: p.vulnerabilityArea);
    _assurance = p.assuranceNeed;
    _jealousyCtrl = TextEditingController(text: p.jealousyLevel);
    _fatigue = p.fatigueResponse;
    _boundaryCtrl = TextEditingController(text: p.boundaryDifficulty);

    _attachmentHistoryCtrl = TextEditingController(text: p.attachmentHistory);
    _misunderstandingCtrl =
        TextEditingController(text: p.misunderstandingRisk);
    _partnerShouldKnowCtrl =
        TextEditingController(text: p.partnerShouldKnowEarly);
    _freeformProfileCtrl = TextEditingController(text: p.freeformForProfile);
  }

  @override
  void dispose() {
    for (final TextEditingController c in <TextEditingController>[
      _displayNameCtrl, _selfDescCtrl, _lifeThemeCtrl, _datingChallengeCtrl,
      _freeformAboutMeCtrl, _openingUpTimeCtrl, _trustBuilderCtrl,
      _recentChallengeCtrl, _respectSignalCtrl, _potentialVsBehaviorCtrl,
      _showsInterestCtrl, _directVsSoftCtrl, _messagingCtrl,
      _recurringPatternCtrl, _feedbackCtrl, _misjudgmentCtrl,
      _judgmentCloudedCtrl, _vulnerabilityCtrl, _jealousyCtrl, _boundaryCtrl,
      _attachmentHistoryCtrl, _misunderstandingCtrl, _partnerShouldKnowCtrl,
      _freeformProfileCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final OnboardingProfile updated = OnboardingProfile(
      displayName: _displayNameCtrl.text,
      selfDescription: _selfDescCtrl.text,
      coreTraits: _coreTraits,
      currentLifeTheme: _lifeThemeCtrl.text,
      datingChallenge: _datingChallengeCtrl.text,
      freeformAboutMe: _freeformAboutMeCtrl.text,
      goal: _goal,
      pacingPreference: _pacing,
      openingUpTime: _openingUpTimeCtrl.text,
      trustBuilder: _trustBuilderCtrl.text,
      relationshipExperience: _experience,
      recentDatingChallenge: _recentChallengeCtrl.text,
      values: _values,
      respectSignal: _respectSignalCtrl.text,
      dealbreakers: _dealbreakers,
      lifestyleFactors: _lifestyleFactors,
      potentialVsBehavior: _potentialVsBehaviorCtrl.text,
      communicationPreference: _commPref,
      showsInterestHow: _showsInterestCtrl.text,
      directVsSoft: _directVsSoftCtrl.text,
      messagingImportance: _messagingCtrl.text,
      ambiguityResponse: _ambiguity,
      conflictStyle: _conflict,
      blindSpots: _blindSpots,
      recurringPattern: _recurringPatternCtrl.text,
      feedbackFromCloseOnes: _feedbackCtrl.text,
      biggestMisjudgment: _misjudgmentCtrl.text,
      judgmentCloudedBy: _judgmentCloudedCtrl.text,
      beliefRightPersonFindsWay: _beliefRightPerson,
      beliefChemistryFeltFast: _beliefChemistry,
      beliefStrongAttractionIsSign: _beliefAttraction,
      beliefFeelsRightOrNot: _beliefFeelsRight,
      beliefFirstFeelingsAreTruth: _beliefFirstFeelings,
      beliefPotentialEqualsValue: _beliefPotential,
      beliefAmbiguityIsNormal: _beliefAmbiguity,
      beliefLoveOvercomesIssues: _beliefLoveOvercomes,
      alarmTriggers: _alarmTriggers,
      vulnerabilityArea: _vulnerabilityCtrl.text,
      assuranceNeed: _assurance,
      jealousyLevel: _jealousyCtrl.text,
      fatigueResponse: _fatigue,
      boundaryDifficulty: _boundaryCtrl.text,
      attachmentHistory: _attachmentHistoryCtrl.text,
      misunderstandingRisk: _misunderstandingCtrl.text,
      partnerShouldKnowEarly: _partnerShouldKnowCtrl.text,
      freeformForProfile: _freeformProfileCtrl.text,
      profileSummaryFeedback: _original.profileSummaryFeedback,
      highAssuranceThought: _original.highAssuranceThought,
      idealizationAwareness: _original.idealizationAwareness,
      firstRelationshipLearning: _original.firstRelationshipLearning,
      noSecondChanceBehavior: _original.noSecondChanceBehavior,
      fastAttachmentDriver: _original.fastAttachmentDriver,
      fastEliminationReason: _original.fastEliminationReason,
      ageConfirmed: _original.ageConfirmed,
      policyAccepted: _original.policyAccepted,
    );

    widget.controller.updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil güncellendi'),
        backgroundColor: t.softGreen.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.noir,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profili Düzenle',
          style: TextStyle(
            color: t.ivoryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: t.ivoryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Kaydet'),
              style: TextButton.styleFrom(
                foregroundColor: t.roseGold,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: <Widget>[
            // Premium header card
            GradientCard(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[t.roseGold, t.dustyRose],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _displayNameCtrl.text.isNotEmpty
                            ? _displayNameCtrl.text[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: t.noir,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _displayNameCtrl.text,
                          style: const TextStyle(
                            color: t.ivoryText,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cevaplarını istediğin zaman güncelleyebilirsin.\n'
                          'Profil skorların otomatik yeniden hesaplanır.',
                          style: TextStyle(
                            color: t.softText,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Section panels ──
            _buildSection(0, 'Kendini Anlat', Icons.person_outline_rounded,
                _buildSection1),
            _buildSection(1, 'İlişki Niyeti', Icons.favorite_outline_rounded,
                _buildSection2),
            _buildSection(2, 'Değerler', Icons.diamond_outlined,
                _buildSection3),
            _buildSection(3, 'İletişim Stili', Icons.chat_outlined,
                _buildSection4),
            _buildSection(4, 'Kör Noktalar', Icons.visibility_off_outlined,
                _buildSection5),
            _buildSection(5, 'İnanç Skalası', Icons.auto_awesome_outlined,
                _buildSection6),
            _buildSection(6, 'Güvenlik & Sınırlar', Icons.shield_outlined,
                _buildSection7),
            _buildSection(7, 'Açık Alan', Icons.edit_note_rounded,
                _buildSection8),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Expandable section builder
  // ═══════════════════════════════════════════════

  Widget _buildSection(
      int index, String title, IconData icon, Widget Function() builder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: t.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded[index]
              ? t.roseGold.withValues(alpha: 0.4)
              : t.smoky.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded[index] = !_expanded[index]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: <Widget>[
                  Icon(icon, color: t.roseGold, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: t.ivoryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded[index] ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: t.softText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: builder(),
            ),
            crossFadeState: _expanded[index]
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 1: Kendini Anlat
  // ═══════════════════════════════════════════════

  Widget _buildSection1() {
    return Column(
      children: <Widget>[
        _premiumField('İsmin', _displayNameCtrl),
        _premiumField('Kendini nasıl tanımlarsın?', _selfDescCtrl, lines: 3),
        _chipMultiSelect(
          'Temel karakter özelliklerin',
          <String>[
            'Empatik', 'Analitik', 'Duygusal', 'Bağımsız', 'Sadık',
            'Spontan', 'Kararlı', 'Sabırlı', 'Hırslı', 'Yaratıcı',
            'Maceracı', 'İçe dönük', 'Dışa dönük',
          ],
          _coreTraits,
          (List<String> v) => setState(() => _coreTraits = v),
        ),
        _premiumField('Hayatında şu an ana tema', _lifeThemeCtrl),
        _premiumField('Flört dünyasında en büyük zorluk', _datingChallengeCtrl,
            lines: 2),
        _premiumField('Serbest alan — kendin hakkında', _freeformAboutMeCtrl,
            lines: 3),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 2: İlişki Niyeti
  // ═══════════════════════════════════════════════

  Widget _buildSection2() {
    return Column(
      children: <Widget>[
        _enumSelect<RelationshipGoal>(
          'İlişki amacın',
          RelationshipGoal.values,
          _goal,
          (RelationshipGoal v) => setState(() => _goal = v),
        ),
        _enumSelect<PacingPreference>(
          'Tempo tercihin',
          PacingPreference.values,
          _pacing,
          (PacingPreference v) => setState(() => _pacing = v),
        ),
        _premiumField('Açılma süren', _openingUpTimeCtrl),
        _premiumField('Güven nasıl kurulur?', _trustBuilderCtrl, lines: 2),
        _enumSelect<RelationshipExperience>(
          'İlişki deneyimin',
          RelationshipExperience.values,
          _experience,
          (RelationshipExperience v) => setState(() => _experience = v),
        ),
        _premiumField('Son dönem flört zorluğu', _recentChallengeCtrl,
            lines: 2),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 3: Değerler
  // ═══════════════════════════════════════════════

  Widget _buildSection3() {
    return Column(
      children: <Widget>[
        _chipMultiSelect(
          'Temel değerlerin',
          <String>[
            'Dürüstlük', 'Sadakat', 'Saygı', 'Güven', 'İletişim',
            'Bağımsızlık', 'Tutku', 'Aile', 'Kariyer', 'Kişisel gelişim',
          ],
          _values,
          (List<String> v) => setState(() => _values = v),
        ),
        _premiumField('Saygı nasıl gösterilir?', _respectSignalCtrl,
            lines: 2),
        _chipMultiSelect(
          'Kesin vazgeçilmezler',
          <String>[
            'Yalan', 'Aldatma', 'Duygusal manipülasyon', 'İlgisizlik',
            'Kontrol', 'Empati eksikliği', 'Tutarsızlık', 'Saygısızlık',
            'İletişim eksikliği', 'Madde bağımlılığı',
          ],
          _dealbreakers,
          (List<String> v) => setState(() => _dealbreakers = v),
        ),
        _chipMultiSelect(
          'Yaşam tarzı faktörleri',
          <String>[
            'Sigara', 'Alkol', 'Spor', 'Seyahat', 'Evcil hayvan',
            'Çocuk isteme', 'Din/inanç', 'Kariyer odaklı',
          ],
          _lifestyleFactors,
          (List<String> v) => setState(() => _lifestyleFactors = v),
        ),
        _premiumField(
            'Potansiyel mi davranış mı?', _potentialVsBehaviorCtrl,
            lines: 2),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 4: İletişim
  // ═══════════════════════════════════════════════

  Widget _buildSection4() {
    return Column(
      children: <Widget>[
        _enumSelect<CommunicationPreference>(
          'İletişim tercihin',
          CommunicationPreference.values,
          _commPref,
          (CommunicationPreference v) => setState(() => _commPref = v),
        ),
        _premiumField('İlgiyi nasıl gösterirsin?', _showsInterestCtrl,
            lines: 2),
        _premiumField('Direkt mi yumuşak mı?', _directVsSoftCtrl),
        _premiumField('Mesajlaşma önemin', _messagingCtrl),
        _enumSelect<AmbiguityResponse>(
          'Belirsizlikte ne yaparsın?',
          AmbiguityResponse.values,
          _ambiguity,
          (AmbiguityResponse v) => setState(() => _ambiguity = v),
        ),
        _enumSelect<ConflictStyle>(
          'Çatışma stilin',
          ConflictStyle.values,
          _conflict,
          (ConflictStyle v) => setState(() => _conflict = v),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 5: Kör Noktalar
  // ═══════════════════════════════════════════════

  Widget _buildSection5() {
    return Column(
      children: <Widget>[
        _chipMultiSelect(
          'Kör noktaların',
          <String>[
            'Çok erken bağlanma', 'Kırmızı bayrakları görmezden gelme',
            'Fazla hızlı eleme', 'Kendi ihtiyacını geri plana atma',
            'Değiştirme isteği', 'Karşılaştırma', 'Aşırı test etme',
          ],
          _blindSpots,
          (List<String> v) => setState(() => _blindSpots = v),
        ),
        _premiumField('Tekrarlayan pattern', _recurringPatternCtrl, lines: 2),
        _premiumField(
            'Yakınların ne der?', _feedbackCtrl, lines: 2),
        _premiumField('En büyük yanlış değerlendirme', _misjudgmentCtrl,
            lines: 2),
        _premiumField(
            'Kararlarını ne bulandırır?', _judgmentCloudedCtrl, lines: 2),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 6: İnanç Skalası (1-7)
  // ═══════════════════════════════════════════════

  Widget _buildSection6() {
    return Column(
      children: <Widget>[
        _beliefSlider('Doğru kişi yolunu bulur',
            _beliefRightPerson, (int v) => setState(() => _beliefRightPerson = v)),
        _beliefSlider('Kimya hemen hissedilir',
            _beliefChemistry, (int v) => setState(() => _beliefChemistry = v)),
        _beliefSlider('Güçlü çekim bir işarettir',
            _beliefAttraction, (int v) => setState(() => _beliefAttraction = v)),
        _beliefSlider('Ya doğru hissedilir ya da değil',
            _beliefFeelsRight, (int v) => setState(() => _beliefFeelsRight = v)),
        _beliefSlider('İlk hisler gerçeği söyler',
            _beliefFirstFeelings, (int v) => setState(() => _beliefFirstFeelings = v)),
        _beliefSlider('Potansiyel = değer',
            _beliefPotential, (int v) => setState(() => _beliefPotential = v)),
        _beliefSlider('Belirsizlik normaldir',
            _beliefAmbiguity, (int v) => setState(() => _beliefAmbiguity = v)),
        _beliefSlider('Aşk sorunları aşar',
            _beliefLoveOvercomes, (int v) => setState(() => _beliefLoveOvercomes = v)),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 7: Güvenlik & Sınırlar
  // ═══════════════════════════════════════════════

  Widget _buildSection7() {
    return Column(
      children: <Widget>[
        _chipMultiSelect(
          'Alarm tetikleyicilerin',
          <String>[
            'İlgisizlik', 'Tutarsız mesajlar', 'Aşırı ilgi', 'Kontrolcülük',
            'Kıskançlık', 'Sınır ihlali', 'Duygusal uzaklık',
            'Başkalarıyla karşılaştırma',
          ],
          _alarmTriggers,
          (List<String> v) => setState(() => _alarmTriggers = v),
        ),
        _premiumField('Kırılganlık alanın', _vulnerabilityCtrl, lines: 2),
        _enumSelect<AssuranceNeed>(
          'Güvence ihtiyacın',
          AssuranceNeed.values,
          _assurance,
          (AssuranceNeed v) => setState(() => _assurance = v),
        ),
        _premiumField('Kıskançlık seviyesi', _jealousyCtrl),
        _enumSelect<FatigueResponse>(
          'Yorulunca ne yaparsın?',
          FatigueResponse.values,
          _fatigue,
          (FatigueResponse v) => setState(() => _fatigue = v),
        ),
        _premiumField('Sınır koyma zorluğu', _boundaryCtrl, lines: 2),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Section 8: Açık Alan
  // ═══════════════════════════════════════════════

  Widget _buildSection8() {
    return Column(
      children: <Widget>[
        _premiumField('Bağlanma geçmişin', _attachmentHistoryCtrl, lines: 3),
        _premiumField('Yanlış anlaşılma riski', _misunderstandingCtrl,
            lines: 2),
        _premiumField(
            'Partner erken bilmeli', _partnerShouldKnowCtrl, lines: 2),
        _premiumField('Serbest alan', _freeformProfileCtrl, lines: 3),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Reusable premium widgets
  // ═══════════════════════════════════════════════

  Widget _premiumField(String label, TextEditingController ctrl,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            maxLines: lines,
            style: const TextStyle(color: t.ivoryText, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: t.graphite,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: t.smoky.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: t.smoky.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: t.roseGold.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _enumSelect<T extends Enum>(
      String label, List<T> values, T current, ValueChanged<T> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((T v) {
              final bool selected = v == current;
              // Access .label via dynamic since all our enums have it
              final String enumLabel = (v as dynamic).label as String;
              return GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? t.roseGold.withValues(alpha: 0.15)
                        : t.graphite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? t.roseGold.withValues(alpha: 0.6)
                          : t.smoky.withValues(alpha: 0.4),
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: t.roseGold.withValues(alpha: 0.12),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    enumLabel,
                    style: TextStyle(
                      color: selected ? t.roseGold : t.softText,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _chipMultiSelect(String label, List<String> options,
      List<String> selected, ValueChanged<List<String>> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((String opt) {
              final bool isSelected = selected.contains(opt);
              return GestureDetector(
                onTap: () {
                  final List<String> updated = List<String>.from(selected);
                  if (isSelected) {
                    updated.remove(opt);
                  } else {
                    updated.add(opt);
                  }
                  onChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? t.roseGold.withValues(alpha: 0.15)
                        : t.graphite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? t.roseGold.withValues(alpha: 0.5)
                          : t.smoky.withValues(alpha: 0.3),
                    ),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: t.roseGold.withValues(alpha: 0.08),
                              blurRadius: 6,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.check_rounded,
                              size: 14, color: t.roseGold),
                        ),
                      Text(
                        opt,
                        style: TextStyle(
                          color: isSelected ? t.roseGold : t.softText,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _beliefSlider(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: t.softText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.roseGold.withValues(alpha: 0.15),
                  border: Border.all(
                      color: t.roseGold.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: t.roseGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: t.roseGold,
              inactiveTrackColor: t.smoky,
              thumbColor: t.roseGold,
              overlayColor: t.roseGold.withValues(alpha: 0.12),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: (double v) => onChanged(v.round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Katılmıyorum',
                  style: TextStyle(color: t.mutedText, fontSize: 10)),
              Text('Katılıyorum',
                  style: TextStyle(color: t.mutedText, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
