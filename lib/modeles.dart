// ============================================================
//  Aria — Modèles de données (piliers, pratiques, projets).
// ============================================================
import 'package:flutter/material.dart';

// ── Données ──────────────────────────────────────────────────
class Pratique {
  final String titre;
  final String sousTitre;
  const Pratique(this.titre, this.sousTitre);
}

// ── Modèle Projets (données utilisateur, modifiables) ────────
class SousTache {
  String titre;
  bool fait;
  SousTache(this.titre, {this.fait = false});

  Map<String, dynamic> toJson() => {'t': titre, 'f': fait};
  factory SousTache.fromJson(Map<String, dynamic> j) =>
      SousTache((j['t'] ?? '').toString(), fait: j['f'] == true);
}

class Tache {
  String titre;
  bool coche; // état direct, utilisé seulement sans sous-tâches
  List<SousTache> sousTaches;
  Tache(this.titre, {this.coche = false, List<SousTache>? sousTaches})
      : sousTaches = sousTaches ?? [];

  // Si la tâche a des sous-tâches, son état est dérivé (toutes cochées).
  bool get fait => sousTaches.isEmpty ? coche : sousTaches.every((s) => s.fait);
  set fait(bool v) => coche = v;
  int get sousFaits => sousTaches.where((s) => s.fait).length;

  Map<String, dynamic> toJson() =>
      {'t': titre, 'f': coche, 'sous': [for (final s in sousTaches) s.toJson()]};
  factory Tache.fromJson(Map<String, dynamic> j) => Tache(
        (j['t'] ?? '').toString(),
        coche: j['f'] == true,
        sousTaches: [
          for (final s in (j['sous'] as List? ?? []))
            SousTache.fromJson(Map<String, dynamic>.from(s as Map))
        ],
      );
}

// Palette de couleurs proposées pour un projet (valeurs ARGB).
const List<int> kCouleursProjet = [
  0xFFD4AF37, // or
  0xFF10B981, // vert
  0xFF2E86C1, // bleu
  0xFFF59E0B, // orange
  0xFFEC4899, // rose
  0xFF06B6D4, // cyan
  0xFFEF4444, // rouge
  0xFF64748B, // ardoise
];

int _compteurIdProjet = 0;
int nouvelIdProjet() =>
    (DateTime.now().microsecondsSinceEpoch + (_compteurIdProjet++)) & 0x7fffffff;

class Projet {
  int id; // identifiant stable (sert d'id de notification)
  String titre;
  String description;
  List<Tache> taches;
  int couleur; // valeur ARGB
  int? echeanceMs; // échéance en ms depuis epoch (null = aucune)
  Projet(
    this.titre, {
    int? id,
    this.description = '',
    List<Tache>? taches,
    this.couleur = 0xFFD4AF37,
    this.echeanceMs,
  })  : id = id ?? nouvelIdProjet(),
        taches = taches ?? [];

  int get faits => taches.where((t) => t.fait).length;
  double get progression => taches.isEmpty ? 0 : faits / taches.length;
  DateTime? get echeance =>
      echeanceMs == null ? null : DateTime.fromMillisecondsSinceEpoch(echeanceMs!);

  Map<String, dynamic> toJson() => {
        'id': id,
        't': titre,
        'd': description,
        'c': couleur,
        'e': echeanceMs,
        'taches': [for (final t in taches) t.toJson()],
      };
  factory Projet.fromJson(Map<String, dynamic> j) => Projet(
        (j['t'] ?? '').toString(),
        id: (j['id'] is int) ? j['id'] as int : null,
        description: (j['d'] ?? '').toString(),
        couleur: (j['c'] is int) ? j['c'] as int : 0xFFD4AF37,
        echeanceMs: (j['e'] is int) ? j['e'] as int : null,
        taches: [
          for (final t in (j['taches'] as List? ?? []))
            Tache.fromJson(Map<String, dynamic>.from(t as Map))
        ],
      );
}

class Pilier {
  final String emoji;
  final String nom;
  final Color couleur;
  final List<Pratique> pratiques; // pratiques par défaut
  const Pilier({
    required this.emoji,
    required this.nom,
    required this.couleur,
    required this.pratiques,
  });
}

const piliers = <Pilier>[
  Pilier(emoji: '🏋️', nom: 'Corps', couleur: Color(0xFF10B981), pratiques: [
    Pratique("Boire 8 verres d'eau", 'Hydratation du jour'),
    Pratique('Séance de sport', '30 minutes'),
    Pratique('Manger sainement', 'Légumes à chaque repas'),
    Pratique('Bien dormir', 'Coucher avant 23h'),
  ]),
  Pilier(emoji: '🧠', nom: 'Esprit', couleur: Color(0xFF4F46E5), pratiques: [
    Pratique('Méditer', '10 minutes'),
    Pratique('Tenir son journal', 'Le soir'),
    Pratique('Lire', '20 pages'),
    Pratique('Gratitude', '3 choses positives'),
  ]),
  Pilier(emoji: '🔄', nom: 'Habitudes', couleur: Color(0xFFF59E0B), pratiques: [
    Pratique('Routine du matin', 'Réveil, eau, étirements'),
    Pratique('Planifier sa journée', '3 priorités'),
    Pratique('Suivre ses habitudes', 'Cocher au fil du jour'),
    Pratique('Routine du soir', 'Déconnexion, lecture'),
  ]),
  Pilier(emoji: '🕊️', nom: 'Âme', couleur: Color(0xFFEC4899), pratiques: [
    Pratique('Prière ou intention', 'Un moment de recueillement'),
    Pratique('Contempler la nature', 'Respirer dehors'),
    Pratique('Acte de bonté', 'Aider quelqu\'un'),
    Pratique('Se reconnecter', 'Loin des écrans'),
  ]),
  Pilier(emoji: '🌱', nom: 'Futur', couleur: Color(0xFF06B6D4), pratiques: [
    Pratique('Visualiser ses objectifs', 'Où je veux être'),
    Pratique('Apprendre une compétence', '15 minutes'),
    Pratique('Avancer sur un projet', 'Une petite étape'),
    Pratique('Épargner', 'Mettre de côté'),
  ]),
];
