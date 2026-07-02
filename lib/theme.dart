// ============================================================
//  Aria — Palette « Or & Nuit », couleurs adaptatives,
//  et petits utilitaires visuels partagés.
// ============================================================
import 'package:flutter/material.dart';

// ── Palette « Or & Nuit » ────────────────────────────────────
const cOr = Color(0xFFD4AF37); // or principal (accent)
const cOrClair = Color(0xFFE6C063); // or clair (surbrillances)
// Nuit (thème sombre)
const cNuitFond = Color(0xFF0B0F1A);
const cNuitCarte = Color(0xFF151B2C);
const cNuitChamp = Color(0xFF10162A);
const cNuitBord = Color(0xFF27304A);
const cCreme = Color(0xFFF4EFE3); // texte clair
const cMutedNuit = Color(0xFF98A1B6);
// Jour (thème clair, crème doré)
const cJourFond = Color(0xFFF7F3EA);
const cJourCarte = Color(0xFFFFFDF8);
const cJourChamp = Color(0xFFF1EADB);
const cJourBord = Color(0xFFE8E1D0);
const cEncreJour = Color(0xFF1B2030); // texte foncé
const cMutedJour = Color(0xFF6C7180);

// ── Couleurs adaptatives ─────────────────────────────────────
Color cCard(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? cJourCarte : cNuitCarte;
Color cInkOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? cEncreJour : cCreme;
Color cMutedOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? cMutedJour : cMutedNuit;
Color cBorderOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? cJourBord : cNuitBord;
Color cFieldOf(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light ? cJourChamp : cNuitChamp;
List<BoxShadow> cardShadow(BuildContext c) =>
    Theme.of(c).brightness == Brightness.light
        ? [BoxShadow(color: const Color(0xFF3A2E12).withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 8))]
        : const [];

// Texte lisible (foncé/clair) posé sur une couleur d'accent.
Color surCouleur(Color c) =>
    c.computeLuminance() > 0.4 ? const Color(0xFF1B2030) : Colors.white;

// Transition « glissement + fondu » partagée entre les écrans.
Route slideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curved),
        child: FadeTransition(opacity: curved, child: child),
      );
    },
  );
}
