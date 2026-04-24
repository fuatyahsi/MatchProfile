import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_profile/src/controller.dart';
import 'package:match_profile/src/home.dart';
import 'package:match_profile/src/models.dart';
import 'package:match_profile/src/theme.dart';

void main() {
  testWidgets('welcome start opens chat onboarding', (
    WidgetTester tester,
  ) async {
    Future<void> pumpUi() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    final MatchProfileController controller = MatchProfileController();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MatchProfileHome(controller: controller),
      ),
    );
    await pumpUi();

    expect(find.byKey(const Key('welcome_start_button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('welcome_start_button')));
    await pumpUi();
    await tester.tap(find.byKey(const Key('welcome_start_button')));
    await pumpUi();

    expect(find.text('Hizli baslangic'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('critical reflection to journal flow works', (
    WidgetTester tester,
  ) async {
    Future<void> pumpUi() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    final MatchProfileController controller = MatchProfileController()
      ..completeOnboarding(_sampleProfile());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: MatchProfileHome(controller: controller),
      ),
    );
    await pumpUi();

    expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('new_reflection_button')));
    await pumpUi();

    final Iterable<Element> textFields = tester.elementList(find.byType(TextField));
    await tester.enterText(
      find.byWidgetPredicate((Widget w) => w == textFields.elementAt(0).widget),
      'First dinner date',
    );
    await tester.enterText(
      find.byWidgetPredicate((Widget w) => w == textFields.elementAt(1).widget),
      'Mekana girdiğinde çok rahattı, çok nazildi, bolca soru sordu. Gözlerini kaçırmadı.',
    );
    await tester.enterText(
      find.byWidgetPredicate((Widget w) => w == textFields.elementAt(2).widget),
      'Bana eski ilişkilerinden bahsederken fedakarlık yapmam dedi. Bu cümle bende bir duraksamaya yol açtı. Ne demek istedi tam anlamadım.',
    );
    await tester.enterText(
      find.byWidgetPredicate((Widget w) => w == textFields.elementAt(3).widget),
      'Şeffaflık konusunda doğrudan konuşmadı ama dürüst bir intiba verdi. Bazı sorularımı geçiştirdiğini hissettim, değerlerimiz uyuşmuyor mu emin olamadım.',
    );
    await tester.enterText(
      find.byWidgetPredicate((Widget w) => w == textFields.elementAt(4).widget),
      'Yanındayken hem heyecanlı hem de biraz tetikte hissettim. Rahattım diyemem ama sıkıldığımı da söyleyemem. Genel bir gerginlik hakimdi.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('reflection_analyze_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUi();
    await tester.tap(find.byKey(const Key('reflection_analyze_button')));
    await pumpUi();

    expect(find.byKey(const Key('insight_screen')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('go_to_validation_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUi();
    await tester.tap(find.byKey(const Key('go_to_validation_button')));
    await pumpUi();

    expect(find.byKey(const Key('validation_screen')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('validation_dogru_positive-curiosity')),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUi();
    await tester.tap(find.byKey(const Key('validation_dogru_positive-curiosity')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('save_to_journal_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await pumpUi();
    await tester.tap(find.byKey(const Key('save_to_journal_button')));
    await pumpUi();
    expect(controller.journalEntries, isNotEmpty);
    expect(controller.latestEntry?.title, 'First dinner date');
    expect(controller.latestEntry?.report.summary, isNotEmpty);
  });
}

OnboardingProfile _sampleProfile() {
  return OnboardingProfile(
    displayName: 'Deniz',
    selfDescription: 'Duygusal farkindaligi yuksek, secici ve netlik arayan biriyim.',
    coreTraits: <String>['Analitik', 'Duygusal', 'Secici'],
    currentLifeTheme: 'Yeni düzen kurma',
    datingChallenge: 'Hoslandigim kisilerde potansiyel ile gercegi ayirmakta zorlaniyorum.',
    freeformAboutMe: 'Daha yavas aciliyorum ama derin bag ariyorum.',
    goal: RelationshipGoal.serious,
    pacingPreference: PacingPreference.balanced,
    openingUpTime: 'Guven gordukce acilirim.',
    trustBuilder: 'Tutarlilik ve net iletisim.',
    relationshipExperience: RelationshipExperience.several,
    recentDatingChallenge: 'Belirsizlik uzadiginda fazla dusunuyorum.',
    values: <String>['Dürüstlük', 'Net konuşmak', 'Saygılı davranmak'],
    respectSignal: 'Alanima ve duygularima dikkat edilmesi.',
    dealbreakers: <String>['Manipülasyon', 'Tutarsızlık'],
    lifestyleFactors: <String>['Günlük düzeni', 'İşin hayatında ne kadar önde olduğu'],
    potentialVsBehavior: 'Bugünkü davranışı',
    communicationPreference: CommunicationPreference.balancedRegular,
    showsInterestHow: 'Soru sorarak ve zaman ayirarak.',
    directVsSoft: 'Doğrudan ve net',
    messagingImportance: 'Duzenli ama abartisiz mesajlasma.',
    ambiguityResponse: AmbiguityResponse.overthink,
    conflictStyle: ConflictStyle.talkItOut,
    blindSpots: <String>['Red flag\'i rasyonalize etme'],
    recurringPattern: 'Ilk iyi izlenimden sonra fazla kredi vermek.',
    feedbackFromCloseOnes: 'Bazen fazla sans veriyorum.',
    biggestMisjudgment: 'Tutarliligi karakter sanmak.',
    judgmentCloudedBy: 'Yuksek cekim ve umut.',
    beliefRightPersonFindsWay: 5,
    beliefChemistryFeltFast: 4,
    beliefStrongAttractionIsSign: 5,
    beliefFeelsRightOrNot: 4,
    beliefFirstFeelingsAreTruth: 3,
    beliefPotentialEqualsValue: 2,
    beliefAmbiguityIsNormal: 3,
    beliefLoveOvercomesIssues: 2,
    alarmTriggers: <String>['Tutarsızlık', 'Manipülasyon'],
    vulnerabilityArea: 'Yanlış kişiyi seçme',
    assuranceNeed: AssuranceNeed.medium,
    jealousyLevel: 'Düşük',
    fatigueResponse: FatigueResponse.overAnalyze,
    boundaryDifficulty: 'Gecikmeli sinyal fark ettigimde gec reaksiyon verebiliyorum.',
    attachmentHistory: 'Gecmis deneyimlerim beni daha secici yapti.',
    misunderstandingRisk: 'Disaridan cok soguk gorunebilirim.',
    partnerShouldKnowEarly: 'Netlik ve saygi benim icin cok onemli.',
    freeformForProfile: 'Sorulmayan ama onemli: duygusal emek tek tarafli olunca hizla geri cekilirim.',
    profileSummaryFeedback: 'Genel olarak dogru.',
    ageConfirmed: true,
    policyAccepted: true,
  );
}
