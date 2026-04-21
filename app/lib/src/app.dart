import 'package:flutter/material.dart';

import 'controller.dart';
import 'home.dart';
import 'notification_service.dart';
import 'theme.dart';

class MatchProfileApp extends StatefulWidget {
  const MatchProfileApp({super.key});

  @override
  State<MatchProfileApp> createState() => _MatchProfileAppState();
}

class _MatchProfileAppState extends State<MatchProfileApp> {
  late final MatchProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MatchProfileController();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService.instance.initialize();
    final bool granted = await NotificationService.instance.requestPermission();
    if (granted) {
      await NotificationService.instance.scheduleDailyCheckInReminder();
      await NotificationService.instance.scheduleWeeklySummaryReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchProfile',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: MatchProfileHome(controller: _controller),
    );
  }
}
