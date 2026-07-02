// ============================================================
//  Aria — Écran de bienvenue (logo, citation du jour,
//  bouton « Commencer »).
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ecran_accueil.dart';
import 'i18n.dart';
import 'theme.dart';

const kCitationsBienvenue = [
  '« Le progrès, pas la perfection. Chaque petit pas compte. »',
  '« Deviens qui tu es, un jour à la fois. »',
  '« La discipline est le pont entre les rêves et la réalité. »',
  '« Chaque matin est une nouvelle page de ton histoire. »',
  "« Un petit pas aujourd'hui, un grand chemin demain. »",
];

class EcranBienvenue extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  final ValueChanged<String> onChangeLang;
  const EcranBienvenue({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
    required this.onChangeLang,
  });

  @override
  State<EcranBienvenue> createState() => _EcranBienvenueState();
}

class _EcranBienvenueState extends State<EcranBienvenue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fondu;
  late final Animation<Offset> _glisse;
  bool _demarre = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fondu = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _glisse = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _citationDuJour {
    final n = DateTime.now();
    final jourAnnee = n.difference(DateTime(n.year, 1, 1)).inDays;
    return kCitationsBienvenue[jourAnnee % kCitationsBienvenue.length];
  }

  void _commencer() {
    HapticFeedback.lightImpact();
    setState(() => _demarre = true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _demarre
          ? EcranAccueil(
              key: const ValueKey('accueil'),
              onToggleTheme: widget.onToggleTheme,
              isDark: widget.isDark,
              onChangeLang: widget.onChangeLang,
              onRetourBienvenue: () {
                setState(() => _demarre = false);
                _ctrl.forward(from: 0);
              },
            )
          : KeyedSubtree(
              key: const ValueKey('bienvenue'), child: _vueBienvenue(context)),
    );
  }

  Widget _vueBienvenue(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: sombre
                ? [cNuitFond, cNuitCarte]
                : [cJourFond, cJourCarte],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fondu,
            child: SlideTransition(
              position: _glisse,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    // Logo : anneau doré
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [cOrClair, cOr],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cOr.withValues(alpha: 0.35),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.self_improvement,
                          size: 64, color: surCouleur(cOr)),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Aria',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: cInkOf(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr("Ton chemin vers l'équilibre"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: cMutedOf(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Citation du jour
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cCard(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cBorderOf(context)),
                        boxShadow: cardShadow(context),
                      ),
                      child: Text(
                        tr(_citationDuJour),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          color: cInkOf(context),
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    // Bouton Commencer
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _commencer,
                        style: FilledButton.styleFrom(
                          backgroundColor: cOr,
                          foregroundColor: surCouleur(cOr),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        child: Text(
                          tr('Commencer'),
                          style: GoogleFonts.poppins(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
