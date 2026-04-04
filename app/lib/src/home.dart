import 'package:flutter/material.dart';

import 'controller.dart';
import 'pages/daily_pages.dart';
import 'pages/main_pages.dart';
import 'pages/reflection_pages.dart';
import 'pages/start_pages.dart';

class MatchProfileHome extends StatefulWidget {
  const MatchProfileHome({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  State<MatchProfileHome> createState() => _MatchProfileHomeState();
}

class _MatchProfileHomeState extends State<MatchProfileHome> {
  bool _showOnboarding = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? _) {
        if (!widget.controller.hasCompletedOnboarding) {
          if (_showOnboarding) {
            return OnboardingPage(
              controller: widget.controller,
              onComplete: () => setState(() {}),
            );
          }
          return WelcomePage(
            onStart: () => setState(() => _showOnboarding = true),
          );
        }

        return AppShell(controller: widget.controller);
      },
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.controller});

  final MatchProfileController controller;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardPage(controller: controller),
      DailyHubPage(controller: controller),
      JournalPage(controller: controller),
      PatternLabPage(controller: controller),
      SettingsPage(controller: controller),
    ];

    return Scaffold(
      body: SafeArea(child: pages[controller.selectedTab]),
      floatingActionButton:
          controller.selectedTab == 0 || controller.selectedTab == 2
          ? FloatingActionButton.extended(
              key: const Key('new_reflection_button'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        ReflectionComposerPage(controller: controller),
                  ),
                );
              },
              label: const Text('Yeni reflection'),
              icon: const Icon(Icons.graphic_eq_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: controller.selectedTab,
        onDestinationSelected: controller.switchTab,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Günlük',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_mosaic_outlined),
            selectedIcon: Icon(Icons.auto_awesome_mosaic_rounded),
            label: 'Pattern',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
