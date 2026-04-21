import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Bildirim servisi — günlük hatırlatmalar ve profil bazlı uyarılar
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ══════════════════════════════════════════════
  //  Başlatma
  // ══════════════════════════════════════════════

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // ══════════════════════════════════════════════
  //  İzin İsteme
  // ══════════════════════════════════════════════

  Future<bool> requestPermission() async {
    // Android 13+ izin kontrolü
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS izin kontrolü
    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final bool? granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // ══════════════════════════════════════════════
  //  Bildirim Kanalları
  // ══════════════════════════════════════════════

  static const String _dailyChannelId = 'daily_reminder';
  static const String _dailyChannelName = 'Günlük Hatırlatma';
  static const String _dailyChannelDesc =
      'Günlük kayıt ve yansıtma hatırlatmaları';

  static const String _insightChannelId = 'insight_alert';
  static const String _insightChannelName = 'İçgörü Bildirimi';
  static const String _insightChannelDesc =
      'Profil bazlı içgörü ve döngü uyarıları';

  static const String _weeklyChannelId = 'weekly_summary';
  static const String _weeklyChannelName = 'Haftalık Özet';
  static const String _weeklyChannelDesc = 'Haftalık ruh hali ve döngü özeti';

  // ══════════════════════════════════════════════
  //  Günlük Kayıt Hatırlatması
  // ══════════════════════════════════════════════

  /// Her gün belirlenen saatte kayıt hatırlatması planlar
  Future<void> scheduleDailyCheckInReminder({
    TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 0),
  }) async {
    await _cancelNotification(_NotificationId.dailyCheckIn);

    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // Eğer bugünkü saat geçtiyse yarına planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const List<String> messages = <String>[
      'Bugün nasıl hissediyorsun? Günlük kaydını oluştur.',
      'Günlük kaydın seni bekliyor. Birkaç dakika kendine ayır.',
      'Bugün ne yaşadın? Kısa bir kayıt, büyük bir farkındalık.',
      'Ruh halini kaydet — verinin biriktikçe içgörülerin derinleşir.',
      'Kendini tanımanın en kolay yolu: her gün bir kayıt.',
      'Bugünkü duyguların yarınki kararlarını aydınlatır.',
    ];
    final String message = messages[now.day % messages.length];

    await _plugin.periodicallyShow(
      _NotificationId.dailyCheckIn,
      'Günlük Kayıt Zamanı',
      message,
      RepeatInterval.daily,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          channelDescription: _dailyChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Haftalık Özet Bildirimi
  // ══════════════════════════════════════════════

  /// Her pazar günü haftalık özet bildirimi planlar
  Future<void> scheduleWeeklySummaryReminder() async {
    await _cancelNotification(_NotificationId.weeklySummary);

    await _plugin.periodicallyShow(
      _NotificationId.weeklySummary,
      'Haftalık Özetin Hazır',
      'Bu haftanın ruh hali, tetikleyici ve döngü analizi seni bekliyor.',
      RepeatInterval.weekly,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _weeklyChannelId,
          _weeklyChannelName,
          channelDescription: _weeklyChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Anlık İçgörü Bildirimi
  // ══════════════════════════════════════════════

  /// Tetikleyici döngüsü veya önemli profil geri bildirimi olduğunda
  Future<void> showInsightNotification({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      _NotificationId.insightAlert,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _insightChannelId,
          _insightChannelName,
          channelDescription: _insightChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Kayıt Serisi Tebrik Bildirimi
  // ══════════════════════════════════════════════

  /// Kayıt serisi milestonelarında tebrik bildirimi
  Future<void> showStreakCelebration(int streakDays) async {
    String message;
    if (streakDays >= 30) {
      message = '$streakDays gün üst üste kayıt! Olağanüstü bir tutarlılık. Kendini tanıma yolculuğun derinleşiyor.';
    } else if (streakDays >= 14) {
      message = '$streakDays gün üst üste! Verilerinde anlamlı döngüler ortaya çıkmaya başladı.';
    } else if (streakDays >= 7) {
      message = 'Bir hafta boyunca her gün kayıt yaptın! İlk haftalık özetin hazır.';
    } else if (streakDays >= 3) {
      message = '$streakDays gündür kayıt yapıyorsun. Güzel bir başlangıç!';
    } else {
      return; // 3 günden az seride bildirim gösterme
    }

    await _plugin.show(
      _NotificationId.streakCelebration,
      'Kayıt Serisi: $streakDays Gün',
      message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          channelDescription: _dailyChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Döngü Uyarı Bildirimi
  // ══════════════════════════════════════════════

  /// Tekrar eden bir tetikleyici veya kalıp tespit edildiğinde
  Future<void> showPatternAlert({
    required String patternName,
    required int occurrenceCount,
  }) async {
    await _plugin.show(
      _NotificationId.patternAlert,
      'Döngü Uyarısı',
      '"$patternName" son 7 günde $occurrenceCount kez tekrarlandı. Bu kalıba birlikte bakalım.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _insightChannelId,
          _insightChannelName,
          channelDescription: _insightChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            '"$patternName" son 7 günde $occurrenceCount kez tekrarlandı. Bu kalıba birlikte bakalım.',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  Tümünü İptal
  // ══════════════════════════════════════════════

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelDailyReminder() async {
    await _cancelNotification(_NotificationId.dailyCheckIn);
  }

  // ══════════════════════════════════════════════
  //  Yardımcılar
  // ══════════════════════════════════════════════

  Future<void> _cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tıklandığında ilgili sayfaya yönlendirme
    // Bu kısım navigator key ile genişletilebilir
    debugPrint('Bildirime tıklandı: ${response.payload}');
  }
}

/// Bildirim kimlikleri
abstract class _NotificationId {
  static const int dailyCheckIn = 1001;
  static const int weeklySummary = 1002;
  static const int insightAlert = 1003;
  static const int streakCelebration = 1004;
  static const int patternAlert = 1005;
}
