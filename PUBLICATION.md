# 🚀 Aria — Checklist de publication Google Play

> Identifiant de l'app : `com.ibrahimadiallo.aria` (définitif, ne plus changer)
> Dernière mise à jour : 2 juillet 2026

## ⚠️ À savoir avant de réinstaller sur ton téléphone

Le changement d'identifiant fait qu'Android considère la nouvelle version comme
une **application différente**. L'ancienne « Aria » (com.example.aria) et ses
données resteront à part. **Avant** d'installer la nouvelle version :

1. Ouvre l'ancienne app → Réglages (⚙️) → **Exporter mes données** → Copier.
2. Colle le texte dans un fichier ou une note pour le garder.
3. Installe la nouvelle version → Réglages → **Importer des données** → Colle.
4. Désinstalle l'ancienne app.

---

## Étape A — Compte développeur (une seule fois)

- [ ] Créer un compte **Google Play Console** : https://play.google.com/console
      (25 $ US, paiement unique, carte bancaire requise)
- [ ] Vérification d'identité (pièce d'identité, quelques jours de délai)

## Étape B — Signature de l'application (une seule fois)

L'app doit être signée avec ta propre clé (actuellement elle utilise la clé de debug).

- [ ] Générer le keystore (dans un terminal) :
      ```
      keytool -genkey -v -keystore C:\dev\cles\aria-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias aria
      ```
- [ ] **Sauvegarder le fichier .jks et les mots de passe précieusement**
      (perdus = impossible de mettre à jour l'app, jamais)
- [ ] Créer `android/key.properties` (ne jamais le partager) :
      ```
      storePassword=TON_MOT_DE_PASSE
      keyPassword=TON_MOT_DE_PASSE
      keyAlias=aria
      storeFile=C:/dev/cles/aria-release.jks
      ```
- [ ] Ajouter `key.properties` au `.gitignore`
- [ ] Brancher la signature dans `android/app/build.gradle.kts`
      (demande-moi, je le fais en 2 minutes)

## Étape C — Contenu obligatoire du store

- [ ] **Politique de confidentialité** : page web publique obligatoire.
      Aria stocke tout en local → politique très simple. Je peux la rédiger
      et on peut l'héberger gratuitement (GitHub Pages).
- [ ] **Icône** 512×512 px (PNG, sans transparence)
- [ ] **Bannière** (feature graphic) 1024×500 px
- [ ] **Captures d'écran** : minimum 2, idéalement 4-8 (téléphone)
- [ ] **Titre** (30 car. max) : ex. « Aria — Équilibre & Habitudes »
- [ ] **Description courte** (80 car.) et **longue** (4000 car.)
      (je peux rédiger les deux)

## Étape D — Formulaires Play Console

- [ ] Classification du contenu (questionnaire) → « Tout public »
- [ ] Sécurité des données : déclarer « aucune donnée collectée »
      (tout est stocké localement sur l'appareil — c'est un argument de vente !)
- [ ] Public cible : 13 ans et +  (éviter le régime « enfants »)
- [ ] Pays de diffusion : au minimum Sénégal + France, ou monde entier

## Étape E — Compilation et envoi

- [ ] Vérifier la version dans `pubspec.yaml` (`version: 1.0.0+1`)
- [ ] Compiler le bundle : `flutter build appbundle --release`
      → fichier produit : `build\app\outputs\bundle\release\app-release.aab`
- [ ] Play Console → Créer une release → **Test interne** d'abord
- [ ] S'ajouter comme testeur, installer via le lien, tout vérifier
- [ ] Passer en **Production** quand tout est bon
- [ ] Première revue Google : 1 à 7 jours

## Étape F — Après la publication

- [ ] Répondre aux premiers avis
- [ ] À chaque mise à jour : incrémenter `version:` dans pubspec.yaml
      (ex. `1.0.1+2`) puis rebuild + nouvelle release
- [ ] Plus tard : crash reporting (Firebase Crashlytics) et statistiques

---

## Ce qui a déjà été fait ✅

- [x] Identifiant unique `com.ibrahimadiallo.aria` (Android, iOS, macOS, Linux, Windows)
- [x] Code restructuré en modules (main, i18n, theme, modeles, écrans…)
- [x] Description de l'app dans pubspec.yaml
- [x] Nom d'app « Aria », icône launcher, écran de démarrage
