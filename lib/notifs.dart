// ============================================================
//  Aria — service de notifications locales (échéances projets)
//  Garde-fous : ne fait rien sur le web, tout est en try/catch
//  pour ne jamais faire planter l'app si une plateforme ne
//  supporte pas les notifications.
// ============================================================
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotifsService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _pret = false;

  static bool get pret => _pret;

  /// À appeler une fois au démarrage (après ensureInitialized).
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      final nom = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(nom));

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings =
          InitializationSettings(android: androidInit, iOS: iosInit);
      await _plugin.initialize(initSettings);
      _pret = true;
    } catch (_) {
      _pret = false;
    }
  }

  /// Demande les permissions (Android 13+, iOS, alarmes exactes).
  static Future<void> demanderPermission() async {
    if (kIsWeb || !_pret) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {
      // On ignore : sans permission, la planification échouera silencieusement.
    }
  }

  /// Planifie (ou reprogramme) une notification unique à [quand].
  static Future<void> planifier({
    required int id,
    required String titre,
    required String corps,
    required DateTime quand,
  }) async {
    if (kIsWeb || !_pret) return;
    try {
      await annuler(id);
      final cible = tz.TZDateTime.from(quand, tz.local);
      if (cible.isBefore(tz.TZDateTime.now(tz.local))) return; // déjà passé
      await _plugin.zonedSchedule(
        id,
        titre,
        corps,
        cible,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aria_echeances',
            'Échéances de projets',
            channelDescription: 'Rappels des échéances de projets Aria',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Silencieux : ne jamais faire planter l'app pour une notif.
    }
  }

  static Future<void> annuler(int id) async {
    if (kIsWeb || !_pret) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  // Ids réservés aux rappels quotidiens (hors plage des id de projets).
  static const int _idRappelHabitudes = 987654321;
  static const int _idRappelJournal = 987654322;

  /// Planifie une notification quotidienne répétée à [heure]:[minute].
  static Future<void> _planifierQuotidien({
    required int id,
    required String canalId,
    required String canalNom,
    required String canalDesc,
    required int heure,
    required int minute,
    required String titre,
    required String corps,
  }) async {
    if (kIsWeb || !_pret) return;
    try {
      await _plugin.cancel(id);
      final now = tz.TZDateTime.now(tz.local);
      var quand = tz.TZDateTime(tz.local, now.year, now.month, now.day, heure, minute);
      if (!quand.isAfter(now)) quand = quand.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id,
        titre,
        corps,
        quand,
        NotificationDetails(
          android: AndroidNotificationDetails(
            canalId,
            canalNom,
            channelDescription: canalDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // répétition quotidienne
      );
    } catch (_) {}
  }

  /// Rappel quotidien des pratiques.
  static Future<void> planifierRappelQuotidien({
    required int heure,
    required int minute,
    required String titre,
    required String corps,
  }) =>
      _planifierQuotidien(
        id: _idRappelHabitudes,
        canalId: 'aria_habitudes',
        canalNom: "Rappels d'habitudes",
        canalDesc: 'Rappel quotidien pour tes pratiques Aria',
        heure: heure,
        minute: minute,
        titre: titre,
        corps: corps,
      );

  static Future<void> annulerRappelQuotidien() async {
    if (kIsWeb || !_pret) return;
    try {
      await _plugin.cancel(_idRappelHabitudes);
    } catch (_) {}
  }

  /// Rappel quotidien du journal du soir.
  static Future<void> planifierRappelJournal({
    required int heure,
    required int minute,
    required String titre,
    required String corps,
  }) =>
      _planifierQuotidien(
        id: _idRappelJournal,
        canalId: 'aria_journal',
        canalNom: 'Rappel du journal',
        canalDesc: 'Rappel du soir pour le journal Aria',
        heure: heure,
        minute: minute,
        titre: titre,
        corps: corps,
      );

  static Future<void> annulerRappelJournal() async {
    if (kIsWeb || !_pret) return;
    try {
      await _plugin.cancel(_idRappelJournal);
    } catch (_) {}
  }
}
