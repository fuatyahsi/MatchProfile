import 'package:flutter/material.dart';

import 'src/ai/ai_config.dart';
import 'src/app.dart';

Future<void> main() async {
  // shared_preferences plugin'i MethodChannel üzerinden çalışır —
  // runApp'ten önce plugin binding'inin hazır olması gerekir.
  WidgetsFlutterBinding.ensureInitialized();

  // Kaydedilmiş API anahtarlarını RAM'e yükle. Hata olsa bile
  // UI açılmalı; AIConfig.loadFromStorage() kendi içinde try/catch yapıyor.
  await AIConfig.instance.loadFromStorage();

  runApp(const MatchProfileApp());
}
