// ============================================================
//  Aria — Écran principal : onglets Accueil / Projets /
//  Journal / Progrès, réglages, sauvegarde et historique.
// ============================================================
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ecran_confidentialite.dart';

import 'ecran_pilier.dart';
import 'ecran_projet.dart';
import 'i18n.dart';
import 'modeles.dart';
import 'notifs.dart';
import 'projets_partage.dart';
import 'theme.dart';
import 'widget_accueil.dart';

class EcranAccueil extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  final ValueChanged<String> onChangeLang;
  final VoidCallback? onRetourBienvenue;
  const EcranAccueil({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
    required this.onChangeLang,
    this.onRetourBienvenue,
  });

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  int _onglet = 0;
  final List<int> _pileOnglets = []; // pour le bouton « retour »
  late List<List<Pratique>> _pratiques; // modifiables par l'utilisateur
  late List<List<bool>> _etats;
  List<Projet> _projets = [];
  String _triProjets = 'defaut'; // defaut | echeance | progression | nom
  bool _rappelActif = false;
  int _rappelH = 8;
  int _rappelM = 0;
  List<Map<String, dynamic>> _historique = []; // {d:'YYYY-MM-DD', f:int, t:int}
  int _fenetreHisto = 7; // 7 ou 30 jours pour le graphique
  // Journal : une entrée par jour {d:'YYYY-MM-DD', appris, g1, g2, g3}
  List<Map<String, dynamic>> _journalEntrees = [];

  final _ctrlAppris = TextEditingController();
  final _ctrlGrat1 = TextEditingController();
  final _ctrlGrat2 = TextEditingController();
  final _ctrlGrat3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pratiques = [for (final p in piliers) List<Pratique>.from(p.pratiques)];
    _etats = [for (final pr in _pratiques) List<bool>.filled(pr.length, false)];
    _charger();
    NotifsService.demanderPermission();
  }

  @override
  void dispose() {
    _ctrlAppris.dispose();
    _ctrlGrat1.dispose();
    _ctrlGrat2.dispose();
    _ctrlGrat3.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < piliers.length; i++) {
      // Pratiques personnalisées
      final titres = prefs.getStringList('aria_prat_titres_$i');
      final sous = prefs.getStringList('aria_prat_sous_$i');
      if (titres != null && sous != null && titres.length == sous.length) {
        _pratiques[i] = [
          for (int k = 0; k < titres.length; k++) Pratique(titres[k], sous[k])
        ];
      }
      // Coches (alignées sur les pratiques)
      final etat = prefs.getStringList('aria_etat_$i');
      if (etat != null && etat.length == _pratiques[i].length) {
        _etats[i] = [for (final e in etat) e == '1'];
      } else {
        _etats[i] = List<bool>.filled(_pratiques[i].length, false);
      }
    }
    await _chargerJournal(prefs);
    // Projets
    final bruts = prefs.getStringList('aria_projets') ?? [];
    _projets = [
      for (final s in bruts)
        Projet.fromJson(Map<String, dynamic>.from(jsonDecode(s) as Map))
    ];
    _triProjets = prefs.getString('aria_projets_tri') ?? 'defaut';
    _rappelActif = prefs.getBool('aria_rappel_actif') ?? false;
    _rappelH = prefs.getInt('aria_rappel_h') ?? 8;
    _rappelM = prefs.getInt('aria_rappel_m') ?? 0;
    _historique = _lireHistorique(prefs);
    await _verifierJour(prefs); // remet à zéro + archive si nouveau jour
    if (mounted) setState(() {});
    // Reprogramme les notifications des échéances à venir.
    for (final p in _projets) {
      planifierNotifProjet(p);
    }
    _appliquerRappel();
    _majWidget();
  }

  // ── Réinitialisation quotidienne + séries ──────────────────
  String _cleJour(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Map<String, dynamic>> _lireHistorique(SharedPreferences prefs) {
    final bruts = prefs.getStringList('aria_historique') ?? [];
    return [
      for (final s in bruts) Map<String, dynamic>.from(jsonDecode(s) as Map)
    ];
  }

  Future<void> _verifierJour(SharedPreferences prefs) async {
    final aujourdhui = _cleJour(DateTime.now());
    final stocke = prefs.getString('aria_jour');
    if (stocke == null) {
      await prefs.setString('aria_jour', aujourdhui);
      return;
    }
    if (stocke == aujourdhui) return;

    // Nouveau jour : on archive le jour précédent (état actuellement chargé)…
    final faits = _totalFaits;
    final total = _totalPratiques;
    if (total > 0) {
      _historique.removeWhere((e) => e['d'] == stocke);
      _historique.add({'d': stocke, 'f': faits, 't': total});
      while (_historique.length > 120) {
        _historique.removeAt(0);
      }
      await prefs.setStringList(
          'aria_historique', [for (final e in _historique) jsonEncode(e)]);
    }
    // …puis on remet les coches à zéro pour la nouvelle journée.
    for (int i = 0; i < _etats.length; i++) {
      _etats[i] = List<bool>.filled(_pratiques[i].length, false);
    }
    await _sauvegarderCoches();
    await prefs.setString('aria_jour', aujourdhui);
  }

  // Série : nombre de jours « pleins » (100%) consécutifs.
  int get _serie {
    final pleins = <String>{};
    for (final e in _historique) {
      final f = (e['f'] ?? 0) as int;
      final t = (e['t'] ?? 0) as int;
      if (t > 0 && f >= t) pleins.add(e['d'] as String);
    }
    final maintenant = DateTime.now();
    var jour = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final todayPlein = _totalPratiques > 0 && _totalFaits >= _totalPratiques;
    int serie = 0;
    if (todayPlein) serie = 1;
    jour = jour.subtract(const Duration(days: 1));
    while (pleins.contains(_cleJour(jour))) {
      serie++;
      jour = jour.subtract(const Duration(days: 1));
    }
    return serie;
  }

  // Félicitation quand la journée devient pleine (une fois par jour).
  Future<void> _verifierJourneePleine() async {
    if (_totalPratiques == 0 || _totalFaits < _totalPratiques) return;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _cleJour(DateTime.now());
    if (prefs.getString('aria_fete_jour') == todayKey) return;
    await prefs.setString('aria_fete_jour', todayKey);
    if (!mounted) return;
    _montrerFete();
  }

  void _montrerFete() {
    final n = _serie;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'fete',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final t = Curves.easeOutBack.transform(anim.value.clamp(0.0, 1.0));
        return Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Center(
            child: Transform.scale(
              scale: 0.7 + 0.3 * t,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 44),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B2236), Color(0xFF2B3352)]),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: cOr.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: const Color(0xFF0B0F1A).withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 16))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 46)),
                    const SizedBox(height: 10),
                    Text(tr('Journée pleine !'),
                        style: const TextStyle(color: cCreme, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(tr('Toutes tes pratiques sont accomplies.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cCreme.withValues(alpha: 0.85), fontSize: 13)),
                    if (n > 0) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: cOr.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cOr.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '🔥 $n ${n == 1 ? tr("jour d'affilée") : tr("jours d'affilée")}',
                          style: const TextStyle(color: cOrClair, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: cOr, foregroundColor: const Color(0xFF1B2030)),
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(tr('Continuer')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmtHeure(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  void _appliquerRappel() {
    if (_rappelActif) {
      NotifsService.planifierRappelQuotidien(
        heure: _rappelH,
        minute: _rappelM,
        titre: '🌱 Aria',
        corps: tr("C'est le moment de tes pratiques du jour."),
      );
    } else {
      NotifsService.annulerRappelQuotidien();
    }
  }

  Future<void> _toggleRappel(bool v) async {
    setState(() => _rappelActif = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aria_rappel_actif', v);
    _appliquerRappel();
  }

  Future<void> _choisirHeureRappel() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _rappelH, minute: _rappelM),
    );
    if (t == null) return;
    setState(() {
      _rappelH = t.hour;
      _rappelM = t.minute;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('aria_rappel_h', _rappelH);
    await prefs.setInt('aria_rappel_m', _rappelM);
    if (_rappelActif) _appliquerRappel();
  }

  // ── Export / Import (sauvegarde JSON) ──────────────────────
  Future<void> _exporter() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final k in prefs.getKeys()) {
      if (k.startsWith('aria_')) data[k] = prefs.get(k);
    }
    final json = const JsonEncoder.withIndent('  ')
        .convert({'app': 'aria', 'v': 1, 'data': data});
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Ouvre la feuille de partage du système avec un fichier .json
      // (à enregistrer dans Fichiers, envoyer par e-mail, Drive…).
      final nom = 'aria_sauvegarde_${_cleJour(DateTime.now())}.json';
      await SharePlus.instance.share(ShareParams(
        files: [XFile.fromData(utf8.encode(json), mimeType: 'application/json')],
        fileNameOverrides: [nom],
        subject: 'Aria — ${tr('Exporter mes données')}',
      ));
    } catch (_) {
      // Repli (plateforme sans partage) : copie dans le presse-papiers.
      await Clipboard.setData(ClipboardData(text: json));
      messenger.showSnackBar(SnackBar(
          content: Text(tr('Copié !')), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _importer() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Importer des données')),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: ctrl,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: tr('Colle ici ta sauvegarde…'),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Importer'))),
        ],
      ),
    );
    if (ok == true) {
      try {
        final parsed = jsonDecode(ctrl.text) as Map<String, dynamic>;
        final data = Map<String, dynamic>.from(parsed['data'] as Map);
        final prefs = await SharedPreferences.getInstance();
        for (final k in prefs.getKeys().where((k) => k.startsWith('aria_')).toList()) {
          await prefs.remove(k);
        }
        for (final e in data.entries) {
          final v = e.value;
          if (v is bool) {
            await prefs.setBool(e.key, v);
          } else if (v is int) {
            await prefs.setInt(e.key, v);
          } else if (v is double) {
            await prefs.setDouble(e.key, v);
          } else if (v is String) {
            await prefs.setString(e.key, v);
          } else if (v is List) {
            await prefs.setStringList(e.key, [for (final x in v) x.toString()]);
          }
        }
        await _charger();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('Import réussi. Redémarre pour le thème/la langue.')),
            behavior: SnackBarBehavior.floating));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(tr('Fichier invalide.')), behavior: SnackBarBehavior.floating));
        }
      }
    }
    ctrl.dispose();
  }

  void _ouvrirReglages() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(tr('Réglages'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_active_rounded),
                title: Text(tr('Rappel quotidien')),
                subtitle: Text(_rappelActif ? _fmtHeure(_rappelH, _rappelM) : tr('Désactivé')),
                value: _rappelActif,
                onChanged: (v) async {
                  await _toggleRappel(v);
                  setSheet(() {});
                },
              ),
              if (_rappelActif)
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: Text(tr('Heure du rappel')),
                  trailing: Text(_fmtHeure(_rappelH, _rappelM),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () async {
                    await _choisirHeureRappel();
                    setSheet(() {});
                  },
                ),
              const Divider(height: 8),
              ListTile(
                leading: const Icon(Icons.upload_rounded),
                title: Text(tr('Exporter mes données')),
                onTap: () {
                  Navigator.pop(ctx);
                  _exporter();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_rounded),
                title: Text(tr('Importer des données')),
                onTap: () {
                  Navigator.pop(ctx);
                  _importer();
                },
              ),
              const Divider(height: 8),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(tr('À propos')),
                onTap: () {
                  Navigator.pop(ctx);
                  _ouvrirAPropos();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── À propos ───────────────────────────────────────────────
  static const String _versionApp = '1.0.0';

  void _ouvrirAPropos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cOrClair, cOr],
                ),
                boxShadow: [
                  BoxShadow(color: cOr.withValues(alpha: 0.35), blurRadius: 24),
                ],
              ),
              child: Icon(Icons.self_improvement, size: 40, color: surCouleur(cOr)),
            ),
            const SizedBox(height: 14),
            Text('Aria',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: cInkOf(ctx))),
            const SizedBox(height: 2),
            Text(tr("Ton chemin vers l'équilibre"),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: cMutedOf(ctx))),
            const SizedBox(height: 14),
            Text('${tr('Version')} $_versionApp',
                style: TextStyle(fontSize: 12.5, color: cMutedOf(ctx))),
            const SizedBox(height: 4),
            Text('${tr('Créée par')} Ibrahima Diallo',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: cInkOf(ctx))),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cOr.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 15, color: cOr),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tr('Tes données restent uniquement sur ton appareil.'),
                      style: TextStyle(fontSize: 11.5, color: cInkOf(ctx)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                    context, slideRoute(const EcranConfidentialite()));
              },
              icon: const Icon(Icons.privacy_tip_outlined, size: 16),
              label: Text(tr('Politique de confidentialité'),
                  style: const TextStyle(fontSize: 13)),
            ),
            Text('© 2026 Ibrahima Diallo',
                style: TextStyle(fontSize: 11, color: cMutedOf(ctx))),
          ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(tr('Fermer'))),
        ],
      ),
    );
  }

  Future<void> _sauvegarderProjets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'aria_projets', [for (final p in _projets) jsonEncode(p.toJson())]);
    _majWidget();
  }

  // Pousse un résumé du jour vers le widget d'écran d'accueil.
  void _majWidget() {
    final total = _totalPratiques;
    final faits = _totalFaits;
    final pct = total == 0 ? 0 : ((faits / total) * 100).round();
    WidgetAccueil.maj(
      pct: pct,
      equilibre: '$faits/$total ${tr('pratiques')}',
      projets: _projEnRetard > 0
          ? '$_projEnRetard ${tr('En retard')}'
          : tr('Rien à signaler'),
    );
  }

  List<Projet> get _projetsTries {
    final list = [..._projets];
    switch (_triProjets) {
      case 'echeance':
        list.sort((a, b) {
          if (a.echeanceMs == null && b.echeanceMs == null) return 0;
          if (a.echeanceMs == null) return 1;
          if (b.echeanceMs == null) return -1;
          return a.echeanceMs!.compareTo(b.echeanceMs!);
        });
        break;
      case 'progression':
        list.sort((a, b) => b.progression.compareTo(a.progression));
        break;
      case 'nom':
        list.sort((a, b) => a.titre.toLowerCase().compareTo(b.titre.toLowerCase()));
        break;
    }
    return list;
  }

  Future<void> _changerTri(String tri) async {
    setState(() => _triProjets = tri);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aria_projets_tri', tri);
  }

  void _reordonnerProjets(int oldIndex, int newIndex) {
    setState(() {
      final p = _projets.removeAt(oldIndex);
      _projets.insert(newIndex, p);
    });
    _sauvegarderProjets();
  }

  // ── Statistiques Projets ───────────────────────────────────
  int get _projTermines =>
      _projets.where((p) => p.taches.isNotEmpty && p.progression >= 1).length;
  int get _projEnRetard => _projets
      .where((p) => p.echeance != null && echeanceEnRetard(p.echeance!) && p.progression < 1)
      .length;
  int get _tachesProjTotal => _projets.fold(0, (s, p) => s + p.taches.length);
  int get _tachesProjFaites => _projets.fold(0, (s, p) => s + p.faits);

  Widget _statTile(String valeur, String libelle, Color couleur) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: couleur.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(valeur, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: couleur)),
            const SizedBox(height: 2),
            Text(libelle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: cMutedOf(context))),
          ],
        ),
      ),
    );
  }

  Widget _statsProjets() {
    final total = _tachesProjTotal;
    final faites = _tachesProjFaites;
    final pct = total == 0 ? 0 : ((faites / total) * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cBorderOf(context)),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr("Vue d'ensemble"),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cInkOf(context))),
          const SizedBox(height: 12),
          Row(
            children: [
              _statTile('${_projets.length}', tr('Projets'), cOr),
              const SizedBox(width: 10),
              _statTile('$_projTermines', tr('Terminés'), const Color(0xFF10B981)),
              const SizedBox(width: 10),
              _statTile('$_projEnRetard', tr('En retard'), const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('$pct%', style: TextStyle(fontWeight: FontWeight.w700, color: cInkOf(context))),
              const SizedBox(width: 6),
              Text(tr('achevé'), style: TextStyle(fontSize: 12, color: cMutedOf(context))),
              const Spacer(),
              Text('$faites / $total ${tr('tâches')}',
                  style: TextStyle(fontSize: 12, color: cMutedOf(context))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : faites / total,
              minHeight: 8,
              backgroundColor: cBorderOf(context),
              color: cOr,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sauvegarderCoches() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < piliers.length; i++) {
      await prefs.setStringList('aria_etat_$i', [for (final b in _etats[i]) b ? '1' : '0']);
    }
    _majWidget();
  }

  Future<void> _sauvegarderPratiques() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < piliers.length; i++) {
      await prefs.setStringList('aria_prat_titres_$i', [for (final pr in _pratiques[i]) pr.titre]);
      await prefs.setStringList('aria_prat_sous_$i', [for (final pr in _pratiques[i]) pr.sousTitre]);
    }
  }

  // ── Journal : chargement, migration et sauvegarde ──────────
  Future<void> _chargerJournal(SharedPreferences prefs) async {
    final bruts = prefs.getStringList('aria_journal') ?? [];
    _journalEntrees = [
      for (final s in bruts) Map<String, dynamic>.from(jsonDecode(s) as Map)
    ];
    // Migration depuis l'ancienne version (champs uniques, sans date).
    if (_journalEntrees.isEmpty) {
      final appris = prefs.getString('aria_jrn_appris') ?? '';
      final g1 = prefs.getString('aria_jrn_grat1') ?? '';
      final g2 = prefs.getString('aria_jrn_grat2') ?? '';
      final g3 = prefs.getString('aria_jrn_grat3') ?? '';
      if ('$appris$g1$g2$g3'.trim().isNotEmpty) {
        _journalEntrees.add({
          'd': _cleJour(DateTime.now()),
          'appris': appris,
          'g1': g1,
          'g2': g2,
          'g3': g3,
        });
        await _persisterJournal();
      }
    }
    for (final k in ['aria_jrn_appris', 'aria_jrn_grat1', 'aria_jrn_grat2', 'aria_jrn_grat3']) {
      await prefs.remove(k);
    }
    // Pré-remplit le formulaire avec l'entrée du jour, si elle existe.
    final auj = _cleJour(DateTime.now());
    final e = _entreeDuJour(auj);
    _ctrlAppris.text = (e?['appris'] ?? '') as String;
    _ctrlGrat1.text = (e?['g1'] ?? '') as String;
    _ctrlGrat2.text = (e?['g2'] ?? '') as String;
    _ctrlGrat3.text = (e?['g3'] ?? '') as String;
  }

  Map<String, dynamic>? _entreeDuJour(String cle) {
    for (final e in _journalEntrees) {
      if (e['d'] == cle) return e;
    }
    return null;
  }

  Future<void> _persisterJournal() async {
    final prefs = await SharedPreferences.getInstance();
    _journalEntrees.sort((a, b) => (b['d'] as String).compareTo(a['d'] as String));
    await prefs.setStringList(
        'aria_journal', [for (final e in _journalEntrees) jsonEncode(e)]);
  }

  Future<void> _sauvegarderJournal({bool notifier = false}) async {
    final auj = _cleJour(DateTime.now());
    _journalEntrees.removeWhere((e) => e['d'] == auj);
    final contenu =
        '${_ctrlAppris.text}${_ctrlGrat1.text}${_ctrlGrat2.text}${_ctrlGrat3.text}';
    if (contenu.trim().isNotEmpty) {
      _journalEntrees.add({
        'd': auj,
        'appris': _ctrlAppris.text,
        'g1': _ctrlGrat1.text,
        'g2': _ctrlGrat2.text,
        'g3': _ctrlGrat3.text,
      });
    }
    await _persisterJournal();
    if (notifier && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(tr('Entrée enregistrée ✓')),
          behavior: SnackBarBehavior.floating));
    }
  }

  int get _totalPratiques => _pratiques.fold(0, (s, e) => s + e.length);
  int get _totalFaits => _etats.fold(0, (s, e) => s + e.where((x) => x).length);

  void _choisirLangue() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(tr('Langue'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            for (final l in kLangs)
              ListTile(
                leading: Text(l['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(l['nom']!),
                trailing: gLang == l['code']
                    ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onChangeLang(l['code']!);
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Revient à l'onglet visité précédemment (ou à l'accueil).
  void _retourOnglet() {
    setState(() {
      _onglet = _pileOnglets.isNotEmpty ? _pileOnglets.removeLast() : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _onglet == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _retourOnglet();
      },
      child: Scaffold(
      body: SafeArea(child: _pageCourante()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (i) {
          if (i != _onglet) _pileOnglets.add(_onglet);
          // « Accueil » ramène à la page de bienvenue.
          if (i == 0 && widget.onRetourBienvenue != null) {
            setState(() => _onglet = 0);
            widget.onRetourBienvenue!();
            return;
          }
          setState(() => _onglet = i);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('Accueil')),
          NavigationDestination(icon: const Icon(Icons.rocket_launch_outlined), selectedIcon: const Icon(Icons.rocket_launch), label: tr('Projets')),
          NavigationDestination(icon: const Icon(Icons.book_outlined), selectedIcon: const Icon(Icons.book), label: tr('Journal')),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: tr('Progrès')),
        ],
      ),
      ),
    );
  }

  Widget _pageCourante() {
    switch (_onglet) {
      case 1:
        return _pageProjets();
      case 2:
        return _pageJournal();
      case 3:
        return _pageProgres();
      default:
        return _pageAccueil();
    }
  }

  Widget _entete(String petit, String grand) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_onglet != 0) ...[
          IconButton.filledTonal(
            onPressed: _retourOnglet,
            tooltip: tr('Retour'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(petit, style: TextStyle(color: cMutedOf(context), fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(grand, style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: cInkOf(context))),
            ],
          ),
        ),
        IconButton.filledTonal(onPressed: _ouvrirReglages, icon: const Icon(Icons.tune_rounded)),
        const SizedBox(width: 8),
        IconButton.filledTonal(onPressed: _choisirLangue, icon: const Icon(Icons.language_rounded)),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: widget.onToggleTheme,
          icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        ),
      ],
    );
  }

  // ── ACCUEIL ────────────────────────────────────────────────
  Widget _pageAccueil() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _entete('${salutation()} Ibrahima 👋', tr('Ta journée')),
        const SizedBox(height: 4),
        Text(dateFr(), style: TextStyle(color: cMutedOf(context), fontSize: 13)),
        const SizedBox(height: 22),
        _heroEquilibre(),
        const SizedBox(height: 16),
        _carteCitation(),
        const SizedBox(height: 24),
        Text(tr('TES PILIERS'),
            style: TextStyle(color: cMutedOf(context), fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: 12.5)),
        const SizedBox(height: 12),
        for (int i = 0; i < piliers.length; i++) _cartePilier(i),
      ],
    );
  }

  Widget _heroEquilibre() {
    final segs = [
      for (int i = 0; i < piliers.length; i++)
        _Seg(piliers[i].couleur,
            _etats[i].isEmpty ? 0.0 : _etats[i].where((x) => x).length / _etats[i].length),
    ];
    final total = _totalPratiques;
    final faits = _totalFaits;
    final pct = total == 0 ? 0 : ((faits / total) * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cCard(context),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cBorderOf(context)),
        boxShadow: cardShadow(context),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(size: const Size(96, 96), painter: _RingPainter(segs)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pct%', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: cInkOf(context))),
                    Text(tr('équilibre'), style: TextStyle(fontSize: 9, color: cMutedOf(context))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr('Ton équilibre du jour'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cInkOf(context))),
                const SizedBox(height: 6),
                Text('$faits / $total ${tr('pratiques')}', style: TextStyle(fontSize: 13, color: cMutedOf(context))),
                const SizedBox(height: 10),
                _chipSerie(),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 6, children: [for (final p in piliers) _legende(p)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipSerie() {
    final n = _serie;
    if (n <= 0) {
      return Text(tr('Commence ta série 💪'),
          style: TextStyle(fontSize: 12, color: cMutedOf(context)));
    }
    final label = n == 1 ? tr("jour d'affilée") : tr("jours d'affilée");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cOr.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cOr.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text('$n $label',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: cInkOf(context))),
        ],
      ),
    );
  }

  Widget _legende(Pilier p) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: p.couleur, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(tr(p.nom), style: TextStyle(fontSize: 11, color: cMutedOf(context))),
      ],
    );
  }

  Widget _carteCitation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B2236), Color(0xFF2B3352)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cOr.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: const Color(0xFF0B0F1A).withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('« Le progrès, pas la perfection. Chaque petit pas compte. »'),
              style: const TextStyle(color: cCreme, fontStyle: FontStyle.italic, height: 1.5, fontSize: 14.5)),
          const SizedBox(height: 8),
          Text(tr('— Ton intention du jour'), style: const TextStyle(color: cOrClair, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _cartePilier(int i) {
    final p = piliers[i];
    final etat = _etats[i];
    final faits = etat.where((x) => x).length;
    final total = etat.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: p.couleur,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () async {
            await Navigator.push(
              context,
              slideRoute(EcranPilier(
                pilier: p,
                pratiques: _pratiques[i],
                coches: _etats[i],
                onChangeCoches: _sauvegarderCoches,
                onChangePratiques: _sauvegarderPratiques,
              )),
            );
            setState(() {});
            _verifierJourneePleine();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: p.couleur.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 10))],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(p.nom), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('$faits / $total ${tr('pratiques')}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : faits / total,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.28),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── PROGRÈS ────────────────────────────────────────────────
  Widget _pageProgres() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _entete(tr('Ton chemin'), tr('Tes progrès')),
        const SizedBox(height: 4),
        Text(dateFr(), style: TextStyle(color: cMutedOf(context), fontSize: 13)),
        const SizedBox(height: 20),
        _carteHistorique(),
        const SizedBox(height: 16),
        for (int i = 0; i < piliers.length; i++) _carteProgres(i),
      ],
    );
  }

  // Fractions de complétion des n derniers jours (du plus ancien à aujourd'hui).
  List<({String label, double frac, bool auj})> _serieJours(int n) {
    final map = <String, double>{};
    for (final e in _historique) {
      final f = (e['f'] ?? 0) as int;
      final t = (e['t'] ?? 0) as int;
      map[e['d'] as String] = t > 0 ? f / t : 0;
    }
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final res = <({String label, double frac, bool auj})>[];
    for (int i = n - 1; i >= 0; i--) {
      final d = base.subtract(Duration(days: i));
      final auj = i == 0;
      final frac = auj
          ? (_totalPratiques > 0 ? _totalFaits / _totalPratiques : 0.0)
          : (map[_cleJour(d)] ?? 0.0);
      final nomJour = tr(kJoursFr[d.weekday - 1]);
      final label = n <= 7 ? (nomJour.isNotEmpty ? nomJour[0] : '') : '${d.day}';
      res.add((label: label, frac: frac, auj: auj));
    }
    return res;
  }

  Widget _carteHistorique() {
    final jours = _serieJours(_fenetreHisto);
    final moy = jours.isEmpty ? 0 : ((jours.fold(0.0, (s, e) => s + e.frac) / jours.length) * 100).round();
    const maxH = 78.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: cCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cBorderOf(context)),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tr('Ton historique'),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cInkOf(context))),
              const Spacer(),
              _boutonFenetre(7),
              const SizedBox(width: 6),
              _boutonFenetre(30),
            ],
          ),
          const SizedBox(height: 4),
          Text('${tr('Moyenne')} : $moy%', style: TextStyle(fontSize: 12, color: cMutedOf(context))),
          const SizedBox(height: 12),
          SizedBox(
            height: maxH,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final j in jours)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: _fenetreHisto <= 7 ? 3 : 1),
                      child: Container(
                        height: (j.frac * maxH).clamp(3.0, maxH),
                        decoration: BoxDecoration(
                          color: j.auj ? cOr : cOr.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_fenetreHisto <= 7) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                for (final j in jours)
                  Expanded(
                    child: Text(j.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: j.auj ? FontWeight.w700 : FontWeight.w400,
                          color: j.auj ? cOr : cMutedOf(context),
                        )),
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tr('il y a')} 30 ${tr('jours')}', style: TextStyle(fontSize: 10, color: cMutedOf(context))),
                Text(tr("Aujourd'hui"), style: TextStyle(fontSize: 10, color: cOr, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _boutonFenetre(int n) {
    final actif = _fenetreHisto == n;
    return GestureDetector(
      onTap: () => setState(() => _fenetreHisto = n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: actif ? cOr.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: actif ? cOr : cBorderOf(context)),
        ),
        child: Text('$n ${tr('jours')}',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: actif ? FontWeight.w700 : FontWeight.w500,
              color: actif ? cInkOf(context) : cMutedOf(context),
            )),
      ),
    );
  }

  Widget _carteProgres(int i) {
    final p = piliers[i];
    final etat = _etats[i];
    final faits = etat.where((x) => x).length;
    final total = etat.length;
    final pct = total == 0 ? 0 : ((faits / total) * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cBorderOf(context)),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(p.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(tr(p.nom), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: cInkOf(context))),
              const Spacer(),
              Text('$pct %', style: TextStyle(color: p.couleur, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : faits / total,
              minHeight: 9,
              backgroundColor: cBorderOf(context),
              color: p.couleur,
            ),
          ),
        ],
      ),
    );
  }

  // ── PROJETS ────────────────────────────────────────────────
  static const Color _cProjet = cOr;

  Future<void> _ajouterProjet() async {
    final r = await dialogueProjet(context);
    if (r == null) return;
    final projet = Projet(
      r.titre,
      description: r.description,
      couleur: r.couleur,
      echeanceMs: r.echeanceMs,
    );
    setState(() => _projets.add(projet));
    _sauvegarderProjets();
    planifierNotifProjet(projet);
  }

  Widget _barreTri() {
    String libelle(String t) {
      switch (t) {
        case 'echeance':
          return tr('Par échéance');
        case 'progression':
          return tr('Par progression');
        case 'nom':
          return tr('Par nom');
        default:
          return tr('Par défaut');
      }
    }

    return Row(
      children: [
        Icon(Icons.sort_rounded, size: 18, color: cMutedOf(context)),
        const SizedBox(width: 6),
        Text('${tr('Trier')} :', style: TextStyle(fontSize: 12.5, color: cMutedOf(context))),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          initialValue: _triProjets,
          onSelected: _changerTri,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(libelle(_triProjets),
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: cInkOf(context))),
              Icon(Icons.arrow_drop_down_rounded, color: cMutedOf(context)),
            ],
          ),
          itemBuilder: (_) => [
            for (final t in ['defaut', 'echeance', 'progression', 'nom'])
              PopupMenuItem(value: t, child: Text(libelle(t))),
          ],
        ),
      ],
    );
  }

  Widget _badgeEcheance(DateTime d) {
    final retard = echeanceEnRetard(d);
    final couleur = retard ? const Color(0xFFEF4444) : cMutedOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_rounded, size: 13, color: couleur),
          const SizedBox(width: 4),
          Text(labelEcheance(d),
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: couleur)),
        ],
      ),
    );
  }

  Widget _pageProjets() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _entete(tr('Ton espace'), tr('Tes projets')),
        const SizedBox(height: 4),
        Text(dateFr(), style: TextStyle(color: cMutedOf(context), fontSize: 13)),
        const SizedBox(height: 20),
        if (_projets.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.rocket_launch_rounded, size: 46, color: _cProjet.withValues(alpha: 0.7)),
                const SizedBox(height: 14),
                Text(tr('Aucun projet pour le moment'),
                    style: TextStyle(fontWeight: FontWeight.w600, color: cInkOf(context))),
                const SizedBox(height: 6),
                Text(tr('Crée ton premier projet et avance étape par étape.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: cMutedOf(context))),
              ],
            ),
          )
        else ...[
          _statsProjets(),
          _barreTri(),
          const SizedBox(height: 12),
          if (_triProjets == 'defaut')
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: _reordonnerProjets,
              children: [
                for (int i = 0; i < _projets.length; i++)
                  _carteProjet(_projets[i], dragIndex: i),
              ],
            )
          else
            for (final proj in _projetsTries) _carteProjet(proj),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _ajouterProjet,
          icon: const Icon(Icons.add_rounded),
          label: Text(tr('Nouveau projet')),
          style: OutlinedButton.styleFrom(
            foregroundColor: _cProjet,
            side: const BorderSide(color: _cProjet),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _carteProjet(Projet proj, {int? dragIndex}) {
    final total = proj.taches.length;
    final pct = (proj.progression * 100).round();
    final couleur = Color(proj.couleur);
    final ech = proj.echeance;
    return Dismissible(
      key: ObjectKey(proj),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsetsDirectional.only(end: 22),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr('Supprimer ce projet ?')),
            content: Text(proj.titre),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr('Supprimer')),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        NotifsService.annuler(proj.id);
        setState(() => _projets.remove(proj));
        _sauvegarderProjets();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: cCard(context),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Navigator.push(
                context,
                slideRoute(EcranProjet(
                  projet: proj,
                  onChange: _sauvegarderProjets,
                )),
              );
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cBorderOf(context)),
                boxShadow: cardShadow(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: couleur.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.rocket_launch_rounded, color: couleur, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(proj.titre,
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: cInkOf(context))),
                            if (proj.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(proj.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: cMutedOf(context))),
                            ],
                          ],
                        ),
                      ),
                      Text('$pct %', style: TextStyle(color: couleur, fontWeight: FontWeight.w700)),
                      if (dragIndex != null)
                        ReorderableDragStartListener(
                          index: dragIndex,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 6),
                            child: Icon(Icons.drag_handle_rounded, color: cMutedOf(context)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: proj.progression,
                      minHeight: 8,
                      backgroundColor: cBorderOf(context),
                      color: couleur,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('${proj.faits} / $total ${tr('tâches')}',
                          style: TextStyle(fontSize: 12, color: cMutedOf(context))),
                      const Spacer(),
                      if (ech != null) _badgeEcheance(ech),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── JOURNAL ────────────────────────────────────────────────
  Widget _pageJournal() {
    final auj = _cleJour(DateTime.now());
    final anciennes = [
      for (final e in _journalEntrees)
        if (e['d'] != auj) e
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        _entete(tr('Ton espace'), tr('Journal du soir')),
        const SizedBox(height: 4),
        Text(dateFr(), style: TextStyle(color: cMutedOf(context), fontSize: 13)),
        const SizedBox(height: 20),
        _carteJournal(titre: tr("📝 Qu'as-tu appris aujourd'hui ?"), enfant: _champ(_ctrlAppris, tr('Écris librement…'), lignes: 4)),
        _carteJournal(
          titre: tr('🙏 3 gratitudes du jour'),
          enfant: Column(children: [
            _champ(_ctrlGrat1, '1. ', lignes: 1),
            const SizedBox(height: 8),
            _champ(_ctrlGrat2, '2. ', lignes: 1),
            const SizedBox(height: 8),
            _champ(_ctrlGrat3, '3. ', lignes: 1),
          ]),
        ),
        FilledButton.icon(
          onPressed: () => _sauvegarderJournal(notifier: true),
          icon: const Icon(Icons.save_rounded),
          label: Text(tr('Enregistrer')),
          style: FilledButton.styleFrom(
            backgroundColor: cOr,
            foregroundColor: surCouleur(cOr),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (anciennes.isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(tr('ENTRÉES PRÉCÉDENTES'),
              style: TextStyle(
                  color: cMutedOf(context),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 12.5)),
          const SizedBox(height: 12),
          for (final e in anciennes) _carteEntreeJournal(e),
        ],
      ],
    );
  }

  String _dateEntree(String cle) {
    final p = cle.split('-');
    final d = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    return '${tr(kJoursFr[d.weekday - 1])} ${dateCourte(d)}';
  }

  Widget _carteEntreeJournal(Map<String, dynamic> e) {
    final appris = (e['appris'] ?? '') as String;
    final grats = [
      for (final k in ['g1', 'g2', 'g3'])
        if (((e[k] ?? '') as String).trim().isNotEmpty) (e[k] as String)
    ];
    final apercu = appris.trim().isNotEmpty ? appris : grats.join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cCard(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _modifierEntree(e),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cBorderOf(context)),
              boxShadow: cardShadow(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cOr.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.book_rounded, color: cOr, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_dateEntree(e['d'] as String),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: cInkOf(context))),
                      if (apercu.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(apercu,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: cMutedOf(context))),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.edit_rounded, size: 18, color: cMutedOf(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _modifierEntree(Map<String, dynamic> e) async {
    final cAppris = TextEditingController(text: (e['appris'] ?? '') as String);
    final cG1 = TextEditingController(text: (e['g1'] ?? '') as String);
    final cG2 = TextEditingController(text: (e['g2'] ?? '') as String);
    final cG3 = TextEditingController(text: (e['g3'] ?? '') as String);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_dateEntree(e['d'] as String),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 14),
              Text(tr("📝 Qu'as-tu appris aujourd'hui ?"),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              _champ(cAppris, tr('Écris librement…'), lignes: 3),
              const SizedBox(height: 14),
              Text(tr('🙏 3 gratitudes du jour'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              _champ(cG1, '1. ', lignes: 1),
              const SizedBox(height: 8),
              _champ(cG2, '2. ', lignes: 1),
              const SizedBox(height: 8),
              _champ(cG3, '3. ', lignes: 1),
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: ctx,
                        builder: (c2) => AlertDialog(
                          title: Text(tr('Supprimer cette entrée ?')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c2, false),
                                child: Text(tr('Annuler'))),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(c2, true),
                              child: Text(tr('Supprimer')),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && ctx.mounted) {
                        _journalEntrees.remove(e);
                        await _persisterJournal();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) setState(() {});
                      }
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 19),
                    label: Text(tr('Supprimer'), style: const TextStyle(color: Colors.red)),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: cOr, foregroundColor: surCouleur(cOr)),
                    onPressed: () async {
                      e['appris'] = cAppris.text;
                      e['g1'] = cG1.text;
                      e['g2'] = cG2.text;
                      e['g3'] = cG3.text;
                      await _persisterJournal();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.save_rounded, size: 19),
                    label: Text(tr('Enregistrer')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    cAppris.dispose();
    cG1.dispose();
    cG2.dispose();
    cG3.dispose();
  }

  Widget _carteJournal({required String titre, required Widget enfant}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cCard(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cBorderOf(context)),
        boxShadow: cardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cInkOf(context))),
          const SizedBox(height: 12),
          enfant,
        ],
      ),
    );
  }

  Widget _champ(TextEditingController c, String hint, {int lignes = 1}) {
    return TextField(
      controller: c,
      maxLines: lignes,
      onChanged: (_) => _sauvegarderJournal(),
      style: TextStyle(color: cInkOf(context), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: cFieldOf(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

// ── Peintre du cercle d'équilibre ────────────────────────────
class _Seg {
  final Color color;
  final double fraction;
  const _Seg(this.color, this.fraction);
}

class _RingPainter extends CustomPainter {
  final List<_Seg> segments;
  _RingPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final n = segments.length;
    if (n == 0) return;
    const gap = 0.20;
    final segAngle = (2 * math.pi - n * gap) / n;
    double start = -math.pi / 2 + gap / 2;
    for (final s in segments) {
      final track = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = s.color.withValues(alpha: 0.18);
      canvas.drawArc(rect, start, segAngle, false, track);
      final f = s.fraction.clamp(0.0, 1.0);
      if (f > 0) {
        final val = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = s.color;
        canvas.drawArc(rect, start, segAngle * f, false, val);
      }
      start += segAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => true;
}
