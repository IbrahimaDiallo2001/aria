// ============================================================
//  Aria — Logique partagée du module Projets :
//  notifications d'échéance + dialogue création/édition.
// ============================================================
import 'package:flutter/material.dart';

import 'i18n.dart';
import 'modeles.dart';
import 'notifs.dart';
import 'theme.dart';

// ── Notifications d'échéance (au niveau global) ──────────────
// Rappel programmé à 9h le jour de l'échéance (null si aucune).
DateTime? momentNotif(Projet p) {
  final e = p.echeance;
  if (e == null) return null;
  return DateTime(e.year, e.month, e.day, 9, 0);
}

void planifierNotifProjet(Projet p) {
  final quand = momentNotif(p);
  if (quand == null) {
    NotifsService.annuler(p.id);
    return;
  }
  NotifsService.planifier(
    id: p.id,
    titre: '📌 ${p.titre}',
    corps: tr("Ce projet arrive à échéance aujourd'hui."),
    quand: quand,
  );
}

// Dialogue partagé création / édition d'un projet.
// Renvoie null si annulé ou titre vide.
Future<({String titre, String description, int couleur, int? echeanceMs})?>
    dialogueProjet(BuildContext context, {Projet? initial}) async {
  final tCtrl = TextEditingController(text: initial?.titre ?? '');
  final dCtrl = TextEditingController(text: initial?.description ?? '');
  int couleur = initial?.couleur ?? kCouleursProjet.first;
  DateTime? echeance = initial?.echeance;
  final edition = initial != null;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(edition ? tr('Modifier le projet') : tr('Nouveau projet')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: tCtrl, autofocus: true, decoration: InputDecoration(labelText: tr('Titre'))),
                const SizedBox(height: 8),
                TextField(controller: dCtrl, decoration: InputDecoration(labelText: tr('Description (facultatif)'))),
                const SizedBox(height: 18),
                Text(tr('Couleur'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cMutedOf(ctx))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final c in kCouleursProjet)
                      GestureDetector(
                        onTap: () => setLocal(() => couleur = c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Color(c),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: couleur == c ? cInkOf(ctx) : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: couleur == c
                              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                              : null,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(tr('Échéance'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cMutedOf(ctx))),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 20, color: Color(couleur)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        echeance == null ? tr('Aucune échéance') : dateCourte(echeance!),
                        style: TextStyle(fontSize: 13.5, color: cInkOf(ctx)),
                      ),
                    ),
                    if (echeance != null)
                      IconButton(
                        onPressed: () => setLocal(() => echeance = null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: echeance ?? now,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 10),
                        );
                        if (d != null) setLocal(() => echeance = d);
                      },
                      child: Text(tr('Choisir')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(edition ? tr('Enregistrer') : tr('Ajouter')),
          ),
        ],
      ),
    ),
  );
  final res = (ok == true && tCtrl.text.trim().isNotEmpty)
      ? (
          titre: tCtrl.text.trim(),
          description: dCtrl.text.trim(),
          couleur: couleur,
          echeanceMs: echeance?.millisecondsSinceEpoch,
        )
      : null;
  tCtrl.dispose();
  dCtrl.dispose();
  return res;
}
