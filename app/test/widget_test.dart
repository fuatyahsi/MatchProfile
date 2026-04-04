import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:match_profile/src/app.dart';

void main() {
  testWidgets('critical onboarding to journal flow works', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MatchProfileApp());

    expect(find.byKey(const Key('welcome_start_button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('welcome_start_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('welcome_start_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('onboarding_name_field')),
      'Deniz',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('onboarding_age_checkbox')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_age_checkbox')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('onboarding_policy_checkbox')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_policy_checkbox')));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('onboarding_complete_button')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding_complete_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('new_reflection_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('reflection_context_field')),
      'First dinner date',
    );
    await tester.enterText(
      find.byKey(const Key('reflection_debrief_field')),
      'Nazikti, soru sordu ama bazen israrciydi ve biraz rahatsiz oldum.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('reflection_analyze_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reflection_analyze_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('insight_screen')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('go_to_validation_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('go_to_validation_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('validation_screen')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('validation_dogru_positive-curiosity')),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('validation_dogru_positive-curiosity')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('validation_missing_context_field')),
      'Ikincide ne kadar tutarli olacagini henuz bilmiyoruz.',
    );
    await tester.enterText(
      find.byKey(const Key('validation_least_accurate_field')),
      'Takip niyeti kismi erken olabilir.',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('save_to_journal_button')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save_to_journal_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('go_to_journal_button')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('go_to_journal_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('go_to_journal_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('journal_screen')), findsOneWidget);
    expect(find.text('First dinner date'), findsOneWidget);
  });
}
