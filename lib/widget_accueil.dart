// ============================================================
//  Aria — pont vers le widget d'écran d'accueil (home_widget).
//  Garde-fous : ne fait rien sur le web, tout en try/catch.
// ============================================================
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

class WidgetAccueil {
  // App Group iOS (à créer dans Xcode, identique côté extension widget).
  static const String _appGroupId = 'group.com.ibrahimadiallo.aria';
  // Nom de la classe AppWidgetProvider (Android) et du kind (iOS).
  static const String _androidName = 'AriaWidgetProvider';
  static const String _iOSName = 'AriaWidget';

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
    } catch (_) {}
  }

  /// Met à jour les données affichées par le widget et le rafraîchit.
  static Future<void> maj({
    required int pct,
    required String equilibre,
    required String projets,
  }) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.saveWidgetData<int>('pct', pct);
      await HomeWidget.saveWidgetData<String>('equilibre', equilibre);
      await HomeWidget.saveWidgetData<String>('projets', projets);
      await HomeWidget.updateWidget(androidName: _androidName, iOSName: _iOSName);
    } catch (_) {}
  }
}
