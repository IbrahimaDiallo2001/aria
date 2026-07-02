// ============================================================
//  Aria — Point d'entrée de l'application.
//
//  Structure du code :
//    main.dart            → démarrage + AriaApp (thème, langue)
//    i18n.dart            → traductions + dates localisées
//    theme.dart           → palette « Or & Nuit » + utilitaires
//    modeles.dart         → Pilier, Pratique, Projet, Tache…
//    projets_partage.dart → dialogue projet + notifs d'échéance
//    ecran_bienvenue.dart → page d'accueil (logo, citation)
//    ecran_accueil.dart   → écran principal (onglets)
//    ecran_pilier.dart    → détail d'un pilier
//    ecran_projet.dart    → détail d'un projet
//    notifs.dart          → service de notifications locales
//    widget_accueil.dart  → widget d'écran d'accueil Android
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ecran_bienvenue.dart';
import 'i18n.dart';
import 'notifs.dart';
import 'theme.dart';
import 'widget_accueil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotifsService.init();
  await WidgetAccueil.init();
  runApp(const AriaApp());
}

// ── L'application (thème + langue) ───────────────────────────
class AriaApp extends StatefulWidget {
  const AriaApp({super.key});
  @override
  State<AriaApp> createState() => _AriaAppState();
}

class _AriaAppState extends State<AriaApp> {
  ThemeMode _mode = ThemeMode.light;
  String _lang = 'fr';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      if (p.getString('aria_theme') == 'dark') _mode = ThemeMode.dark;
      _lang = p.getString('aria_lang') ?? 'fr';
    });
  }

  Future<void> _toggleTheme() async {
    setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
    HapticFeedback.lightImpact();
    final p = await SharedPreferences.getInstance();
    await p.setString('aria_theme', _mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> _changerLangue(String code) async {
    setState(() => _lang = code);
    final p = await SharedPreferences.getInstance();
    await p.setString('aria_lang', code);
  }

  ThemeData _theme(Brightness b) {
    final sombre = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: cOr, brightness: b).copyWith(
      primary: cOr,
      secondary: cOrClair,
      surface: sombre ? cNuitCarte : cJourCarte,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: b);
    return base.copyWith(
      scaffoldBackgroundColor: sombre ? cNuitFond : cJourFond,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: sombre ? cCreme : cEncreJour,
        displayColor: sombre ? cCreme : cEncreJour,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    gLang = _lang;
    return MaterialApp(
      title: 'Aria',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: _mode,
      builder: (context, child) => Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: EcranBienvenue(
        onToggleTheme: _toggleTheme,
        isDark: _mode == ThemeMode.dark,
        onChangeLang: _changerLangue,
      ),
    );
  }
}
