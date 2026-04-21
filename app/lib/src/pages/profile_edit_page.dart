import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import '../theme.dart' as t;
import '../widgets/app_widgets.dart';

// ═══════════════════════════════════════════════
//  Profile Edit — BuzdolabıŞef-style gradient cards
//  Swipe right to open each section
// ═══════════════════════════════════════════════

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late OnboardingProfile _original;

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

  // ── Section 6 ──
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
      // Derin soru alanlarını koru
      friendDescription: _original.friendDescription,
      threeExperiences: _original.threeExperiences,
      idealDay: _original.idealDay,
      valueConflict: _original.valueConflict,
      unheardFeeling: _original.unheardFeeling,
      stayedTooLong: _original.stayedTooLong,
      feelingsChanged: _original.feelingsChanged,
      safetyExperience: _original.safetyExperience,
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

  // ═══════════════════════════════════════════════
  //  Open section in a beautiful bottom sheet
  // ═══════════════════════════════════════════════

  void _openSectionSheet(
      String title, List<Color> gradient, Widget Function() builder) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (BuildContext context, ScrollController scrollCtrl) {
                return Container(
                  decoration: BoxDecoration(
                    color: t.noir,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(
                          color: gradient.first.withValues(alpha: 0.4),
                          width: 2),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      // Drag handle + gradient header
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              gradient.first.withValues(alpha: 0.2),
                              t.noir,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                        child: Column(
                          children: <Widget>[
                            // Drag bar
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: gradient.first.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: t.textOnDark,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: gradient.take(2).toList()),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'Tamam',
                                      style: TextStyle(
                                        color: t.noir,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          children: <Widget>[builder()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════
  //  Main Build — Gradient card list
  // ═══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: t.noir,
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: t.charcoal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: t.smoky.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: t.textOnDark, size: 18),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _displayNameCtrl.text,
                            style: const TextStyle(
                              color: t.textOnDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Profilini güncelle',
                            style: TextStyle(
                              color: t.softText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[t.roseGold, t.dustyRose],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: t.roseGold.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.check_rounded,
                                color: t.noir, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Kaydet',
                              style: TextStyle(
                                color: t.noir,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: t.charcoal,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: t.smoky.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.home_rounded,
                            color: t.textOnDark, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Description
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Cevaplarını istediğin zaman güncelleyebilirsin. '
                  'Profil skorların otomatik yeniden hesaplanır.',
                  style: TextStyle(
                    color: t.mutedText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // ── 8 Gradient Section Cards ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 1',
                    title: 'Kendini Anlat',
                    description:
                        'İsmin, karakter özelliklerin, hayat teman ve flört zorluğun.',
                    icon: Icons.person_outline_rounded,
                    gradientColors: SectionGradients.selfIntro,
                    onOpen: () => _openSectionSheet(
                        'Kendini Anlat', SectionGradients.selfIntro,
                        _buildSection1),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 2',
                    title: 'İlişki Niyeti',
                    description:
                        'Amacın, tempo tercihin, güven inşası ve deneyimlerin.',
                    icon: Icons.favorite_outline_rounded,
                    gradientColors: SectionGradients.relationship,
                    onOpen: () => _openSectionSheet(
                        'İlişki Niyeti', SectionGradients.relationship,
                        _buildSection2),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 3',
                    title: 'Değerler ve Vazgeçilmezler',
                    description:
                        'Temel değerlerin, kırmızı çizgilerin ve yaşam tarzın.',
                    icon: Icons.diamond_outlined,
                    gradientColors: SectionGradients.values,
                    onOpen: () => _openSectionSheet(
                        'Değerler', SectionGradients.values, _buildSection3),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 4',
                    title: 'İletişim ve Yakınlık',
                    description:
                        'İletişim tercihin, belirsizlik tepkin ve çatışma stilin.',
                    icon: Icons.chat_outlined,
                    gradientColors: SectionGradients.communication,
                    onOpen: () => _openSectionSheet('İletişim Stili',
                        SectionGradients.communication, _buildSection4),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 5',
                    title: 'Kör Noktalar',
                    description:
                        'Tekrarlayan örüntülerin, geri bildirimler ve yanlış değerlendirmelerin.',
                    icon: Icons.visibility_off_outlined,
                    gradientColors: SectionGradients.blindSpots,
                    onOpen: () => _openSectionSheet('Kör Noktalar',
                        SectionGradients.blindSpots, _buildSection5),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 6',
                    title: 'Romantik İnanç Skalası',
                    description:
                        'Aşka dair 8 temel inancını 1-7 arasında güncelle.',
                    icon: Icons.auto_awesome_outlined,
                    gradientColors: SectionGradients.beliefs,
                    onOpen: () => _openSectionSheet('İnanç Skalası',
                        SectionGradients.beliefs, _buildSection6),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 7',
                    title: 'Güvenlik ve Sınırlar',
                    description:
                        'Alarm tetikleyicilerin, kırılganlık alanın ve güvence ihtiyacın.',
                    icon: Icons.shield_outlined,
                    gradientColors: SectionGradients.safety,
                    onOpen: () => _openSectionSheet('Güvenlik & Sınırlar',
                        SectionGradients.safety, _buildSection7),
                  ),
                  FeatureGradientCard(
                    kicker: 'BÖLÜM 8',
                    title: 'Açık Profil Alanı',
                    description:
                        'Bağlanma geçmişin, partnerinin bilmesi gerekenler ve serbest alan.',
                    icon: Icons.edit_note_rounded,
                    gradientColors: SectionGradients.openField,
                    onOpen: () => _openSectionSheet('Açık Alan',
                        SectionGradients.openField, _buildSection8),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Section Builders (inside bottom sheets)
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
        _premiumField('Tanışma sürecinde en büyük zorluk', _datingChallengeCtrl,
            lines: 2),
        _premiumField('Serbest alan — kendin hakkında', _freeformAboutMeCtrl,
            lines: 3),
      ],
    );
  }

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

  Widget _buildSection5() {
    return Column(
      children: <Widget>[
        _chipMultiSelect(
          'Kör noktaların',
          <String>[
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
          _blindSpots,
          (List<String> v) => setState(() => _blindSpots = v),
        ),
        _premiumField('Tekrarlayan döngü', _recurringPatternCtrl, lines: 2),
        _premiumField('Yakınların ne der?', _feedbackCtrl, lines: 2),
        _premiumField('En büyük yanlış değerlendirme', _misjudgmentCtrl,
            lines: 2),
        _premiumField('Kararlarını ne bulandırır?', _judgmentCloudedCtrl,
            lines: 2),
      ],
    );
  }

  Widget _buildSection6() {
    return Column(
      children: <Widget>[
        _beliefSlider('Doğru kişi yolunu bulur', _beliefRightPerson,
            (int v) => setState(() => _beliefRightPerson = v)),
        _beliefSlider('Kimya hemen hissedilir', _beliefChemistry,
            (int v) => setState(() => _beliefChemistry = v)),
        _beliefSlider('Güçlü çekim bir işarettir', _beliefAttraction,
            (int v) => setState(() => _beliefAttraction = v)),
        _beliefSlider('Ya doğru hissedilir ya da değil', _beliefFeelsRight,
            (int v) => setState(() => _beliefFeelsRight = v)),
        _beliefSlider('İlk hisler gerçeği söyler', _beliefFirstFeelings,
            (int v) => setState(() => _beliefFirstFeelings = v)),
        _beliefSlider('Potansiyel = değer', _beliefPotential,
            (int v) => setState(() => _beliefPotential = v)),
        _beliefSlider('Belirsizlik normaldir', _beliefAmbiguity,
            (int v) => setState(() => _beliefAmbiguity = v)),
        _beliefSlider('Aşk sorunları aşar', _beliefLoveOvercomes,
            (int v) => setState(() => _beliefLoveOvercomes = v)),
      ],
    );
  }

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

  Widget _buildSection8() {
    return Column(
      children: <Widget>[
        _premiumField('Bağlanma geçmişin', _attachmentHistoryCtrl, lines: 3),
        _premiumField('Yanlış anlaşılma riski', _misunderstandingCtrl,
            lines: 2),
        _premiumField('Partner erken bilmeli', _partnerShouldKnowCtrl,
            lines: 2),
        _premiumField('Serbest alan', _freeformProfileCtrl, lines: 3),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  Premium form widgets
  // ═══════════════════════════════════════════════

  Widget _premiumField(String label, TextEditingController ctrl,
      {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            maxLines: lines,
            style: const TextStyle(color: t.textOnDark, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: t.charcoal,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: t.smoky.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((T v) {
              final bool selected = v == current;
              final String enumLabel = (v as dynamic).label as String;
              return GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? t.roseGold.withValues(alpha: 0.15)
                        : t.charcoal,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? t.roseGold.withValues(alpha: 0.6)
                          : t.smoky.withValues(alpha: 0.3),
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: t.roseGold.withValues(alpha: 0.12),
                              blurRadius: 10,
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
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label,
              style: TextStyle(
                  color: t.softText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((String opt) {
              final bool isSelected = selected.contains(opt);
              return GestureDetector(
                onTap: () {
                  final List<String> updated = List<String>.from(selected);
                  isSelected ? updated.remove(opt) : updated.add(opt);
                  onChanged(updated);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? t.roseGold.withValues(alpha: 0.15)
                        : t.charcoal,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? t.roseGold.withValues(alpha: 0.5)
                          : t.smoky.withValues(alpha: 0.3),
                    ),
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
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: t.softText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      t.roseGold.withValues(alpha: 0.2),
                      t.warmGold.withValues(alpha: 0.15),
                    ],
                  ),
                  border: Border.all(
                      color: t.roseGold.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: t.primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
