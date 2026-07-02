// ============================================================
//  Aria — Écran d'un projet (tâches / étapes / sous-tâches).
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'i18n.dart';
import 'modeles.dart';
import 'projets_partage.dart';
import 'theme.dart';

class EcranProjet extends StatefulWidget {
  final Projet projet;
  final VoidCallback onChange;
  const EcranProjet({
    super.key,
    required this.projet,
    required this.onChange,
  });

  @override
  State<EcranProjet> createState() => _EcranProjetState();
}

class _EcranProjetState extends State<EcranProjet> {
  final Set<Tache> _ouverts = {}; // tâches dépliées (affichent leurs sous-tâches)

  // Couleur dérivée du projet (se met à jour si on l'édite).
  Color get _c => Color(widget.projet.couleur);

  Future<void> _editer() async {
    final r = await dialogueProjet(context, initial: widget.projet);
    if (r == null) return;
    setState(() {
      widget.projet.titre = r.titre;
      widget.projet.description = r.description;
      widget.projet.couleur = r.couleur;
      widget.projet.echeanceMs = r.echeanceMs;
    });
    widget.onChange();
    planifierNotifProjet(widget.projet);
  }

  Future<void> _ajouterTache() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Nouvelle tâche')),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(labelText: tr('Titre'))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Ajouter'))),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      setState(() => widget.projet.taches.add(Tache(ctrl.text.trim())));
      widget.onChange();
    }
    ctrl.dispose();
  }

  Future<void> _ajouterSousTache(Tache parent) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Nouvelle sous-tâche')),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(controller: ctrl, autofocus: true, decoration: InputDecoration(labelText: tr('Titre'))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Ajouter'))),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      setState(() {
        parent.sousTaches.add(SousTache(ctrl.text.trim()));
        _ouverts.add(parent);
      });
      widget.onChange();
      _feterSiComplet();
    }
    ctrl.dispose();
  }

  void _feterSiComplet() {
    final t = widget.projet.taches;
    if (t.isNotEmpty && t.every((x) => x.fait)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎉 ${widget.projet.titre} : ${tr('projet terminé !')}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _c,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _toggle(int i) {
    final t = widget.projet.taches[i];
    setState(() {
      if (t.sousTaches.isEmpty) {
        t.fait = !t.fait;
      } else {
        // Tâche parente : cocher/décocher toutes les sous-tâches d'un coup.
        final tout = t.fait;
        for (final s in t.sousTaches) {
          s.fait = !tout;
        }
      }
    });
    HapticFeedback.selectionClick();
    widget.onChange();
    _feterSiComplet();
  }

  void _toggleSousTache(SousTache s) {
    setState(() => s.fait = !s.fait);
    HapticFeedback.selectionClick();
    widget.onChange();
    _feterSiComplet();
  }

  void _supprimer(int i) {
    setState(() => widget.projet.taches.removeAt(i));
    widget.onChange();
  }

  void _reordonnerTaches(int oldIndex, int newIndex) {
    setState(() {
      final t = widget.projet.taches.removeAt(oldIndex);
      widget.projet.taches.insert(newIndex, t);
    });
    widget.onChange();
  }

  @override
  Widget build(BuildContext context) {
    final proj = widget.projet;
    final total = proj.taches.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _c,
        foregroundColor: surCouleur(_c),
        elevation: 0,
        title: Text(proj.titre, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: tr('Modifier'),
            onPressed: _editer,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (proj.description.isNotEmpty) ...[
            Text(proj.description, style: TextStyle(fontSize: 14, color: cMutedOf(context))),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, color: _c),
                const SizedBox(width: 10),
                Text('${proj.faits} / $total ${tr('tâches')}',
                    style: TextStyle(color: _c, fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text('${(proj.progression * 100).round()} %',
                    style: TextStyle(color: _c, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: _reordonnerTaches,
            children: [
              for (int i = 0; i < proj.taches.length; i++) _ligneTache(i),
            ],
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _ajouterTache,
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('Ajouter une tâche')),
            style: OutlinedButton.styleFrom(
              foregroundColor: _c,
              side: BorderSide(color: _c),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (proj.taches.isNotEmpty) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(tr('Glisse vers la gauche pour supprimer'),
                  style: TextStyle(fontSize: 11, color: cMutedOf(context))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ligneTache(int i) {
    final t = widget.projet.taches[i];
    final aSous = t.sousTaches.isNotEmpty;
    final ouvert = _ouverts.contains(t);
    return Column(
      key: ValueKey('tache_${identityHashCode(t)}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Dismissible(
          key: ObjectKey(t),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsetsDirectional.only(end: 22),
            alignment: AlignmentDirectional.centerEnd,
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(tr('Supprimer cette tâche ?')),
                content: Text(t.titre),
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
            _ouverts.remove(t);
            _supprimer(i);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: cCard(context),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _toggle(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cBorderOf(context)),
                    boxShadow: cardShadow(context),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.fait ? _c : Colors.transparent,
                          border: Border.all(color: t.fait ? _c : cBorderOf(context), width: 2),
                        ),
                        child: t.fait ? Icon(Icons.check_rounded, size: 17, color: surCouleur(_c)) : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.titre,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: t.fait ? cMutedOf(context) : cInkOf(context),
                                  decoration: t.fait ? TextDecoration.lineThrough : null,
                                )),
                            if (aSous) ...[
                              const SizedBox(height: 2),
                              Text('${t.sousFaits} / ${t.sousTaches.length}',
                                  style: TextStyle(fontSize: 11.5, color: cMutedOf(context))),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          if (ouvert) {
                            _ouverts.remove(t);
                          } else {
                            _ouverts.add(t);
                          }
                        }),
                        icon: Icon(
                          ouvert ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: cMutedOf(context),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 2, end: 2),
                          child: Icon(Icons.drag_handle_rounded, size: 20, color: cMutedOf(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (ouvert)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 26, bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int k = 0; k < t.sousTaches.length; k++) _ligneSousTache(t, k),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _ajouterSousTache(t),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(tr('Ajouter une sous-tâche')),
                    style: TextButton.styleFrom(foregroundColor: _c),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _ligneSousTache(Tache parent, int k) {
    final s = parent.sousTaches[k];
    return Dismissible(
      key: ObjectKey(s),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsetsDirectional.only(end: 18),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 18),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr('Supprimer cette sous-tâche ?')),
            content: Text(s.titre),
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
        setState(() => parent.sousTaches.removeAt(k));
        widget.onChange();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: cCard(context),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _toggleSousTache(s),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cBorderOf(context)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.fait ? _c : Colors.transparent,
                      border: Border.all(color: s.fait ? _c : cBorderOf(context), width: 2),
                    ),
                    child: s.fait ? Icon(Icons.check_rounded, size: 13, color: surCouleur(_c)) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.titre,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: s.fait ? cMutedOf(context) : cInkOf(context),
                          decoration: s.fait ? TextDecoration.lineThrough : null,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
