// ============================================================
//  Aria — Politique de confidentialité (affichée dans l'app).
// ============================================================
import 'package:flutter/material.dart';

import 'i18n.dart';
import 'theme.dart';

class EcranConfidentialite extends StatelessWidget {
  const EcranConfidentialite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cOr,
        foregroundColor: surCouleur(cOr),
        elevation: 0,
        title: Text(tr('Politique de confidentialité'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Résumé mis en avant
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cOr.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cOr.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded, color: cOr, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "En résumé : Aria ne collecte aucune donnée. Tout ce que tu écris dans l'application reste sur ton appareil. Rien n'est envoyé sur Internet, rien n'est partagé, rien n'est vendu.",
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: cInkOf(context)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _section(context, '1. Qui est responsable ?',
              "Aria est développée et éditée par Ibrahima Diallo. Pour toute question relative à cette politique ou à tes données, tu peux écrire à : ibrahimadiallo2047@gmail.com."),
          _section(context, "2. Quelles données l'application traite-t-elle ?",
              "Aria te permet de suivre des pratiques quotidiennes, gérer des projets, tenir un journal et consulter tes progrès. Toutes ces informations (coches, textes du journal, projets, historique, préférences de thème et de langue) sont enregistrées uniquement en local, dans le stockage privé de l'application sur ton appareil."),
          _section(context, "3. Ce qu'Aria ne fait pas",
              "Aria ne collecte pas de données personnelles, ne crée pas de compte, n'utilise ni publicité, ni traceur, ni outil de mesure d'audience, et ne transmet aucune information à des serveurs ou à des tiers."),
          _section(context, '4. Notifications',
              "Si tu actives les rappels, les notifications sont programmées et affichées localement par ton appareil. Aucun service externe n'est utilisé. Tu peux les désactiver à tout moment."),
          _section(context, '5. Export et suppression de tes données',
              "Tu peux exporter l'ensemble de tes données à tout moment (Réglages → Exporter mes données) : le fichier t'appartient. Pour tout supprimer, il suffit de désinstaller l'application."),
          _section(context, '6. Enfants',
              "Aria ne collectant aucune donnée, elle peut être utilisée sans risque particulier. Elle ne contient ni contenu inapproprié, ni achat intégré, ni publicité."),
          _section(context, '7. Évolution de cette politique',
              "Si une future version d'Aria devait introduire une fonctionnalité impliquant des données (par exemple une sauvegarde en ligne optionnelle), cette politique serait mise à jour et le changement clairement annoncé dans l'application."),
          const SizedBox(height: 12),
          Center(
            child: Text('© 2026 Ibrahima Diallo — Dernière mise à jour : 2 juillet 2026',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: cMutedOf(context))),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String titre, String corps) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w700, color: cInkOf(context))),
          const SizedBox(height: 6),
          Text(corps,
              style: TextStyle(fontSize: 13.5, height: 1.6, color: cMutedOf(context))),
        ],
      ),
    );
  }
}
