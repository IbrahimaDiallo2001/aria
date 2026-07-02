// ============================================================
//  Aria — Écran d'un pilier (pratiques personnalisables).
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'i18n.dart';
import 'modeles.dart';
import 'theme.dart';

class EcranPilier extends StatefulWidget {
  final Pilier pilier;
  final List<Pratique> pratiques;
  final List<bool> coches;
  final VoidCallback onChangeCoches;
  final VoidCallback onChangePratiques;
  const EcranPilier({
    super.key,
    required this.pilier,
    required this.pratiques,
    required this.coches,
    required this.onChangeCoches,
    required this.onChangePratiques,
  });

  @override
  State<EcranPilier> createState() => _EcranPilierState();
}

class _EcranPilierState extends State<EcranPilier> {
  Future<void> _ajouterPratique() async {
    final tCtrl = TextEditingController();
    final sCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Nouvelle pratique')),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tCtrl, autofocus: true, decoration: InputDecoration(labelText: tr('Titre'))),
              const SizedBox(height: 8),
              TextField(controller: sCtrl, decoration: InputDecoration(labelText: tr('Sous-titre (facultatif)'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr('Annuler'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr('Ajouter'))),
        ],
      ),
    );
    if (ok == true && tCtrl.text.trim().isNotEmpty) {
      setState(() {
        widget.pratiques.add(Pratique(tCtrl.text.trim(), sCtrl.text.trim()));
        widget.coches.add(false);
      });
      widget.onChangePratiques();
      widget.onChangeCoches();
    }
    tCtrl.dispose();
    sCtrl.dispose();
  }

  void _toggle(int i) {
    setState(() => widget.coches[i] = !widget.coches[i]);
    HapticFeedback.selectionClick();
    widget.onChangeCoches();
    if (widget.coches.isNotEmpty && widget.coches.every((x) => x)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎉 ${tr(widget.pilier.nom)} : ${tr('tout est accompli !')}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.pilier.couleur,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _supprimer(int i) {
    setState(() {
      widget.pratiques.removeAt(i);
      widget.coches.removeAt(i);
    });
    widget.onChangePratiques();
    widget.onChangeCoches();
  }

  void _reordonner(int oldIndex, int newIndex) {
    setState(() {
      final prat = widget.pratiques.removeAt(oldIndex);
      final coche = widget.coches.removeAt(oldIndex);
      widget.pratiques.insert(newIndex, prat);
      widget.coches.insert(newIndex, coche);
    });
    widget.onChangePratiques();
    widget.onChangeCoches();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pilier;
    final faits = widget.coches.where((x) => x).length;
    final total = widget.pratiques.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.couleur,
        foregroundColor: surCouleur(p.couleur),
        elevation: 0,
        title: Text('${p.emoji}  ${tr(p.nom)}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: p.couleur.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: p.couleur),
                const SizedBox(width: 10),
                Text('$faits / $total ${tr('pratiques')}',
                    style: TextStyle(color: p.couleur, fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: _reordonner,
            children: [
              for (int i = 0; i < widget.pratiques.length; i++) _ligne(i),
            ],
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _ajouterPratique,
            icon: const Icon(Icons.add_rounded),
            label: Text(tr('Ajouter une pratique')),
            style: OutlinedButton.styleFrom(
              foregroundColor: p.couleur,
              side: BorderSide(color: p.couleur),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          if (widget.pratiques.isNotEmpty) ...[
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

  Widget _ligne(int i) {
    final prat = widget.pratiques[i];
    final coche = widget.coches[i];
    final p = widget.pilier;
    return Dismissible(
      key: ObjectKey(prat),
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
            title: Text(tr('Supprimer cette pratique ?')),
            content: Text(tr(prat.titre)),
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
      onDismissed: (_) => _supprimer(i),
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
                      color: coche ? p.couleur : Colors.transparent,
                      border: Border.all(color: coche ? p.couleur : cBorderOf(context), width: 2),
                    ),
                    child: coche ? Icon(Icons.check_rounded, size: 17, color: surCouleur(p.couleur)) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(prat.titre),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: coche ? cMutedOf(context) : cInkOf(context),
                              decoration: coche ? TextDecoration.lineThrough : null,
                            )),
                        if (prat.sousTitre.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(tr(prat.sousTitre), style: TextStyle(fontSize: 12, color: cMutedOf(context))),
                        ],
                      ],
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: Icon(Icons.drag_handle_rounded, size: 20, color: cMutedOf(context)),
                    ),
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
