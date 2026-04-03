import 'package:flutter/material.dart';

import 'controller.dart';
import 'screens.dart';
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
